import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Window {
    width: 1280
    height: 800
    visible: true
    title: qsTr("Hello World")

    ColumnLayout {
        id: workingArea
        anchors.fill: parent
        spacing: 5
        Collapsible {
            id: bi1
            width: parent.width
            socketName: "SOCKET"

            Layout.fillWidth: true
            Layout.fillHeight: true

            content: DummySocket {
                anchors.fill: parent
                coagModeName: "FORCE"
                coagModePower: "80"
                cutModeName: "CUT"
                cutModePower: "300"
            }
        }
        Collapsible {
            id: bi2
            width: parent.width
            socketName: "SOCKET"

            Layout.fillWidth: true
            Layout.fillHeight: true

            content: DummySocket {
                anchors.fill: parent
                coagModeName: "FORCE"
                coagModePower: "80"
                cutModeName: "CUT"
                cutModePower: "300"
            }
        }
        Collapsible {
            id: mono1
            width: parent.width
            socketName: "SOCKET"

            Layout.fillWidth: true
            Layout.fillHeight: true

            content: DummySocket {
                anchors.fill: parent
                coagModeName: "FORCE"
                coagModePower: "80"
                cutModeName: "CUT"
                cutModePower: "300"
            }
        }
        Collapsible {
            id: mono2
            width: parent.width
            socketName: "SOCKET"

            Layout.fillWidth: true
            Layout.fillHeight: true

            content: DummySocket {
                anchors.fill: parent
                coagModeName: "FORCE"
                coagModePower: "80"
                cutModeName: "CUT"
                cutModePower: "300"
            }
        }
    }

}
