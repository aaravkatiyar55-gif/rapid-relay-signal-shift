# Rapid Relay: Signal Shift

An AI-assisted Godot reaction-game practice project where a player keeps a relay station online through short keyboard and mouse challenges.

![Rapid Relay main menu](screenshots/main-menu.png)

## Current status

The local game, automated logic checks, local runtime screenshots, and a public source repository exist. This project has no public playable demo, tracker-time evidence, or Stardance submission claim. Visible-window manual testing is still incomplete.

## How it plays

Start the relay, read the active instruction, and preserve three signal bars through four rounds. A failed challenge removes one bar. Losing all bars opens **Signal Lost**; surviving all four rounds opens **Transmission Complete**.

### Controls

- **Tab** and **Enter**: move to and activate focused menu/end-scene buttons.
- **Space**: use only after `GO` in Pulse Press.
- **Mouse click** or **tap**: catch the moving orb in Orb Catch.
- **Esc**: return to the main menu during a run or ending screen.

## Mini-games

### Pulse Press

Wait for the central relay lamp to say `GO`, then press Space inside the active window. Pressing early or missing the window fails the round.

### Orb Catch

Click or tap the drifting signal orb before it crosses the exit line. A click outside the orb or a timeout fails the round.

## Features

- 960×540 Godot 4 Compatibility-renderer project.
- Four-round alternating challenge flow: Press, Catch, Press, Catch.
- Textual `SIGNAL BARS x / 3` HUD plus visible bars.
- Separate original Win and Death scenes with replay and menu routes.
- Simple local SVG assets for the relay icon, signal bars, success stamp, and failure stamp.

## Run locally

1. Install Godot 4.7 or a compatible Godot 4 release.
2. Import or open `project.godot` from this folder.
3. Press **F6** to run the current scene, or **F5** to run the project.
4. Use keyboard and mouse controls listed above.

## Test locally

The recorded results are in [docs/TESTING.md](docs/TESTING.md). The checks can be run from a terminal with a Godot console executable:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/press_logic_test.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/catch_logic_test.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/flow_test.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/navigation_test.gd
```

## Assets and technology

- Godot 4.7
- GDScript
- Local SVG files in `assets/`
- No external asset pack or external font

The SVG assets and game source in this practice project were produced with AI assistance and are stored locally in this repository folder.

## Screenshots

All images below were captured from the local non-headless Godot runtime on 2026-08-18.

![Main menu](screenshots/main-menu.png)
![Pulse Press HUD](screenshots/relay-round.png)
![Transmission Complete](screenshots/transmission-complete.png)
![Signal Lost](screenshots/signal-lost.png)

## Public links

- Source: [GitHub repository](https://github.com/aaravkatiyar55-gif/rapid-relay-signal-shift)
- Playable demo: not published yet. The required Godot Web export templates are not installed locally.

## Known limitations

- Only two minigame types are included.
- There is no sound effects, high-score system, or mobile-specific layout pass yet.
- Visible-window manual testing is still required in addition to the recorded headless tests.
- A Web export preset exists, but the required Godot 4.7.1 Web export templates are not installed on this machine.

## AI disclosure

OpenAI Codex was used for project setup, implementation support, debugging, testing support, and documentation. This repository and its project evidence describe the actual verified behavior; it is an AI-assisted practice prototype.

It must not be represented as meeting Stardance’s “none to minimal AI usage” requirement without independent confirmation from the mission organizers.
