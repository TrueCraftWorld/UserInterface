import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: neutButRoot
    property color borderColor
    property int borderWidth
    property color neutColor
    property color theColor
    property color innerTextColor
    property alias innerText: optionalText.text
    property int innerTextFontSize: 14  // Размер шрифта для innerText
    property int neutRadius: 12
    property alias radius : backRect.radius
    property bool divided
    property bool button: true

    component DevHalf: Rectangle {
        id: divHalfRoot
        color: "transparent"
        property bool isLeft
        transform: Scale {
            origin.x: divHalfRoot.width / 2
            origin.y: divHalfRoot.height / 2
            xScale: divHalfRoot.isLeft ? -1 : 1
        }
        Rectangle {
            id: body
            radius: neutRadius
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 0
            }
            height: .75 * parent.height
            color: neutColor
        }
        Rectangle {
            id: handle
            radius: body.radius/2
            anchors {
                left: parent.left
                bottom: body.top
                top: parent.top
                margins: 0
                bottomMargin: -(1.1 * (handle.radius + body.radius))
            }
            width: nonDividedBody.width * .2
            color: neutColor
        }
    }

    background: Rectangle {
        id: backRect
        anchors.fill: parent
        anchors.margins: 0
        color: theColor
        radius: 10
        border {
            color: borderColor
            width: borderWidth
        }
    }

    contentItem: Rectangle {
        color: "transparent"
        anchors {
            fill: parent
            topMargin: parent.height * .1
            bottomMargin: parent.height * .1
            leftMargin: parent.width * .1
            rightMargin: parent.width * .1
        }
        Rectangle {
            id: darker
            visible: button
            anchors.centerIn: parent
            width: backRect.width
            height: backRect.height
            color: "black"
            opacity: neutButRoot.pressed ? 0.2 : 0
            radius: backRect.radius
        }

        Label {
            id: optionalText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            visible: text.length != 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            color: innerTextColor
            font.pixelSize: innerTextFontSize
        }
        Rectangle {
            id: nonDividedRoot
            visible: !divided
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: optionalText.visible ? optionalText.height : 0
                bottomMargin: 0
                leftMargin: 0
                rightMargin: 0
            }
            Rectangle {
                id: nonDividedBody
                radius: neutRadius
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 0
                }
                height: .75 * parent.height
                color: neutColor
            }
            Rectangle {
                id: nonDividedHandle
                radius: neutRadius/2
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: nonDividedBody.top
                    top: parent.top
                    margins: 0
                    bottomMargin: -nonDividedHandle.radius
                }
                width: nonDividedBody.width * .2
                color: neutColor
            }
        }
        Rectangle {
            id: dividedRoot
            visible: divided
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: optionalText.visible ? optionalText.height : 0
                bottomMargin: 0
                leftMargin: 0
                rightMargin: 0
            }
            DevHalf {
                id: leftDivHalf
                isLeft: true
                anchors {
                    left: parent.left
                    right: parent.horizontalCenter
                    top: parent.top
                    bottom: parent.bottom
                    margins: 0
                    rightMargin: parent.width * .05
                }
            }
            DevHalf {
                id: rightDivHalf
                isLeft: false
                anchors {
                    right: parent.right
                    left: parent.horizontalCenter
                    top: parent.top
                    bottom: parent.bottom
                    margins: 0
                    leftMargin: parent.width * .05
                }
            }
        }
    }


}
