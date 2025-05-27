// CollapsibleSection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    id: root

    property string title: "Section"
    property bool expanded: false
    property alias contentItem: content.data

    implicitHeight: header.height + content.height
    clip: true

    Rectangle {
        id: header
        width: parent.width
        height: 40
        color: "#e0e0e0"
        border.color: "#cccccc"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            font.bold: true
        }

        Button {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            text: root.expanded ? "▲" : "▼"
            onClicked: root.expanded = !root.expanded
        }
    }

    Item {
        id: content
        width: parent.width
        anchors.top: header.bottom
        height: childrenRect.height
        visible: expanded
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }
}
