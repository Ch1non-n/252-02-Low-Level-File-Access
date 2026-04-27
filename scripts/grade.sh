#!/usr/bin/env bash
set -euo pipefail

bash "$(cd "$(dirname "$0")" && pwd)/autograde.sh"
echo "grade hook: visible checks passed"
