#!/bin/bash

echo "Building iOS app for Appetize.io..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for iOS simulator
flutter build ios --simulator --release --no-codesign

# Create a zip file that Appetize.io expects
cd build/ios/iphonesimulator
zip -r Runner.app.zip Runner.app

echo "Build complete!"
echo "App file: build/ios/iphonesimulator/Runner.app"
echo "Zip file for Appetize: build/ios/iphonesimulator/Runner.app.zip"
echo ""
echo "Upload Runner.app.zip to Appetize.io"