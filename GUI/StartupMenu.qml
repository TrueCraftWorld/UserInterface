import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import StratifyLabs.UI 2.0

Item {
    id: startupMenu

    signal recommendedProgramsPressed()
    signal lastSettingsPressed()
    signal freeSettingsPressed()
    signal userProgramsPressed()
    signal languageButtonPressed()
    signal infoButtonPressed()

    property color fotekBlue: "#264093"
    property color fotekOrange: "#faa731"
    readonly property int screenMargin: 34
    readonly property int topButtonWidth: 160
    readonly property int topButtonHeight: 64
    readonly property int mainSpacing: 24
    readonly property int actionButtonHeight: 146
    readonly property int actionsColumnHeight: actionButtonHeight * 3 + mainSpacing * 2

    Rectangle {
        anchors.fill: parent
        color: "#F3F5F9"
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 22
        border.color: startupMenu.fotekBlue
    }

    Button {
        id: infoButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: startupMenu.screenMargin
        anchors.leftMargin: startupMenu.screenMargin
        width: startupMenu.topButtonWidth
        height: startupMenu.topButtonHeight
        text: qsTr("ИНФО")
        onPressed: startupMenu.infoButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: startupMenu.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: startupMenu.fotekBlue
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
        anchors.topMargin: startupMenu.screenMargin
        anchors.rightMargin: startupMenu.screenMargin
        width: startupMenu.topButtonWidth
        height: startupMenu.topButtonHeight
        text: qsTr("RU / EN")
        onPressed: startupMenu.languageButtonPressed()

        background: Rectangle {
            radius: 18
            color: "white"
            border.width: 1
            border.color: startupMenu.fotekBlue
        }

        contentItem: Text {
            text: parent.text
            color: startupMenu.fotekBlue
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Image {
        id: logoImage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: startupMenu.screenMargin - 8
        width: 260
        height: 120
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        source: "file:///home/kikorik/FOTEK/Images/logo.png"
    }

    Item {
        id: actionsArea
        anchors.top: logoImage.bottom
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - startupMenu.screenMargin * 2
        height: startupMenu.actionsColumnHeight

        RowLayout {
            anchors.fill: parent
            spacing: startupMenu.mainSpacing

            Button {
                id: recommendedButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.56
                Layout.preferredHeight: startupMenu.actionsColumnHeight
                text: qsTr("Рекомендованные\nпрограммы")
                onPressed: startupMenu.recommendedProgramsPressed()

                background: Rectangle {
                    radius: 28
                    color: "white"
                    border.width: 2
                    border.color: startupMenu.fotekOrange
                }

                contentItem: Text {
                    text: parent.text
                    color: startupMenu.fotekBlue
                    font.pixelSize: 44
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: startupMenu.actionsColumnHeight
                Layout.preferredWidth: parent.width * 0.44
                spacing: startupMenu.mainSpacing

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: startupMenu.actionButtonHeight
                    text: qsTr("Последние установки")
                    onPressed: startupMenu.lastSettingsPressed()

                    background: Rectangle {
                        radius: 24
                        color: startupMenu.fotekBlue
                        border.width: 1
                        border.color: "#1E3274"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 34
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: startupMenu.actionButtonHeight
                    text: qsTr("Свободная установка")
                    onPressed: startupMenu.freeSettingsPressed()

                    background: Rectangle {
                        radius: 24
                        color: "white"
                        border.width: 1
                        border.color: "#C7CEDA"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "black"
                        font.pixelSize: 34
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: startupMenu.actionButtonHeight
                    text: qsTr("Пользовательские программы")
                    onPressed: startupMenu.userProgramsPressed()

                    background: Rectangle {
                        radius: 24
                        color: startupMenu.fotekOrange
                        border.width: 1
                        border.color: "#D88714"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#111111"
                        font.pixelSize: 34
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
