import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: modePowerRect

    property bool isCoag
    property string modeName
    property int modeId
    property int modePower
    property int maxPower: 400

    signal modeEditDialogRequest()
    signal newPower(int pwr)

    function colorFromId() {
        if (modePowerRect.modeId == 1000)
            return "darkgray"
        return isCoag ? "blue" : "yellow"
    }

    color: {
        if (modePowerRect.modeId == 1000)
            return "darkgray"
        return isCoag ? "blue" : "yellow"

    }

    Connections {
        target: modePowerRect
        function onModeIdChanged() {
            modePowerRect.color = modePowerRect.colorFromId()
            console.log(isCoag, modePowerRect.color, modePowerRect.modeId)
        }
    }

    radius: 8

    Rectangle {
        id: mode
        color: "transparent"
        Label {
            id: modeLabel
            text: modeName
            font.pixelSize: 22
            font.bold: true
            wrapMode: Text.Wrap
            height: 60
            color: isCoag ? "white" : "black"
            verticalAlignment: Qt.AlignVCenter
            anchors {
                margins: 10
                fill: parent
            }
        }
        MouseArea {
            id: modeSelectButton
            anchors.fill: parent
            onClicked: modePowerRect.modeEditDialogRequest()
        }
    }

    Rectangle {
        id: power
        color: "transparent"
        Label {
            id: powerLabel
            text: modePower
            visible: (modeId != 1000)
            width: fontMetrics.advanceWidth("999")
            height: 31
            font.pixelSize: 30
            font.bold: true
            color: isCoag ? "white" : "black"
            verticalAlignment: Qt.AlignVCenter
            anchors {
                margins: 10
                fill: parent
            }
        }
        FontMetrics {
            id: fontMetrics
            font: powerLabel.font
        }
    }
    Rectangle {
        id: powerPlusButton
        width: 60
        height: 60
        color: "transparent"
        radius: 8
        border {
            color: modePowerRect.isCoag ? "white" : "color"
            width: 2
        }
        anchors.margins: 15
        Label {
            anchors {
                margins: 10
                fill: parent
            }
            color: modePowerRect.isCoag ? "white" : "color"
            font.pixelSize: 30
            font.bold: true
            text: "+"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: modePowerRect.newPower(powerSlider.value + 1);
        }
    }
    Rectangle {
        id: powerMinusButton
        width: 60
        height: 60
        color: "transparent"
        radius: 8
        border {
            color: modePowerRect.isCoag ? "white" : "color"
            width: 2
        }
        anchors.margins: 15
        Label {
            anchors {
                margins: 10
                fill: parent
            }
            color: modePowerRect.isCoag ? "white" : "color"
            font.pixelSize: 30
            font.bold: true
            text: "-"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: modePowerRect.newPower(powerSlider.value - 1);
        }
    }
    Slider {
        id: powerSlider
        value: modePower
        from: 1
        to: maxPower
        onValueChanged: modePowerRect.newPower(value);
    }
    states: [
        State {
            name: "collapsed"
            PropertyChanges { target: powerPlusButton;  visible: false }
            PropertyChanges { target: powerMinusButton; visible: false }
            PropertyChanges { target: powerSlider;      visible: false }
            PropertyChanges {
                target: powerLabel;
                horizontalAlignment: isCoag ? Text.AlignLeft : Text.AlignRight
                font.pixelSize: 34
            }
            PropertyChanges {
                target: modeLabel;
                horizontalAlignment: isCoag ? Text.AlignRight : Text.AlignLeft
                font.pixelSize: 20
            }
            PropertyChanges {
                target: power;
                anchors.topMargin: undefined
            }
            PropertyChanges {
                target: modeSelectButton;
                enabled: false
            }
            AnchorChanges {
                target: power
                anchors.left: {modePowerRect.isCoag ? modePowerRect.left : undefined}
                anchors.right: {modePowerRect.isCoag ? undefined : modePowerRect.right}
                anchors.top: modePowerRect.top
                anchors.bottom: modePowerRect.bottom
            }
            AnchorChanges {
                target: mode
                anchors.left: {modePowerRect.isCoag ? power.right : modePowerRect.left}
                anchors.right: {modePowerRect.isCoag ? modePowerRect.right : power.left}
                anchors.top: modePowerRect.top
                anchors.bottom: modePowerRect.bottom
            }
            AnchorChanges {
                target: powerPlusButton
                anchors.right: undefined
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: powerMinusButton
                anchors.left: undefined
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: powerSlider
                anchors.left: undefined
                anchors.right: undefined
                anchors.verticalCenter: undefined
            }
        },
        State {
            name: "expanded"
            PropertyChanges { target: powerPlusButton;  visible: (modeId != 1000) }
            PropertyChanges { target: powerMinusButton; visible: (modeId != 1000) }
            PropertyChanges { target: powerSlider;      visible: (modeId != 1000) }
            PropertyChanges {
                target: powerLabel;
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 50
            }
            PropertyChanges {
                target: modeLabel;
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 28
            }
            PropertyChanges {
                target: power;
                anchors.topMargin: 100
            }
            PropertyChanges {
                target: modeSelectButton;
                enabled: true
            }
            AnchorChanges {
                target: powerPlusButton
                anchors.right: modePowerRect.right
                anchors.bottom: modePowerRect.bottom
            }
            AnchorChanges {
                target: powerMinusButton
                anchors.left: modePowerRect.left
                anchors.bottom: modePowerRect.bottom
            }
            AnchorChanges {
                target: powerSlider
                anchors.left: powerMinusButton.right
                anchors.right: powerPlusButton.left
                anchors.verticalCenter: powerPlusButton.verticalCenter
            }
            AnchorChanges {
                target: mode
                anchors.left: modePowerRect.left
                anchors.right: modePowerRect.right
                anchors.top: modePowerRect.top
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: power
                anchors.left: modePowerRect.left
                anchors.right: modePowerRect.right
                anchors.top: modePowerRect.top
                anchors.bottom: undefined
            }
        }
    ]
    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"
            NumberAnimation {  duration: 100; easing.type: Easing.InQuad }
        },
        Transition {
            from: "expanded"
            to: "collapsed"
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }
    ]
}
