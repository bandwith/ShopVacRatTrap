"""Automated geometry, printability, and assembly tests for 3d_models/."""

from __future__ import annotations

import math
import re
import struct
from collections import defaultdict, deque
from pathlib import Path

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
    tuple[
        tuple[float, float, float],
        tuple[float, float, float],
        tuple[float, float, float],
    ]
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


def _analyze_mesh(
    stl_path: Path,
) -> dict[str, float | int | bool | tuple[float, float, float]]:
    """Compute bounding box, manifoldness, connected solid count, and bed contact area."""
    tris = _parse_stl(stl_path)
    assert tris, f"{stl_path.name} contains no triangles"

    xs = [v[0] for tri in tris for v in tri]
    ys = [v[1] for tri in tris for v in tri]
    zs = [v[2] for tri in tris for v in tri]
    z_min, z_max = min(zs), max(zs)
    bbox_size = (max(xs) - min(xs), max(ys) - min(ys), z_max - z_min)

    directed_edges: dict[tuple[tuple[int, int, int], tuple[int, int, int]], int] = defaultdict(int)
    undirected_edges: dict[tuple[tuple[int, int, int], tuple[int, int, int]], list[int]] = (
        defaultdict(list)
    )
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


def _transform_point(
    pt: tuple[float, float, float],
    rx_deg: float = 0.0,
    ry_deg: float = 0.0,
    rz_deg: float = 0.0,
    tx: float = 0.0,
    ty: float = 0.0,
    tz: float = 0.0,
) -> tuple[float, float, float]:
    """Apply OpenSCAD's rotate([rx, ry, rz]) followed by translate([tx, ty, tz])."""
    x, y, z = pt
    if rx_deg:
        r = math.radians(rx_deg)
        y, z = y * math.cos(r) - z * math.sin(r), y * math.sin(r) + z * math.cos(r)
    if ry_deg:
        r = math.radians(ry_deg)
        x, z = x * math.cos(r) + z * math.sin(r), -x * math.sin(r) + z * math.cos(r)
    if rz_deg:
        r = math.radians(rz_deg)
        x, y = x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r)
    return (x + tx, y + ty, z + tz)


def _transformed_bbox(
    stl_name: str,
    transform_fn,
) -> tuple[tuple[float, float, float], tuple[float, float, float]]:
    """Compute world-space (min_xyz, max_xyz) of a printable STL under a rigid transform."""
    tris = _parse_stl(MODELS_DIR / f"{stl_name}.stl")
    pts = [transform_fn(v) for tri in tris for v in tri]
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    zs = [p[2] for p in pts]
    return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


