import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtQuick.Layouts 1.15
import StratifyLabs.UI 2.0

Popup {
    // property alias pedTitle : title.text
    property var shownPedalsArray: []
    property int selectedPed
    signal pedSelected(int index)

    id: pedalSelectRoot

    function calcDimensions() {
        var maxHeight = pedalSelectRoot.height * .7
        var maxWidth = ((pedalSelectRoot.width * .9)
                        /  (pedalSelectRoot.shownPedalsArray.length + 1))
                        // - (1.5 * layoutRow.spacing)
        return (maxHeight > maxWidth) ? maxWidth : maxHeight
    }
    function calcSpacing() {
        return ((pedalSelectRoot.width
                - (layoutRow.elementSize * (pedalSelectRoot.shownPedalsArray.length + 1)))
                / pedalSelectRoot.shownPedalsArray.length ) * .5
    }


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
        layoutRow.elementSize = calcDimensions()
        layoutRow.spacing = calcSpacing()
    }

    Row {
        id: layoutRow
        property int elementSize
        spacing: 40
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            centerIn: parent
        }
        Rectangle {
            id: emptyPed
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 0 ? "cyan" : "transparent"
            radius: 8

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
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 1 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "blue"
                border {
                    width: 1
                    color: "white"
                }
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
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 2 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "yellow"
                border {
                    width: 1
                    color: "black"
                }
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: parent.width * 0.13
                }
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "blue"
                border {
                    width: 1
                    color: "white"
                }
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: parent.width * 0.13
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(2)
            }
        }
        Rectangle {
            id: biHandle
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 3 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .65
                height: parent.height * .65
                radius: width/2
                color: "purple"
                border {
                    width: 2
                    color: "white"
                }
                anchors.centerIn: parent;
            }

            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(3)
            }
        }
        Rectangle {
            id: monoHandle
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 4 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .42
                height: parent.height * .42
                radius: width/2
                color: "yellow"
                border {
                    width: 2
                    color: "black"
                }
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: parent.width * .085
                }
            }
            Rectangle {
                width: parent.width * .42
                height: parent.height * .42
                radius: width/2
                color: "blue"
                border {
                    width: 2
                    color: "white"
                }
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: parent.width * .085
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pedalSelectRoot.pedSelected(4)
            }
        }
    }
}
