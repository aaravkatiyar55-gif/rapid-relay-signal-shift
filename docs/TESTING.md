# Testing notes

Date: 2026-08-18
Environment: Windows, Godot 4.7.1 stable console build, headless local runs.

## Source inspection

- Checked the exact `rapid-relay-rebuild` workspace: six scenes, seven GDScript files, four local SVG assets, four 960×540 local screenshots, README, test scripts, and a 960×540 Compatibility-renderer Godot project were present.
- No source reference to the prohibited older project names was found.

## Automated and local runtime checks

| Test | Input or action | Observed result | Status |
| --- | --- | --- | --- |
| Project startup | Ran the project for five headless frames after changing SVG usage to imported textures | Godot started without console errors or SVG asset-load warnings | Passed |
| Desktop startup | Ran the project for five non-headless frames | Godot exited 0 using the Compatibility renderer; it selected ANGLE after a GPU-driver warning | Passed |
| Runtime screenshots | Ran the non-headless screenshot capture script | Saved four readable PNGs for menu, active game HUD, win, and death states | Passed |
| SVG export-safety check | Loaded the menu, HUD, and both ending scenes through the automated runs | Imported SVG textures loaded without the earlier raw-image export warnings | Passed |
| Web export preflight | Ran the Web preset through Godot’s headless exporter | Blocked: required Godot 4.7.1 Web export templates are not installed on this machine | Not completed |
| Pulse Press, early | Sent Space while the test was waiting | The result signal returned failure | Passed |
| Pulse Press, success | Advanced the test to GO, then sent Space | The result signal returned success | Passed |
| Pulse Press, late | Advanced beyond the allowed GO window | The result signal returned failure | Passed |
| Orb Catch, direct hit | Sent a click at the orb position | The result signal returned success | Passed |
| Orb Catch, wrong click | Sent a click outside the orb | The result signal returned failure | Passed |
| Orb Catch, timeout | Advanced the orb beyond its time limit | The result signal returned failure | Passed |
| Four-round route | Simulated four successful minigame result signals in the controller | Alternated Press, Catch, Press, Catch and opened `WinScene` | Passed |
| Loss route | Simulated three failed minigame result signals in the controller | Signal bars changed from 3 to 0 and opened `DeathScene` | Passed |
| End-scene focus | Checked the first button after each ending scene loaded | `Play Again` and `Try Again` each had focus | Passed |
| Menu start route | Loaded MainMenu and invoked its Start Relay action | Game scene opened with round 1 and three signal bars | Passed |
| Replay and menu routes | Loaded ending scenes and invoked Try Again, Play Again, and Back to Menu actions | Each route opened the expected fresh scene | Passed |

## Visible manual testing

Not completed. The local non-headless screenshot capture ran successfully, but Computer Use could not consistently capture the Godot application window. Tab/Enter, mouse playthrough, and visible 960×540 layout therefore remain unverified by a person playing the window.

## Deployed browser testing

Not completed. No public Web export or demo exists because the required Godot 4.7.1 Web export templates are not installed.

## Known limitations

- These are headless logic checks, not a replacement for a person playing the visible game window.
- Manual keyboard Tab/Enter interaction, mouse playthrough, and 960×540 visual layout still need a visible-window check. Computer Use could not capture the Godot window on this machine during this session.
- An attempted headless synthetic Tab/Enter test did not activate focused Godot buttons, so it is not counted as keyboard-interaction evidence.
- The local Web export needs Godot 4.7.1 Web templates before a playable web build can be generated.
- No public repository, public demo, tracker time, or Stardance submission evidence exists yet.
