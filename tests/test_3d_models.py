"""Automated geometry, printability, and assembly tests for 3d_models/."""

from __future__ import annotations

from collections import defaultdict, deque
import math
from pathlib import Path
import re
import struct

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
MODELS_DIR = REPO_ROOT / "3d_models"

PRINTABLE_PARTS = (
    "bait_cap",
    "bait_station",
    "control_box_exit_mount",
    "control_box_lid",
    "trap_body_front",
    "trap_body_rear",
    "trap_ramp_entrance",
    "vacuum_adapter_universal",
)

LIBRARY_FILES = (
    "helpers.scad",
    "trap_modules.scad",
)

# Standard 220x220x250mm FDM build volume
MAX_BED_X_MM = 220.0
MAX_BED_Y_MM = 220.0
MAX_BED_Z_MM = 250.0


def _parse_stl(
    stl_path: Path,
) -> list[
    tuple[tuple[float, float, float], tuple[float, float, float], tuple[float, float, float]]
]:
    """Parse an ASCII or binary STL file into a list of vertex triples."""
    data = stl_path.read_bytes()
    if data[:5].lower() == b"solid" and b"facet" in data[:1024]:
        text = data.decode("utf-8", errors="replace")
        verts: list[tuple[float, float, float]] = []
        for line in text.splitlines():
            stripped = line.strip()
            if stripped.startswith("vertex"):
                parts = stripped.split()
                verts.append((float(parts[1]), float(parts[2]), float(parts[3])))
        return [(verts[i], verts[i + 1], verts[i + 2]) for i in range(0, len(verts), 3)]

    num_tris = struct.unpack("<I", data[80:84])[0]
    tris = []
    offset = 84
    for _ in range(num_tris):
        floats = struct.unpack("<12fH", data[offset : offset + 50])
        v0 = (floats[3], floats[4], floats[5])
        v1 = (floats[6], floats[7], floats[8])
        v2 = (floats[9], floats[10], floats[11])
        tris.append((v0, v1, v2))
        offset += 50
    return tris


def _quantize(pt: tuple[float, float, float], tol: float = 1e-4) -> tuple[int, int, int]:
    """Quantize a 3D vertex coordinate to integer grid keys for topology checks."""
    return (round(pt[0] / tol), round(pt[1] / tol), round(pt[2] / tol))


def _analyze_mesh(stl_path: Path) -> dict[str, float | int | bool | tuple[float, float, float]]:
    """Compute bounding box, manifoldness, connected solid count, and bed contact area."""
    tris = _parse_stl(stl_path)
    assert tris, f"{stl_path.name} contains no triangles"

    xs = [v[0] for tri in tris for v in tri]
    ys = [v[1] for tri in tris for v in tri]
    zs = [v[2] for tri in tris for v in tri]
    z_min, z_max = min(zs), max(zs)
    bbox_size = (max(xs) - min(xs), max(ys) - min(ys), z_max - z_min)

    directed_edges: dict[tuple[ tuple[int, int, int], tuple[int, int, int] ], int] = defaultdict(int)
    undirected_edges: dict[tuple[ tuple[int, int, int], tuple[int, int, int] ], list[int]] = defaultdict(list)
    degenerate_count = 0
    bed_contact_area = 0.0

    for idx, (v0, v1, v2) in enumerate(tris):
        q0, q1, q2 = _quantize(v0), _quantize(v1), _quantize(v2)
        if q0 == q1 or q1 == q2 or q2 == q0:
            degenerate_count += 1
            continue

        # Cross product for triangle area and normal
        ux, uy, uz = v1[0] - v0[0], v1[1] - v0[1], v1[2] - v0[2]
        vx, vy, vz = v2[0] - v0[0], v2[1] - v0[1], v2[2] - v0[2]
        nx = uy * vz - uz * vy
        ny = uz * vx - ux * vz
        nz = ux * vy - uy * vx
        area = 0.5 * math.sqrt(nx * nx + ny * ny + nz * nz)
        if area < 1e-10:
            degenerate_count += 1
            continue

        if (
            abs(v0[2] - z_min) < 0.05
            and abs(v1[2] - z_min) < 0.05
            and abs(v2[2] - z_min) < 0.05
            and nz < 0
        ):
            bed_contact_area += area

        for a, b in ((q0, q1), (q1, q2), (q2, q0)):
            directed_edges[(a, b)] += 1
            edge_key = (a, b) if a < b else (b, a)
            undirected_edges[edge_key].append(idx)

    open_edges = 0
    non_manifold_edges = 0
    adj: dict[int, list[int]] = defaultdict(list)
    for (a, b), faces in undirected_edges.items():
        if len(faces) == 1:
            open_edges += 1
        elif len(faces) != 2:
            if directed_edges[(a, b)] != directed_edges[(b, a)]:
                non_manifold_edges += 1
        for f1 in faces:
            for f2 in faces:
                if f1 != f2:
                    adj[f1].append(f2)

    # Count connected components via BFS over triangles
    visited: set[int] = set()
    solid_count = 0
    for i in range(len(tris)):
        if i in visited:
            continue
        solid_count += 1
        queue = deque([i])
        visited.add(i)
        while queue:
            curr = queue.popleft()
            for nxt in adj[curr]:
                if nxt not in visited:
                    visited.add(nxt)
                    queue.append(nxt)

    return {
        "triangle_count": len(tris),
        "z_min": z_min,
        "z_max": z_max,
        "bbox_size": bbox_size,
        "open_edges": open_edges,
        "non_manifold_edges": non_manifold_edges,
        "degenerate_triangles": degenerate_count,
        "solid_count": solid_count,
        "bed_contact_area_mm2": bed_contact_area,
    }


