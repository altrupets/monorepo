#!/bin/bash
# Validate Mermaid diagrams in markdown files
# Checks for common syntax errors that break rendering

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "Validating Mermaid diagrams in markdown files..."

# Find all markdown files with mermaid blocks
MD_FILES=$(grep -rl '```mermaid' docs/content || true)

if [ -z "$MD_FILES" ]; then
	echo "No mermaid blocks found"
	exit 0
fi

for file in $MD_FILES; do
	echo "Checking: $file"

	# Extract mermaid blocks and check for issues
	awk '/```mermaid/,/```/' "$file" | while read -r line; do
		# Check for emojis in node names (common cause of errors)
		if echo "$line" | grep -qE '(^|\[)[^]]*(🛡|🏗|📱|💻|🔒|🚀|📦|⚙|💾|☁|🚪|🎨|👥|🔌|📋|🏛|❌|✅)'; then
			echo "  WARNING: Emoji found in node: $line"
			WARNINGS=$((WARNINGS + 1))
		fi

		# Check for pipes outside of table context
		if echo "$line" | grep -q '|'; then
			if ! echo "$line" | grep -qE '^\|.*\|$'; then
				if ! echo "$line" | grep -qE 'subgraph|end|style |linkStyle'; then
					echo "  WARNING: Pipe outside table context: $line"
					WARNINGS=$((WARNINGS + 1))
				fi
			fi
		fi
	done
done

echo ""
echo "Summary: $WARNINGS warnings"
echo "Note: These are potential issues, not blocking errors"

# Exit with warning status but don't block
if [ "$WARNINGS" -gt 0 ]; then
	exit 0
fi

exit 0
