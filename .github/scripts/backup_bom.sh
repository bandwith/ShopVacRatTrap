#!/bin/bash

# Create backup directory if it doesn't exist
mkdir -p pricing_backup

# Create today's backup with date stamp
cp BOM_CONSOLIDATED.csv pricing_backup/BOM_CONSOLIDATED_$(date +%Y%m%d).csv

# Keep only the 5 most recent backups and remove older ones
cd pricing_backup
ls -t BOM_CONSOLIDATED_*.csv | tail -n +6 | xargs -r rm
cd ..
