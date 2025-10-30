import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot
    color: "transparent"

    property string title
    property int socketId
    property int socketState

    property string cutModeName
    property int cutModePower
    property int cutModeId
    property int cutMaxPower
    property int cutInstrumId
    property string cutInstrumName: qsTr("не выбран")
    property bool cutIsEndo: false

    property string coagModeName
    property int coagModePower
    property int coagModeId
    property int coagMaxPower
    property int coagInstrumId
    property string coagInstrumName: qsTr("не выбран")
    property bool coagIsEndo: false

    signal modeEditDialogRequest(int socketId, bool isCoag)
    signal instrumEditDialogRequest(int socketId, bool isCoag)
    signal newPower(int socketId, int pwr, bool isCoag)
    signal socketExpandRequest()
    signal socketCollapseRequest()
    // signal absolutePositionChanged(int socketId, real absoluteY)  // Изменение позиции для привязки педалей

//    state: "expanded"
    // state: model.socketdisplaymode

    // Принудительно обновляем state при изменении модели
    property string currentModelState: model.socketdisplaymode
    onCurrentModelStateChanged: {
        if (state !== currentModelState) {
            socketRoot.state = currentModelState
        }
    }
    onSocketStateChanged: {
        if (socketState == 3) {
            activationIndicator.isCoag = true
            activationIndicator.modeName = coagModeName
            activationIndicator.power = coagModePower
            activationIndicator.open();
        } else if (socketState == 4) {
            activationIndicator.isCoag = false
            activationIndicator.modeName = cutModeName
            activationIndicator.power = cutModePower
            activationIndicator.open();
        } else {
            activationIndicator.close();
        }
    }

    // Логирование абсолютного положения по высоте при изменении позиции
    // onYChanged: {
    //     var absY = mapToItem(null, 0, 0).y
    //     absolutePositionChanged(socketId, absY)
    // }

    // onHeightChanged: {
    //     var absY = mapToItem(null, 0, 0).y
    //     absolutePositionChanged(socketId, absY)
    // }

    // onStateChanged: {
    //     var absY = mapToItem(null, 0, 0).y
    //     absolutePositionChanged(socketId, absY)
    // }

    // Component.onCompleted: {
    //     var absY = mapToItem(null, 0, 0).y
    //     absolutePositionChanged(socketId, absY)
    // }

    // MouseArea для всего сокета - переход в expanded
   MouseArea {
       id: socketMouseArea
       anchors.fill: parent
       onClicked: {
           if (socketRoot.state === "collapsed") {
               socketRoot.state = "expanded"
               socketRoot.socketExpandRequest()
           }
       }
       // Не перехватываем события от дочерних элементов
       propagateComposedEvents: true
       // Не перехватываем события, если сокет уже развернут
       enabled: socketRoot.state === "collapsed"
   }

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
        isEndo:     socketRoot.cutIsEndo

        // Перехватываем события от HalfSocket только для разворачивания
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketRoot.state === "collapsed") {
                    socketRoot.state = "expanded"
                    socketRoot.socketExpandRequest()
                }
                mouse.accepted = true // Останавливаем распространение события
            }
            // Не перехватываем события, если сокет уже развернут
            enabled: socketRoot.state === "collapsed"
        }
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
        isEndo:     socketRoot.coagIsEndo

        // Перехватываем события от HalfSocket только для разворачивания
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketRoot.state === "collapsed") {
                    socketRoot.state = "expanded"
                    socketRoot.socketExpandRequest()
                }
                mouse.accepted = true // Останавливаем распространение события
            }
            // Не перехватываем события, если сокет уже развернут
            enabled: socketRoot.state === "collapsed"
        }
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
            color: "white"
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
    Activation {
        id: activationIndicator
        parent: socketRoot
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
//            PropertyChanges {
//                target: leftRect
//                color: "black"
//                width: (parent.width - fontMetrics.advanceWidth("MONO 22MONO")) * .5
//            }
            AnchorChanges {
                target: rightRect
                anchors.left: middleRect.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
//            PropertyChanges {
//                target: rightRect
//                color: "black"
//                width: (parent.width - fontMetrics.advanceWidth("MONO 22MONO")) * .5
//            }
        },
        // Развернутое состояние
        State {
            name: "expanded"
            AnchorChanges {
                target: middleRect
                anchors.horizontalCenter: undefined
                anchors.left: parent.left
                anchors.right: parent.right
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
                anchors.right: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
//            PropertyChanges {
//                target: leftRect
//                width: (parent.width - fontMetrics.advanceWidth("MONO")) * .5
//            }

            AnchorChanges {
                target: rightRect
                anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
//            PropertyChanges {
//                target: rightRect
//                width: (parent.width - fontMetrics.advanceWidth("MONO")) * .5
//            }
        }
    ]
}
