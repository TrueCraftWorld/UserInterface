// CollapsibleSection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    id: root

    property string title: "Section"
    property bool expanded: true
    property alias contentItem: content.data
    property int headerHeight: 40

    implicitHeight: content.height ? content.height : header.height
    height: content.height ? content.height : header.height
    clip: true

    Item {
        id: content
        width: parent.width
        anchors.top: header.top
        // anchors.topMargin: header.height
        height: childrenRect.height
        visible: expanded
        // z: 22
    }
    Rectangle {
        id: header
        width: parent.width
        height: 40
        radius: 8
        // z: 1
        color: root.expanded ? "transparent" : "#e0e0e0"
        border.color: root.expanded ? "transparent" : "#cccccc"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: root.title.toUpperCase()
            font.bold: true
        }

        Rectangle {
            anchors.right: parent.right
            anchors.margins: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 8
            Text {
                anchors.fill: parent
                anchors.centerIn: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                text: root.expanded ? "▲" : "▼"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.expanded = !root.expanded
            }

        }
    }


    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }
}
