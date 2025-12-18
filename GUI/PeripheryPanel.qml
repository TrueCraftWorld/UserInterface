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
        function onActivCylinderToggled(first) {
            console.log("PeripheryPanel.qml: onActivCylinderToggled", first)
            periphHandle.activCylinderFirst = first
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
        neutralDivided: periphHandle.neutralElDivided
        neutralSize: periphHandle.neutralSize
        showControls: false
    }
    
    // MouseArea для открытия drawer - размещаем в конце для наивысшего z-order
    MouseArea {
        anchors.fill: parent
        z: 1000  // Очень высокий z
        onPressed: {
//            console.log("PeripheryPanel PRESSED at", mouse.x, mouse.y)
        }
        onReleased: {
//            console.log("PeripheryPanel RELEASED")
        }
        onClicked: {
//            console.log("PeripheryPanel CLICKED - opening drawer")
            peripheryPanelRoot.openPeriphDrawer()
        }
    }
}
