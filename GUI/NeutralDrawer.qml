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
        color: "white"
    }

    Rectangle {
        anchors.fill: parent
        color: "white"
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
            color: fotekBlue
            font.pixelSize: 24
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
            color: "black"
            font.pixelSize: 36
            font.bold: true
        }

        Label {
            id: neutralChoice
            anchors {
                top: neutralResistValue.bottom
                topMargin: 100
                left: parent.left
                right: parent.right
            }
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("ВЫБОР НЕЙТРАЛЬНОГО ЭЛЕКТРОДА")
            color: fotekBlue
            font.pixelSize: 26
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

    Button {
        id: closeButton
        anchors {
            top: parent.top
            topMargin: 10
            right: parent.right
            rightMargin: 10
        }
        width: 68
        height: 68
        z: 1001
        onPressed: neutralDrawerRoot.close()

        background: Rectangle {
            color: "transparent"
        }

        contentItem: Text {
            text: qsTr("X")
            font.pixelSize: 34
            font.bold: true
            color: fotekBlue
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
