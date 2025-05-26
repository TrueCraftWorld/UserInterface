import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    property string cutModeName
    property string coagModeName
    property string cutModePower
    property string coagModePower

    Rectangle {
        id: cutMain
        color: "yellow"
        radius: 8

        anchors {
            left: parent.left
            right: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
        }
        Label {
            id: cutMode
            text: cutModeName
            height: parent.height * .6
            width: parent.width
            color: "black"
            anchors {
                top: parent.top
                margins: 10
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
                margins: 10
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
            left: parent.horizontalCenter
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        Text {
            id: coagMode
            text: coagModeName
            height: parent.height * .6
            width: parent.width
            color: "white"
            anchors {
                top: parent.top
                margins: 10
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
                margins: 10
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
