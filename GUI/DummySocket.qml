import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot
    property string cutModeName
    property string coagModeName
    property int cutModePower
    property int coagModePower
    property int cutModeIndex
    property int coagModeIndex
    property int socketId
    property int cutInstrumId
    property int coagInstrumId
    // property alias cutInstrPath: cutInstrImage.source
    // property alias coagInstrPath: coagInstrImage.source
    property string cutInstrumName: qsTr("не выбран")
    property string coagInstrumName: qsTr("не выбран")

    signal cutEditDialogRequest()
    signal coagEditDialogRequest()

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
            font.pixelSize: 32
            font.bold: true
            color: "black"
            anchors {
                left: parent.left
                top: parent.top
                margins: 15
                topMargin: 40
            }
        }
        Label {
            id: cutPower
            text: cutModePower
            font.pixelSize: 45
            font.bold: true
            color: "black"
            anchors {
                left: parent.left
                top: cutMode.bottom
                margins: 15
            }
        }
        Label {
            id: cutInstrum
            text: cutInstrumName
            font.pixelSize: 14
            font.bold: true
            color: "black"
            anchors {
                top: cutPower.top
                left: cutPower.left
                margins: 15
                topMargin: 0
            }
        }
        Image {
            id: cutInstrImage
            // anchors.centerIn: parent
            asynchronous: true
            source: "image://instrums/" + (cutInstrumId)
            fillMode: Image.PreserveAspectFit
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: cutInstrum.bottom
            }
            // source: "image://instrums/" + root.instrImageName
        }
        MouseArea {
            anchors.fill: parent
            onClicked: socketRoot.cutEditDialogRequest()
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
            color: "white"
            anchors {
                top: parent.top
                right: parent.right
                margins: 15
            }
        }
        Label {
            id: coagPower
            text: coagModePower
            font.pixelSize: 45
            font.bold: true
            color: "white"
            anchors {
                top: coagMode.bottom
                right: parent.right
                margins: 15
            }
        }
        Label {
            id: coagInstrum
            text: coagInstrumName
            font.pixelSize: 14
            font.bold: true
            color: "white"
            anchors {
                top: coagPower.top
                right: coagPower.right
                margins: 15
                topMargin: 0
            }
        }
        Image {
            id: coagInstrImage
            // anchors.centerIn: parent
            asynchronous: true
            source: "image://instrums/" + ("Cut_" + coagInstrumId)
            fillMode: Image.PreserveAspectFit
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                top: coagInstrum.bottom
            }

            // source: "image://instrums/" + root.instrImageName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: socketRoot.coagEditDialogRequest()
        }
    }
    Rectangle {
        id: coagBorder
        color: "blue"
        width: 8
        height: coagMain.height
        anchors.left: coagMain.left
    }
    onCoagInstrumIdChanged: coagInstrImage.update()
    onCutInstrumIdChanged: cutInstrImage.update()
}
