import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias innerModel: theView.model
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        ListView {
            id: theView
            // model: innerModel
            Layout.fillHeight: true
            Layout.fillWidth: true
            layoutDirection: Qt.LeftToRight
            verticalLayoutDirection: ListView.TopToBottom
            displayMarginBeginning: 15
            displayMarginEnd: 15
            spacing: 5

            clip: true
            // anchors.fill: parent

            delegate: Rectangle {
                height: 100
                width: ListView.view.width
                color: "green"
                Rectangle {
                    id: itemImageRect
                    height: parent.height
                    width: parent.height
                    anchors {
                        top:parent.top
                        // bottom: parent.bottom
                        left: parent.left
                    }
                    color: "cyan"
                    Image {
                        id: itemImage
                        source: "file"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }
                Rectangle {
                    id: itemNameRect
                    color: "darkslategray"
                    anchors {
                        top:parent.top
                        bottom: parent.bottom
                        left: itemImageRect.right
                        right:  parent.right
                    }
                    Label {
                        anchors.fill: parent
                        text: model.itemName
                    }
                }
            }
        }
        // Item {
        //     Layout.fillHeight: true
        // }

    }
}
