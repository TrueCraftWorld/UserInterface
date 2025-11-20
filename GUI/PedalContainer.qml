import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pedContainer

    property var innerModel
    signal pedMenuRequest(int socketId)
    color: "#2c2c2c"

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        spacing: 10
        Rectangle {
            id: progPage
            height: 20
            Layout.fillWidth: true
            color: "transparent"
        }
        PedalRepeater {
            id: repeat
            model: innerModel
            containerMargins: layout.anchors.margins
            containerHeight: layout.height - layout.spacing - progPage.height
            usedSpacing: layout.spacing
            Layout.alignment: Qt.AlignHCenter
        }
        Item {
            Layout.fillHeight: true
        }
    }
    Connections {
        target: repeat
        function onPedalMenuRequest(socketId) {
            // console.log("container PedClick")
            pedContainer.pedMenuRequest(socketId)
        }
    }
}
