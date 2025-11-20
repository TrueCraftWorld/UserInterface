import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: addTypeSelector

    signal typeChosen(int buttonType)
    parent: Overlay.overlay
    anchors.centerIn: parent

    component VariantRect: Rectangle {
        id: someRect
        property int buttonType: 0
        property alias title : titleLabel.text

        width: 250
        height: 100
        radius: 8
        color: "transparent"
        border {
            color: "white"
            width: 1
        }
        Label {
            id: titleLabel
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            wrapMode: Text.WordWrap
            color: "white"
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                addTypeSelector.typeChosen(someRect.buttonType)
                addTypeSelector.close()
            }
        }
    }

    Rectangle {
        color: "transparent"
        anchors.fill: parent
        Rectangle {
            id: upper
            anchors.top: parent.top
            // anchors.topMargin: 0
            // anchors.bottomMargin:  800
            anchors.left: parent.left
            anchors.right: parent.right
            height: 200
            color: "transparent"
            RowLayout {
                // color: "transparent"
                id: buttonRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                spacing: 20
                VariantRect{
                    title: qsTr("ДУБЛИРОВАТЬ ТЕКУЩИЙ")
                    buttonType: 0
                    Layout.alignment: Qt.AlignCenter
                }
                VariantRect{
                    title: qsTr("ЗАГРУЗИТЬ РЕКОМЕНДОВАННЫЙ")
                    buttonType: 1
                    Layout.alignment: Qt.AlignCenter
                }
                VariantRect{
                    title: qsTr("ДОБАВИТЬ ПУСТОЙ")
                    buttonType: 2
                    Layout.alignment: Qt.AlignCenter
                }
            }
        }
        Rectangle {
            color: "transparent"
            anchors.top: upper.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

    }

}
