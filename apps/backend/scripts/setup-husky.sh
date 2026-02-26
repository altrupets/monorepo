#!/bin/bash
# Husky pre-commit hooks setup script
# Run this script to initialize husky hooks

set -e

echo "🚀 Setting up Husky pre-commit hooks..."

# Initialize husky
npx husky install

# Create pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"

echo "✅ Husky hooks configured!"
echo ""
echo "🎉 Setup complete!"
