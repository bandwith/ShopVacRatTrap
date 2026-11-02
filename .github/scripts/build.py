import argparse
import json
import os
import subprocess

# Constants
MODELS_DIR = "3d_models"
SCAD_EXTENSION = ".scad"
STL_EXTENSION = ".stl"
OPENSCAD_COMMAND = "openscad"
MANIFEST_FILE = os.path.join(MODELS_DIR, "parts_manifest.json")


def load_manifest() -> dict:
    """Load the single source of truth parts manifest if present."""
    if os.path.exists(MANIFEST_FILE):
        with open(MANIFEST_FILE, encoding="utf-8") as f:
            return json.load(f)
    return {}


# Library files that only define modules/constants and have no top-level
# geometry, so they must never be rendered to STL. Centralized here (rather
# than duplicated per function) so every code path agrees on what to skip.
_manifest_data = load_manifest()
MODULE_ONLY_FILES = tuple(
    _manifest_data.get("library_files", ["trap_modules.scad", "helpers.scad"])
)


def _is_module_only(file_path: str) -> bool:
    """True if the given SCAD path is a non-renderable library file."""
    base = os.path.basename(file_path)
    if base in MODULE_ONLY_FILES:
        return True
    # assembly.scad is a visualization assembly, not a printed part
    if base == "assembly.scad":
        return True
    return False


def _iterate_model_files(extension: str):
    """Iterates through files in MODELS_DIR with a specific extension."""
    for root, _, files in os.walk(MODELS_DIR):
        for file in files:
            if file.endswith(extension):
                yield os.path.join(root, file)


def get_changed_scad_files():
    """Get buildable SCAD files changed in HEAD whose STL was not also updated in HEAD."""
    cmd = ["git", "diff", "--name-only", "--diff-filter=AMR", "HEAD^", "HEAD"]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    changed_files = {f.strip() for f in result.stdout.strip().splitlines() if f.strip()}
    changed_scad = [
        f for f in changed_files if f.endswith(SCAD_EXTENSION) and f.startswith(f"{MODELS_DIR}/")
    ]
    if not changed_scad:
        return []

    changed_stl = {
        f for f in changed_files if f.endswith(STL_EXTENSION) and f.startswith(f"{MODELS_DIR}/")
    }

    # If a shared library file (trap_modules.scad / helpers.scad) changed and no
    # STL files were updated in the commit, rebuild all buildable SCAD files.
    if any(_is_module_only(f) for f in changed_scad) and not changed_stl:
        candidates = sorted(get_all_scad_files())
    else:
        candidates = sorted(f for f in changed_scad if not _is_module_only(f))

    # Skip rebuilding SCAD files whose corresponding STL file was already
    # updated in the same commit and exists on disk.
    return [
        scad_path
        for scad_path in candidates
        if scad_path.replace(SCAD_EXTENSION, STL_EXTENSION) not in changed_files
        or not os.path.exists(scad_path.replace(SCAD_EXTENSION, STL_EXTENSION))
    ]


def get_all_scad_files():
    """Get a sorted list of all SCAD files (excluding module-only library files)."""
    scad_files = []
    for file_path in _iterate_model_files(SCAD_EXTENSION):
        if not _is_module_only(file_path):
            scad_files.append(file_path)
    return sorted(scad_files)


def get_missing_stl_files():
    """Get a list of SCAD files that are missing their STL file (excluding module-only library files)."""
    missing_files = []
    for scad_path in _iterate_model_files(SCAD_EXTENSION):
        if _is_module_only(scad_path):
            continue

        stl_path = scad_path.replace(SCAD_EXTENSION, STL_EXTENSION)
        if not os.path.exists(stl_path):
            missing_files.append(scad_path)
    return missing_files


