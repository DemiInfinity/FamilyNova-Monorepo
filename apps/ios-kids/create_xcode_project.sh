#!/bin/bash

# Script to create Xcode project for FamilyNova Kids App

PROJECT_NAME="FamilyNovaKids"
BUNDLE_ID="com.familynova.kids"
PROJECT_DIR="/Users/deminimmo/Mobile Projects/familynova/apps/ios-kids"

cd "$PROJECT_DIR"

# Create .xcodeproj directory
mkdir -p "${PROJECT_NAME}.xcodeproj"

# Create project.pbxproj file
cat > "${PROJECT_NAME}.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
/* Begin PBXBuildFile section */
/* End PBXBuildFile section */
/* Begin PBXFileReference section */
/* End PBXFileReference section */
/* Begin PBXGroup section */
/* End PBXGroup section */
/* Begin PBXNativeTarget section */
/* End PBXNativeTarget section */
/* Begin PBXProject section */
		29B97313FDCFA39411CA2CEA /* Project object */ = {
			isa = PBXProject;
			attributes = {
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = C01FCF4A08A954540054247B /* Build configuration list for PBXProject "FamilyNovaKids" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 1;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 29B97314FDCFA39411CA2CEA /* CustomTemplate */;
			productRefGroup = 29B97317FDCFA39411CA2CEA /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				29B97318FDCFA39411CA2CEA /* FamilyNovaKids */,
			);
		};
/* End PBXProject section */
/* Begin XCBuildConfiguration section */
		C01FCF4E08A954540054247B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsMultipleScenes = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.familynova.kids;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		C01FCF4F08A954540054247B /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsMultipleScenes = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.familynova.kids;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */
	};
	rootObject = 29B97313FDCFA39411CA2CEA /* Project object */;
}
EOF

echo "Created ${PROJECT_NAME}.xcodeproj"
echo "Note: You'll need to open this in Xcode and add the source files manually,"
echo "or install xcodegen (brew install xcodegen) and run: xcodegen generate"

