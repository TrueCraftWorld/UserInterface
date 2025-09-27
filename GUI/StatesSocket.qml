import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot

    property string title
    property int socketId

    property int socketPedal

    property string cutModeName
    property int cutModePower
    property int cutModeId
    property int cutMaxPower
    property int cutInstrumId
    property string cutInstrumName: qsTr("не выбран")

    property string coagModeName
    property int coagModePower
    property int coagModeId
    property int coagMaxPower
    property int coagInstrumId
    property string coagInstrumName: qsTr("не выбран")

    signal modeEditDialogRequest(int socketId, bool isCoag)
    signal instrumEditDialogRequest(int socketId, bool isCoag)
    signal newPower(int socketId, int pwr, bool isCoag)
    signal pedSelect(int socketId, int ped)
    signal socketExpandRequest()
    signal socketCollapseRequest()

    state: "expanded"
    color: "transparent"

    HalfSocket {
        id:         leftRect
        isCoag:     false
        state:      socketRoot.state
        modeName:   socketRoot.cutModeName
        modePower:  socketRoot.cutModePower
        modeId:     socketRoot.cutModeId
        maxPower:   socketRoot.cutMaxPower
        instrumId:  socketRoot.cutInstrumId
        instrumName:socketRoot.cutInstrumName
    }
    HalfSocket {
        id:         rightRect
        isCoag:     true
        state:      socketRoot.state
        modeName:   socketRoot.coagModeName
        modePower:  socketRoot.coagModePower
        modeId:     socketRoot.coagModeId
        maxPower:   socketRoot.coagMaxPower
        instrumId:  socketRoot.coagInstrumId
        instrumName:socketRoot.coagInstrumName
    }
    Rectangle {
        id: middleRect
        color: "black"
        width: fontMetrics.advanceWidth("MONO 22")

        Label {
            id: socketNameLabel
            anchors.fill: parent
            anchors.margins: 10
            text: title
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignTop
        }
        FontMetrics {
            id: fontMetrics
            font: socketNameLabel.font
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketRoot.state === "collapsed") {
                    socketRoot.socketExpandRequest()
                } else {
                    socketRoot.socketCollapseRequest()
                }
            }
        }
    }
    Pedal {
        id: pedalRect
        pedalStateIdx: socketRoot.socketPedal
        width: fontMetrics.advanceWidth("PEDAL")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
    PedalEditor {
        id: pedPop
    }

    Connections {
        target: pedPop
        function onPedSelected(idx) {
            console.log("pedSelect", idx)
            if (idx >=0 && idx <=4) {
                socketRoot.pedSelect(socketId, idx)
            }
            pedPop.close()
        }
    }
    Connections {
        target: pedalRect
        function onPedalMenuRequest() {
            pedPop.selectedPed = socketRoot.socketPedal
            pedPop.shownPedalsArray = [1,2,3,4]
            pedPop.open()
        }
    }
    Connections {
        target: rightRect
        function onNewPower(pwr) {
            socketRoot.newPower(socketRoot.socketId, pwr, true)
        }
    }
    Connections {
        target: rightRect
        function onModeEditDialogRequest() {
            socketRoot.modeEditDialogRequest(socketRoot.socketId, true)
        }
    }
    Connections {
        target: rightRect
        function onInstrumEditDialogRequest() {
            socketRoot.instrumEditDialogRequest(socketRoot.socketId, true)
        }
    }
    Connections {
        target: leftRect
        function onNewPower(pwr) {
            socketRoot.newPower(socketRoot.socketId, pwr, false)
        }
    }
    Connections {
        target: leftRect
        function onModeEditDialogRequest() {
            socketRoot.modeEditDialogRequest(socketRoot.socketId, false)
        }
    }
    Connections {
        target: leftRect
        function onInstrumEditDialogRequest() {
            socketRoot.instrumEditDialogRequest(socketRoot.socketId, false)
        }
    }

    states: [
        // Свернутое состояние
        State {
            name: "collapsed"
            AnchorChanges {
                target: middleRect
                anchors.left: leftRect.right
                anchors.right: undefined
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: middleRect
                color: "black"
                width: fontMetrics.advanceWidth("MONO 22")
            }
            AnchorChanges {
                target: leftRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: leftRect
                color: "black"
                width: (parent.width - fontMetrics.advanceWidth("MONO 22MONO")) * .5
            }
            AnchorChanges {
                target: rightRect
                anchors.left: middleRect.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: rightRect
                color: "black"
                width: (parent.width - fontMetrics.advanceWidth("MONO 22MONO")) * .5
            }
            AnchorChanges {
                target: pedalRect
                anchors.top: parent.top
            }
        },
        // Развернутое состояние
        State {
            name: "expanded"
            AnchorChanges {
                target: middleRect
                anchors.horizontalCenter: undefined
                anchors.left: parent.left
                anchors.right: rightRect.right
                anchors.top: parent.top
                anchors.bottom: undefined
            }
            PropertyChanges {
                target: middleRect
                color: "transparent"
                height: fontMetrics.height + socketNameLabel.anchors.margins
            }

            AnchorChanges {
                target: leftRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: leftRect
                width: (parent.width - fontMetrics.advanceWidth("MONO")) * .5
            }

            AnchorChanges {
                target: rightRect
                anchors.left: leftRect.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
            PropertyChanges {
                target: rightRect
                width: (parent.width - fontMetrics.advanceWidth("MONO")) * .5
            }

            AnchorChanges {
                target: pedalRect
                anchors.top: parent.top
            }
        }
    ]
    // Переходы между состояниями (опционально)
    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"
            NumberAnimation {  duration: 100; easing.type: Easing.InQuad }
        },
        Transition {
            from: "expanded"
            to: "collapsed"
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }
    ]
}
