import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: halfSocketRoot
    // required property ломает передачу свойсвт по умолчанию из делегата....
    // required property bool isCoag
    property bool isCoag
    property string modeName
    property int modePower
    property int maxPower
    property int socketId
    property int instrumId
    property string instrumName: qsTr("не выбран")

    signal modeEditDialogRequest()
    signal instrumEditDialogRequest()

    InstrumRect {
        id: instrumRect
        isCoag: halfSocketRoot.isCoag
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
        anchors {
            top: instrumRect.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onModeEditDialogRequest: halfSocketRoot.modeEditDialogRequest()
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
                height: halfSocketRoot.height/2
            }
        }
    ]
}
