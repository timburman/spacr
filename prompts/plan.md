# WindowsHypr

> **A lightweight workflow layer for Windows virtual desktops inspired by Hyprland.**
>
> WindowsHypr enhances the native Windows desktop experience without replacing Explorer or the Windows shell. It focuses on fast, keyboard-driven workspace management while remaining lightweight, modular, and extensible.

---

# Vision

Windows already provides virtual desktops, but they lack the workflow and productivity features available in modern Linux window managers such as Hyprland.

WindowsHypr aims to bridge that gap by building **on top of** Windows rather than replacing it.

## Goals

- Preserve the native Windows experience.
- Improve productivity through keyboard-driven workflows.
- Keep the project lightweight.
- Keep the architecture modular.
- Be friendly to contributors.
- Be open source from day one.

## Non Goals

WindowsHypr is **not**:

- a Windows shell replacement
- a desktop environment
- a compositor
- another FancyZones clone

Instead, it is a workflow layer that enhances native Windows virtual desktops.

---

# Current Architecture

```
                Hotkeys
                    │
                    ▼
          Workspace Manager
                    │
                    ▼
        VirtualDesktopAccessor
                    │
                    ▼
              Windows API
```

Future architecture:

```
                Hotkeys
                    │
                    ▼
          Workspace Manager
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
 Window Tracker           Event System
         │                     │
         └──────────┬──────────┘
                    ▼
              Project State
                    │
                    ▼
             Layout Engine
                    │
                    ▼
               Renderer
                    │
                    ▼
                WinMove API
```

---

# Project Structure

```
WindowsHypr/
│
├── main.ahk
├── config.toml
├── README.md
├── LICENSE
│
├── lib/
│   ├── vda.ahk
│   ├── workspace.ahk
│   ├── tracker.ahk
│   ├── layout.ahk
│   ├── renderer.ahk
│   ├── state.ahk
│   └── utils.ahk
│
├── state/
```

---

# Guiding Principles

## 1. State Driven

Hotkeys never manipulate windows directly.

Instead:

```
Hotkey

↓

Workspace State

↓

Layout Engine

↓

Renderer
```

This keeps the project maintainable and allows new layouts without rewriting window management code.

---

## 2. Single Responsibility

Every module has one job.

Examples:

- WorkspaceManager manages desktops.
- Renderer moves windows.
- LayoutEngine computes geometry.
- VDA wrapper communicates with VirtualDesktopAccessor.

No module should perform another module's responsibilities.

---

## 3. Renderer Owns WinMove

The Renderer is the **only** component allowed to resize or move windows.

Everything else produces state.

---

## 4. WorkspaceManager Owns VirtualDesktopAccessor

No module should call VirtualDesktopAccessor directly.

All desktop operations go through WorkspaceManager.

---

# Current Features

Implemented

- Stable desktop switching
- Auto-create missing workspaces
- Move window to workspace
- Move + Follow workflow
- Explorer flashing fix

Planned

- Previous workspace
- Window tracking
- Dynamic tiling
- Floating windows
- Rules
- Persistent layouts

---

# Milestones

## v0.1

Goal:

Stable workspace management.

Features

- Workspace switching
- Auto-create desktops
- Move + Follow
- Previous workspace
- Stable Explorer integration

Nothing more.

---

## v0.2

Window tracking.

- Track workspace windows
- Event system
- Internal state management

---

## v0.3

Dynamic tiling.

- Master layout
- Auto layout updates
- Window ordering

---

## v0.4

Layouts.

- Grid
- Monocle
- Master ratio adjustment

---

## v1.0

Stable release.

---

# Design Decisions

## Native Windows

WindowsHypr enhances Windows.

It never replaces Explorer.

---

## AutoHotkey v2

Chosen because it provides

- small footprint
- zero dependencies
- easy installation
- excellent Windows API access

---

## VirtualDesktopAccessor

Chosen because it provides reliable access to Windows virtual desktop functionality.

All interaction should be abstracted through the VDA wrapper.

---

## TOML Configuration

Configuration should never require editing source code.

Example:

```toml
workspace_count = 9
auto_delete = true

[general]
modifier = "Alt"

[layout]
default = "master"
```

---

## Workspace Deletion

Rules:

A workspace may only be deleted when:

- it contains zero tracked windows
- it is not the current workspace
- the user has already left it

Deletion should never occur while the user is still inside the workspace.

---

# Research & Discoveries

## Explorer Flashing

Problem

Switching desktops through VirtualDesktopAccessor caused taskbar flashing.

Cause

Explorer did not own focus before desktop switching.

Solution

```ahk
WinActivate("ahk_class Shell_TrayWnd")
Sleep 20
GoToDesktopNumber(...)
```

Result

Native Windows behavior restored.

This behavior should remain documented because it represents undocumented shell behavior.

---

# Coding Standards

- Keep modules focused.
- Avoid global state where possible.
- Document public functions.
- Keep `main.ahk` minimal.
- Prefer composition over large scripts.
- Never duplicate Windows API calls across modules.
- All magic numbers require comments.
- Every major design decision should be documented.

---

# Future Ideas

These are intentionally **not** part of the initial roadmap.

- Rules

  ```
  Discord.exe → Workspace 5
  Chrome.exe → Workspace 2
  ```

- Persistent workspace names

- Floating windows

- Multiple monitor layouts

- Theme support

- GUI configuration editor

These should only be considered after the core workspace workflow is stable.

---

# Known Challenges

Windows introduces several edge cases that will require testing.

Examples:

- Explorer restarts
- UWP applications
- Elevated windows
- Fullscreen games
- Multi-monitor setups
- DPI scaling
- Hidden utility windows
- Tool windows
- Dialog ownership

Reliability should always take priority over new features.

---

# Development Philosophy

WindowsHypr should grow slowly.

Every release should prioritize:

1. Stability
2. Predictability
3. Simplicity
4. Clean architecture

It is better to release one feature that is rock-solid than ten features that only work most of the time.

The long-term goal is to build a maintainable, extensible, and community-friendly project that brings a Hyprland-inspired workflow to native Windows virtual desktops without sacrificing compatibility with the Windows ecosystem.
