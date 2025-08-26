import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property color borderColor: "transparent"
    property int power
    property bool selected: false
    signal powerChosen(int pwr)
    id: but
    radius: 6
    border.width: 2
    border.color: borderColor
    color: selected ? borderColor : "darkslategray"

    Label {
        id:powerText
        text: power
        anchors.fill: parent

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pixelSize: 34
    }

    MouseArea {
        anchors.fill: parent
        onClicked: but.powerChosen(power)
    }
}
