import QtQuick
import qs.Ui

// Lid-close stay awake, from this plugin's own service (LidAwakeService.qml).
BarIndicator {
  id: root

  readonly property var lidAwakeService: bar && bar.shell && typeof bar.shell.serviceFor === "function"
    ? bar.shell.serviceFor("m.indicators") : null

  active: lidAwakeService ? lidAwakeService.active : false
  activeText: "󰌢"
  inactiveText: "󰌢"
  activeTooltipText: "Allow suspend when lid closes"
  inactiveTooltipText: lidAwakeService
    ? (lidAwakeService.lastError || "Stay awake when lid is closed")
    : "Lid-close wake service unavailable"

  function toggle() {
    if (root.lidAwakeService) root.lidAwakeService.toggle()
  }

  onPressed: function() { root.toggle() }
}
