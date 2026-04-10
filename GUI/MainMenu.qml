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
    signal serviceMenuButtonPressed()
    
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
        onPressed: settinsScreen.exitButtonPressed()
        anchors {
            left:parent.left
            bottom: parent.bottom
            margins: 15
        }
    }


    ColumnLayout {
        id: buttonGrid
        anchors {
            top: screenTitle.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 20

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            SButton {
                id: wifiButton
                style: "btn-primary lg"
                Layout.preferredWidth: 480
                Layout.preferredHeight: 110
                text: qsTr("Рекомендованные программы")
                onPressed: recommendButtonPressed()
                contentItem: Text {
                    text: wifiButton.text
                    font: wifiButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }

            SButton {
                id: userProgButton
                style: "btn-primary lg"
                Layout.preferredWidth: 480
                Layout.preferredHeight: 110
                text: qsTr("Пользовательские программы")
                onPressed: userButtonPressed()
                contentItem: Text {
                    text: userProgButton.text
                    font: userProgButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            SButton {
                id: freeSettingsButton
                style: "btn-primary lg"
                Layout.preferredWidth: 480
                Layout.preferredHeight: 110
                text: qsTr("Свободные установки")
                onPressed: {
                    recomHandle.loadFreeSettings()
                    freeSettingsButtonPressed()
                }
                contentItem: Text {
                    text: freeSettingsButton.text
                    font: freeSettingsButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
            
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            SButton {
                id: videoButton
                style: "btn-primary lg"
                Layout.preferredWidth: 480
                Layout.preferredHeight: 110
                text: qsTr("Видео 🎬")
                onPressed: settinsScreen.videoPlayerVisible = true
                contentItem: Text {
                    text: videoButton.text
                    font: videoButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
            
            SButton {
                id: serviceMenuButton
                style: "btn-primary lg"
                Layout.preferredWidth: 480
                Layout.preferredHeight: 110
                text: qsTr("Сервисное меню")
                onPressed: serviceMenuButtonPressed()
                contentItem: Text {
                    text: serviceMenuButton.text
                    font: serviceMenuButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
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
