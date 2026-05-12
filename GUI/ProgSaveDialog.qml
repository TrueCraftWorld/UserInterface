import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import StratifyLabs.UI 2.0
import BackEnd 1.0

Dialog {
    signal overwriteConfirmationRequested()
    readonly property string progName: progNameInput.text
    readonly property string scopeName: contRect.isNewScope ? newScopeNameInput.text : scopeNameBox.currentText
    property string originalProgName: ""
    property bool currentProgramIsUser: false
    title: qsTr("Сохранение программы")
    modal: true
    onOpened: {
        console.log("openSaveDia")
        recomHandle.isRecomProgs = false;
        scopeNameBox.model = recomHandle.scopeNameList
        progNameInput.text = originalProgName
        Qt.callLater(function() {
            progNameInput.forceActiveFocus()
            Qt.inputMethod.show()
        })
    }

    contentItem: Rectangle {
        id: contRect
        property bool isNewScope: false
        color: "transparent"

        SPanel {
            id: scopePanel
            style: "panel-primary";
            heading: "Выберите папку или создайте новую";
            width: 0.9 * parent.width
            anchors.top : contRect.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            SRow {
                SDropdown {
                    id: scopeNameBox
                    span: 8
                    model: ["1","2", "3", "4"]
                    visible: !contRect.isNewScope
                }
                SInput {
                    id: newScopeNameInput
                    span: 8
                    placeholder: "Категория"
                    visible: contRect.isNewScope
                }

                SButton{
                    id: addScopeButton
                    span: 4
                    iconString: contRect.isNewScope ? Fa.Icon.chevron_left : Fa.Icon.plus_square;
                    onClicked: {
                        contRect.isNewScope = !contRect.isNewScope
                    }
                }
            }
        }

        SPanel {
            id: inputPanel
            heading: "Укажите название программы";
            width: 0.9 * parent.width
            anchors.top : scopePanel.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            SInput {
                id: progNameInput
                placeholder: "Название";
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * .9
            }
        }

    }

    footer: Rectangle {
        color: "transparent"
        implicitHeight: 108

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            spacing: 16

            DialogActionButton {
                Layout.preferredWidth: 180
                Layout.fillHeight: true
                text: qsTr("ОТМЕНА")
                onPressed: reject()
            }

            Item { Layout.fillWidth: true }

            DialogActionButton {
                Layout.preferredWidth: 180
                Layout.fillHeight: true
                text: qsTr("ПРИНЯТЬ")
                primary: true
                enabled: progName.length > 0 && scopeName.length > 0
                onPressed: {
                    var isSameName = progName === originalProgName
                    if (currentProgramIsUser && isSameName && originalProgName.length > 0) {
                        overwriteConfirmationRequested()
                        return
                    }
                    accept()
                }
            }
        }
    }

}
