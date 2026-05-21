import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Rectangle {

    id: peripheryPanelRoot
    signal openPeriphDrawer()

    color: "#2c2c2c"

    NeutralEl {
        id: neutralView
        height: 280
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        neutralConnected: periphHandle.neutralElConnected
        neutralDivided: periphHandle.neutralElDivided
        neutralSize: periphHandle.neutralSize
        showControls: false
    }

    Rectangle {
        id: futurePanel
        anchors {
            left: parent.left
            right: parent.right
            top: argonCard.bottom
            bottom: neutralView.top
        }
        color: "white"
        radius: 10
        border.color: "purple"
        border.width: 3
    }

    Rectangle {
        id: argonCard
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: argonView.compactContentHeight
        color: "white"
        radius: 10
        border.color: "purple"
        border.width: 3

        Argon {
            id: argonView
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: compactContentHeight
            showControls: false
            compactOnLightBackground: true
            cylinder1Connected: periphHandle.argonCylinder1Connected
            cylinder2Connected: periphHandle.argonCylinder2Connected
            flowRate: periphHandle.argonFlowRate
            realFlowRate: periphHandle.argonRealRate
            isActivation: periphHandle.activation
            activCylinderFirst: periphHandle.activCylinderFirst
        }
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

    // Касание по компактной панели — открыть drawer (внутри drawer свои контролы)
    MouseArea {
        anchors.fill: parent
        z: 10
        onClicked: peripheryPanelRoot.openPeriphDrawer()
    }
}
