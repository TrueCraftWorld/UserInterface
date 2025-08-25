import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property alias borderColor: but.border.color
    property int power
    signal powerChosen(int pwr)
    id: but
    radius: 6
    border.width: 2
    color: "darkslategray"

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
