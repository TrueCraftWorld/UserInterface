import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: halfSocketRoot
    color: "transparent"

    property bool isCoag
    property string modeName
    property int modePower
    property int modeId
    property int maxPower
    property int socketId
    property int instrumNum
    property string instrumName: qsTr("не выбран")
    property bool isEndo: false

    signal modeEditDialogRequest()
    signal instrumEditDialogRequest()
    signal newPower(int power)


    InstrumRect {
        id: instrumRect
        isCoag: halfSocketRoot.isCoag
        instrumName: halfSocketRoot.instrumName
        instrumNum: halfSocketRoot.instrumNum
        modeId: halfSocketRoot.modeId
        isEndo: halfSocketRoot.isEndo
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    ModePowerRect {
        id: modePower
        state: halfSocketRoot.state
        isCoag: halfSocketRoot.isCoag
        modeName: halfSocketRoot.modeName
        modePower: halfSocketRoot.modePower
        modeId: halfSocketRoot.modeId
        maxPower: halfSocketRoot.maxPower
        isEndo: halfSocketRoot.isEndo
        anchors {
            top: instrumRect.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    Connections {
        target: instrumRect
        function onInstrumEditDialogRequest() {
            halfSocketRoot.instrumEditDialogRequest()
        }
    }
    Connections {
        target: modePower
        function onModeEditDialogRequest() {
            halfSocketRoot.modeEditDialogRequest()
        }
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
}
