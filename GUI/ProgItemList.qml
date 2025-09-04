import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Rectangle {
    id: recProgs
    // property alias innerModel: repeatRoot.model
    signal clickedButton(int idx)
    signal returnButtonPressed()
    color: "darkblue"
    Button {
        id: retButton

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 100
        height: 50

        onClicked: recProgs.returnButtonPressed()
    }
    GridView {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: retButton.top

    // Repeater {
        id: repeatRoot
        model: 55
        clip: true

        delegate: Button {
            id: progNumber
            width: 80
            height: 80
            // Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            // Layout.preferredHeight: state === "expanded" ?
            //                             repeatRoot.calculateExpandedHeight() :
            //                             repeatRoot.calculateCollapsedHeight()
            background: Rectangle {
                radius: 8
                color: "transparent"
                border.color: "white"
                border.width: 2
                Text {
                    id: name
                    text: index
                    color: "white"
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
            }
            anchors.margins: 3

            Connections {
                target: progNumber
                function onClicked() {
                    recProgs.clickedButton(index)
                }
            }
        }
    // }
    }
}

