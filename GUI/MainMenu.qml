import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: settinsScreen
    signal recommendButtonPressed()
    signal settingsButtonPressed()
    signal userButtonPressed()
    signal exitButtonPressed()
    signal secretKeysButtonPressed()
    signal userProgsButtonPressed()
    signal freeSettingsButtonPressed()
    
    property bool videoPlayerVisible: false
    Rectangle {
        id: background
        anchors.fill: parent
        color: "darkslategray"
    }
    SLabel {
        id: screenTitle
        style: "label-primary lg"
        text: qsTr("Настройки")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    SButton{
        id: exitButton
        style: "btn-secondary"
        text: qsTr("Выход")
        onClicked: settinsScreen.exitButtonPressed()
        anchors {
            left:parent.left
            bottom: parent.bottom
            margins: 15
        }
    }


    SColumn {
        id: buttonGrid
        anchors {
            top: screenTitle.bottom
            topMargin: 25
            horizontalCenter: parent.horizontalCenter
        }
        columns: 2
        rows: 3
        columnSpacing: 20
        rowSpacing: 20
        clip: false  // Не обрезаем - позволяем теням отображаться

        width: parent.width
        // rowSpacing: 15

        SButton {
            id: wifiButton
            style: "btn-outline-primary lg"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 320
            Layout.preferredHeight: 120

            text: qsTr("Рекомендованные программы")
            onClicked: recommendButtonPressed()
        }

        SButton {
            id: userProgButton
            style: "btn-outline-primary lg"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 320
            Layout.preferredHeight: 120

            onClicked: userButtonPressed()
            text: qsTr("Пользовательские программы")

        }

        SButton {
            id: updateButton
            style: "btn-outline-primary lg"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 320
            Layout.preferredHeight: 120

            onClicked: settingsButtonPressed()
            text: qsTr("Настройки ...")
        }
            
        SButton {
            id: videoButton
            style: "btn-primary lg"           // Попробуйте: btn-primary, btn-secondary, btn-info, btn-light
//                style: "btn-outline-primary lg"
            width: parent.width
            height: parent.height
            onClicked: settinsScreen.videoPlayerVisible = true
            text: qsTr("Видео 🎬")
        }

        SButton {
            id: secretKeysButton
            style: "btn-primary lg"
            width: parent.width
            height: parent.height
            onClicked: secretKeysButtonPressed()
            text: qsTr("Секретные ключи 🔐")
        }
        
        
        Item {
            id: filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    VideoPlayer {
        id: videoPlayer
        anchors.fill: parent
        visible: settinsScreen.videoPlayerVisible
        z: 1000
        onCloseRequested: settinsScreen.videoPlayerVisible = false
   }
}
