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
    property var modeEditor: Editor

    onOpened: {
        modeEditor.initialize(socName, modeName)
        paramEditorLoader.active = true
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
                sourceComponent: SocketEditor {}
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: "Cancel"
                onClicked: {
                    modeEditor.rollBack()
                    root.close()
                }
            }

            Button {
                text: "Apply"
                enabled: modeEditor.hasChanges
                onClicked: {
                    modeEditor.commitChanges()
                    root.close()
                }
            }
        }
    }
}
