import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: halfSocketRoot

    property bool isCoag
    property string modeName
    property int modePower
    property int maxPower
    property int socketId
    property int instrumId
    property string instrumName: qsTr("не выбран")

    signal modeEditDialogRequest()
    signal instrumEditDialogRequest()
    signal newPower(int power)

    InstrumRect {
        id: instrumRect
        isCoag: halfSocketRoot.isCoag
        instrumName: halfSocketRoot.instrumName
        instrumId: halfSocketRoot.instrumId
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onInstrumEditDialogRequest: halfSocketRoot.instrumEditDialogRequest()
    }
    ModePowerRect {
        id: modePower
        state: halfSocketRoot.state
        isCoag: halfSocketRoot.isCoag
        modeName: halfSocketRoot.modeName
        modePower: halfSocketRoot.modePower
        maxPower: halfSocketRoot.maxPower
        anchors {
            top: instrumRect.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onModeEditDialogRequest: halfSocketRoot.modeEditDialogRequest()

    }

    Connections {
        target: modePower
        function onNewPower(pwr) {
            halfSocketRoot.newPower(pwr)
        }
    }

    states: [
        State {
            name: "collapsed"
            PropertyChanges {
                target: instrumRect;
                visible: false
                height: 0
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: instrumRect;
                visible: true
                height: halfSocketRoot.height * .4
            }
        }
    ]
    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        },
        Transition {
            from: "expanded"
            to: "collapsed"
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }
    ]
}
