import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: settinsScreen
    signal recommendButtonPressed()
    signal settingsButtonPressed()
    signal exitButtonPressed()
    
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
        rows: 2
        columnSpacing: 20
        rowSpacing: 20

        SButton {
            id: wifiButton
            style: "btn-outline-primary lg"
            width: 380
            height: 280

            text: qsTr("Рекомендованные")
            onClicked: recommendButtonPressed()
        }

        SButton {
            id: updateButton
            style: "btn-outline-primary lg"
            width: 380
            height: 280

            onClicked: settingsButtonPressed()
            text: qsTr("Настройки ...")
        }
        
        SButton {
            id: videoButton
            style: "btn-outline-primary lg"
            width: 380
            height: 280

            onClicked: settinsScreen.videoPlayerVisible = true
            text: qsTr("Видео 🎬")
        }
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
