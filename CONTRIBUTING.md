# Contributing

Thank you for considering contributing to SketchIDE! Before you start, please take a moment to review the guidelines outlined below.

By contributing to this project, you agree to abide by the terms specified in the [CODE OF CONDUCT](./CODE_OF_CONDUCT.md).

## Requirements

To contribute to SketchIDE, you'll need the following:

- **Flutter SDK** (latest stable version).
- **Dart SDK** (comes bundled with the Flutter SDK).
- **Android Studio** (for Android and iOS development). We recommend **Android Studio Ladybug** for the best Flutter experience.
- **Xcode** (for iOS development, if you're building for iOS).
- **JDK 17** (preferably the one bundled with Android Studio).
- **VS Code** (optional, but can be used as an alternative to Android Studio).
- **Project IDX** (optional, a cloud-based IDE for Flutter development).

> [!NOTE]  
> At the time of writing, the stable version of Android Studio (Android Studio Iguana | 2023.2.1) comes bundled with JDK 17, which is recommended for Flutter development.

## Building the Project

1. Clone the repository and open it in **Android Studio** (or **VS Code** or **Project IDX**).
2. Make sure you have the **Flutter** plugin installed in Android Studio or **VS Code**.
3. Run the following command to ensure the Flutter dependencies are installed:
    ```bash
    flutter pub get
    ```
4. For **Android** development, make sure you have an Android device or emulator connected.
5. For **iOS** development, ensure you have **Xcode** set up and a simulator or real device connected.

While it's possible to build SketchIDE within Flutter itself, it's recommended to use **Android Studio Ladybug** for the best performance, especially considering the potential resource requirements. **VS Code** and **Project IDX** are also good alternatives if you prefer a lighter setup or a cloud-based environment.

## Proposing Changes

Before proposing a change, it is always recommended to open an issue and discuss it with the maintainers.

**The `main` branch is protected and requires all the commits to be signed with your GPG key and the commit history to be linear.**
See [protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches).

To contribute to this project:

- Fork the repo:
  ```bash
  https://github.com/sketchide/SketchIDE.git
  ```
- Clone the forked repo to your local machine.
- Open the project in **Android Studio** (or **VS Code** or **Project IDX**).
- Make your changes using **Dart** and **Flutter**.
- Run the project on both **Android** and **iOS** platforms to ensure cross-platform compatibility.
- Create a pull request. Give a proper title and description to your PR.

## Issues & Pull Requests

Whenever possible, use the provided issue and pull request templates. Ensure that you provide a concise title and a detailed description. For bug reports, include a step-by-step procedure to reproduce the issue. Additionally, include relevant information such as crash logs and build outputs within `code blocks`.

## Contact Us

If you have any questions or want to discuss anything related to the project, feel free to join our [Telegram group](https://t.me/sketchidegroup). We're here to help!
