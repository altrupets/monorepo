#!/bin/bash
# Validate Mermaid diagrams in markdown files
# Used as pre-commit hook to prevent broken diagrams

set -euo pipefail

WARNINGS=0

echo "Validating Mermaid diagrams..."

# Find markdown files with mermaid blocks
MD_FILES=$(grep -rl '```mermaid' docs/content 2>/dev/null || true)

if [ -z "$MD_FILES" ]; then
    echo "No mermaid blocks found"
    exit 0
fi

for file in $MD_FILES; do
    # Check for emojis in mermaid blocks
    if awk '/```mermaid/,/```/' "$file" 2>/dev/null | grep -qE '[\U{1F300}-\U{1F9FF}]|🛡|🏗|📱|💻|🔒|🚀|📦|⚙|💾|☁|🚪|🎨|👥|🔌|📋|🏛|❌|✅'; then
        echo "WARNING: Emoji found in $file - may cause render errors"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check for pipes outside table context
    if awk '/```mermaid/,/```/' "$file" 2>/dev/null | grep -q '|' ; then
        if ! awk '/```mermaid/,/```/' "$file" 2>/dev/null | grep -qE '^\|.*\|$' ; then
            if awk '/```mermaid/,/```/' "$file" 2>/dev/null | grep -qE '\|' ; then
                echo "WARNING: Unescaped pipe in $file - may break mermaid"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    fi
done

if [ "$WARNINGS" -gt 0 ]; then
    echo "Found $WARNINGS potential issues"
    echo "Note: These are warnings, not blocking errors"
fi

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
