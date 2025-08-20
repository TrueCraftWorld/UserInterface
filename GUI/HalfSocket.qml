import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: halfSocketRoot
    required property bool isCoag
    property string modeName
    property int modePower
    property int socketId
    property int instrumId
    property string instrumName: qsTr("не выбран")
    property bool collapsed

    signal modeEditDialogRequest()
    signal instrumEditDialogRequest()

    Rectangle {
        id: main
        color: isCoag ? "blue" : "yellow"
        radius: 8

        Label {
            id: mode
            text: modeName
            font.pixelSize: 32
            font.bold: true
            color: isCoag ? "white" : "black"
            anchors {
                left: parent.left
                top: parent.top
                margins: 15
                topMargin: 40
            }
            MouseArea {
                id: modeSelectButton
                anchors.fill: parent
                onClicked: halfSocketRoot.modeEditDialogRequest()
            }
        }
        Label {
            id: power
            text: modePower
            font.pixelSize: 45
            font.bold: true
            color: isCoag ? "white" : "black"
            anchors {
                left: parent.left
                top: mode.bottom
                margins: 15
            }
        }
        Label {
            id: instrum
            text: instrumName
            font.pixelSize: 14
            font.bold: true
            color: isCoag ? "white" : "black"
            anchors {
                top: parent.top
                right: isCoag ? undefined : parent.right
                left: isCoag ? parent.left : undefined
                margins: 15
                topMargin: 0
            }
        }
        Image {
            id: instrImage
            asynchronous: true
            source: "image://instrums/" + (isCoag ? ("Cut_" + (instrumId+1)) : (instrumId+1))
            fillMode: Image.PreserveAspectFit
            anchors {
                left: isCoag ? undefined : parent.left
                right: isCoag ? parent.right : undefined

                bottom: mode.top
                top: parent.top
            }
        }
        Rectangle {
            id: powerPlusButton
            anchors {
                right: parent.right
                bottom: parent.bottom
                left: powerSlider.right
            }

            Label {
                text: "+"
                anchors.fill: parent
            }
            MouseArea {
                anchors.fill: parent
            }
        }
        Rectangle {
            id: powerMinusButton
            anchors {
                left: parent.left
                right: powerSlider.left
                bottom: parent.bottom
            }
            Label {
                text: "+"
                anchors.fill: parent
            }
            MouseArea {
                anchors.fill: parent
            }
        }
        Slider {
            id: powerSlider
            value: modePower
            width: parent.width * 0.6
            horizontalCenter: parent.horizontalCenter
            verticalCenter: powerMinusButton.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: halfSocketRoot.cutEditDialogRequest()
        }
        states: [
            State {
                name: "collapsed"
                PropertyChanges { target: modeSelectButton; enabled: false }
                PropertyChanges { target: powerMinusButton; visible: false }
                PropertyChanges { target: powerPlusButton; visible: false }
                PropertyChanges { target: powerSlider; visible: false }
                AnchorChanges { target: power; anchors.horizontalCenter: parent.horizontalCenter}
                AnchorChanges { target: power; anchors.left: undefined}
                AnchorChanges { target: power; anchors.right: undefined}
                AnchorChanges { target: mode; anchors.horizontalCenter: parent.horizontalCenter}
                AnchorChanges { target: mode; anchors.left: undefined}
                AnchorChanges { target: mode; anchors.right: undefined}
            },
            State {
                name: "expanded"
                PropertyChanges { target: modeSelectButton; enabled: true }
                PropertyChanges { target: powerMinusButton; visible: true }
                PropertyChanges { target: powerPlusButton; visible: true }
                PropertyChanges { target: powerSlider; visible: true }
                AnchorChanges { target: power; anchors.horizontalCenter: undefined}
                AnchorChanges { target: power; anchors.left: isCoag ? parent.right : undefined}
                AnchorChanges { target: power; anchors.right: isCoag ? undefined : parent.left}
                AnchorChanges { target: mode; anchors.horizontalCenter: undefined}
                AnchorChanges { target: mode; anchors.right: isCoag ? parent.right : undefined}
                AnchorChanges { target: mode; anchors.left: isCoag ? undefined : parent.left}
            }
        ]
    }
}
