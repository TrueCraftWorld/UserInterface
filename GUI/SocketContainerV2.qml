import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: socketContainer

    signal progAddRequest(int type)
    property var innerModel
    color: "gray"
    
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 0
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        spacing: 10
        Rectangle {
            id: progPage
            height: 30
            Layout.fillWidth: true
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                Item {
                    Layout.fillWidth: true
                }
                Repeater {
                    model: theModel.subProgCount
                    delegate: Rectangle {
                        height: 27
                        width: 40
                        color: index === theModel.subProgIdx ? "white" : "black"
                        border.color: "white"
                        border.width: 1
                        radius: 6
                        Text {
                            id: name
                            text: index + 1
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            anchors.fill: parent
                            color: index === theModel.subProgIdx ? "black" : "white"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: theModel.subProgIdx = index
                        }
                    }
                }
                Rectangle {
                    id: progAddSign
                    height: 27
                    width: 40
                    color: "black"
                    border.color: "white"
                    border.width: 1
                    radius: 6
                    visible: theModel.subProgCount < 5 ? true : false

                    Text {
                        text: "+"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        anchors.fill: parent
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: progSelector.open()
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    id: progDeleteSign
                    height: 27
                    width: 40*5
                    color: "black"
                    border.color: "red"
                    border.width: 1
                    radius: 6
                    visible: theModel.subProgCount < 5 ? true : false

                    Text {
                        text: qsTr("удалить")
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        anchors.fill: parent
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: recomHandle.removeSubProg()
                    }
                }
            }
        }
        SocketRepeater {
            id: repeat
            model: innerModel
            containerMargins: layout.anchors.margins
            containerHeight: layout.height - layout.spacing - progPage.height
            usedSpacing: layout.spacing
        }
        Item {
            Layout.fillHeight: true
        }
    }
    ProgAdditionPop {
        id: progSelector
        width: socketContainer.width
        height: 200
        anchors.centerIn: parent
        y: 0
        // y: - socketContainer.height/2
    }
    InstrumEditor {
        id: instrDialog
    }
    ModeEditor {
        id: modeDialog
    }

    Connections {
        target: progSelector
        function onTypeChosen (addType) {
            socketContainer.progAddRequest(addType)
        }
    }
    Connections {
        target: repeat
        function onInstrumDialogRequest(soc, mod, iscoag) {
            instrDialog.socId = soc
            instrDialog.modeIndex = mod
            instrDialog.isCoag = iscoag
            instrDialog.open()
        }
        function onModeDialogRequest(soc, mod, iscoag) {
            modeDialog.socId = soc
            modeDialog.modeIndex = mod
            modeDialog.isCoag = iscoag
            modeDialog.open()
        }
    }
}

