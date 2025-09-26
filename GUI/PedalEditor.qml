import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    property alias pedTitle : title.text
    property var shownPedalsArray: []

    id: pedalSelectRoot

    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    modal: true
    focus: true

    Label {
        id: title
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        // text:
    }
}
