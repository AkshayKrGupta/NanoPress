<p align="center">
  <img src="Sources/NanoPress/Resources/AppIcon.png" width="128" height="128" alt="NanoPress Icon">
</p>

# NanoPress ⚡️

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat&logo=swift)](https://developer.apple.com/swift/)
[![Platform macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg?style=flat&logo=apple)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat)](LICENSE)

**NanoPress** is a lightning-fast, privacy-first file compression utility built natively for macOS using SwiftUI. It helps you reduce the size of your images and PDFs without compromising quality, all while running 100% locally on your machine.

---

## 🚀 Why NanoPress?

In an era of bloated files and slow uploads, **NanoPress** offers a streamlined solution for designers, developers, and content creators. Whether you need to optimize assets for the web, shrink PDF reports for email, or just save disk space, NanoPress delivers.

**Key Benefits:**
*   **Privacy First:** No cloud uploads. All compression happens locally on your device.
*   **Performance:** Built with Swift concurrency for blazing fast batch processing.
*   **Simplicity:** Clean, drag-and-drop interface with zero learning curve.

## ✨ Features

### 🖼️ Image Compression
Drastically reduce file sizes for typical web formats.
*   **Formats:** Supports `JPG`, `PNG`, `HEIC`, and `TIFF`.
*   **Custom Levels:** Choose from Low (50%), Medium (75%), High (90%), or a custom slider value.
*   **Smart Preview:** See potential savings before you commit.

### 📄 PDF Optimization
Shrink document sizes efficiently.
*   **Standard Mode:** Balanced compression maintaining good visual quality.
*   **Aggressive Mode:** Maximum size reduction for internal sharing or archiving.

### ⚡️ Power User Tools
*   **Batch Processing:** Drag and drop hundreds of files at once. NanoPress handles them in parallel.
*   **Smart Output:** Choose to overwrite originals or save to a specific destination.
*   **Dark Mode:** Fully adaptive UI that looks great in Light and Dark modes.

## 🛠️ Built With

*   **Language:** [Swift 5.9+](https://developer.apple.com/swift/)
*   **UI Framework:** [SwiftUI](https://developer.apple.com/xcode/swiftui/)
*   **Architecture:** MVVM with Swift Concurrency (`async/await`, `Actors`).

## 📦 Installation & Build

### Prerequisites
*   macOS 14.0 (Sonoma) or later.
*   Xcode 15.0 or later.

### Building from Source
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/AkshayKrGupta/NanoPress.git
    cd NanoPress
    ```
2.  **Open in Xcode:**
    Double-click `Package.swift` or open the directory in Xcode.
3.  **Run:**
    Press `Cmd + R` to build and run the application.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📝 License

Distributed under the Apache 2.0 License. See `LICENSE` for more information.

---

<p align="center">
  Generated with ❤️ by <a href="https://github.com/AkshayKrGupta">Akshay Kumar Gupta</a>
</p>