def test_assembly_horizontal_layout_and_mating_interfaces() -> None:
    """All 8 printable STL files must assemble into the horizontal rat trap on Z=0."""
    asm_scad = (MODELS_DIR / "assembly.scad").read_text(encoding="utf-8")
    for mod_name in (
        "placed_ramp_entrance",
        "placed_body_front",
        "placed_bait_station",
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

    # Transform all 8 printable STL files directly from their build-plate orientation (z>=0)
    # into the assembly coordinate frame and verify flush mating & Z=0 ground contact.
    def tube_place(x_off: float):
        return lambda p: _transform_point(p, rx_deg=90, rz_deg=90, tx=x_off, tz=65.0)

    ramp_min, ramp_max = _transformed_bbox("trap_ramp_entrance", tube_place(0.0))
    front_min, front_max = _transformed_bbox("trap_body_front", tube_place(155.0))
    bait_min, bait_max = _transformed_bbox("bait_station", tube_place(300.0))
    rear_min, rear_max = _transformed_bbox("trap_body_rear", tube_place(400.0))
    adap_min, adap_max = _transformed_bbox("vacuum_adapter_universal", tube_place(545.0))

    box_min, box_max = _transformed_bbox(
        "control_box_exit_mount",
        lambda p: _transform_point(
            (p[0] - 64.0, p[1], p[2]), rz_deg=180, tx=585.0, ty=-65.0, tz=0.0
        ),
    )
    lid_min, lid_max = _transformed_bbox(
        "control_box_lid",
        lambda p: _transform_point(
            _transform_point(p, rx_deg=180, tx=-64.0, ty=108.0),
            rz_deg=180,
            tx=585.0,
            ty=-65.0,
            tz=73.0,
        ),
    )
    cap_min, cap_max = _transformed_bbox(
        "bait_cap",
        lambda p: _transform_point(
            _transform_point(p, rz_deg=66.0),
            rx_deg=90.0,
            tx=355.0,
            ty=71.2,
            tz=65.0,
        ),
    )

    # 1. All 5 tube sections + upright control box rest flat on the Z=0 ground plane
    for name, bmin in (
        ("trap_ramp_entrance", ramp_min),
        ("trap_body_front", front_min),
        ("bait_station", bait_min),
        ("trap_body_rear", rear_min),
        ("vacuum_adapter_universal", adap_min),
        ("control_box_exit_mount", box_min),
    ):
        assert abs(bmin[2]) < 1e-2, f"{name} in assembly does not rest on Z=0 (z_min={bmin[2]})"

    # 2. Each tube section's male lip (9.5mm = lip_length - 0.5mm clearance) seats inside
    #    the next section's 10mm female socket while flanges clamp flush at 155/300/400/545mm.
    assert abs(ramp_max[0] - (155.0 + 9.5)) < 0.2 and abs(front_min[0] - 155.0) < 0.2
    assert abs(front_max[0] - (300.0 + 9.5)) < 0.2 and abs(bait_min[0] - 300.0) < 0.2
    assert abs(bait_max[0] - (400.0 + 9.5)) < 0.2 and abs(rear_min[0] - 400.0) < 0.2
    assert abs(rear_max[0] - (545.0 + 9.5)) < 0.2 and abs(adap_min[0] - 545.0) < 0.2

    # 3. Upright control box mates flush with vacuum adapter bracket at Y = -65.0mm
    #    and control box lid seats into top of control box at Z = 66..73mm
    assert abs(adap_min[1] - (-65.0)) < 0.2 and abs(box_max[1] - (-65.0)) < 0.2
    assert abs(box_max[2] - 69.0) < 0.2
    assert abs(lid_min[2] - 66.0) < 0.2 and abs(lid_max[2] - 73.0) < 0.2

    # 4. Bait cap engages bait_station's side bayonet port at X=355mm, Z=65mm
    assert abs(0.5 * (cap_min[0] + cap_max[0]) - 355.0) < 1.0
    assert abs(0.5 * (cap_min[2] + cap_max[2]) - 65.0) < 1.0
    assert cap_min[1] < bait_max[1] < cap_max[1]

    asm_stl = MODELS_DIR / "assembly.stl"
    assert asm_stl.exists(), "Missing assembly.stl"
    tris = _parse_stl(asm_stl)
    xs = [v[0] for tri in tris for v in tri]
    zs = [v[2] for tri in tris for v in tri]
    x_span = max(xs) - min(xs)
    z_min = min(zs)
    assert abs(z_min) < 1e-3, f"Assembled rat trap should rest on ground plane z=0 (got {z_min})"
    assert x_span > 650.0, (
        f"Assembled 8-part rat trap should extend horizontally along +X (>650mm, got {x_span:.1f}mm)"
    )


def test_build_script_skips_already_updated_stls(monkeypatch: pytest.MonkeyPatch) -> None:
    """build.get_changed_scad_files must skip SCADs whose STL was updated in the same commit."""
    import sys

    scripts_dir = str(REPO_ROOT / ".github" / "scripts")
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)
    import build as build_script  # type: ignore[import-not-found]

    class DummyResult:
        def __init__(self, stdout: str) -> None:
            self.stdout = stdout

    # 1. Both SCAD and STL updated in same commit -> nothing to rebuild
    monkeypatch.setattr(
        build_script.subprocess,
        "run",
        lambda *a, **kw: DummyResult("3d_models/bait_cap.scad\n3d_models/bait_cap.stl\n"),
    )
    assert build_script.get_changed_scad_files() == []

    # 2. Only SCAD updated -> returns that SCAD
    monkeypatch.setattr(
        build_script.subprocess,
        "run",
        lambda *a, **kw: DummyResult("3d_models/bait_cap.scad\n"),
    )
    assert build_script.get_changed_scad_files() == ["3d_models/bait_cap.scad"]

    # 3. Shared library updated without STLs -> returns all buildable SCADs
    monkeypatch.setattr(
        build_script.subprocess,
        "run",
        lambda *a, **kw: DummyResult("3d_models/trap_modules.scad\n"),
    )
    changed = build_script.get_changed_scad_files()
    assert "3d_models/bait_cap.scad" in changed
    assert "3d_models/trap_modules.scad" not in changed

    # 4. Shared library updated alongside updated STLs -> skips unaffected SCADs
    monkeypatch.setattr(
        build_script.subprocess,
        "run",
        lambda *a, **kw: DummyResult(
            "3d_models/trap_modules.scad\n3d_models/bait_cap.scad\n3d_models/bait_cap.stl\n"
        ),
    )
    assert build_script.get_changed_scad_files() == []


