#!/bin/bash
set -e

osascript -e 'tell application "Xcode" to quit' || true

flutter clean
flutter pub get

cd ios
pod install
cd ..

flutter run --flavor development -t lib/main_development.dart
