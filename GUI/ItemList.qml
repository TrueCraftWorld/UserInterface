import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Rectangle {
    id: itemList
    property alias innerModel: theView.model
    property string imageSourceTemplate
    property alias curIndex: theView.currentIndex

    signal newIndexSelected(int newIndex)

    color: "black"
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        ListView {
            id: theView
            Layout.fillHeight: true
            Layout.fillWidth: true
            layoutDirection: Qt.LeftToRight
            verticalLayoutDirection: ListView.TopToBottom
            displayMarginBeginning: 15
            displayMarginEnd: 15
            spacing: 10

            clip: true

            delegate: Rectangle {
                property bool isCurrent: (index == theView.currentIndex)
                height: 100
                width: ListView.view.width
                radius: 8
                color: "black"
                Rectangle {
                    id: itemImageRectBorder
                    width: 10
                    color: "black"

                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        right: itemImageRect.right
                    }
                }
                Rectangle {
                    id: itemNameRectBorder
                    width: 10
                    color: "black"
                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        left: itemNameRect.left
                    }
                }
                Rectangle {
                    id: itemImageRect
                    height: parent.height
                    width: parent.height
                    radius: 8
                    anchors {
                        top:parent.top
                        left: parent.left
                    }
                    color: "black"
                    Image {
                        id: itemImage
                        asynchronous: true
                        source: imageSourceTemplate.arg(model.itemId)
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }
                Rectangle {
                    id: itemNameRect
                    color: "black"
                    radius: 8
                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        left: itemImageRect.right
                        right:  parent.right
                    }
                    Label {
                        anchors.fill: parent
                        text: model.itemName
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        font.pixelSize: 18
                        color: "white"
                    }
                }
                Rectangle {
                    id: selectionBorder
                    anchors.fill: parent
                    color: "transparent"
                    border.width: isCurrent ? 3 : 0
                    radius: 8
                    border.color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        itemList.newIndexSelected(index)
                    }
                }
            }
        }
    }
}
