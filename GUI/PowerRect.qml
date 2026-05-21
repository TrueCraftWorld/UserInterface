import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property color borderColor: "transparent"
    property color idleFillColor: "transparent"
    property color idleTextColor: "white"
    property color selectedTextColor: "black"
    property int power
    property bool selected: false
    property bool isEndo: false
    signal powerChosen(int pwr)
    id: but
    visible: (power != 0)
    background: Rectangle {
        radius: 8
        border.width: 2
        border.color: borderColor
        color: selected ? borderColor : idleFillColor
    }
    Label {
        id:powerText
        text: power
        visible: !isEndo
        anchors.fill: parent

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        font.bold: true
        font.pixelSize: 48
        color: selected ? selectedTextColor : idleTextColor
    }
    Column {
        id: endoRow
        visible: isEndo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            text: qsTr("рез-%1 коаг-%2").arg(Math.floor(power / 10)).arg(power % 10)
//            text: qsTr("эф.рез. %1").arg(Math.floor(power / 10))
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 32
            color: selected ? selectedTextColor : idleTextColor
        }
//        Text {
//            text: Math.floor(power / 10)
//            horizontalAlignment: Qt.AlignHCenter
//            verticalAlignment: Qt.AlignVCenter
//            font.pixelSize: 48
//            color: selected ? "black" : "white"
//        }
//        Text {
//            text: qsTr("эф.коаг. %1").arg(power % 10)
//            horizontalAlignment: Qt.AlignHCenter
//            verticalAlignment: Qt.AlignVCenter
//            font.pixelSize: 26
//            color: selected ? "black" : "white"
//        }
//        Text {
//            text: (power % 10)
//            horizontalAlignment: Qt.AlignHCenter
//            verticalAlignment: Qt.AlignVCenter
//            font.pixelSize: 48
//            color: selected ? "black" : "white"
//        }
    }

    onClicked: but.powerChosen(power)
}
