import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property color borderColor: "transparent"
    property int power
    property bool selected: false
    signal powerChosen(int pwr)
    id: but
    visible: (power != 0)
    background: Rectangle {
        radius: 8
        border.width: 2
        border.color: borderColor
        color: selected ? borderColor : "black"
    }
    Label {
        id:powerText
        text: power
        anchors.fill: parent

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pixelSize: 34
    }
    onClicked: but.powerChosen(power)
}
