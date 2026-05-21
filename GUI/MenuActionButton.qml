import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    property string iconSource: ""
    property color accentColor: "#faa731"
    property color textColor: "#264093"
    property int labelPixelSize: 36
    property int cornerRadius: 28
    property int iconSize: 88
    property int maxLabelLines: 2

    padding: 0
    topPadding: 10
    bottomPadding: 10
    leftPadding: 16
    rightPadding: 12

    background: Rectangle {
        radius: control.cornerRadius
        color: "white"
        border.width: 2
        border.color: control.accentColor
    }

    contentItem: Item {
        Text {
            id: actionLabel
            anchors {
                left: parent.left
                right: actionIcon.left
                verticalCenter: parent.verticalCenter
                rightMargin: 12
            }
            text: control.text
            color: control.textColor
            font.pixelSize: control.labelPixelSize
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            maximumLineCount: control.maxLabelLines
            lineHeight: 1.04
            elide: Text.ElideRight
        }

        Image {
            id: actionIcon
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            source: control.iconSource
            width: control.iconSize
            height: control.iconSize
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
    }
}
