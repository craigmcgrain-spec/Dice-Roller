import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28
    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: Kirigami.Units.gridUnit * 20

    property var rollHistory: []
    property string selectedDice: "d20"
    property int diceCount: 1
    property var lastRoll: null
    property bool isCritical: false
    property string criticalMessage: ""

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
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                text: "🎲 Dice Roller"
                level: 2
                Layout.alignment: Qt.AlignHCenter
            }

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
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                        checked: root.selectedDice === modelData
                        checkable: true
                        flat: !checked
                        onClicked: {
                            root.selectedDice = modelData
                            root.diceCount = 1
                            diceCountSpinBox.value = 1
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

                Kirigami.Label {
                    text: "Count:"
                }

                Controls.SpinBox {
                    id: diceCountSpinBox
                    value: 1
                    from: 1
                    to: 10
                    onValueChanged: root.diceCount = value
                    Layout.fillWidth: true
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            Controls.Button {
                id: rollButton
                text: "🎲 Roll Dice"
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                font.bold: true
                background: Rectangle {
                    color: rollButton.hovered ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                    radius: 8
                    border.color: Kirigami.Theme.highlightColor
                    border.width: 2
                }
                onClicked: root.rollDice()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 6
                color: {
                    if (root.isCritical && root.criticalMessage === "You're a Natural") return Qt.rgba(0.2, 0.7, 0.2, 0.3)
                    if (root.isCritical && root.criticalMessage === "You're Fucked") return Qt.rgba(0.8, 0.2, 0.2, 0.3)
                    return Kirigami.Theme.backgroundColor
                }
                border.color: {
                    if (root.isCritical && root.criticalMessage === "You're a Natural") return Kirigami.Theme.positiveTextColor
                    if (root.isCritical && root.criticalMessage === "You're Fucked") return Kirigami.Theme.negativeTextColor
                    return Kirigami.Theme.textColor
                }
                border.width: 2
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Label {
                        text: root.lastRoll ? "Total: " + root.lastRoll.total : "Roll to see results"
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 2.5
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Kirigami.Label {
                        text: root.lastRoll ? root.lastRoll.notation : ""
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
                        opacity: 0.7
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Kirigami.Label {
                        text: root.lastRoll ? "[" + root.lastRoll.rolls.join(", ") + "]" : ""
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Kirigami.Label {
                        text: root.criticalMessage
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
                        font.bold: true
                        color: {
                            if (root.criticalMessage === "You're a Natural") return Kirigami.Theme.positiveTextColor
                            if (root.criticalMessage === "You're Fucked") return Kirigami.Theme.negativeTextColor
                            return "transparent"
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Kirigami.Label {
                text: "History:"
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
            }

            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    model: root.rollHistory

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: Kirigami.Units.gridUnit * 2.5
                        color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                        border.color: Kirigami.Theme.textColor
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.smallSpacing
                            spacing: 2

                            Kirigami.Label {
                                text: modelData.notation + ": " + modelData.total
                                font.bold: true
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.95
                            }

                            Kirigami.Label {
                                text: "[" + modelData.rolls.join(", ") + "]"
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.8
                                opacity: 0.7
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

    function rollDice() {
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

        root.rollHistory.unshift(result)
        if (root.rollHistory.length > 20) root.rollHistory.pop()
        root.rollHistory = root.rollHistory
    }
}
