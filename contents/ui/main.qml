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

            // Dice animation display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 7
                color: "transparent"

                Rectangle {
                    id: diceVisual
                    width: Kirigami.Units.gridUnit * 6
                    height: Kirigami.Units.gridUnit * 6
                    anchors.centerIn: parent
                    radius: 12
                    color: root.isCritical && root.criticalMessage === "You're a Natural"
                           ? Qt.rgba(0.2, 0.7, 0.2, 0.85)
                           : root.isCritical && root.criticalMessage === "You're Fucked"
                           ? Qt.rgba(0.8, 0.2, 0.2, 0.85)
                           : Kirigami.Theme.highlightColor

                    border.color: Qt.lighter(color, 1.4)
                    border.width: 3

                    layer.enabled: true
                    layer.effect: null

                    // Shadow effect via extra rectangle
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        z: -1
                        radius: parent.radius + 4
                        color: Qt.rgba(0, 0, 0, 0.3)
                        anchors.verticalCenterOffset: 4
                    }

                    Text {
                        id: diceValueText
                        anchors.centerIn: parent
                        text: root.lastRoll ? root.lastRoll.total : root.selectedDice.toUpperCase()
                        font.pixelSize: Kirigami.Units.gridUnit * 2
                        font.bold: true
                        color: "white"
                    }

                    // Rotation animation
                    transform: [
                        Rotation {
                            id: diceRotationX
                            origin.x: diceVisual.width / 2
                            origin.y: diceVisual.height / 2
                            axis { x: 1; y: 0; z: 0 }
                            angle: 0
                        },
                        Rotation {
                            id: diceRotationZ
                            origin.x: diceVisual.width / 2
                            origin.y: diceVisual.height / 2
                            axis { x: 0; y: 0; z: 1 }
                            angle: 0
                        },
                        Scale {
                            id: diceScale
                            origin.x: diceVisual.width / 2
                            origin.y: diceVisual.height / 2
                            xScale: 1.0
                            yScale: 1.0
                        }
                    ]

                    // Roll spin animation
                    SequentialAnimation {
                        id: rollAnimation

                        ParallelAnimation {
                            NumberAnimation {
                                target: diceRotationZ
                                property: "angle"
                                from: 0; to: 720
                                duration: 600
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: diceRotationX
                                property: "angle"
                                from: 0; to: 360
                                duration: 600
                                easing.type: Easing.InOutQuad
                            }
                            SequentialAnimation {
                                NumberAnimation {
                                    target: diceScale
                                    properties: "xScale,yScale"
                                    from: 1.0; to: 0.6
                                    duration: 150
                                    easing.type: Easing.InQuad
                                }
                                NumberAnimation {
                                    target: diceScale
                                    properties: "xScale,yScale"
                                    from: 0.6; to: 1.2
                                    duration: 300
                                    easing.type: Easing.OutQuad
                                }
                                NumberAnimation {
                                    target: diceScale
                                    properties: "xScale,yScale"
                                    from: 1.2; to: 1.0
                                    duration: 150
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        // Bounce settle
                        SequentialAnimation {
                            NumberAnimation {
                                target: diceScale
                                properties: "xScale,yScale"
                                from: 1.0; to: 1.1
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: diceScale
                                properties: "xScale,yScale"
                                from: 1.1; to: 1.0
                                duration: 80
                                easing.type: Easing.InQuad
                            }
                        }

                        onFinished: {
                            root.isRolling = false
                            diceRotationZ.angle = 0
                            diceRotationX.angle = 0
                        }
                    }

                    // Number cycling timer during animation
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
                }

                // Critical flash overlay
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    opacity: root.isCritical ? 1 : 0

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.criticalMessage
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        font.bold: true
                        color: root.criticalMessage === "You're a Natural"
                               ? Kirigami.Theme.positiveTextColor
                               : Kirigami.Theme.negativeTextColor

                        SequentialAnimation on opacity {
                            running: root.isCritical && !root.isRolling
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                        }
                    }
                }
            }

            // Dice type selection
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
                            diceValueText.text = modelData.toUpperCase()
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
                    color: rollButton.hovered && !root.isRolling ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                    radius: 8
                    border.color: Kirigami.Theme.highlightColor
                    border.width: 2
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                onClicked: root.startRoll()
            }

            // Notation result bar
            Text {
                visible: root.lastRoll !== null && !root.isRolling
                text: root.lastRoll ? root.lastRoll.notation + "  →  [" + root.lastRoll.rolls.join(", ") + "]" : ""
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
                color: Kirigami.Theme.disabledTextColor
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Kirigami.Theme.textColor; opacity: 0.15 }

            Text {
                text: "History:"
                font.bold: true
                color: Kirigami.Theme.textColor
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
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
        rollAnimation.restart()
        rollTimer.start()
    }

    Timer {
        id: rollTimer
        interval: 550
        repeat: false
        onTriggered: root.finishRoll()
    }

    function finishRoll() {
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
            else if (rolls[0] === 1) { critical = true; critMsg = "You're Fucked" }
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
