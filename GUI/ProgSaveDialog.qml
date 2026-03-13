import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Dialog {
    readonly property string progName: progNameInput.text
    readonly property string scopeName: "Программы пользователя"
    
    title: qsTr("Название программы")
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true
    
    onOpened: {
        recomHandle.isRecomProgs = false
        progNameInput.text = container.currentProgName || "Программа 1"
        progNameInput.selectAll()
    }
    
    onClosed: {
        progNameInput.focus = false
        Qt.inputMethod.hide()
    }

    contentItem: Item {
        implicitWidth: 400
        implicitHeight: 150
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Введите название:")
                font.pixelSize: 22
                color: "black"
            }

            TextField {
                id: progNameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                text: "Программа 1"
                
                Component.onCompleted: {
                    forceActiveFocus()
                }
            }
        }
    }
}
