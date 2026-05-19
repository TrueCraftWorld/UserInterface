import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: settingsScreen
    signal recommendButtonPressed()
    signal settingsButtonPressed()
    signal userButtonPressed()
    signal exitButtonPressed()
    signal secretKeysButtonPressed()
    signal userProgsButtonPressed()
    signal freeSettingsButtonPressed()
    signal lastSettingsButtonPressed()
    signal serviceMenuButtonPressed()
    signal languageButtonPressed()
    signal infoButtonPressed()

    property bool startupMode: false
    property color fotekBlue: "#264093"
    property color fotekOrange: "#faa731"
    readonly property string iconsBasePath: "file:///home/kikorik/FOTEK/Images/icons/"
    readonly property int screenMargin: 34
    readonly property int topButtonWidth: 160
    readonly property int topButtonHeight: 64
    readonly property int mainSpacing: startupMode ? 18 : 24
    readonly property int actionButtonHeight: startupMode ? 96 : 132
    readonly property int headerHeight: startupMode ? 110 : 70
    readonly property int bottomActionsHeight: 132
    readonly property int bottomRowBottomInset: screenMargin + 72 + 24
    readonly property int menuActionIconSize: startupMode ? 96 : 96
    readonly property int menuActionLabelSize: 38
    readonly property int menuActionLargeLabelSize: 42
    readonly property int menuActionLargeIconSize: startupMode ? 112 : 112

    property bool videoPlayerVisible: false

    Rectangle {
        anchors.fill: parent
        color: "#F3F5F9"
    }

    Button {
        id: infoButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: settingsScreen.screenMargin
        anchors.leftMargin: settingsScreen.screenMargin
        width: settingsScreen.topButtonWidth
        height: settingsScreen.topButtonHeight
        text: qsTr("ИНФО")
        onPressed: settingsScreen.infoButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: settingsScreen.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: settingsScreen.fotekBlue
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
        anchors.topMargin: settingsScreen.screenMargin
        anchors.rightMargin: settingsScreen.screenMargin
        width: settingsScreen.topButtonWidth
        height: settingsScreen.topButtonHeight
        text: qsTr("RU / EN")
        onPressed: settingsScreen.languageButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: settingsScreen.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: settingsScreen.fotekBlue
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item {
        id: headerArea
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: settingsScreen.screenMargin - 8
        }
        width: parent.width - settingsScreen.screenMargin * 2 - settingsScreen.topButtonWidth * 2
        height: settingsScreen.headerHeight

        Image {
            id: logoImage
            visible: settingsScreen.startupMode
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: "file:///home/kikorik/FOTEK/Images/logo.png"
        }

        Text {
            id: screenTitle
            visible: !settingsScreen.startupMode
            text: qsTr("МЕНЮ")
            anchors.centerIn: parent
            color: settingsScreen.fotekBlue
            font.pixelSize: 48
            font.bold: true
        }
    }

    DialogActionButton {
        id: exitButton
        visible: !settingsScreen.startupMode
        width: 180
        height: 72
        text: qsTr("НАЗАД")
        secondaryColor: settingsScreen.fotekBlue
        secondaryBorderWidth: 1
        secondaryBorderColor: "#1E3274"
        cornerRadius: 20
        labelPixelSize: 30
        onPressed: settingsScreen.exitButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: settingsScreen.screenMargin
        }
    }

    RowLayout {
        id: bottomActionsRow
        z: 2
        anchors {
            left: parent.left
            right: parent.right
            bottom: settingsScreen.startupMode ? parent.bottom : exitButton.top
            leftMargin: settingsScreen.screenMargin
            rightMargin: settingsScreen.screenMargin
            bottomMargin: settingsScreen.startupMode ? settingsScreen.bottomRowBottomInset : 24
        }
        height: settingsScreen.bottomActionsHeight
        spacing: settingsScreen.mainSpacing

        MenuActionButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("Видеоинструкции")
            iconSource: settingsScreen.iconsBasePath + "iconVideo.png"
            accentColor: settingsScreen.fotekOrange
            textColor: settingsScreen.fotekBlue
            iconSize: settingsScreen.menuActionIconSize
            labelPixelSize: settingsScreen.menuActionLabelSize
            onPressed: settingsScreen.videoPlayerVisible = true
        }

        MenuActionButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("Сервисное меню")
            iconSource: settingsScreen.iconsBasePath + "iconSetting.png"
            accentColor: settingsScreen.fotekOrange
            textColor: settingsScreen.fotekBlue
            iconSize: settingsScreen.menuActionIconSize
            labelPixelSize: settingsScreen.menuActionLabelSize
            onPressed: settingsScreen.serviceMenuButtonPressed()
        }
    }

    Item {
        id: actionsArea
        anchors {
            top: headerArea.bottom
            topMargin: settingsScreen.startupMode ? 12 : 26
            left: parent.left
            right: parent.right
            bottom: bottomActionsRow.top
            bottomMargin: settingsScreen.mainSpacing
            leftMargin: settingsScreen.screenMargin
            rightMargin: settingsScreen.screenMargin
        }

        RowLayout {
            anchors.fill: parent
            spacing: settingsScreen.mainSpacing

            MenuActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Рекомендованные\nпрограммы")
                iconSource: settingsScreen.iconsBasePath + "iconRecom.png"
                accentColor: settingsScreen.fotekOrange
                textColor: settingsScreen.fotekBlue
                iconSize: settingsScreen.menuActionLargeIconSize
                labelPixelSize: settingsScreen.menuActionLargeLabelSize
                onPressed: settingsScreen.recommendButtonPressed()
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: settingsScreen.mainSpacing

                MenuActionButton {
                    visible: settingsScreen.startupMode
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Последние\nустановки")
                    iconSource: settingsScreen.iconsBasePath + "iconLast.png"
                    accentColor: settingsScreen.fotekOrange
                    textColor: settingsScreen.fotekBlue
                    iconSize: settingsScreen.menuActionIconSize
                    labelPixelSize: settingsScreen.menuActionLabelSize
                    onPressed: settingsScreen.lastSettingsButtonPressed()
                }

                MenuActionButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Пользовательские\nпрограммы")
                    iconSource: settingsScreen.iconsBasePath + "iconUser.png"
                    accentColor: settingsScreen.fotekOrange
                    textColor: settingsScreen.fotekBlue
                    iconSize: settingsScreen.menuActionIconSize
                    labelPixelSize: settingsScreen.menuActionLabelSize
                    onPressed: settingsScreen.userButtonPressed()
                }

                MenuActionButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Свободная\nустановка режимов")
                    iconSource: settingsScreen.iconsBasePath + "iconFree.png"
                    accentColor: settingsScreen.fotekOrange
                    textColor: settingsScreen.fotekBlue
                    iconSize: settingsScreen.menuActionIconSize
                    labelPixelSize: settingsScreen.menuActionLabelSize
                    onPressed: {
                        if (!settingsScreen.startupMode) {
                            recomHandle.loadFreeSettings()
                        }
                        settingsScreen.freeSettingsButtonPressed()
                    }
                }
            }
        }
    }

    Loader {
        id: videoPlayerLoader
        anchors.fill: parent
        z: 1000
        active: settingsScreen.videoPlayerVisible
        sourceComponent: videoPlayerComponent
    }

    Component {
        id: videoPlayerComponent
        VideoPlayer {
            anchors.fill: parent
            onCloseRequested: settingsScreen.videoPlayerVisible = false
        }
    }
}
