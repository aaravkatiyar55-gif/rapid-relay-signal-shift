# Design notes

## The idea

Rapid Relay: Signal Shift takes place during the night shift at Relay Station Five. An ion storm has scattered the navigation signal of KITE, a small courier drone trying to reach Luma Bay. The player repairs five links in the route before all backup channels go dark.

This is an original setting. It does not use Nintendo characters, art, music, names, or UI.

## Game loop

1. Read the stage name and one short instruction.
2. Complete a quick keyboard, mouse, or touch challenge.
3. A success stabilizes the link without using a backup.
4. A failure uses one of three backup signal bars, then the route continues.
5. Losing the third backup opens Signal Lost.
6. Surviving all five stages opens Transmission Complete.

The backup-channel idea explains why a failed stage can be recovered. A player does not need a perfect run, but three failures end the transmission.

## Five relay repairs

- **Wake — Pulse Press:** press Space only after the lamp changes to GO.
- **Catch — Orb Catch:** click, tap, or keyboard-capture KITE's drifting carrier signal.
- **Tune — Wave Tuner:** use Left and Right to hold a tuning needle inside the stable band.
- **Route — Relay Route:** enter the visible four-arrow cable sequence before time runs out.
- **Dock — Core Dock:** drag the marked navigation core into the matching socket, or choose a socket with the keyboard.

## Visual direction

The game uses a small six-colour station palette: dark navy, indigo panel, warm off-white, cyan, lime, and coral. KITE is a diamond-shaped drone with a cyan lens and lime fins. The interface uses grid lines, circuit paths, route nodes, status words, and simple motion instead of copied arcade art.

Success and failure never rely on colour alone. They also use words, icons, route changes, and shape changes. There are no full-screen flashes.

## Endings

- **Transmission Complete:** all five route nodes light up and KITE reaches Luma Bay at dawn.
- **Signal Lost:** the route is broken, but KITE's last safe ping is still visible and the player can rebuild the route.

## Assistance note

These design notes, the code, and the visual assets in this practice build were produced with substantial Codex assistance. That fact must stay visible in the README and any project evidence.
