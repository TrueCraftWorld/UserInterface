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
    signal languageButtonPressed()
    signal infoButtonPressed()

    property color fotekBlue: "#264093"
    property color fotekOrange: "#faa731"
    readonly property int screenMargin: 34
    readonly property int topButtonWidth: 160
    readonly property int topButtonHeight: 64
    readonly property int mainSpacing: 24
    readonly property int actionButtonHeight: 132
    readonly property int topActionsHeight: actionButtonHeight * 2 + mainSpacing

    property bool videoPlayerVisible: false

    Rectangle {
        anchors.fill: parent
        color: "#F3F5F9"
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 22
        border.color: settinsScreen.fotekBlue
    }

    Button {
        id: infoButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: settinsScreen.screenMargin
        anchors.leftMargin: settinsScreen.screenMargin
        width: settinsScreen.topButtonWidth
        height: settinsScreen.topButtonHeight
        text: qsTr("ИНФО")
        onPressed: settinsScreen.infoButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: settinsScreen.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: settinsScreen.fotekBlue
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button {
        id: languageButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: settinsScreen.screenMargin
        anchors.rightMargin: settinsScreen.screenMargin
        width: settinsScreen.topButtonWidth
        height: settinsScreen.topButtonHeight
        text: qsTr("RU / EN")
        onPressed: settinsScreen.languageButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: settinsScreen.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: settinsScreen.fotekBlue
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Text {
        id: screenTitle
        text: qsTr("МЕНЮ")
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: settinsScreen.screenMargin + 6
        }
        color: settinsScreen.fotekBlue
        font.pixelSize: 48
        font.bold: true
    }

    Button {
        id: exitButton
        width: 180
        height: 72
        text: qsTr("НАЗАД")
        onPressed: settinsScreen.exitButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: settinsScreen.screenMargin
        }

        background: Rectangle {
            radius: 20
            color: settinsScreen.fotekBlue
            border.width: 1
            border.color: "#1E3274"
        }

        contentItem: Text {
            text: parent.text
            color: "white"
            font.pixelSize: 30
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item {
        id: actionsArea
        anchors {
            top: screenTitle.bottom
            topMargin: 26
            horizontalCenter: parent.horizontalCenter
            bottom: exitButton.top
            bottomMargin: 24
        }
        width: parent.width - settinsScreen.screenMargin * 2

        ColumnLayout {
            anchors.fill: parent
            spacing: settinsScreen.mainSpacing

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: settinsScreen.topActionsHeight
                spacing: settinsScreen.mainSpacing

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: settinsScreen.topActionsHeight
                    text: qsTr("Рекомендованные программы")
                    onPressed: recommendButtonPressed()

                    background: Rectangle {
                        radius: 28
                        color: "white"
                        border.width: 2
                        border.color: settinsScreen.fotekOrange
                    }

                    contentItem: Text {
                        text: parent.text
                        color: settinsScreen.fotekBlue
                        font.pixelSize: 42
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: settinsScreen.topActionsHeight
                    spacing: settinsScreen.mainSpacing

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: settinsScreen.actionButtonHeight
                        text: qsTr("Пользовательские программы")
                        onPressed: userButtonPressed()

                        background: Rectangle {
                            radius: 24
                            color: settinsScreen.fotekOrange
                            border.width: 1
                            border.color: "#D88714"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#111111"
                            font.pixelSize: 30
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: settinsScreen.actionButtonHeight
                        text: qsTr("Свободные установки")
                        onPressed: {
                            recomHandle.loadFreeSettings()
                            freeSettingsButtonPressed()
                        }

                        background: Rectangle {
                            radius: 24
                            color: "white"
                            border.width: 1
                            border.color: "#C7CEDA"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "black"
                            font.pixelSize: 30
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: settinsScreen.actionButtonHeight
                spacing: settinsScreen.mainSpacing

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: settinsScreen.actionButtonHeight
                    text: qsTr("Видеоинструкции")
                    onPressed: settinsScreen.videoPlayerVisible = true

                    background: Rectangle {
                        radius: 24
                        color: "white"
                        border.width: 1
                        border.color: "#C7CEDA"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "black"
                        font.pixelSize: 30
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: settinsScreen.actionButtonHeight
                    text: qsTr("Сервисное меню")
                    onPressed: serviceMenuButtonPressed()

                    background: Rectangle {
                        radius: 24
                        color: settinsScreen.fotekBlue
                        border.width: 1
                        border.color: "#1E3274"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 30
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    Loader {
        id: videoPlayerLoader
        anchors.fill: parent
        z: 1000
        active: settinsScreen.videoPlayerVisible
        sourceComponent: videoPlayerComponent
    }

    Component {
        id: videoPlayerComponent
        VideoPlayer {
            anchors.fill: parent
            onCloseRequested: settinsScreen.videoPlayerVisible = false
        }
    }
}
