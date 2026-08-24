# Testing notes

Date: 2026-08-24
Workspace: `rapid-relay-rebuild`
Environment: Windows, Godot 4.7.1 stable, Compatibility renderer.

## What was checked

Testing is separated into source inspection, automated Godot checks, local runtime rendering, local browser checks, and public verification. A check is not listed as manual owner testing unless a person actually played it.

## Source inspection

- Confirmed one Godot 4 project with a 960×540 viewport and Web export preset.
- Confirmed nine runtime scenes: menu, game controller, five minigames, win, and death.
- Confirmed five distinct minigame scripts with keyboard, mouse, or touch input.
- Confirmed seven project-specific SVG source files, one locally rendered boot-splash PNG, and no external asset pack or font.
- Confirmed one ordered five-stage controller plan and a one-result-only shared minigame base.
- Confirmed README and design notes retain substantial Codex assistance disclosure.
- Confirmed there is no semantic screen-reader text layer; this remains a documented limitation rather than a tested accessibility claim.

## Automated Godot results

All seven suites below were run with the Godot 4.7.1 console executable. Final suite runs exited `0` with no script/runtime error and no failed assertion.

| Suite | Main cases observed | Assertions | Result |
| --- | --- | ---: | --- |
| Pulse Press | randomized wait range, early input, correct input, late input, duplicate guard | 5 | Passed |
| Orb Catch | pointer hit, reticle move, keyboard capture, wrong click, timeout | 5 | Passed |
| Wave Tuner | both directions, long-frame crossing, stable hold, hold reset, late target, timeout, duplicate guard, reset-timer cancellation | 19 | Passed |
| Relay Route | full sequence, wrong arrow, timeout, duplicate guard, stopped state, reset | 7 | Passed |
| Core Dock | correct drag, empty drop retry, wrong socket, keyboard dock, timeout, duplicate guard, reset | 10 | Passed |
| Five-stage flow | real child result signals, exact order/metadata, full win, three-loss death, final-stage recovery, duplicate controller result | 21 | Passed |
| Navigation | real Enter/Esc dispatch, result-delay escape, menu focus/start, fresh replay, win/death buttons, back to menu | 13 | Passed |
| **Total** |  | **80** | **Passed** |

## Local runtime and visual checks

| Check | Action | Observed result | Status |
| --- | --- | --- | --- |
| Non-headless renderer | Ran screenshot capture with Godot 4.7.1 | Compatibility mode started through ANGLE after a known Intel OpenGL driver warning | Passed |
| Runtime screenshots | Captured menu, all five minigames, win, and death | Nine 960×540 PNG files saved from the actual runtime | Passed |
| Screenshot failure guard | Locked one output file during a negative capture run, then ran normally | Failed save exited `1`; final unlocked capture saved all nine and exited `0` | Passed |
| Layout review | Inspected all nine generated images | Instructions, route nodes, backup text, buttons, gameplay objects, and ending copy were visible without overlap | Passed |
| Colour-independent state | Inspected HUD and result visuals | Text plus rings, crosses, filled nodes, backup count, and status copy accompany colours | Passed |
| Web icon branding | Exported with the project relay icon | Browser icon files show the relay antenna instead of default Godot artwork | Passed |
| Export packaging | Exported the Web release preset | Export succeeded; runtime-only package was about 175 KB plus Godot Web runtime | Passed |

The display server warned that the Intel HD Graphics 4000 driver has low-quality OpenGL 3.3 support and automatically selected ANGLE. The run completed successfully, so this is recorded as an environment warning rather than a game failure.

## Local Chrome Web check

The exported build was served from `127.0.0.1` and opened in the connected Chrome browser.

| Check | Observed result | Status |
| --- | --- | --- |
| Page load | Title was `Rapid Relay: Signal Shift`; the Godot canvas rendered the current menu | Passed |
| Browser console | No warning or error was returned after load and interaction checks | Passed |
| Menu keyboard start | Enter activated the focused Start button and opened Pulse Press | Passed |
| Web font check | A Unicode arrow first rendered as a missing-glyph square | Failed, then fixed |
| Glyph regression | Replaced the arrow with ASCII `>`; re-exported and reloaded | Passed |
| Failure path input | Late/incorrect inputs visibly removed backup channels and advanced the route | Passed |
| Complete browser win route | Background canvas timing was throttled during automated waits, so reaction timing was not reliable | Not claimed |

## Public verification

The source commits were pushed to the existing public repository and the Web export was pushed to its existing `gh-pages` branch on 2026-08-24.

| Check | Observed result | Status |
| --- | --- | --- |
| Public build bytes | Live `index.pck` was 303,468 bytes and its SHA-256 matched the final local export | Passed |
| Uncached live load | Chrome showed the project-specific neon boot screen and then the five-test KITE menu | Passed |
| Public keyboard start | Enter opened `STAGE 01 / 05` and rendered Pulse Press | Passed |
| Game-origin console | No warning or error came from the GitHub Pages game origin | Passed |

One unrelated warning came from a locally installed Chrome extension, not from the game URL. A complete public win route is still not claimed.

## Still requires a human play pass

- Complete one full win route in a visible browser or Godot window.
- Complete one deliberate three-loss route.
- Confirm Core Dock drag feel with a real pointer and touch device if available.
- Confirm the scaled 960×540 canvas is comfortable on a real phone.

## Evidence boundaries

- The automated suites verify game logic, state transitions, and reset behavior.
- Runtime screenshots verify rendered layout at selected moments, not a complete human playthrough.
- Local Chrome checks verify the exported canvas loads and accepts input, not that every timing challenge was manually completed.
- No coding hours, tracker time, Stardance approval, mission eligibility, or reward is inferred from these tests.
