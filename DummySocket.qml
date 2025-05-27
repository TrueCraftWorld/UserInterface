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
            height: parent.height * .6
            width: parent.width
            color: "black"
            anchors {
                top: parent.top
                margins: 15
            }
        }
        Label {
            id: cutPower
            text: cutModePower
            height: parent.height * .3
            width: parent.width
            color: "black"
            anchors {
                bottom: parent.bottom
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
        border {
            width: 2
            color: "green"
        }

        anchors {
            left: socketRoot.horizontalCenter
            right: socketRoot.right
            top: socketRoot.top
            bottom: socketRoot.bottom
        }
        Text {
            id: coagMode
            text: coagModeName
            height: parent.height * .6
            width: parent.width
            color: "white"
            anchors {
                top: parent.top
                margins: 15
            }
        }
        Text {
            id: coagPower
            text: coagModePower
            height: parent.height * .3
            width: parent.width
            color: "white"
            anchors {
                bottom: parent.bottom
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
