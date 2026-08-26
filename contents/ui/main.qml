import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 32
    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 28

    property var rollHistory: []
    property string selectedDice: "d20"
    property int diceCount: 1
    property var lastRoll: null
    property bool isCritical: false
    property string criticalMessage: ""
    property bool isRolling: false
    property int displayNumber: 20

    property var diceTypes: ["d4", "d6", "d8", "d10", "d12", "d20", "d100"]
    property var diceSides: ({
        "d4": 4, "d6": 6, "d8": 8, "d10": 10,
        "d12": 12, "d20": 20, "d100": 100
    })

    signal rollStarted()

    function startRoll() {
        root.isRolling = true
        root.isCritical = false
        root.criticalMessage = ""
        root.rollStarted()
        rollTimer.restart()
    }

    Timer {
        id: rollTimer
        interval: 700; repeat: false
        onTriggered: {
            var sides = root.diceSides[root.selectedDice]
            var rolls = []
            var total = 0
            for (var i = 0; i < root.diceCount; i++) {
                var r = Math.floor(Math.random() * sides) + 1
                rolls.push(r); total += r
            }
            var critical = false; var critMsg = ""
            if (root.selectedDice === "d20" && root.diceCount === 1) {
                if (rolls[0] === 20) { critical = true; critMsg = "You're a Natural" }
                else if (rolls[0] === 1)  { critical = true; critMsg = "You're Fucked" }
            }
            root.lastRoll = { notation: root.diceCount + root.selectedDice, rolls: rolls, total: total }
            root.isCritical = critical
            root.criticalMessage = critMsg
            root.displayNumber = total
            root.isRolling = false
            root.rollHistory.unshift(root.lastRoll)
            if (root.rollHistory.length > 20) root.rollHistory.pop()
            root.rollHistory = root.rollHistory
        }
    }

    fullRepresentation: Controls.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Text {
                text: "🎲 Dice Roller"
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.6
                font.bold: true
                color: Kirigami.Theme.textColor
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
            }

            // Dice face — all animation lives here where diceVisual is in scope
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 7

                Rectangle {
                    id: diceVisual
                    width: Kirigami.Units.gridUnit * 5
                    height: Kirigami.Units.gridUnit * 5
                    anchors.centerIn: parent
                    radius: 12
                    color: root.isCritical && root.criticalMessage === "You're a Natural" ? "#2e7d32"
                         : root.isCritical && root.criticalMessage === "You're Fucked"    ? "#c62828"
                         : Kirigami.Theme.highlightColor
                    border.color: Qt.lighter(color, 1.5)
                    border.width: 3
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        id: diceValueText
                        anchors.centerIn: parent
                        text: root.displayNumber
                        font.pixelSize: Kirigami.Units.gridUnit * 2
                        font.bold: true
                        color: "white"
                    }
                }

                // Animations target diceVisual directly — same scope
                NumberAnimation {
                    id: spinAnim
                    target: diceVisual
                    property: "rotation"
                    from: 0; to: 360
                    duration: 700
                    easing.type: Easing.InOutCubic
                    running: false
                }

                SequentialAnimation {
                    id: bounceAnim
                    running: false
                    NumberAnimation { target: diceVisual; property: "scale"; from: 1.0; to: 0.6;  duration: 150; easing.type: Easing.InQuad }
                    NumberAnimation { target: diceVisual; property: "scale"; from: 0.6; to: 1.2;  duration: 350; easing.type: Easing.OutBack }
                    NumberAnimation { target: diceVisual; property: "scale"; from: 1.2; to: 1.0;  duration: 150; easing.type: Easing.InOutQuad }
                }

                // Number cycling timer — in same scope as diceValueText
                Timer {
                    id: cycleTimer
                    interval: 60; repeat: true; running: root.isRolling
                    onTriggered: root.displayNumber = Math.floor(Math.random() * root.diceSides[root.selectedDice]) + 1
                }

                // Listen for rollStarted signal to trigger animations
                Connections {
                    target: root
                    function onRollStarted() {
                        spinAnim.restart()
                        bounceAnim.restart()
                    }
                }

                // Critical pulse text
                Text {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.isCritical && !root.isRolling
                    text: root.criticalMessage
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                    font.bold: true
                    color: root.criticalMessage === "You're a Natural" ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    SequentialAnimation on opacity {
                        running: root.isCritical && !root.isRolling
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.2; duration: 500 }
                        NumberAnimation { from: 0.2; to: 1.0; duration: 500 }
                    }
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
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
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
                            root.displayNumber = root.diceSides[modelData]
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                            border.color: Kirigami.Theme.textColor
                            border.width: parent.checked ? 2 : 1
                            radius: 4
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
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
                    color: rollButton.hovered && !root.isRolling ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
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

            Text { text: "History:"; font.bold: true; color: Kirigami.Theme.textColor }

            Repeater {
                model: root.rollHistory
                Rectangle {
                    width: parent ? parent.width : 0
                    height: Kirigami.Units.gridUnit * 2
                    color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                    border.color: Kirigami.Theme.textColor; border.width: 1
                    RowLayout {
                        anchors.fill: parent; anchors.margins: Kirigami.Units.smallSpacing
                        Text { text: modelData.notation + ": " + modelData.total; font.bold: true; color: Kirigami.Theme.textColor; font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9 }
                        Item { Layout.fillWidth: true }
                        Text { text: "[" + modelData.rolls.join(", ") + "]"; font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.8; color: Kirigami.Theme.disabledTextColor }
                    }
                }
            }

            Controls.Button {
                text: "Clear History"
                Layout.fillWidth: true; flat: true
                visible: root.rollHistory.length > 0
                onClicked: root.rollHistory = []
                Layout.bottomMargin: Kirigami.Units.largeSpacing
            }
        }
    }
}
