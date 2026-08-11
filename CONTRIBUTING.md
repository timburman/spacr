# Contributing to Spacr

Thank you for your interest in contributing to **Spacr**. 

Spacr is an open-source productivity layer for Windows virtual desktops. Our goal is to build a rock-solid, keyboard-driven workspace management workflow for native Windows.

---

## Engineering Principles

Every contribution must prioritize engineering trade-offs in this strict order:

1. **Stability**
2. **Correctness**
3. **Simplicity**
4. **Maintainability**
5. **Modularity**
6. **Performance**

> *Never sacrifice stability or simplicity to add new features.*

---

## Architectural Ownership Rules

Before submitting code changes, ensure your PR respects Spacr's module boundaries:

- **WorkspaceManager**: Owns all interactions with `VirtualDesktopAccessor.dll`. No other module may invoke VDA directly.
- **Hotkeys**: Pure trigger layer. Hotkeys must delegate 100% of actions to `WorkspaceManager` public APIs and must never manipulate windows or desktops directly.
- **Renderer** *(Phase 4)*: Owns window movement and resizing operations (`WinMove`).
- **State** *(Phase 2)*: Owns workspace and window tracking state.

---

## Code Guidelines

- **Language**: AutoHotkey v2 only.
- **Single Responsibility**: Every file and class should do exactly one job. If a class starts taking on multiple roles, split it.
- **Explicit API**: Communication between modules must occur through public methods—never through shared global variables.
- **Windows First**: Respect native Windows behavior. Do not hide Windows quirks behind arbitrary delays or hacks without documenting the root cause.
- **No Premature Architecture**: Build only what is required by the current phase roadmap. Avoid adding plugin systems, event buses, or future-proofing abstractions unless they solve an active requirement.

---

## Submitting a Pull Request

1. **Fork the Repository** and create a focused topic branch from `main`:
   ```bash
   git checkout -b feature/my-focused-change
   ```
2. **Test Your Changes**: Verify that your changes run cleanly without errors using AutoHotkey v2:
   ```powershell
   & "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /Validate main.ahk
   ```
3. **Commit & Push**: Keep commits concise and descriptive.
4. **Open a PR**: Describe what your PR accomplishes, why it is necessary, and any Windows behavior trade-offs involved.

---

## Code Review Process

All submissions are reviewed against our engineering guidelines and project roadmap. We prioritize clean, readable, and maintainable implementations over clever solutions.

If you are proposing a major structural change or new feature, please open an **Issue** or **Discussion** first to align on architecture before writing code.
