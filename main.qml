import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.CuteKeyboard 1.0

import StratifyLabs.UI 2.0

Window {
    id: container
    width: 1280
    height: 800
    visible: true
    title: qsTr("Hello World")
    color: "darkslategray"

    StatusBar {
        id: statusDummy
        text: "Quick brown fox jumps over the lazy dog"
        anchors {
            bottom: socketsDummy.top
            right: parent.right
            left: parent.left
            top: parent.top
            margins: 10
        }
    }

    SocketContainer {
        id: socketsDummy
        width: 980
        height: 700
        radius: 8
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 10
        }
    }
    Rectangle {
        id: argonDummy
        // height: .75 * socketsDummy.height
        radius: 8
        color: "lightgray"
        anchors {
            left: parent.left
            right: socketsDummy.left
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 10
            topMargin: 0
            top: socketsDummy.top
            bottom: neutralDummy.top
        }
        border {
            color: "black"
            width: 1
        }
    }
    Rectangle {
        id: neutralDummy
        height: .25 * socketsDummy.height
        radius: 8
        color: "green"
        anchors {
            left: parent.left
            right: socketsDummy.left
            bottom: parent.bottom
            margins: 10
        }
        border {
            color: "black"
            width: 1
        }
    }

    Drawer {
        id: leftDrawer
        width: 0.8 * container.width
        height: container.height
        SettingsMain {
            anchors.fill: parent
        }
    }

    Connections {
        target: statusDummy
        function onDrawerCalled() {
            leftDrawer.open()
        }
    }

    // InputPanel {
    //     id: inputPanel
    //     z: 99
    //     y: root.height
    //     availableLanguageLayouts: ["Ru","En"]
    //     anchors.left: parent.left
    //     anchors.right: parent.right

    //     states: State {
    //         name: "visible"
    //         when: Qt.inputMethod.visible
    //         PropertyChanges {
    //             target: inputPanel
    //             y: root.height - inputPanel.height
    //         }
    //     }
    //     transitions: Transition {
    //         from: ""
    //         to: "visible"
    //         reversible: true
    //         ParallelAnimation {
    //             NumberAnimation {
    //                 properties: "y"
    //                 duration: 150
    //                 easing.type: Easing.InOutQuad
    //             }
    //         }
    //     }
    // }


}