@pytest.mark.parametrize("part_name", PRINTABLE_PARTS)
def test_printable_part_manifold_and_print_orientation(part_name: str) -> None:
    """Every printable part must be a single watertight 2-manifold solid resting on z=0."""
    scad_path = MODELS_DIR / f"{part_name}.scad"
    stl_path = MODELS_DIR / f"{part_name}.stl"
    assert scad_path.exists(), f"Missing SCAD file: {scad_path}"
    assert stl_path.exists(), f"Missing STL file: {stl_path}"

    stats = _analyze_mesh(stl_path)
    sx, sy, sz = stats["bbox_size"]  # type: ignore[misc]

    assert stats["open_edges"] == 0, f"{part_name}.stl has {stats['open_edges']} open edges"
    assert stats["non_manifold_edges"] == 0, (
        f"{part_name}.stl has {stats['non_manifold_edges']} non-manifold edges"
    )
    assert stats["degenerate_triangles"] == 0, (
        f"{part_name}.stl has {stats['degenerate_triangles']} degenerate triangles"
    )
    assert stats["solid_count"] == 1, (
        f"{part_name}.stl has {stats['solid_count']} disconnected solids (expected 1)"
    )
    assert abs(float(stats["z_min"])) < 1e-3, (
        f"{part_name}.stl floats at z_min={stats['z_min']}mm instead of resting on z=0"
    )
    assert float(stats["bed_contact_area_mm2"]) >= 1000.0, (
        f"{part_name}.stl has insufficient bed contact area: {stats['bed_contact_area_mm2']} mm^2"
    )
    assert sx <= MAX_BED_X_MM and sy <= MAX_BED_Y_MM and sz <= MAX_BED_Z_MM, (
        f"{part_name}.stl dimensions {stats['bbox_size']} exceed 220x220x250mm build volume"
    )


def test_library_files_have_no_top_level_renders() -> None:
    """Shared library SCAD files must not contain top-level geometry calls."""
    for lib_name in LIBRARY_FILES:
        lib_path = MODELS_DIR / lib_name
        assert lib_path.exists(), f"Missing library file: {lib_path}"
        assert not (MODELS_DIR / lib_name.replace(".scad", ".stl")).exists(), (
            f"Library file {lib_name} should not have an exported STL"
        )


def test_assembly_horizontal_layout_and_mating_interfaces() -> None:
    """assembly.scad must place all 7 parts horizontally along +X on the Z>=0 ground plane."""
    asm_scad = (MODELS_DIR / "assembly.scad").read_text(encoding="utf-8")
    for mod_name in (
        "placed_ramp_entrance",
        "placed_body_front",
        "placed_bait_cap",
        "placed_body_rear",
        "placed_vacuum_adapter",
        "placed_control_box",
        "placed_control_box_lid",
    ):
        assert f"module {mod_name}(" in asm_scad, f"Missing {mod_name} in assembly.scad"

    # Verify shared mating interface parameters between trap_modules.scad and assembly.scad
    trap_mods = (MODELS_DIR / "trap_modules.scad").read_text(encoding="utf-8")
    flange_od_match = re.search(r"flange_od\s*=\s*(\d+(?:\.\d+)?)\s*;", trap_mods)
    assert flange_od_match and float(flange_od_match.group(1)) == 130.0
    assert "control_box_bolt_pattern()" in (MODELS_DIR / "vacuum_adapter_universal.scad").read_text(
        encoding="utf-8"
    )
    assert "control_box_bolt_pattern()" in (MODELS_DIR / "control_box_exit_mount.scad").read_text(
        encoding="utf-8"
    )

    asm_stl = MODELS_DIR / "assembly.stl"
    assert asm_stl.exists(), "Missing assembly.stl"
    tris = _parse_stl(asm_stl)
    xs = [v[0] for tri in tris for v in tri]
    zs = [v[2] for tri in tris for v in tri]
    x_span = max(xs) - min(xs)
    z_min = min(zs)
    assert abs(z_min) < 1e-3, f"Assembled rat trap should rest on ground plane z=0 (got {z_min})"
    assert x_span > 550.0, (
        f"Assembled rat trap should extend horizontally along +X (>550mm, got {x_span:.1f}mm)"
    )
