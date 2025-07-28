import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: root
    modal: true
    parent: Overlay.overlay
    width: Math.min(500, parent.width * 0.9)
    height: Math.min(400, parent.height * 0.8)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property string socName: ""
    property string modeName: ""
    property int socId: -1
    property int modeIndex: -1
    property bool isCoag: false
    property var modeEditor: Editor

    onOpened: {
        // modeEditor.initialize(socName, modeName)
        modeEditor.initialize(socId, modeIndex, isCoag)
        paramEditorLoader.active = true
    }

    function setPower(power) {
        modeEditor.updateParameter("currentpower", Number(power))
    }

    onClosed: paramEditorLoader.active = false

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Label {
            text: modeEditor.socketName
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ComboBox {
            id: modeSelector
            Layout.fillWidth: true
            model: modeEditor.modeNames
            currentIndex: modeEditor.currentModeIndex
            onActivated: modeEditor.currentModeIndex = index
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            Loader {
                id: paramEditorLoader
                width: parent.width
                active: false
                sourceComponent:
                    SocketEditor {
                        instrImageName: "" //тут нужно будет обращение к imageprovider
                }
            }
        }

        ComboBox {
            id: instrSelector
            Layout.fillWidth: true
            model: modeEditor.instrList
            currentIndex: modeEditor.currentInstrIndex
            onActivated: modeEditor.currentInstrIndex = index
        }


        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 10

            Button {
                id: lowPower
                visible: text != '0'
                text: modeEditor.lowPowerBound
                // background.c: "blue"
                // color: "blue"
                onClicked: {
                    root.setPower(text);
                }
            }

            Button {
                id: midPower
                text: modeEditor.midPowerBound
                visible: text != '0'
                // background: "lightgreen"
                onClicked: {
                    root.setPower(text);
                }
            }
            Button {
                id: maxPower
                text: modeEditor.highPowerBound
                visible: text != '0'
                // background: "lightred"
                onClicked: {
                    root.setPower(text);
                }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: qsTr("Отмена")
                onClicked: {
                    modeEditor.rollBack()
                    root.close()
                }
            }

            Button {
                text: qsTr("Принять")
                enabled: modeEditor.hasChanges
                onClicked: {
                    modeEditor.commitChanges()
                    root.close()
                }
            }
        }
    }
}
