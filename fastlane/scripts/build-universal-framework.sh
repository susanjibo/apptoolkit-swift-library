#!/bin/sh

PROJECT_NAME="AppToolkit"
WORKSPACE_NAME=${PROJECT_NAME}

BUILD_DIR=$(xcodebuild -workspace "${WORKSPACE_NAME}.xcworkspace" -scheme "${PROJECT_NAME}" -showBuildSettings | grep -w BUILD_DIR | awk -F' = ' '/BUILD_DIR =/{print $2}')
BUILD_ROOT=${BUILD_DIR}
CONFIGURATION="Release"
UNIVERSAL_OUTPUTFOLDER="build/${CONFIGURATION}-universal"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"


# Build Device and Simulator versions
set -o pipefail && xcodebuild -workspace "${WORKSPACE_NAME}.xcworkspace" -scheme "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphoneos ONLY_ACTIVE_ARCH=NO CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO clean build
set -o pipefail && xcodebuild -workspace "${WORKSPACE_NAME}.xcworkspace" -scheme "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO clean build

# Copy the framework structure (from iphoneos build) to the universal folder
# Target framework
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
    cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"
