import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: startupInfo

    signal returnButtonPressed()

    property color fotekBlue: "#264093"
    property color fotekOrange: "#faa731"
    readonly property string deviceTypeText: {
        var value = String(savedJson.readString("deviceType", "")).trim()
        return value === "" ? qsTr("Не указан") : value
    }
    readonly property string serialNumberText: {
        var value = String(savedJson.readString("serialNumber", "")).trim()
        return value === "" ? qsTr("Не указан") : value
    }

    Rectangle {
        anchors.fill: parent
        color: "#F4F6FA"
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 28
        radius: 28
        color: "white"
        border.width: 2
        border.color: startupInfo.fotekBlue

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 34
            spacing: 22

            Label {
                Layout.fillWidth: true
                text: qsTr("Информация об аппарате")
                color: startupInfo.fotekBlue
                font.pixelSize: 34
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: startupInfo.fotekOrange
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, 720)
                    spacing: 18

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        radius: 22
                        color: "#F7F9FD"
                        border.width: 1
                        border.color: "#D3D9E6"

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 12

                            Label {
                                width: parent.width
                                text: qsTr("Тип аппарата")
                                color: "#616161"
                                font.pixelSize: 24
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: startupInfo.deviceTypeText
                                color: "black"
                                font.pixelSize: 36
                                font.bold: true
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        radius: 22
                        color: "#F7F9FD"
                        border.width: 1
                        border.color: "#D3D9E6"

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 12

                            Label {
                                width: parent.width
                                text: qsTr("Серийный номер")
                                color: "#616161"
                                font.pixelSize: 24
                                font.bold: true
                            }

                            Label {
                                width: parent.width
                                text: startupInfo.serialNumberText
                                color: "black"
                                font.pixelSize: 36
                                font.bold: true
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            DialogActionButton {
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: 180
                Layout.preferredHeight: 66
                text: qsTr("НАЗАД")
                secondaryColor: startupInfo.fotekBlue
                secondaryBorderWidth: 1
                secondaryBorderColor: "#1C2F6B"
                onPressed: startupInfo.returnButtonPressed()
            }
        }
    }
}
