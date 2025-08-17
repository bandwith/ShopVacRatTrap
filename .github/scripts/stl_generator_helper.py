import os
import subprocess
import json


def get_changed_scad_files():
    """Get a list of changed SCAD files."""
    cmd = "git diff --name-only --diff-filter=d HEAD^ HEAD"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    changed_files = result.stdout.strip().split("\n")
    scad_files = [
        f for f in changed_files if f.endswith(".scad") and f.startswith("3D Models/")
    ]
    return scad_files


def get_all_scad_files():
    """Get a list of all SCAD files."""
    scad_files = []
    for root, _, files in os.walk("3D Models"):
        for file in files:
            if file.endswith(".scad"):
                scad_files.append(os.path.join(root, file))
    return scad_files


def get_missing_stl_files():
    """Get a list of SCAD files that are missing their STL file."""
    missing_files = []
    for root, _, files in os.walk("3D Models"):
        for file in files:
            if file.endswith(".scad"):
                scad_path = os.path.join(root, file)
                stl_path = scad_path.replace(".scad", ".stl")
                if not os.path.exists(stl_path):
                    missing_files.append(scad_path)
    return missing_files


def generate_build_report():
    """Generate a build report for the STL files."""
    report = []
    report.append("# STL Build Report")
    report.append("| SCAD File | STL File |")
    report.append("|-----------|----------|")
    for root, _, files in os.walk("3D Models"):
        for file in files:
            if file.endswith(".stl"):
                scad_file = file.replace(".stl", ".scad")
                report.append(f"| {scad_file} | {file} |")
    with open("3D Models/build_report.md", "w") as f:
        f.write("\n".join(report))


if __name__ == "__main__":
    import argparse

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
