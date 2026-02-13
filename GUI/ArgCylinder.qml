import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {

    property bool cylConnected
    property bool cylSelected
    property bool isFirst: true
    property bool interactive: true  // Разрешить клики по баллону
    signal cylClicked()

    readonly property int step: 16

    id: cylinderRoot
    color: "transparent"

    Rectangle {
        id: cylinderBody
        width: step * 4
        height: step * 11
        radius: width / 2
        color: cylConnected ? (cylSelected ? "#30f020" : "#80f070") : "gray"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        border.color: "#d9d9d9"
        border.width: 6
    }
    Rectangle {
        id: cylinderNeck
        width: step
        height: step * 2
        radius: width / 2
        color: "#d9d9d9"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: cylinderBody.top
        anchors.bottomMargin: -(step / 2)
    }
    Rectangle {
        id: cylinderValve
        width: step * 3
        height: step
        radius: height / 2
        color: "#d9d9d9"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: cylinderNeck.top
        anchors.topMargin: 3
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: isFirst ? "1" : "2"
        font.pixelSize: {
            if (cylConnected) {
                if (cylSelected) return step * 2.5
                else return step * 2
            }
            else return step * 2
        }
        font.bold: true
        color: "black"
    }
    Label {
        id: empty1
        text: "X"
        anchors.fill: parent
        font.pixelSize: step * 5
        font.bold: true
        color: "yellow"
        visible: !cylConnected
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
    }

    MouseArea {
        id: cylinder1MA
        anchors.fill: parent
        enabled: cylinderRoot.interactive
        onClicked: cylinderRoot.cylClicked()
    }
}
