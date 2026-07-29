#!/bin/bash
set -e
export ANDROID_HOME=/home/andrew/Android/Sdk
export ANDROID_SDK_ROOT=/home/andrew/Android/Sdk
export JAVA_HOME=/home/andrew/jdk17
export PATH="/home/andrew/flutter/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export DISPLAY=${DISPLAY:-:1}

# Backend
if ! ss -tln | grep -q ':8000'; then
  (cd /var/www/html/retail && nohup php artisan serve --host=0.0.0.0 --port=8000 >/tmp/retail_serve.log 2>&1 &)
  sleep 2
fi

# Emulator
if ! adb devices | grep -q emulator; then
  find "$HOME/.android/avd/des_emu.avd" -name '*.lock' -exec rm -rf {} + 2>/dev/null || true
  nohup emulator -avd des_emu -gpu swiftshader_indirect -no-snapshot -no-boot-anim -no-audio >/tmp/emu_run.log 2>&1 &
  adb wait-for-device
  until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 2; done
fi

cd /var/www/html/DES-Customer-APP
flutter run -d emulator-5554 --no-enable-impeller
