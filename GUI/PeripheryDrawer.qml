import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Drawer {
    id: peripheryRoot

    property var handle: periphHandle

    Rectangle {
        id: argonView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: "grey"
        radius: 7
        border.color: "orange"

        Text {
            id: arLabel
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("РАСХОД АРГОНА")
            font.pixelSize: 24
            font.bold: true
            color: "#2c2c2c"
        }
    }
}
