import QtQuick 2.15
import StratifyLabs.UI 2.0

Item {
    id: touchTestRoot
    signal returnButtonPressed()

    property real pressX: 0
    property real pressY: 0
    property double pressTimestampMs: 0
    property bool pressedNow: false
    property bool watchdogTripped: false
    property real circleSize: 70
    property string statusText: qsTr("Коснитесь экрана для проверки")
    property string pressedText: ""
    property int pressedCount: 0
    property int releasedCount: 0
    property int stuckCount: 0
    property int moveCount: 0
    property var recentDelaysMs: []
    property int avgDelayMs: 0
    property string eventLogText: ""
    readonly property int maxLogLines: 20
    readonly property int watchdogThresholdMs: 2000

    function appendLog(message) {
        var now = new Date()
        var hh = ("0" + now.getHours()).slice(-2)
        var mm = ("0" + now.getMinutes()).slice(-2)
        var ss = ("0" + now.getSeconds()).slice(-2)
        var line = hh + ":" + mm + ":" + ss + "  " + message

        var lines = eventLogText.length > 0 ? eventLogText.split("\n") : []
        lines.push(line)
        if (lines.length > maxLogLines) {
            lines = lines.slice(lines.length - maxLogLines)
        }
        eventLogText = lines.join("\n")
    }

    function trackDelay(elapsedMs) {
        var rounded = Math.max(0, Math.round(elapsedMs))
        var values = recentDelaysMs.slice(0)
        values.push(rounded)
        if (values.length > 20) {
            values = values.slice(values.length - 20)
        }
        recentDelaysMs = values

        var sum = 0
        for (var i = 0; i < values.length; i += 1) {
            sum += values[i]
        }
        avgDelayMs = values.length > 0 ? Math.round(sum / values.length) : 0
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    SLabel {
        id: infoLabel
        style: "label-primary lg"
        text: touchTestRoot.statusText
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 18
        }
        z: 3
    }

    SLabel {
        id: pressedLabel
        style: "label-primary lg"
        text: touchTestRoot.pressedText
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 20
            topMargin: 18
        }
        z: 3
    }

    Rectangle {
        id: diagnosticsPanel
        width: parent.width - 40
        height: 50
        radius: 8
        color: "#1A1A1A"
        border.color: "#4A4A4A"
        border.width: 1
        anchors {
            top: infoLabel.bottom
            topMargin: 12
            horizontalCenter: parent.horizontalCenter
        }
        z: 3

        Text {
            anchors {
                fill: parent
                margins: 10
            }
            color: "#E6E6E6"
            font.pixelSize: 20
            text: qsTr("нажато: %1   отпущено: %2   задержка: %3   движение: %4   залипание: %5\nПоследние события:\n%6")
                    .arg(touchTestRoot.pressedCount)
                    .arg(touchTestRoot.releasedCount)
                    .arg(qsTr("%1 мс (20)").arg(touchTestRoot.avgDelayMs))
                    .arg(touchTestRoot.moveCount)
                    .arg(touchTestRoot.stuckCount)
                    .arg(touchTestRoot.eventLogText.length > 0 ? touchTestRoot.eventLogText : qsTr("—"))
        }
    }

    Rectangle {
        id: touchMarker
        width: touchTestRoot.circleSize
        height: touchTestRoot.circleSize
        radius: width / 2
        color: "#40A5FF"
        border.color: "#BEE2FF"
        border.width: 3
        x: touchTestRoot.pressX - width / 2
        y: touchTestRoot.pressY - height / 2
        visible: touchTestRoot.pressedNow
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        hoverEnabled: false
        preventStealing: true
        // Кнопка «Назад» (z: 4) и подписи (z: 3) остаются кликабельными
        propagateComposedEvents: false

        onPressed: function(mouse) {
            mouse.accepted = true
            touchTestRoot.pressX = mouse.x
            touchTestRoot.pressY = mouse.y
            touchTestRoot.pressTimestampMs = Date.now()
            touchTestRoot.pressedNow = true
            touchTestRoot.watchdogTripped = false
            touchTestRoot.pressedCount += 1
            touchTestRoot.pressedText = qsTr("Нажатие: (%1, %2)")
                    .arg(Math.round(mouse.x))
                    .arg(Math.round(mouse.y))
            touchTestRoot.appendLog(qsTr("нажатие (%1, %2)")
                                    .arg(Math.round(mouse.x))
                                    .arg(Math.round(mouse.y)))
        }

        onPositionChanged: function(mouse) {
            if (touchTestRoot.pressedNow) {
                touchTestRoot.pressX = mouse.x
                touchTestRoot.pressY = mouse.y
                touchTestRoot.moveCount += 1
            }
        }

        onReleased: function(mouse) {
            var elapsedMs = Date.now() - touchTestRoot.pressTimestampMs
            var elapsedRoundedMs = Math.max(0, Math.round(elapsedMs))
            touchTestRoot.pressX = mouse.x
            touchTestRoot.pressY = mouse.y
            touchTestRoot.pressedNow = false
            touchTestRoot.releasedCount += 1
            touchTestRoot.trackDelay(elapsedRoundedMs)
            if (touchTestRoot.watchdogTripped
                    && elapsedMs > touchTestRoot.watchdogThresholdMs) {
                touchTestRoot.statusText = qsTr("Поздний release после сброса: %1 мс")
                        .arg(elapsedRoundedMs)
                touchTestRoot.appendLog(qsTr("поздний release (%1, %2), %3 ms")
                                        .arg(Math.round(mouse.x))
                                        .arg(Math.round(mouse.y))
                                        .arg(elapsedRoundedMs))
            } else {
                touchTestRoot.statusText = qsTr("Время удержания: %1 мс")
                        .arg(elapsedRoundedMs)
                touchTestRoot.appendLog(qsTr("отпущено (%1, %2), задержка %3 мс")
                                        .arg(Math.round(mouse.x))
                                        .arg(Math.round(mouse.y))
                                        .arg(elapsedRoundedMs))
            }
            touchTestRoot.watchdogTripped = false
        }

        onCanceled: {
            touchTestRoot.pressedNow = false
            touchTestRoot.watchdogTripped = false
            touchTestRoot.statusText = qsTr("Событие отменено системой")
            touchTestRoot.appendLog(qsTr("отменено системой"))
        }
    }

    Timer {
        id: stuckWatchdog
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            if (touchTestRoot.pressedNow) {
                var elapsedMs = Date.now() - touchTestRoot.pressTimestampMs
                if (elapsedMs > touchTestRoot.watchdogThresholdMs) {
                    touchTestRoot.stuckCount += 1
                    touchTestRoot.pressedNow = false
                    touchTestRoot.watchdogTripped = true
                    touchTestRoot.statusText = qsTr("Подозрение на зависание: %1 мс").arg(Math.round(elapsedMs))
                    touchTestRoot.appendLog(qsTr("сброс по таймеру %1 ms").arg(Math.round(elapsedMs)))
                }
            }
        }
    }

    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        z: 10
        onPressed: touchTestRoot.returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
    }
}