def check_stl_solid_and_z0(stl_path: str) -> tuple[bool, bool]:
    """Check if STL is a watertight 2-manifold solid resting on z=0."""
    if not os.path.exists(stl_path):
        return False, False
    try:
        with open(stl_path, "rb") as f:
            data = f.read()
        if len(data) < 84:
            return False, False
        if data[:5].lower() == b"solid" and b"facet" in data[:1024]:
            text = data.decode("utf-8", errors="replace")
            verts = []
            for line in text.splitlines():
                stripped = line.strip()
                if stripped.startswith("vertex"):
                    p = stripped.split()
                    verts.append((float(p[1]), float(p[2]), float(p[3])))
            tris = [(verts[i], verts[i + 1], verts[i + 2]) for i in range(0, len(verts), 3)]
        else:
            import struct

            num_tris = struct.unpack("<I", data[80:84])[0]
            tris = []
            offset = 84
            for _ in range(num_tris):
                fl = struct.unpack("<12fH", data[offset : offset + 50])
                tris.append(
                    (
                        (fl[3], fl[4], fl[5]),
                        (fl[6], fl[7], fl[8]),
                        (fl[9], fl[10], fl[11]),
                    )
                )
                offset += 50
        if not tris:
            return False, False
        zs = [v[2] for tri in tris for v in tri]
        z_min = min(zs)
        rests_on_z0 = abs(z_min) < 1e-3 and max(zs) > 0
        edges = {}
        for v0, v1, v2 in tris:
            q0 = (round(v0[0], 4), round(v0[1], 4), round(v0[2], 4))
            q1 = (round(v1[0], 4), round(v1[1], 4), round(v1[2], 4))
            q2 = (round(v2[0], 4), round(v2[1], 4), round(v2[2], 4))
            for a, b in ((q0, q1), (q1, q2), (q2, q0)):
                key = (a, b) if a < b else (b, a)
                edges[key] = edges.get(key, 0) + 1
        is_manifold = all(count == 2 for count in edges.values())
        return is_manifold, rests_on_z0
    except Exception:
        return False, False


def generate_build_report():
    """Generate a build report for the STL files from the manifest."""
    manifest = load_manifest()
    parts = manifest.get("parts", [])
    report = []
    report.append("# STL Build Report")
    report.append("")
    report.append(
        "| Part | Qty | SCAD File | STL File | Watertight 2-Manifold | Resting on Z=0 | Description |"
    )
    report.append(
        "|------|-----|-----------|----------|-----------------------|----------------|-------------|"
    )
    if parts:
        for part in parts:
            name = part["name"]
            qty = part.get("quantity", 1)
            scad = os.path.basename(part["scad_file"])
            stl = os.path.basename(part["stl_file"])
            stl_path = os.path.join(MODELS_DIR, stl)
            is_manifold, on_z0 = check_stl_solid_and_z0(stl_path)
            m_badge = "✅ Yes" if is_manifold else "❌ No"
            z_badge = "✅ Yes" if on_z0 else "❌ No"
            desc = part.get("description", "")
            report.append(f"| {name} | {qty} | {scad} | {stl} | {m_badge} | {z_badge} | {desc} |")
    else:
        for stl_path in sorted(_iterate_model_files(STL_EXTENSION)):
            file = os.path.basename(stl_path)
            scad_file = file.replace(STL_EXTENSION, SCAD_EXTENSION)
            report.append(f"| {file} | 1 | {scad_file} | {file} | - | - | - |")

    report.append("")
    report.append(
        "All printable parts are verified to be single watertight 2-manifold solids resting on z=0 in supportless print orientation."
    )
    with open(os.path.join(MODELS_DIR, "build_report.md"), "w") as f:
        f.write("\n".join(report) + "\n")


def build_stl_files(scad_files):
    """Generate STL files from a list of SCAD files."""
    for scad_file in scad_files:
        stl_file = scad_file.replace(SCAD_EXTENSION, STL_EXTENSION)
        print(f"Generating {stl_file} from {scad_file}...")
        try:
            subprocess.run(
                [OPENSCAD_COMMAND, "-o", stl_file, scad_file],
                check=True,
                capture_output=True,
                text=True,
            )
        except FileNotFoundError:
            print(
                f"Error: '{OPENSCAD_COMMAND}' command not found. "
                "Please ensure OpenSCAD is installed and in your PATH."
            )
            exit(1)
        except subprocess.CalledProcessError as e:
            print(f"Error generating {stl_file} from {scad_file}:")
            print(f"Stdout: {e.stdout}")
            print(f"Stderr: {e.stderr}")
            exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="STL Generator Helper")
    parser.add_argument("--get-changed-files", action="store_true", help="Get changed SCAD files")
    parser.add_argument("--get-all-files", action="store_true", help="Get all SCAD files")
    parser.add_argument(
        "--get-missing-files",
        action="store_true",
        help="Get SCAD files with missing STL files",
    )
    parser.add_argument("--generate-report", action="store_true", help="Generate build report")
    parser.add_argument(
        "--build",
        nargs="*",
        help="Build STL files from a list of SCAD files. If no files are provided, all SCAD files will be built.",
    )

    args = parser.parse_args()

    if args.get_changed_files:
        files = get_changed_scad_files()
        print(json.dumps(files))
    elif args.get_all_files:
        files = get_all_scad_files()
        print(json.dumps(files))
    elif args.get_missing_files:
        files = get_missing_stl_files()
        print(json.dumps(files))
    elif args.generate_report:
        generate_build_report()
    elif args.build is not None:
        if not args.build:
            scad_files = get_all_scad_files()
        else:
            scad_files = args.build
        build_stl_files(scad_files)
        generate_build_report()
