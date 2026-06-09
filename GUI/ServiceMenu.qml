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
    signal wifiFileReceiveButtonPressed()
    signal wifiSettingsButtonPressed()
    signal touchScreenTestButtonPressed()
    signal aboutButtonPressed()
    signal logUpdateButtonPressed()
    signal specialCommandsButtonPressed()
    readonly property int menuButtonWidth: 550
    readonly property int menuButtonHeight: 96
    readonly property int menuColumnsSpacing: 24
    
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
    
    GridLayout {
        anchors {
            top: screenTitle.bottom
            topMargin: 36
            horizontalCenter: parent.horizontalCenter
        }
        columns: 2
        columnSpacing: serviceMenuRoot.menuColumnsSpacing
        rowSpacing: 20
        width: serviceMenuRoot.menuButtonWidth * 2 + serviceMenuRoot.menuColumnsSpacing

        SButton {
            id: specialCommandsButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("СПЕЦ КОМАНДЫ")
            onPressed: serviceMenuRoot.specialCommandsButtonPressed()
        }

        SButton {
            id: serialNumberButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Серийный номер")
            onPressed: serviceMenuRoot.serialNumberButtonPressed()
        }

        SButton {
            id: softwareUpdateButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Обновление ПО")
            onPressed: serviceMenuRoot.softwareUpdateButtonPressed()
        }

        SButton {
            id: wifiFileReceiveButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Приём файлов по Wi‑Fi")
            onPressed: serviceMenuRoot.wifiFileReceiveButtonPressed()
        }

        SButton {
            id: wifiSettingsButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Настройки WiFi")
            onPressed: serviceMenuRoot.wifiSettingsButtonPressed()
        }

        SButton {
            id: aboutButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Об аппарате")
            onPressed: serviceMenuRoot.aboutButtonPressed()
        }

        SButton {
            id: touchScreenTestButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Проверка тач-скрина")
            onPressed: serviceMenuRoot.touchScreenTestButtonPressed()
        }

        SButton {
            id: logUpdateButton
            style: "btn-primary lg"
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth
            Layout.preferredHeight: serviceMenuRoot.menuButtonHeight
            text: qsTr("Лог обновлений")
            onPressed: serviceMenuRoot.logUpdateButtonPressed()
        }

        SButton {
            id: deleteAllUserProgsButton
            style: "btn-danger lg"
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            Layout.preferredWidth: serviceMenuRoot.menuButtonWidth * 2 + serviceMenuRoot.menuColumnsSpacing
            Layout.preferredHeight: 106
            text: qsTr("Удалить все пользовательские программы")
            onPressed: confirmDeleteDialog.open()
        }
    }
    
    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onPressed: returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
//        contentItem: Text {
//            text: retButton.text
//            font: retButton.font
//            opacity: enabled ? 1.0 : 0.3
//            color: "white"
//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
//            elide: Text.ElideRight
//        }
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
