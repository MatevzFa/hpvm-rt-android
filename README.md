# Compiling HPVM for Android

## Requirements

* Properly set up environment
* Patched HPVM Compiler: https://gitlab.engr.illinois.edu/llvm/hpvm-release
* [Android NDK](https://developer.android.com/ndk/guides)
* Accompanying Android application: https://github.com/MatevzFa/hpvm-rt-android-app


## Setting up the environment

Set up the following environment variables. You can use `set-env.example.sh` as a starting point.

* `ANDROID_NDK`: Path to the Andorid NDK (e.g. .../Android/Sdk/ndk/21.3.6528147)
* `HPVM_ROOT`: Path to the root of hpvm-release project
* `HPVM_BUILD`: Path to hpvm build directory
* `TARGET`: Android NDK Target. Passed to clang -target (e.g. "aarch64-linux-android21")
* `LIB_INSTALL_PATH`: points to .../app/src/main/cpp/libs
* `INCLUDE_INSTALL_PATH`: points to .../app/src/main/cpp/include


## Patching the HPVM Compiler

After the environment is set up, run the following command to patch HPVM's GenHPVM pass.

```
./patch-hpvm.sh
```


## Building

The Makefile defines the [HPVM compilation pipeline](https://gitlab.engr.illinois.edu/llvm/hpvm-release/-/blob/hpvm-release/hpvm/docs/compilation.md). If the environment is set up correctly, building the library with HPVM code is as simple as running

```
make
```

You can install the library into the [Android application](https://github.com/MatevzFa/hpvm-rt-android-app) by running

```
make install
```

This installs `example-hpvm-sum.h` and `libexample-hpvm-sum.so` into correct folders within the Android application source tree.


## Running

Code in this project cannot be executed by itself. It has to be built into an Android application. See https://github.com/MatevzFa/hpvm-rt-android-app for further information.
