import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: settinsScreen
    signal recommendButtonPressed()
    signal settingsButtonPressed()
    signal exitButtonPressed()
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
        id: buttonColumn
        anchors{
            top: screenTitle.bottom
            topMargin: 25
        }

        width: parent.width
        rowSpacing: 15

        SButton {
            id: wifiButton
            style: "btn-outline-primary lg"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 320
            Layout.preferredHeight: 320
            // verticalPadding: 10

            text: qsTr("Рекомендованные")
            onClicked: recommendButtonPressed()
        }

        SButton {
            id: updateButton
            style: "btn-outline-primary lg"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: 320
            Layout.preferredHeight: 320
            // span: 10
            // verticalPadding: 10

            onClicked: settingsButtonPressed()
            text: qsTr("Настройки ...")
        }
    }
}
