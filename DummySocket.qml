import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot
    property string cutModeName
    property string coagModeName
    property string cutModePower
    property string coagModePower

    Rectangle {
        id: cutMain
        color: "yellow"
        radius: 8

        anchors {
            left: socketRoot.left
            right: socketRoot.horizontalCenter
            top: socketRoot.top
            bottom: socketRoot.bottom
        }
        Label {
            id: cutMode
            text: cutModeName
            // height: parent.height * .6
            font.pixelSize: 32
            font.bold: true
            color: "black"
            anchors {
                left: parent.left
                // right: cutBorder.left
                top: parent.top
                margins: 15
                topMargin: 40
            }
        }
        Label {
            id: cutPower
            text: cutModePower
            // height: parent.height * .3
            font.pixelSize: 32
            font.bold: true
            color: "black"
            anchors {
                left: parent.left
                // right: cutBorder.left
                top: cutMode.bottom
                // bottom: parent.bottom
                margins: 15
            }
        }
    }
    Rectangle {
        id: cutBorder
        color: "yellow"
        width: 8
        height: cutMain.height
        anchors.right: cutMain.right
    }
    Rectangle {
        id: coagMain
        color: "blue"
        radius: 8

        anchors {
            left: socketRoot.horizontalCenter
            right: socketRoot.right
            top: socketRoot.top
            bottom: socketRoot.bottom
        }
        Label {
            id: coagMode
            text: coagModeName
            font.pixelSize: 32
            font.bold: true
            // height: parent.height * .6
            color: "white"
            anchors {
                top: parent.top
                // left: coagBorder.right
                right: parent.right
                margins: 15
                topMargin: 40
            }
        }
        Label {
            id: coagPower
            text: coagModePower
            // height: parent.height * .3
            font.pixelSize: 32
            font.bold: true
            color: "white"
            anchors {
                // bottom: parent.bottom
                top: coagMode.bottom
                // left: coagBorder.right
                right: parent.right
                margins: 15
            }
        }
    }
    Rectangle {
        id: coagBorder
        color: "blue"
        width: 8
        height: coagMain.height
        anchors.left: coagMain.left
    }
}
