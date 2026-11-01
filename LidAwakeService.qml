// Lid-close stay awake, adapted from io.github.tahler.lid-awake (MIT, tahler).
// The inhibitor lives in the m-lid-awake.service systemd user unit, not in this
// process, so a shell reload or plugin hot-reload cannot drop it while the lid is
// closed. Enabled/disabled is the persisted state, so it also survives reboots.
import QtQuick
import Quickshell.Io

Item {
  id: root

  readonly property string unit: "m-lid-awake.service"

  property bool active: false
  property string lastError: ""
  property bool inhibitorRunning: false

  function setActive(value) {
    var next = !!value
    if (next === active) return next ? "enabled" : "disabled"

    active = next
    lastError = ""
    toggleProcess.command = ["/usr/bin/systemctl", "--user", next ? "enable" : "disable", "--now", root.unit]
    toggleProcess.running = true
    return next ? "enabled" : "disabled"
  }

  function toggle() {
    return setActive(!active)
  }

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
  }

  Component.onCompleted: refresh()

  Process {
    id: toggleProcess

    onExited: function(exitCode) {
      if (exitCode !== 0) root.lastError = "Could not change lid-close wake service"
      root.refresh()
    }
  }

  // Prints is-enabled then is-active, one per line.
  Process {
    id: statusProcess

    command: ["/bin/sh", "-c", "systemctl --user is-enabled \"$1\"; systemctl --user is-active \"$1\"", "sh", root.unit]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = text.trim().split("\n")
        root.active = lines[0] === "enabled"
        root.inhibitorRunning = lines[1] === "active"
        if (root.active && !root.inhibitorRunning && lines[1] !== "activating")
          root.lastError = "Lid-close wake inhibitor stopped"
      }
    }
  }

  // Picks up changes made outside the bar, e.g. systemctl from a terminal.
  Timer {
    interval: 15000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: "m.lid-awake"

    function status(): string {
      return JSON.stringify({
        active: root.active,
        inhibitorRunning: root.inhibitorRunning,
        error: root.lastError
      })
    }

    function enable(): string {
      return root.setActive(true)
    }

    function disable(): string {
      return root.setActive(false)
    }

    function toggle(): string {
      return root.toggle()
    }
  }
}
