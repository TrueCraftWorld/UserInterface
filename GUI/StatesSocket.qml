import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot
    color: "transparent"

    // Константы состояний сокета (соответствуют Onyx::SocStatus)
    readonly property int socketStateOff: 0          // S_OFF - Отключен
    readonly property int socketStateDisabled: 1    // S_DISABLED - Выключен, активация запрещена
    readonly property int socketStateEnabled: 2     // S_ENABLED - Включен, активация разрешена
    readonly property int socketStateActiveCoag: 3  // S_ACTIVE_COAG - Активирован, коагуляция
    readonly property int socketStateActiveCut: 4   // S_ACTIVE_CUT - Активирован, резание
    readonly property int socketStateError: 5        // S_ERROR - Ошибка, активация запрещена

    property string title
    property int socketId
    property int socketState

    property string cutModeName
    property int cutModePower
    property int cutModeId
    property int cutMaxPower
    property int cutInstrumNum
    property string cutInstrumName: qsTr("не выбран")
    property bool cutIsEndo: false

    property string coagModeName
    property int coagModePower
    property int coagModeId
    property int _coagAutoDisplayRev: 0
    property int coagMaxPower
    property int coagInstrumNum
    property string coagInstrumName: qsTr("не выбран")
    property bool coagIsEndo: false

    signal socketEditorRequest(int socketId, bool isCoag)

    readonly property string coagModeNameForDisplay: {
        var _ = _coagAutoDisplayRev
        var a = periphHandle.autoMode(socketId)
        var base = coagModeName
        if (coagModeId === 5) {
            if (a === 1)
                return base + qsTr(" АВТОСТОП")
            if (a === 2)
                return base + qsTr(" АВТОСТАРТ/СТОП")
        }
        if (coagModeId === 21 && socketId >= 2 && socketId <= 3 && a === 1)
            return base + qsTr(" АВТОСТОП")
        return base
    }

    state: "collapsed"

    onSocketStateChanged: {
//        console.log("socketState", socketState)
        if (socketState === socketStateActiveCoag) {
            activationIndicator.socketName = title
            activationIndicator.isCoag = true
            activationIndicator.modeName = coagModeNameForDisplay
            activationIndicator.power = coagModePower
            activationIndicator.isEndo = coagIsEndo
//            console.log("Activation: socketName=", title, "modeName=", coagModeName, "power=", coagModePower, "isEndo=", coagIsEndo)
            activationIndicator.open();
        } else if (socketState === socketStateActiveCut) {
            activationIndicator.socketName = title
            activationIndicator.isCoag = false
            activationIndicator.modeName = cutModeName
            activationIndicator.power = cutModePower
            activationIndicator.isEndo = cutIsEndo
//            console.log("Activation: socketName=", title, "modeName=", cutModeName, "power=", cutModePower, "isEndo=", cutIsEndo)
            activationIndicator.open();
        } else {
            activationIndicator.close();
        }
    }

    HalfSocket {
        id:         leftRect
        isCoag:     false
        state:      socketRoot.state
        modeName:   socketRoot.cutModeName
        modePower:  socketRoot.cutModePower
        modeId:     socketRoot.cutModeId
        maxPower:   socketRoot.cutMaxPower
        instrumNum: socketRoot.cutInstrumNum
        instrumName:socketRoot.cutInstrumName
        isEndo:     socketRoot.cutIsEndo

        MouseArea {
            anchors.fill: parent
            onClicked: socketRoot.socketEditorRequest(socketRoot.socketId, false)
        }
    }
    HalfSocket {
        id:         rightRect
        isCoag:     true
        state:      socketRoot.state
        modeName:   socketRoot.coagModeNameForDisplay
        modePower:  socketRoot.coagModePower
        modeId:     socketRoot.coagModeId
        maxPower:   socketRoot.coagMaxPower
        instrumNum: socketRoot.coagInstrumNum
        instrumName:socketRoot.coagInstrumName
        isEndo:     socketRoot.coagIsEndo

        MouseArea {
            anchors.fill: parent
            onClicked: socketRoot.socketEditorRequest(socketRoot.socketId, true)
        }
    }

//    Rectangle {
//        id: middleRect
//        color: "green"
//        width: fontMetrics.advanceWidth("MONO 22")
//        height: 60

//        Label {
//            id: socketNameLabel
//            anchors.fill: parent
//            anchors.margins: 10
//            text: title
//            color: "white"
//            font.pixelSize: 24
//            font.bold: true
//            horizontalAlignment: Qt.AlignHCenter
//            verticalAlignment: Qt.AlignTop
//        }
//        FontMetrics {
//            id: fontMetrics
//            font: socketNameLabel.font
//        }
//        MouseArea {
//            anchors.fill: parent
//            onClicked: socketRoot.socketEditorRequest(socketRoot.socketId, false)
//        }

//    }
    Activation {
        id: activationIndicator
        parent: socketRoot
    }

    Connections {
        target: periphHandle
        function onAutoModeChanged(socketId, mode) {
            socketRoot._coagAutoDisplayRev++
        }
    }

    states: [
        // Свернутое состояние
        State {
            name: "collapsed"
            AnchorChanges {
                target: middleRect
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: undefined
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
                anchors.right: middleRect.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }

            AnchorChanges {
                target: rightRect
                anchors.left: middleRect.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }
    ]
}
