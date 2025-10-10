import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: pedalRoot

    signal pedalMenuRequest()
    property int pedalStateIdx

    Connections {
        target: pedalRoot
        function onPedalStateIdxChanged() {
            if (pedalStateIdx == 0) {
                pedalRoot.state = "empty"
            } else if (pedalStateIdx == 1) {
                pedalRoot.state = "single"
            } else if (pedalStateIdx == 2) {
                pedalRoot.state = "double"
            } else if (pedalStateIdx == 3) {
                pedalRoot.state = "handleBi"
            }
        }
    }
    color: "transparent"

    state: "empty"
    states: [
        State {
            name: "empty"
            PropertyChanges { target: singleRect; opacity: 0 }
            PropertyChanges { target: doubleRect; opacity: 0 }
            PropertyChanges { target: biHandle; opacity: 0 }
        },
        State {
            name: "single"
            PropertyChanges { target: singleRect; opacity: 1 }
            PropertyChanges { target: doubleRect; opacity: 0 }
            PropertyChanges { target: biHandle; opacity: 0 }
        },
        State {
            name: "double"
            PropertyChanges { target: singleRect; opacity: 0 }
            PropertyChanges { target: doubleRect; opacity: 1 }
            PropertyChanges { target: biHandle; opacity: 0 }
        },
        State {
            name: "handleBi"
            PropertyChanges { target: singleRect; opacity: 0 }
            PropertyChanges { target: doubleRect; opacity: 0 }
            PropertyChanges { target: biHandle; opacity: 1 }
        }
    ]
    transitions: [
        Transition {
            from: "*"; to: "*"
            NumberAnimation { properties: "opacity"; duration: 500; easing.type: Easing.InOutQuad }
        }
    ]

//    Label {
//        id: name
//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//            topMargin: 1
//            rightMargin: 10
//        }
//        horizontalAlignment: Qt.AlignHCenter
//        text: qsTr("ПЕДАЛЬ")
//        color: "white"
//        font.pixelSize: 16
//        font.bold: true
//    }
    Rectangle {
        id: shell
        width: 70
        height: 70
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        radius: 10
        border.color: "orange"

        color: "grey"

        Rectangle {
            id: singleRect
            anchors {
                fill: parent
            }
            color: "transparent"
            Rectangle {
                color: "blue"
                height: parent.height * .8
                width: 0.3 * parent.width
                anchors.centerIn: parent
                radius: 6
                border.color: "white"
            }
        }
        Rectangle {
            id: doubleRect
            anchors {
                fill: parent
            }
            color: "transparent"
            Rectangle {
                color: "blue"
                height: parent.height * .8
                width: 0.3 * parent.width
                radius: 6
                border.color: "white"
                anchors {
                    left: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    leftMargin: 6
                }
            }
            Rectangle {
                color: "yellow"
                height: parent.height *.8
                width: 0.3 * parent.width
                radius: 6
                border.color: "white"
                anchors {
                    right: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    rightMargin: 6
                }
            }
        }
        Rectangle {
            id: biHandle
            anchors {
                margins: 10
            }
            color: "transparent"
            Rectangle {
                width: parent.height *.8
                height: width
                radius: width/2
                color: "purple"
                border {
                    color: "white"
                    width:2
                }
                anchors.centerIn: parent
            }
        }
    }

    MouseArea {
        id: pressHandle
        anchors.fill: parent
        z: 1  // Локальный z-order внутри педали
        onClicked: {
            pedalRoot.pedalMenuRequest()
        }
    }

}
