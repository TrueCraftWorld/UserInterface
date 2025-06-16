import QtQuick 2.15
import StratifyLabs.UI 2.0

Rectangle {
    id: statusRoot
    signal drawerCalled()
    signal savePressed()
    property alias text: mainText.text

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
        anchors.left: drawerButton.right
        anchors.right: saveButton.left

    }
    SButton {
        id: saveButton
        height: parent.height
        width: height
        anchors.right: parent.right
        iconString: Fa.Icon.save
        style: "btn-naked"

            onClicked: {
                statusRoot.savePressed()
            }
    }

}
