import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    property alias pedTitle : title.text
    property var shownPedalsArray: []
    property int selectedPed
    signal pedSelected(int index)

    id: pedalSelectRoot

    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    modal: true
    focus: true

    onOpened: {
        singlePed.visible = false;
        doublePed.visible = false;
        biHandle.visible = false;
        monoHandle.visible = false;
        for (var idx = 0; idx < shownPedalsArray.length; ++idx) {
            if (shownPedalsArray[idx] == 1) {
                singlePed.visible = true;
            }
            if (shownPedalsArray[idx] == 2) {
                doublePed.visible = true;
            }
            if (shownPedalsArray[idx] == 3) {
                biHandle.visible = true;
            }
            if (shownPedalsArray[idx] == 4) {
                monoHandle.visible = true;
            }
        }
    }

    Label {
        id: title
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    Row {
        spacing: 10
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Rectangle {
            id: emptyPed
            width: 50
            height: 50
            color: pedalSelectRoot === 0 ? "cyan" : "transparent"
            border {
                width: 1
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(0)
            }
        }
        Rectangle {
            id: singlePed
            width: 50
            height: 50
            color: pedalSelectRoot === 1 ? "cyan" : "transparent"
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: 14
                height: 30
                radius: 6
                color: "blue"
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(1)
            }
        }
        Rectangle {
            id: doublePed
            width: 50
            height: 50
            color: pedalSelectRoot === 2 ? "cyan" : "transparent"
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: 14
                height: 30
                radius: 6
                color: "yellow"
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: 8
                }
            }
            Rectangle {
                width: 14
                height: 30
                radius: 6
                color: "blue"
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 8
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(2)
            }
        }
        Rectangle {
            id: biHandle
            width: 50
            height: 50
            color: pedalSelectRoot === 3 ? "cyan" : "transparent"
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: "purple"
                anchors.centerIn: parent;
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(3)
            }
        }
        Rectangle {
            id: monoHandle
            width: 50
            height: 50
            color: pedalSelectRoot === 4 ? "cyan" : "transparent"
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                color: "yellow"
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 6
                }
            }
            Rectangle {
                width: 18
                height: 18
                radius: 9
                color: "blue"
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: 6
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(4)
            }
        }
    }
}
