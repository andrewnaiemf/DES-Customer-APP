#!/bin/bash

# Script to copy Flutter.xcframework to the correct location

FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
PROJECT_DIR="$SRCROOT"

# Check if Flutter.xcframework exists in Debug folder
if [ -d "$PROJECT_DIR/Flutter/Debug/Flutter.xcframework" ]; then
    echo "Copying Flutter.xcframework from Debug folder..."
    rm -rf "$PROJECT_DIR/Flutter/Flutter.xcframework"
    cp -R "$PROJECT_DIR/Flutter/Debug/Flutter.xcframework" "$PROJECT_DIR/Flutter/"
    echo "Flutter.xcframework copied successfully"
elif [ -d "$FLUTTER_ROOT/bin/cache/artifacts/engine/ios/Flutter.xcframework" ]; then
    echo "Copying Flutter.xcframework from Flutter SDK..."
    rm -rf "$PROJECT_DIR/Flutter/Flutter.xcframework"
    cp -R "$FLUTTER_ROOT/bin/cache/artifacts/engine/ios/Flutter.xcframework" "$PROJECT_DIR/Flutter/"
    echo "Flutter.xcframework copied from SDK"
else
    echo "Warning: Flutter.xcframework not found"
fi
