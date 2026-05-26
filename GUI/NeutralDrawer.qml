import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Drawer {
    id: neutralDrawerRoot

    interactive: false
    modal: false
    closePolicy: Popup.NoAutoClose

    onOpened: {
        if (typeof appControl !== "undefined" && appControl) {
            appControl.setNeutralResistPollEnabled(true)
        }
    }

    onClosed: {
        if (typeof appControl !== "undefined" && appControl) {
            appControl.setNeutralResistPollEnabled(false)
        }
    }

    background: Rectangle {
        color: "darkgray"
    }

    Rectangle {
        anchors.fill: parent
        color: "darkgray"
        z: -1

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
            onReleased: mouse.accepted = true
            onClicked: mouse.accepted = true
            onPositionChanged: mouse.accepted = true
            onDoubleClicked: mouse.accepted = true
        }
    }

    Rectangle {
        id: wrapRect
        anchors.fill: parent
        color: "transparent"

        Label {
            id: neutralResistTitle
            anchors {
                top: parent.top
                topMargin: 15
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("СОПРОТИВЛЕНИЕ НЭ")
            color: "white"
            font.pixelSize: 20
            font.bold: true
        }

        Label {
            id: neutralResistValue
            anchors {
                top: neutralResistTitle.bottom
                topMargin: 8
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Qt.AlignHCenter
            text: periphHandle.neutralResistText
            color: "white"
            font.pixelSize: 36
            font.bold: true
        }

        Label {
            id: neutralChoice
            anchors {
                top: neutralResistValue.bottom
                topMargin: 20
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("ВЫБОР НЕЙТРАЛЬНОГО ЭЛЕКТРОДА")
            color: "white"
            font.pixelSize: 20
            font.bold: true
        }

        NeutralEl {
            id: neutralView
            anchors {
                top: neutralChoice.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 10
                leftMargin: 5
                rightMargin: 5
                bottomMargin: 10
            }
            neutralConnected: periphHandle.neutralElConnected
            neutralDivided: periphHandle.neutralElDivided
            neutralSize: periphHandle.neutralSize
            showControls: true
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 1000
        enabled: neutralDrawerRoot.opened
        propagateComposedEvents: true

        property real startX: 0
        property real startY: 0
        property bool isSwipeGesture: false
        readonly property real minSwipeDistance: 50

        onPressed: function(mouse) {
            startX = mouse.x
            startY = mouse.y
            isSwipeGesture = false

            var item = wrapRect.childAt(mouse.x - wrapRect.x, mouse.y - wrapRect.y)
            if (item && item.hasInteractiveContent === true) {
                mouse.accepted = false
                return
            }
            mouse.accepted = true
        }

        onPositionChanged: function(mouse) {
            if (!pressed)
                return
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            if (deltaX < -50 && Math.abs(deltaX) > deltaY * 2 && !isSwipeGesture)
                isSwipeGesture = true
        }

        onReleased: function(mouse) {
            var deltaX = mouse.x - startX
            if (isSwipeGesture && deltaX < -minSwipeDistance)
                neutralDrawerRoot.close()
            isSwipeGesture = false
        }
    }

    Connections {
        target: neutralView
        function onNeutralDividedToggled(divided) {
            periphHandle.neutralElDivided = divided
        }
        function onNeutralSizeSelected(size) {
            periphHandle.neutralSize = size
        }
    }
}
