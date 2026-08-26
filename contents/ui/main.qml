import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 30
    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: Kirigami.Units.gridUnit * 22

    property var rollHistory: []
    property string selectedDice: "d20"
    property int diceCount: 1
    property var lastRoll: null
    property bool isCritical: false
    property string criticalMessage: ""
    property bool isRolling: false

    property var diceTypes: ["d4", "d6", "d8", "d10", "d12", "d20", "d100"]
    property var diceSides: ({
        "d4": 4, "d6": 6, "d8": 8, "d10": 10,
        "d12": 12, "d20": 20, "d100": 100
    })

    fullRepresentation: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Text {
                text: "🎲 Dice Roller"
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.8
                font.bold: true
                color: Kirigami.Theme.textColor
                Layout.alignment: Qt.AlignHCenter
            }

            // Animated dice face
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 7

                Rectangle {
                    id: diceVisual
                    width: Kirigami.Units.gridUnit * 6
                    height: Kirigami.Units.gridUnit * 6
                    anchors.centerIn: parent
                    radius: 14
                    color: root.isCritical && root.criticalMessage === "You're a Natural"
                           ? "#2e7d32"
                           : root.isCritical && root.criticalMessage === "You're Fucked"
                           ? "#c62828"
                           : Kirigami.Theme.highlightColor
                    border.color: Qt.lighter(color, 1.5)
                    border.width: 3

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        id: diceValueText
                        anchors.centerIn: parent
                        text: root.lastRoll ? root.lastRoll.total : root.selectedDice
                        font.pixelSize: Kirigami.Units.gridUnit * 2.2
                        font.bold: true
                        color: "white"
                    }

                    // Rotation animation
                    NumberAnimation on rotation {
                        id: spinAnim
                        from: 0; to: 360
                        duration: 600
                        easing.type: Easing.InOutCubic
                        running: false
                        loops: 1
                    }

                    // Scale bounce
                    SequentialAnimation on scale {
                        id: bounceAnim
                        running: false
                        NumberAnimation { from: 1.0; to: 0.7; duration: 150; easing.type: Easing.InQuad }
                        NumberAnimation { from: 0.7; to: 1.15; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { from: 1.15; to: 1.0; duration: 150; easing.type: Easing.InOutQuad }
                        onFinished: root.isRolling = false
                    }
                }

                // Critical message below dice
                Text {
                    anchors.top: diceVisual.bottom
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.criticalMessage
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                    font.bold: true
                    color: root.criticalMessage === "You're a Natural"
                           ? Kirigami.Theme.positiveTextColor
                           : Kirigami.Theme.negativeTextColor
                    visible: root.isCritical && !root.isRolling

                    SequentialAnimation on opacity {
                        running: root.isCritical && !root.isRolling
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 500 }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 500 }
                    }
                }
            }

            // Number cycling timer during roll
            Timer {
                id: cycleTimer
                interval: 60
                repeat: true
                running: root.isRolling
                onTriggered: {
                    var sides = root.diceSides[root.selectedDice]
                    diceValueText.text = Math.floor(Math.random() * sides) + 1
                }
            }

            // Dice type buttons
            GridLayout {
                columns: 4
                columnSpacing: Kirigami.Units.smallSpacing
                rowSpacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                Repeater {
                    model: root.diceTypes
                    Controls.Button {
                        text: modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
                        checked: root.selectedDice === modelData
                        checkable: true
                        flat: !checked
                        enabled: !root.isRolling
                        onClicked: {
                            root.selectedDice = modelData
                            root.diceCount = 1
                            diceCountSpinBox.value = 1
                            root.lastRoll = null
                            root.isCritical = false
                            root.criticalMessage = ""
                            diceValueText.text = modelData
                        }
                        background: Rectangle {
                            color: parent.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                            border.color: Kirigami.Theme.textColor
                            border.width: parent.checked ? 2 : 1
                            radius: 5
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing
                Text { text: "Count:"; color: Kirigami.Theme.textColor }
                Controls.SpinBox {
                    id: diceCountSpinBox
                    value: 1; from: 1; to: 10
                    enabled: !root.isRolling
                    onValueChanged: root.diceCount = value
                    Layout.fillWidth: true
                }
            }

            Controls.Button {
                id: rollButton
                text: root.isRolling ? "Rolling..." : "🎲 Roll " + root.diceCount + root.selectedDice
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                font.bold: true
                enabled: !root.isRolling
                background: Rectangle {
                    color: rollButton.hovered && !root.isRolling
                           ? Kirigami.Theme.highlightColor
                           : Kirigami.Theme.alternateBackgroundColor
                    radius: 8
                    border.color: Kirigami.Theme.highlightColor
                    border.width: 2
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                onClicked: root.startRoll()
            }

            Text {
                visible: root.lastRoll !== null && !root.isRolling
                text: root.lastRoll ? root.lastRoll.notation + "  →  [" + root.lastRoll.rolls.join(", ") + "]" : ""
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.85
                color: Kirigami.Theme.disabledTextColor
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Kirigami.Theme.textColor; opacity: 0.15 }

            Text {
                text: "History:"
                font.bold: true
                color: Kirigami.Theme.textColor
            }

            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView {
                    model: root.rollHistory
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: Kirigami.Units.gridUnit * 2.2
                        color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                        border.color: Kirigami.Theme.textColor
                        border.width: 1
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            Text {
                                text: modelData.notation + ": " + modelData.total
                                font.bold: true
                                color: Kirigami.Theme.textColor
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "[" + modelData.rolls.join(", ") + "]"
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.8
                                color: Kirigami.Theme.disabledTextColor
                            }
                        }
                    }
                }
            }

            Controls.Button {
                text: "Clear History"
                Layout.fillWidth: true
                flat: true
                onClicked: root.rollHistory = []
            }
        }
    }

    function startRoll() {
        root.isRolling = true
        root.isCritical = false
        root.criticalMessage = ""
        spinAnim.restart()
        bounceAnim.restart()
        rollTimer.restart()
    }

    Timer {
        id: rollTimer
        interval: 500
        repeat: false
        onTriggered: {
            var sides = root.diceSides[root.selectedDice]
            var rolls = []
            var total = 0
            for (var i = 0; i < root.diceCount; i++) {
                var roll = Math.floor(Math.random() * sides) + 1
                rolls.push(roll)
                total += roll
            }
            var critical = false
            var critMsg = ""
            if (root.selectedDice === "d20" && root.diceCount === 1) {
                if (rolls[0] === 20) { critical = true; critMsg = "You're a Natural" }
                else if (rolls[0] === 1)  { critical = true; critMsg = "You're Fucked" }
            }
            var result = { notation: root.diceCount + root.selectedDice, rolls: rolls, total: total }
            root.lastRoll = result
            root.isCritical = critical
            root.criticalMessage = critMsg
            diceValueText.text = total
            root.rollHistory.unshift(result)
            if (root.rollHistory.length > 20) root.rollHistory.pop()
            root.rollHistory = root.rollHistory
        }
    }
}
