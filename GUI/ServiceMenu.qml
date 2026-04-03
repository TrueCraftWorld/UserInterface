import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: serviceMenuRoot
    signal returnButtonPressed()
    signal deleteAllUserProgsRequested()
    signal serialNumberButtonPressed()
    signal softwareUpdateButtonPressed()
    signal networkSettingsButtonPressed()
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: "darkslategray"
    }
    
    SLabel {
        id: screenTitle
        style: "label-primary lg"
        text: qsTr("Сервисное меню")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    
    ColumnLayout {
        anchors {
            top: screenTitle.bottom
            topMargin: 50
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 30

        SButton {
            id: serialNumberButton
            style: "btn-primary lg"
            Layout.preferredWidth: 500
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Серийный номер")
            onClicked: {
                serviceMenuRoot.serialNumberButtonPressed()
            }
        }

        SButton {
            id: softwareUpdateButton
            style: "btn-primary lg"
            Layout.preferredWidth: 500
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Обновление ПО")
            onClicked: {
                serviceMenuRoot.softwareUpdateButtonPressed()
            }
        }

        SButton {
            id: networkSettingsButton
            style: "btn-primary lg"
            Layout.preferredWidth: 500
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Настройка сети")
            onClicked: {
                serviceMenuRoot.networkSettingsButtonPressed()
            }
        }
        
        SButton {
            id: deleteAllUserProgsButton
            style: "btn-danger lg"
            Layout.preferredWidth: 500
            Layout.preferredHeight: 120
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Удалить все\nпользовательские программы")
            onClicked: {
                confirmDeleteDialog.open()
            }
        }
    }
    
    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onClicked: returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
        contentItem: Text {
            text: retButton.text
            font: retButton.font
            opacity: enabled ? 1.0 : 0.3
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
    
    Dialog {
        id: confirmDeleteDialog
        title: "Подтверждение удаления"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        
        Label {
            text: "Удалить все пользовательские программы?\nЭто действие необратимо."
            font.pixelSize: 20
        }
        
        onAccepted: {
            serviceMenuRoot.deleteAllUserProgsRequested()
        }
    }
}
