import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Rectangle {
    id: recProgs

    signal clickedButton(int idx)
    signal returnButtonPressed()
    Button {
        id: retButton

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 100
        height: 50

        onClicked: recProgs.returnButtonPressed()
    }

    Repeater {
        id: repeatRoot

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: retButton.top
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
            }
            anchors.margins: 3

            Connections {
                target: progNumber
                function onClicked() {
                    recProgs.clickedButton(index)
                }
            }
        }
    }
}

