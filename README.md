# Lid Awake — Omarchy indicator

Keep your Omarchy laptop running with the lid closed, toggled from the bar's indicator drawer.

- One click on the 󰌢 indicator: the laptop stays awake when you close the lid
- The inhibitor runs in its own systemd user unit (`m-lid-awake.service`), not in the shell,
  so a shell restart or plugin hot-reload never drops it while the lid is closed
- On/off is the unit's enabled state, so it survives reboots
- Picks up changes made from a terminal (`systemctl --user ...`) within 15 seconds

## Files

| | |
|---|---|
| `LidAwakeService.qml` | shell service: toggles the unit, reports status, IPC |
| `indicators/LidAwake.qml` | bar indicator for an indicators widget |
| `systemd/m-lid-awake.service` | holds `systemd-inhibit --what=handle-lid-switch` |

## Install

It lives inside a clone of the stock indicators widget:

```bash
omarchy plugin clone omarchy.indicators      # gives you ~/.config/omarchy/plugins/<user>.indicators
git clone https://github.com/MarDevMint/omarchy-lid-awake /tmp/lid-awake
P=~/.config/omarchy/plugins/<user>.indicators
cp /tmp/lid-awake/LidAwakeService.qml "$P/"
cp /tmp/lid-awake/indicators/LidAwake.qml "$P/indicators/"
cp /tmp/lid-awake/systemd/m-lid-awake.service ~/.config/systemd/user/
systemctl --user daemon-reload
```

Then in the clone's `manifest.json`:

- add `"service"` to `kinds` and `"service": "LidAwakeService.qml"` to `entryPoints`
- add `{ "value": "LidAwake", "label": "Lid awake", "description": "Keep running with the lid closed" }` to the `items` options

and add `"LidAwake"` to `defaultIndicatorEntries` in the clone's `Indicators.qml`.
`LidAwake.qml` looks its service up as `serviceFor("m.indicators")`; change that id to your clone's id.

## IPC

```bash
omarchy-shell m.lid-awake status
omarchy-shell m.lid-awake toggle
omarchy-shell m.lid-awake enable
omarchy-shell m.lid-awake disable
```

## Credits

Adapted from the `io.github.tahler.lid-awake` Omarchy plugin (MIT, tahler).
This version moves the inhibitor into a systemd user unit and turns it into an indicator.

## License

MIT
