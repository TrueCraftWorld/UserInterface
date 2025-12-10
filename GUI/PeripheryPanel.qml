import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Rectangle {

    id: peripheryPanelRoot
    signal openPeriphDrawer()

    color: "#2c2c2c"

    Argon {
        id: argonView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            // topMargin: 50

        }
        height: 430
        showControls: false
        //не передаём ибо у меня нет стм
        cylinder1Connected: periphHandle.argonCylinder1Connected
        cylinder2Connected: periphHandle.argonCylinder2Connected
        flowRate: periphHandle.argonFlowRate
        realFlowRate: periphHandle.argonRealRate
        isActivation: periphHandle.activation
        activCylinderFirst: periphHandle.activCylinderFirst
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
    NeutralEl {
        id: neutralView
        height: 165
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 5
        }
        // Передаем параметры
        neutralConnected: periphHandle.neutralElConnected
        showControls: false
    }
    MouseArea {
        anchors.fill: parent
        onClicked: peripheryPanelRoot.openPeriphDrawer();
    }
}
