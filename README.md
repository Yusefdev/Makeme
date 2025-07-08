# Makeme

![Makeme Banner](banner.png)

**Makeme** is a tool designed to simplify the C/C++ development workflow — especially for newcomers. It handles all the heavy lifting so you can focus on your code, not your build system.

---

## 🎯 Purpose

Makeme is built with one goal: **make C/C++ development easy** — no need to touch the command line. Everything can be done through a **user-friendly UI interface**.

---

## 🪟 Platform Support

- ✅ **Windows only** (for now)  
- 📦 Requires [MSYS2](https://www.msys2.org/) as a package manager  
- 🐧 **Linux support is planned for the future**

---

## 🧰 Features

- 🖥️ **Full UI Experience** – No command-line required.
- 🔍 **Automatic Package Detection** – Finds and installs needed libraries.
- ⚙️ **Smart Compilation** – Compiles your project based on its structure and dependencies.
- 🐞 **Integrated Debugger** – Debug your applications without external setup.
- 📂 **Source Management** – Automatically organizes your source files.
- 💾 **Build Backups** – Keeps backups of builds and compresses them to save space.
- 🔧 **CMake-Like Flexibility** – Supports ordered file builds and architecture/compiler flags.

---

## 🚀 Quick Start

1. Download the latest [release](#) (insert your release link).
2. Install [MSYS2](https://www.msys2.org/).
3. Launch Makeme – everything is accessible through the UI.
4. Enjoy building your C/C++ projects with zero hassle.

---

## 🖥️ CLI Tool (`mkme`)

Makeme includes a CLI tool for those who prefer scripting or terminal usage:

### 🔧 Usage Examples:

```bash
mkme -build --release            # Build in release mode
mkme -build --debug              # Build in debug mode
mkme -build                      # Uses config file in current folder
mkme -build -run                # Run after build (with or without --release/--debug)
mkme -build -compress           # Compress build outputs
mkme -build -autopackage        # Automatically detect and install required packages
mkme -build -packages=["libA","libB"]  # Manually specify required packages
mkme -build -customflag         # Use custom build flags
mkme -build -architect=x64      # Target architecture: x64 or x86
mkme -build -compiler=gcc       # Choose compiler: gcc, g++, clang, clang++
```

---

## 🤝 Contributing

Want to help improve Makeme? **You’re welcome to contribute!**  
Just open an issue or contact us — tell us what you’d like to work on or what you need.

---

## 📄 License

[MIT](LICENSE)
