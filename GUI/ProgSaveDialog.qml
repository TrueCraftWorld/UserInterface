import QtQuick 2.15
import QtQuick.Controls 2.15
import BackEnd 1.0

Dialog {

    property string progName: progNameInput.text
    title: qsTr("Укажите название программы")
    // footer: ""
    standardButtons: Dialog.Ok | Dialog.Cancel
    onOpened: {
        console.log("openSaveDia")
        recomHandle.isRecomProgs = false;
        scopeNameBox.model = recomHandle.scopeNameList
        // var model = recomHandle.scopeNameList;
        // for (var i = 0; i < model.length; ++i) {
        //     console.log(i, model[i])
        // }
    }
    contentItem: Rectangle {
        id: contRect
        // anchors.fill: parent
        // color: "transparent"
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
