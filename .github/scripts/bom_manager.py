import argparse
import json
import os
from pathlib import Path

from bom_updater import BOMUpdater
from bom_validator import BOMValidator
from bom_reporter import BOMReporter
from bom_purchase_file_generator import BOMPurchaseFileGenerator
from mouser_api import MouserAPIClient

# Load environment variables from .env file if it exists (for local development)
try:
    from dotenv import load_dotenv

    env_path = Path(__file__).parent.parent.parent / ".env"
    if env_path.exists():
        load_dotenv(env_path)
        print(f"🔧 Loaded environment variables from {env_path}")
except ImportError:
    # python-dotenv not available, continue with system environment variables
    pass


def _should_do_all(args: argparse.Namespace) -> bool:
    """Determines if all operations should be performed."""
    return args.all or not any(
        [
            args.validate,
            args.check_availability,
            args.update_pricing,
            args.generate_purchase_files,
            args.generate_mouser_template,
            args.generate_mouser_only,
        ]
    )


def main():
    parser = argparse.ArgumentParser(
        description="BOM Manager - consolidated tool for BOM management"
    )
    parser.add_argument("--bom-file", required=True, help="BOM file to process")
    parser.add_argument("--output-dir", default=".", help="Output directory")
    parser.add_argument(
        "--api-key", help="Mouser API key (or set MOUSER_API_KEY env var)"
    )
    parser.add_argument(
        "--priority-components", nargs="*", help="Priority component MPNs"
    )

    # Action flags
    parser.add_argument("--validate", action="store_true", help="Validate BOM pricing")
    parser.add_argument(
        "--check-availability", action="store_true", help="Check component availability"
    )
    parser.add_argument(
        "--update-pricing", action="store_true", help="Update BOM with current pricing"
    )
    parser.add_argument(
        "--generate-purchase-files",
        action="store_true",
        help="Generate purchase guide and files",
    )
    parser.add_argument(
        "--generate-mouser-template",
        action="store_true",
        help="Generate BOM in official Mouser template format",
    )
    parser.add_argument(
        "--generate-mouser-only", action="store_true", help="Generate Mouser-only BOM"
    )

    # If no action specified, do all
    parser.add_argument("--all", action="store_true", help="Perform all operations")

    args = parser.parse_args()

    do_all = _should_do_all(args)

    # Load priority components from config
    config_path = Path(__file__).parent / "config.json"
    with open(config_path) as f:
        config = json.load(f)
    priority_components = config.get("PRIORITY_COMPONENTS", [])
    if args.priority_components:
        priority_components.extend(args.priority_components)

    try:
        # Ensure output directory exists
        os.makedirs(args.output_dir, exist_ok=True)

        # Initialize clients and services
        client = MouserAPIClient(args.api_key)
        validator = BOMValidator(client)
        reporter = BOMReporter()
        updater = BOMUpdater()
        purchase_file_generator = BOMPurchaseFileGenerator(client)

        # Track results for later operations
        validation_results = None

        # Validate BOM
        if do_all or args.validate or args.check_availability:
            validation_results = validator.validate_bom(
                args.bom_file, args.priority_components
            )

            if "error" not in validation_results:
                output_file = os.path.join(args.output_dir, "validation_results.json")
                with open(output_file, "w") as f:
                    json.dump(validation_results, f, indent=2)
                print(f"💾 Validation results saved to {output_file}")

                reporter.generate_pricing_report(validation_results)
                reporter.generate_availability_report(validation_results)

                # Set GitHub Actions outputs if running in GH Actions
                if "GITHUB_OUTPUT" in os.environ:
                    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                        f.write(
                            f"changes_detected={validation_results['pricing_changes']['changes_detected']}\n"
                        )
                        f.write(
                            f"significant_changes={validation_results['pricing_changes']['significant_changes']}\n"
                        )

                        # Availability checks
                        if args.check_availability or do_all:
                            has_unavailable = (
                                validation_results["availability_issues"][
                                    "unavailable_components"
                                ]
                                > 0
                            )
                            f.write(
                                f"unavailable_components={'true' if has_unavailable else 'false'}\n"
                            )
            else:
                print(f"❌ Validation failed: {validation_results['error']}")
                return 1

        # Update BOM pricing if changes detected
        if (
            (do_all or args.update_pricing)
            and validation_results
            and validation_results["pricing_changes"]["changes_detected"]
        ):
            updater.update_bom_pricing(args.bom_file, validation_results)

        # Generate purchase files
        if (
            do_all
            or args.generate_purchase_files
            or args.generate_mouser_template
            or args.generate_mouser_only
        ):
            print("🛒 Generating comprehensive purchase files...")

            # Generate Mouser template (primary format)
            purchase_file_generator.generate_mouser_template_file(
                args.bom_file, args.output_dir
            )

            # Generate legacy Mouser-only BOM (for compatibility)
            purchase_file_generator.generate_mouser_only_bom(
                args.bom_file, args.output_dir
            )

            # Create unified purchase guide
            purchase_file_generator.generate_purchase_guide(
                args.bom_file, validation_results, args.output_dir
            )

            print(
                """
✅ Purchase files generated successfully!

📁 Generated Files:
   - BOM_MOUSER_TEMPLATE.xlsx (Official Mouser template - RECOMMENDED)
   - BOM_MOUSER_TEMPLATE.csv (CSV version for review)
   - BOM_MOUSER_ONLY.csv (Mouser-only consolidated BOM)
   - mouser_upload_consolidated_only.csv (Legacy simple upload format)
   - PURCHASE_GUIDE.md (Comprehensive purchase instructions)

🛒 Next Steps:
1. See COMPONENT_SOURCING.md for complete sourcing strategy
2. Upload BOM_MOUSER_TEMPLATE.xlsx to https://www.mouser.com/tools/bom-tool
3. Enjoy simplified single-distributor ordering!

💡 Benefits of integrated BOM manager:
   ✅ Real-time pricing via Mouser API
   ✅ Dynamic part lookup (no hardcoded mappings)
   ✅ Official Mouser template format
   ✅ Complete component data (availability, datasheets)
"""
            )

        print("✅ BOM management operations complete")
        return 0

    except Exception as e:
        print(f"❌ Fatal error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
