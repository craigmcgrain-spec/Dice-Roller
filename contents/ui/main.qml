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
    Layout.minimumWidth: Kirigami.Units.gridUnit * 14
    Layout.minimumHeight: Kirigami.Units.gridUnit * 20

    ListModel { id: rollHistoryModel }
    property var rollHistory: []  // kept for Clear History visibility check
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

    // Returns array of {x,y} points for each die shape, normalised to a unit circle
    function dicePoints(type, cx, cy, r) {
        var pts = []
        if (type === "d4") {
            // Equilateral triangle pointing up
            for (var i = 0; i < 3; i++) {
                var a = (i * 120 - 90) * Math.PI / 180
                pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
            }
        } else if (type === "d6") {
            // Square rotated 45°
            for (var i = 0; i < 4; i++) {
                var a = (i * 90 - 45) * Math.PI / 180
                pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
            }
        } else if (type === "d8") {
            // Diamond (4-pointed star / elongated diamond)
            pts = [
                { x: cx,     y: cy - r },
                { x: cx + r * 0.65, y: cy },
                { x: cx,     y: cy + r },
                { x: cx - r * 0.65, y: cy }
            ]
        } else if (type === "d10") {
            // Kite / irregular pentagon (d10 looks like a squished diamond)
            pts = [
                { x: cx,           y: cy - r },
                { x: cx + r * 0.85, y: cy - r * 0.1 },
                { x: cx + r * 0.55, y: cy + r },
                { x: cx - r * 0.55, y: cy + r },
                { x: cx - r * 0.85, y: cy - r * 0.1 }
            ]
        } else if (type === "d12") {
            // Regular pentagon
            for (var i = 0; i < 5; i++) {
                var a = (i * 72 - 90) * Math.PI / 180
                pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
            }
        } else if (type === "d20") {
            // Regular hexagon
            for (var i = 0; i < 6; i++) {
                var a = (i * 60 - 90) * Math.PI / 180
                pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
            }
        } else {
            // d100 — octagon
            for (var i = 0; i < 8; i++) {
                var a = (i * 45 - 22.5) * Math.PI / 180
                pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
            }
        }
        return pts
    }

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
                else if (rolls[0] === 1) { critical = true; critMsg = "You're Fucked" }
            }
            root.lastRoll = { notation: root.diceCount + root.selectedDice, rolls: rolls, total: total }
            root.isCritical = critical
            root.criticalMessage = critMsg
            root.displayNumber = total
            root.isRolling = false
            rollHistoryModel.insert(0, {
                notation: root.diceCount + root.selectedDice,
                rollsText: "[" + rolls.join(", ") + "]",
                total: total
            })
            if (rollHistoryModel.count > 5) rollHistoryModel.remove(5)
            root.rollHistory = [1]  // trigger Clear History visibility
        }
    }

    fullRepresentation: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            // Title
            Text {
                text: "🎲 Dice Roller"
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                font.bold: true
                color: Kirigami.Theme.textColor
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: Kirigami.Units.smallSpacing
            }

            // Main body: left=controls, right=history
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.smallSpacing

                // ── LEFT COLUMN ──────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.smallSpacing

                    // Dice face — fills remaining vertical space
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: Kirigami.Units.gridUnit * 5

                        Item {
                            id: diceVisual
                            property real faceSize: Math.min(parent.width, parent.height) * 0.8
                            width: faceSize
                            height: faceSize
                            anchors.centerIn: parent

                            property color diceColor: root.isCritical && root.criticalMessage === "You're a Natural" ? "#2e7d32"
                                                    : root.isCritical && root.criticalMessage === "You're Fucked"    ? "#c62828"
                                                    : Kirigami.Theme.highlightColor

                            Behavior on diceColor { ColorAnimation { duration: 200 } }

                            Canvas {
                                id: diceCanvas
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    var cx = width / 2
                                    var cy = height / 2
                                    var r = Math.min(width, height) / 2 - 4
                                    var pts = root.dicePoints(root.selectedDice, cx, cy, r)
                                    ctx.beginPath()
                                    ctx.moveTo(pts[0].x, pts[0].y)
                                    for (var i = 1; i < pts.length; i++)
                                        ctx.lineTo(pts[i].x, pts[i].y)
                                    ctx.closePath()
                                    ctx.fillStyle = diceVisual.diceColor
                                    ctx.fill()
                                    ctx.strokeStyle = Qt.lighter(diceVisual.diceColor, 1.6).toString()
                                    ctx.lineWidth = 3
                                    ctx.stroke()
                                }
                                Connections {
                                    target: root
                                    function onSelectedDiceChanged()    { diceCanvas.requestPaint() }
                                    function onIsCriticalChanged()       { diceCanvas.requestPaint() }
                                    function onCriticalMessageChanged() { diceCanvas.requestPaint() }
                                }
                                Connections {
                                    target: diceVisual
                                    function onDiceColorChanged() { diceCanvas.requestPaint() }
                                }
                            }

                            Text {
                                id: diceValueText
                                anchors.centerIn: parent
                                text: root.displayNumber
                                font.pixelSize: diceVisual.width * 0.32
                                font.bold: true
                                color: "white"
                                style: Text.Outline
                                styleColor: Qt.rgba(0,0,0,0.4)
                            }
                        }

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

                        Timer {
                            id: cycleTimer
                            interval: 60; repeat: true; running: root.isRolling
                            onTriggered: root.displayNumber = Math.floor(Math.random() * root.diceSides[root.selectedDice]) + 1
                        }

                        Connections {
                            target: root
                            function onRollStarted() {
                                spinAnim.restart()
                                bounceAnim.restart()
                            }
                        }

                        // Critical pulse
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: root.isCritical && !root.isRolling
                            text: root.criticalMessage
                            font.pixelSize: Math.max(Kirigami.Theme.defaultFont.pixelSize, diceVisual.width * 0.12)
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
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
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
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }
                } // end left ColumnLayout

                // ── DIVIDER ──────────────────────────────────────────────
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: Kirigami.Theme.textColor
                    opacity: 0.2
                }

                // ── RIGHT COLUMN: History ────────────────────────────────
                ColumnLayout {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 3.5
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 3.5
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.smallSpacing

                    Text {
                        text: "Last 5 Rolls"
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Kirigami.Units.smallSpacing
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Kirigami.Theme.textColor; opacity: 0.3 }

                    Repeater {
                        id: historyRepeater
                        model: rollHistoryModel
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: Kirigami.Units.gridUnit * 2.5
                            color: index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor
                            border.color: Kirigami.Theme.textColor
                            border.width: 1
                            radius: 3
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.smallSpacing
                                spacing: 1

                                Text {
                                    text: model.notation + " = " + model.total
                                    font.bold: true
                                    color: "white"
                                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.rollsText
                                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.75
                                    color: Kirigami.Theme.disabledTextColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Controls.Button {
                        text: "Clear"
                        Layout.fillWidth: true
                        flat: true
                        visible: rollHistoryModel.count > 0
                        onClicked: { rollHistoryModel.clear(); root.rollHistory = [] }
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                } // end right ColumnLayout
            } // end RowLayout
        } // end outer ColumnLayout
    } // end fullRepresentation
} // end PlasmoidItem
