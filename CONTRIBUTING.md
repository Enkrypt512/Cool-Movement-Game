# Contributing to Cool Movement Game

Thank you for your interest in contributing to **Cool Movement Game**! As an open-source project, community contributions, bug reports, and code improvements are always welcome.

Please take a moment to review these guidelines before getting started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Project Prerequisites & Setup](#project-prerequisites--setup)
- [Code Style](#code-style)
- [Assets Rights](#assets-rights)

## Code of Conduct

Please maintain a respectful, welcoming, and collaborative environment. Be constructive in code reviews and respectful when opening issues or discussing design decisions. Check the [Code of Conduct file](CODE_OF_CONDUCT.md) for more information.

## How Can I Contribute?

### Reporting Bugs

If you find a bug or unexpected behavior while playing or testing:

1. Check the [Existing Issues](https://github.com/Enkrypt512/Cool-Movement-Game/issues) to ensure it hasn't already been reported.
2. If it's a new bug, [Open a New Issue](https://github.com/Enkrypt512/Cool-Movement-Game/issues/new).
3. Include the following details in your report:
   - **Game / Commit Version:** (e.g., `v0.8.9` or a recent commit hash).
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
   git clone https://github.com/YourUsername/Cool-Movement-Game.git
   ```
3. **Create a Feature Branch:**
   ```bash
   git checkout -b feature/add-stages
   ```
4. **Make and Test Your Changes:** Open the project in Godot Engine and verify that your changes run without causing console errors or breaking existing movement mechanics.
5. **Commit Your Changes:** Write clear, descriptive commit messages.
   ```bash
   git commit -m "Add Stages"
   ```
6. **Push to Your Fork & Open a PR:**
   ```bash
   git push origin feature/add-stages
   ```
   Submit a pull request targeting the `main` branch of this repository.

7. **Use a Semantic PR Title:** The **Validate PR Title** workflow rejects any pull request whose title does not start with one of the prefixes below, so set the title before opening the PR.

   | Prefix | Use for |
   | ------ | ------ |
   | `feat` | A new feature |
   | `fix` | A bug fix |
   | `docs` | Documentation only |
   | `style` | Formatting only, no code change |
   | `refactor` | Restructuring code with no behavior change |
   | `test` | Adding or fixing tests |
   | `chore` | Maintenance, CI, and dependency updates |

   For example: `feat: Add stages`

## Project Prerequisites & Setup

- **Engine Version:** [Godot Engine 4.8-dev6](https://godotengine.org/download/archive/4.8-dev6)
- **Importing:** Open Godot 4, click **Import**, select `project.godot`, and launch the project.
- **Testing:** Press `F5` inside Godot to run and test the game directly.

## Code Style

Variables, functions, signals and enum members use **PascalCase with underscores** between words,which is the style the official Godot documentation uses, plus no spaces between commas (like this: `Call_Function(Argument1,Argument2)`) and no abbreviations (like IP):

```gdscript
var This_Variable: int = 0

func This_Function(Argument: int) -> void:
	var Local_Variable: int = Argument * 2
```

When you edit a file, keep the existing conventions — matching the surrounding code matters more than any external style guide.

The only exception is Godot itself. **If capitalizing a name would shadow a built-in Godot type, leave it lowercase.** For example, `Time` is Godot's singleton (`Time.get_ticks_msec()`), so a variable named `time` must not be renamed to `Time` — the local would shadow the type. The same applies to:

| Lowercase | Would collide with |
| --------- | ------------------ |
| `time` | `Time` (singleton) |
| `node` | `Node` (type) |
| `label` | `Label` (type) |
| `button` | `Button` (type) |
| `timer` | `Timer` (type) |
| `tween` | `Tween` (type) |
| `error` | `Error` (type) |

Godot's overridable callbacks and their parameters are lowercase for the same reason — the engine
looks them up by name, so they must not be renamed:

| Kind | Names |
| ---- | ----- |
| Callbacks | `_ready`, `_process`, `_physics_process`, `_input`, `_unhandled_input`, `_enter_tree`, `_exit_tree`, `_init`, `_draw`, `_notification`, … |
| Signal handlers | `_on_<signal_name>` |
| Their parameters | `delta`, `event` |

If you add a variable whose capitalized form would shadow another Godot type, add that lowercase
spelling to the patterns in [`.gdlintrc`](.gdlintrc).

Other notes:

- Indent with **tabs** (Godot's default).
- Line length: up to **240** characters, matching the existing scripts.
- `var`, `@export var` and `@onready var` blocks may be interleaved; declaration order is not enforced.
- Add `@export` to any variable that might be useful to have exported in the inspector.
- No underscore prefix on variables or functions (unless they are a native Godot function).

### Linting and formatting

Pull requests are checked by the **Godot Check Bot** workflow, which runs
[gdtoolkit](https://github.com/gdtoolkit/gdtoolkit) on every PR. Run the same checks locally before
pushing:

```bash
pip install gdtoolkit

gdlint .        # must pass - blocks the pull request
gdformat .      # optional - advisory, the bot only reports it
```

The naming rules are configured in [`.gdlintrc`](.gdlintrc), which encodes this convention and the
Godot exceptions above. If you need to change the conventions, update `.gdlintrc` rather than
renaming code.

## Assets Rights

By contributing to this repository:

1. **Code License:** You agree that all code contributions will be licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).
2. **Third-Party Assets:** Any 3D models, textures, or audio assets added must be **CC0 / Public Domain**. Always provide proper attribution in the `README.md` and the Credits menu for any added assets.
