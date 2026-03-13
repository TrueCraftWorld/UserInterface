import QtQuick 2.15
import QtQuick.Controls 2.15
import BackEnd 1.0

Dialog {
    readonly property string progName: progNameInput.text
    readonly property string scopeName: scopeNameBox.currentText
    title: qsTr("Укажите название программы")
    standardButtons: Dialog.Ok | Dialog.Cancel
    onOpened: {
        console.log("openSaveDia")
        recomHandle.isRecomProgs = false;
        scopeNameBox.model = recomHandle.scopeNameList
        progNameInput.text = "Программа 1"
    }

    contentItem: Rectangle {
        id: contRect
        color: "transparent"

        ComboBox {
            id: scopeNameBox
            width: 0.7 * parent.width
            height: 40
            anchors.top : contRect.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            model: ["ha","hahaha", "bu", "bububu"]
        }

        TextInput {
            id: progNameInput
            width: 0.7 * parent.width
            height: 40
            anchors.top : scopeNameBox.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            color: "blue"
            text: "placeholder"
        }
    }
}
