import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Drawer {

    id: peripheryRoot
    property var handle: periphHandle

    background: Rectangle {
        color: "darkgray"
    }

    Label {
        id: argonChoice
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("НАСТРОЙКА ГАЗОВОГО ТРАКТА")
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
    Argon {
        id: argonView
        anchors {
            top: argonChoice.bottom
            left: parent.left
            right: parent.right
        }
        height: 350
        showControls: true
        //не передаём ибо у меня нет стм
        cylinder1Connected: periphHandle.argonCylinder1Connected
        cylinder2Connected: periphHandle.argonCylinder2Connected
        flowRate: periphHandle.argonFlowRate
        realFlowRate: periphHandle.argonRealRate
        isActivation: periphHandle.activation
        activCylinderFirst: periphHandle.activCylinderFirst
    }
    NeutralEl {
        id: neutralView
        height: 260
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 5
        }
        // neutralConnected: periphHandle.neutralElConnected
        showControls: true
    }

    Label {
        id: neutralChoice
        // visible: panelExpanded
        anchors {
            // top: argonView.bottom
            bottom: neutralView.top
            left: parent.left
            right: parent.right
            bottomMargin: 5
            topMargin: 15
            // horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("ВЫБОР НЕЙТРАЛЬНОГО ЭЛЕКТРОДА")
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
    Connections {
        target: argonView
        function onFlowRateUpdated(newRate) {
            periphHandle.setArgonFlowRate(newRate)
        }
        function onArgonBlow() {
            periphHandle.argonBlow()
        }
    }
    Connections {
        target: neutralView
        function onNeutralDividedChanged() {
            // Можно добавить обработку изменения типа
        }
        function onNeutralSizeChanged() {
            // Можно добавить обработку изменения размера
        }
    }
}
