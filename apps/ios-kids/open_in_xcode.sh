#!/bin/bash

# Script to help open iOS Kids app in Xcode

PROJECT_DIR="/Users/deminimmo/Mobile Projects/familynova/apps/ios-kids"

cd "$PROJECT_DIR"

echo "🚀 Opening FamilyNova Kids App in Xcode..."
echo ""
echo "If the project doesn't open properly, follow these steps:"
echo ""
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. iOS → App"
echo "4. Product Name: FamilyNovaKids"
echo "5. Interface: SwiftUI, Language: Swift"
echo "6. Save to: $PROJECT_DIR"
echo "7. Replace existing files when prompted"
echo ""

# Try to open the project if it exists
if [ -d "FamilyNovaKids.xcodeproj" ]; then
    echo "Attempting to open existing project..."
    open FamilyNovaKids.xcodeproj 2>/dev/null || echo "Could not open project. Please create it manually in Xcode."
else
    echo "Project file not found. Please create it in Xcode (see instructions above)."
fi

echo ""
echo "📝 All source files are ready in: FamilyNovaKids/"

