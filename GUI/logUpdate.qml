import QtQuick 2.15
import QtQuick.Layouts 1.15
import StratifyLabs.UI 2.0

Item {
    id: updateLogScreen

    signal returnButtonPressed()

    property var logLines: []

    function refreshLog() {
        if (typeof updateLog === "undefined" || !updateLog) {
            updateLogScreen.logLines = [qsTr("Журнал обновлений недоступен")]
            return
        }

        var lines = updateLog.readLogLines(2000)
        updateLogScreen.logLines = lines.length > 0 ? lines : [qsTr("Записей нет")]
        Qt.callLater(function() {
            if (logList.count > 0) {
                logList.positionViewAtEnd()
            }
        })
    }

    Component.onCompleted: refreshLog()

    Rectangle {
        anchors.fill: parent
        color: "darkslategray"
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: retButton.top
            margins: 20
        }
        spacing: 12

        SLabel {
            Layout.fillWidth: true
            style: "label-primary lg"
            text: qsTr("Лог обновлений")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#102828"
            radius: 8
            border.color: "#5f7f7f"
            border.width: 1

            ListView {
                id: logList
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                spacing: 8
                model: updateLogScreen.logLines

                onCountChanged: Qt.callLater(function() {
                    if (logList.count > 0) {
                        logList.positionViewAtEnd()
                    }
                })

                delegate: Text {
                    width: logList.width
                    text: modelData
                    color: "white"
                    font.pixelSize: 20
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onPressed: updateLogScreen.returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
    }
}
