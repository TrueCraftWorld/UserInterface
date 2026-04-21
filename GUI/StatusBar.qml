import QtQuick 2.15
import StratifyLabs.UI 2.0

Rectangle {
    id: statusRoot
    signal drawerCalled()
    signal saveCalled()
    property alias text: mainText.text
    property alias versionText: appVersionText.text
    readonly property int sideSpacing: 12
    readonly property int leftOccupiedWidth: drawerButton.width + sideSpacing
    readonly property int rightOccupiedWidth: saveButton.width
                                            + (appVersionText.visible ? appVersionText.width + sideSpacing : 0)
                                            + sideSpacing
    readonly property int titleSideMargin: Math.max(leftOccupiedWidth, rightOccupiedWidth)

    border {
        width: 1
        color: "black"
    }
    radius: 8

    SButton {
        id: drawerButton
        height: parent.height
        width: height
        anchors.left: parent.left
        iconString: Fa.Icon.bars
        style: "btn-naked"

        onClicked: {
            statusRoot.drawerCalled()
        }
    }
    SText {
        id: mainText
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: titleSideMargin
        anchors.right: parent.right
        anchors.rightMargin: titleSideMargin
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    SText {
        id: appVersionText
        height: parent.height
        width: visible ? Math.min(implicitWidth, statusRoot.width * 0.25) : 0
        anchors.right: saveButton.left
        anchors.rightMargin: sideSpacing
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        text: ""
        visible: text !== ""
    }
    SButton {
        id: saveButton
        height: parent.height
        width: height
        anchors.right: parent.right
        iconString: Fa.Icon.save
        style: "btn-naked"

        onClicked: {
            statusRoot.saveCalled()
        }
    }

}
