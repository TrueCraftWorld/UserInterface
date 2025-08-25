import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias innerModel: theView.model
    property string imageSource
    // property alias imageSource: itemImage.source

    color: "darkgray"
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
            spacing: 5

            clip: true

            delegate: Rectangle {
                height: 100
                width: ListView.view.width
                color: "green"
                radius: 8
                Rectangle {
                    id: itemImageRect
                    height: parent.height
                    width: parent.height
                    radius: 8
                    anchors {
                        top:parent.top
                        left: parent.left
                    }
                    color: "cyan"
                    Image {
                        id: itemImage
                        asynchronous: true
                        source: imageSource.arg(model.itemId)
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }
                Rectangle {
                    id: itemImageRectBorder
                    width: 10
                    color: "cyan"
                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        right: itemImageRect.right
                    }
                }
                Rectangle {
                    id: itemNameRectBorder
                    width: 10
                    color: "darkslategray"
                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        left: itemNameRect.left
                    }
                }
                Rectangle {
                    id: itemNameRect
                    color: "darkslategray"
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
                    }
                }
            }
        }
    }
}
