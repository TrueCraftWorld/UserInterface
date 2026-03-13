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


    Grid {
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

        Item {
            width: 380
            height: 220
            clip: true
            
            SButton {
                id: wifiButton
//                style: "btn-outline-primary lg"
                style: "btn-primary lg"           // Попробуйте: btn-primary, btn-secondary, btn-info, btn-light
                width: parent.width
                height: parent.height
                text: qsTr("Рекомендованные\n программы")
                onClicked: recommendButtonPressed()
            }
        }

        Item {
            width: 380
            height: 220
            clip: true

            SButton {
                id: userProgsButton
                style: "btn-primary lg"
                width: parent.width
                height: parent.height
                onClicked: userProgsButtonPressed()
                text: qsTr("Пользовательские\n программы")
            }
        }

        Item {
            width: 380
            height: 220
            clip: true

            SButton {
                id: freeSettingsButton
                style: "btn-primary lg"
                width: parent.width
                height: parent.height
                onClicked: freeSettingsButtonPressed()
                text: qsTr("Свободные\n установки")
            }
        }

        Item {
            width: 380
            height: 220
            clip: true
            
            SButton {
                id: updateButton
//                style: "btn-outline-primary lg"
                style: "btn-primary lg"           // Попробуйте: btn-primary, btn-secondary, btn-info, btn-light
                width: parent.width
                height: parent.height
                onClicked: settingsButtonPressed()
                text: qsTr("Настройки ...")
            }
        }
        
        Item {
            width: 380
            height: 220
            clip: true
            
            SButton {
                id: videoButton
                style: "btn-primary lg"           // Попробуйте: btn-primary, btn-secondary, btn-info, btn-light
//                style: "btn-outline-primary lg"
                width: parent.width
                height: parent.height
                onClicked: settinsScreen.videoPlayerVisible = true
                text: qsTr("Видео 🎬")
            }
        }
        
//        Item {
//            width: 380
//            height: 220
//            clip: true
            
//            SButton {
//                id: secretKeysButton
//                style: "btn-primary lg"
//                width: parent.width
//                height: parent.height
//                onClicked: secretKeysButtonPressed()
//                text: qsTr("Секретные ключи 🔐")
//            }
//        }
        
    }
    
    // Видеопроигрыватель
    VideoPlayer {
        id: videoPlayer
        anchors.fill: parent
        visible: settinsScreen.videoPlayerVisible
        z: 1000
        onCloseRequested: settinsScreen.videoPlayerVisible = false
    }
}
