#!/bin/bash

# Script to set up Xcode project for FamilyNova Parent App

PROJECT_DIR="/Users/deminimmo/Mobile Projects/familynova/apps/ios-parent"
cd "$PROJECT_DIR"

echo "🔧 Setting up Xcode project for FamilyNova Parent..."
echo ""

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "📦 xcodegen not found. Installing via Homebrew..."
    echo "   (This may take a few minutes)"
    echo ""
    brew install xcodegen
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Failed to install xcodegen."
        echo ""
        echo "Please install manually:"
        echo "  brew install xcodegen"
        echo ""
        echo "Or create the project manually in Xcode:"
        echo "  1. Open Xcode"
        echo "  2. File → New → Project"
        echo "  3. iOS → App"
        echo "  4. Product Name: FamilyNovaParent"
        echo "  5. Interface: SwiftUI, Language: Swift"
        echo "  6. Save to: $PROJECT_DIR"
        echo "  7. Replace existing files when prompted"
        exit 1
    fi
fi

echo "✅ xcodegen installed"
echo ""
echo "📝 Generating Xcode project from project.yml..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Project generated successfully!"
    echo ""
    echo "🚀 Opening in Xcode..."
    open FamilyNovaParent.xcodeproj
else
    echo ""
    echo "❌ Failed to generate project."
    echo "Please check project.yml file or create project manually in Xcode."
    exit 1
fi