def test_component_allowances_and_rodent_resistance() -> None:
    """Verify electronic component variation allowances, tool-free access, and rodent resistance."""
    trap_mods = (MODELS_DIR / "trap_modules.scad").read_text(encoding="utf-8")
    ctrl_box = (MODELS_DIR / "control_box_exit_mount.scad").read_text(encoding="utf-8")

    def get_num(text: str, name: str) -> float:
        match = re.search(rf"\b{name}\s*=\s*(\d+(?:\.\d+)?)\s*;", text)
        assert match, f"Parameter {name} not found"
        return float(match.group(1))

    # 1. FDM variation tolerance & component mounting allowances
    tol = get_num(trap_mods, "print_tolerance")
    assert 0.2 <= tol <= 0.4, f"Expected print_tolerance in 0.2..0.4mm, got {tol}"

    assert get_num(trap_mods, "stemma_qt_board_width") == 17.78
    assert get_num(trap_mods, "stemma_qt_board_length") == 25.4
    assert 2.65 <= get_num(trap_mods, "stemma_qt_hole_diameter") <= 2.85  # M2.5 clearance

    assert get_num(trap_mods, "esp32_board_width") == 22.9
    assert get_num(trap_mods, "esp32_board_length") == 50.8
    assert get_num(trap_mods, "esp32_hole_spacing_x") == 20.32
    assert get_num(trap_mods, "esp32_hole_spacing_y") == 48.26
    assert 2.65 <= get_num(trap_mods, "esp32_hole_diameter") <= 2.85

    assert get_num(trap_mods, "pir_dome_clearance") >= get_num(trap_mods, "pir_dome_diameter") + 1.5
    assert get_num(trap_mods, "camera_lens_clearance") >= 14.0
    assert get_num(trap_mods, "cable_channel_id") >= 8.0  # Clears ~6mm JST-SH connectors

    # 2. Rodent-resistance structural wall & spigot invariants
    wall_t = get_num(trap_mods, "wall_thickness")
    flange_t = get_num(trap_mods, "flange_thickness")
    box_wall = get_num(ctrl_box, "box_wall")
    lip_len = get_num(trap_mods, "lip_length")
    assert wall_t >= 3.0, f"Tube wall ({wall_t}mm) must be >= 3.0mm for rodent resistance"
    assert flange_t >= 5.0, f"Flange thickness ({flange_t}mm) must be >= 5.0mm"
    assert box_wall >= 4.0, f"Control box wall ({box_wall}mm) must be >= 4.0mm"
    assert lip_len >= 10.0, f"Telescoping spigot ({lip_len}mm) must shield internal joint seam"

    # 3. Tool-free servicing: bayonet twist-lock & thumbscrew/wing-nut flange clearance
    assert get_num(trap_mods, "bayonet_tab_count") >= 3
    assert get_num(trap_mods, "bayonet_rotation") >= 25
    flange_od = get_num(trap_mods, "flange_od")
    tube_od = get_num(trap_mods, "tube_od")
    bolt_inset = get_num(trap_mods, "bolt_hole_inset")
    bolt_radius = flange_od / 2.0 - bolt_inset
    radial_finger_clearance = bolt_radius - tube_od / 2.0
    assert radial_finger_clearance >= 7.5, (
        f"Insufficient radial clearance ({radial_finger_clearance:.2f}mm) for M4 wing nuts/thumbscrews"
    )
    assert "module sensor_mounting_plate()" in ctrl_box
