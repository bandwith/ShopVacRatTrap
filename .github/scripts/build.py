import os
import subprocess
import json
import argparse

# Constants
MODELS_DIR = "3d_models"
SCAD_EXTENSION = ".scad"
STL_EXTENSION = ".stl"
OPENSCAD_COMMAND = "openscad"


def _iterate_model_files(extension: str):
    """Iterates through files in MODELS_DIR with a specific extension."""
    for root, _, files in os.walk(MODELS_DIR):
        for file in files:
            if file.endswith(extension):
                yield os.path.join(root, file)


def get_changed_scad_files():
    """Get a list of changed SCAD files."""
    cmd = "git diff --name-only --diff-filter=AMR HEAD^ HEAD"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    changed_files = result.stdout.strip().split("\n")
    scad_files = [
        f
        for f in changed_files
        if f.endswith(SCAD_EXTENSION) and f.startswith(f"{MODELS_DIR}/")
    ]
    return scad_files


def get_all_scad_files():
    """Get a list of all SCAD files (excluding module-only library files)."""
    # Files that only contain module definitions and shouldn't be rendered
    module_only_files = ["trap_modules.scad"]

    scad_files = []
    for file_path in _iterate_model_files(SCAD_EXTENSION):
        # Skip module-only library files
        if os.path.basename(file_path) not in module_only_files:
            scad_files.append(file_path)
    return scad_files


def get_missing_stl_files():
    """Get a list of SCAD files that are missing their STL file (excluding module-only library files)."""
    # Files that only contain module definitions and shouldn't be rendered
    module_only_files = ["trap_modules.scad"]

    missing_files = []
    for scad_path in _iterate_model_files(SCAD_EXTENSION):
        # Skip module-only library files
        if os.path.basename(scad_path) in module_only_files:
            continue

        stl_path = scad_path.replace(SCAD_EXTENSION, STL_EXTENSION)
        if not os.path.exists(stl_path):
            missing_files.append(scad_path)
    return missing_files


def generate_build_report():
    """Generate a build report for the STL files."""
    report = []
    report.append("# STL Build Report")
    report.append("| SCAD File | STL File |")
    report.append("|-----------|----------|")
    for stl_path in _iterate_model_files(STL_EXTENSION):
        file = os.path.basename(stl_path)
        scad_file = file.replace(STL_EXTENSION, SCAD_EXTENSION)
        report.append(f"| {scad_file} | {file} |")
    with open(os.path.join(MODELS_DIR, "build_report.md"), "w") as f:
        f.write("\n".join(report))


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
    parser.add_argument(
        "--get-changed-files", action="store_true", help="Get changed SCAD files"
    )
    parser.add_argument(
        "--get-all-files", action="store_true", help="Get all SCAD files"
    )
    parser.add_argument(
        "--get-missing-files",
        action="store_true",
        help="Get SCAD files with missing STL files",
    )
    parser.add_argument(
        "--generate-report", action="store_true", help="Generate build report"
    )
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
