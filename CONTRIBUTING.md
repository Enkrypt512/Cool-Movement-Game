# Contributing to Cool Movement Game

Thank you for your interest in contributing to **Cool Movement Game**! As an open-source project, community contributions, bug reports, and code improvements are always welcome.

Please take a moment to review these guidelines before getting started.

## Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [How Can I Contribute?](#-how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Project Prerequisites & Setup](#-project-prerequisites--setup)
- [Assets](#assets)

## Code of Conduct

Please maintain a respectful, welcoming, and collaborative environment. Be constructive in code reviews and respectful when opening issues or discussing design decisions. Check The [Code Of Conduct File](CODE_OF_CONDUCT.md) For More Information

## How Can I Contribute?

### Reporting Bugs

If you find a bug or unexpected behavior while playing or testing:

1. Check the [Existing Issues](https://github.com/Enkrypt512/Cool-Movement-Game/issues) to ensure it hasn't already been reported.
2. If it's a new bug, [Open a New Issue](https://github.com/Enkrypt512/Cool-Movement-Game/issues/new).
3. Include the following details in your report:
   - **Game / Commit Version:** (e.g., `v0.8.9` or recent commit hash).
   - **System Specs:** OS, CPU, GPU, and RAM.
   - **Steps to Reproduce:** Clear step-by-step instructions.
   - **Expected vs. Actual Behavior.**
   - **Logs / Screenshots:** Attach screenshots or console/terminal output if applicable.

### Suggesting Features

Feature requests and ideas for new mechanics or improvements are appreciated!

- Open an issue describing the feature you'd like to see.
- Explain **why** it fits and how it impacts the game.

### Submitting Pull Requests

1. **Fork the Repository:** Click the "Fork" button at the top right of this page.
2. **Clone your Fork:**
   ```bash
   git clone https://github.com/Enkrypt512/Cool-Movement-Game.git
   ```
3. **Create a Feature Branch:**
   ```bash
   git checkout -b feature/add-stages
   ```
4. **Make and Test Your Changes:** Open the project in Godot Engine and verify that your changes run without console errors or breaking existing movement mechanics.
5. **Commit Your Changes:** Write clear, descriptive commit messages.
   ```bash
   git commit -m "Add Stages"
   ```
6. **Push to Your Fork & Open a PR:**
   ```bash
   git push origin feature/add-stages
   ```
   Submit a Pull Request targeting the `main` branch of this repository.

## Project Prerequisites & Setup

- **Engine Version:** [Godot Engine 4.8-dev4](https://godotengine.org/download/archive/4.8-dev4)
- **Importing:** Open Godot 4, click **Import**, select `project.godot`, and launch the project.
- **Testing:** Press `F5` inside Godot to run and test the game directly.

## Assets Rights

By contributing to this repository:

1. **Code License:** You agree that all code contributions will be licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).
2. **Third-Party Assets:** Any 3D models, textures, or audio assets added must be **CC0 / Public Domain**. Always provide proper attribution in the `README.md` for any added assets.
