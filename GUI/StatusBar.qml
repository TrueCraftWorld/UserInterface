import QtQuick 2.15
import StratifyLabs.UI 2.0

Rectangle {
    id: statusRoot
    signal drawerCalled()
    signal saveCalled()
    property alias text: mainText.text
    property alias versionText: appVersionText.text
    property bool saveHighlighted: false
    readonly property int sideSpacing: 12
    readonly property int leftOccupiedWidth: drawerButton.width + sideSpacing
    readonly property int rightOccupiedWidth: saveButton.width
                                            + (appVersionText.visible ? appVersionText.width + sideSpacing : 0)
                                            + sideSpacing
    readonly property int titleSideMargin: Math.max(leftOccupiedWidth, rightOccupiedWidth)
    readonly property int titleLargeFontSize: 42
    readonly property int titleCompactFontSize: 30
    readonly property bool useCompactTitle: mainTextLargeMetrics.width > mainText.width

    border {
        width: 1
        color: "black"
    }
    radius: 8

    SButton {
        id: drawerButton
        height: Math.round(parent.height * 1.30)
        width: height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        iconString: Fa.Icon.bars
        style: "btn-naked lg"
        scale: 1.12

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
        font.pixelSize: statusRoot.useCompactTitle
                        ? statusRoot.titleCompactFontSize
                        : statusRoot.titleLargeFontSize
        wrapMode: Text.WordWrap
        maximumLineCount: statusRoot.useCompactTitle ? 2 : 1
        elide: Text.ElideRight
    }
    TextMetrics {
        id: mainTextLargeMetrics
        text: mainText.text
        font.pixelSize: statusRoot.titleLargeFontSize
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
        height: Math.round(parent.height * 1.50)
        width: container.pedalPanelWidth
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        iconString: Fa.Icon.save
        style: "btn-naked lg"
        scale: 1.12

        onClicked: {
            statusRoot.saveCalled()
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            radius: 10
            color: "#70F870"
            opacity: statusRoot.saveHighlighted ? 0.95 : 0.0
            z: -1
        }
    }

}
