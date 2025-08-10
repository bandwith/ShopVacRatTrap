# Pricing Backup Folder

This folder stores historical backups of the BOM (Bill of Materials) pricing data. It is managed automatically by the GitHub Actions workflow.

## Purpose

- Maintain historical component pricing data
- Allow tracking of price trends over time
- Provide a safety net for reverting to previous pricing if needed
- Support cost analysis and budget planning

## Retention Policy

The system automatically:
- Creates a dated backup (YYYYMMDD format) before updating prices
- Keeps only the **5 most recent backups**
- Removes older backups to keep the repository size manageable

## File Naming Convention

Files follow the pattern:
```
BOM_CONSOLIDATED_YYYYMMDD.csv
```

Example: `BOM_CONSOLIDATED_20250810.csv`

## Automated Management

This folder is managed by the `.github/workflows/bom-validation.yml` workflow:
- Backups are created automatically during scheduled price updates
- Older backups are pruned automatically
- No manual maintenance is required

**Note:** If you need to restore pricing from a backup, copy the desired backup file to replace the current `BOM_CONSOLIDATED.csv` in the project root.
