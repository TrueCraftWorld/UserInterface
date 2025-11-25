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
    property int cutInstrumNum
    property string cutInstrumName: qsTr("не выбран")
    property bool cutIsEndo: false

    property string coagModeName
    property int coagModePower
    property int coagModeId
    property int coagMaxPower
    property int coagInstrumNum
    property string coagInstrumName: qsTr("не выбран")
    property bool coagIsEndo: false

    signal modeEditDialogRequest(int socketId, bool isCoag)
    signal instrumEditDialogRequest(int socketId, bool isCoag)
    signal newPower(int socketId, int pwr, bool isCoag)
    signal socketExpandRequest()
    signal socketCollapseRequest()

    state: "expanded"

    onSocketStateChanged: {
//        console.log("socketState changed to", socketState, "for socket", socketId)
        if (socketState == 3) {
            // Принудительно закрываем перед открытием, чтобы гарантировать обновление
            if (activationIndicator.opened) {
                activationIndicator.close()
            }
            activationIndicator.isCoag = true
            activationIndicator.isEndo = coagIsEndo
            activationIndicator.modeName = coagModeName
            activationIndicator.power = coagModePower
            // Используем Qt.callLater для гарантии, что закрытие произошло
            Qt.callLater(function() {
                activationIndicator.open()
            })
        } else if (socketState == 4) {
            // Принудительно закрываем перед открытием, чтобы гарантировать обновление
            if (activationIndicator.opened) {
                activationIndicator.close()
            }
            activationIndicator.isCoag = false
            activationIndicator.isEndo = cutIsEndo
            activationIndicator.modeName = cutModeName
            activationIndicator.power = cutModePower
            // Используем Qt.callLater для гарантии, что закрытие произошло
            Qt.callLater(function() {
                activationIndicator.open()
            })
        } else {
            activationIndicator.close();
        }
    }

    // MouseArea для всего сокета - переход в expanded
   MouseArea {
       id: socketMouseArea
       anchors.fill: parent
       onClicked: {
           if (socketRoot.state === "collapsed") {
               socketRoot.socketExpandRequest()
           }
       }
       // Не перехватываем события от дочерних элементов
       propagateComposedEvents: true
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
        instrumNum: socketRoot.cutInstrumNum
        instrumName:socketRoot.cutInstrumName
        isEndo:     socketRoot.cutIsEndo

        // Перехватываем события от HalfSocket только для разворачивания
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketRoot.state === "collapsed") {
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
        instrumNum: socketRoot.coagInstrumNum
        instrumName:socketRoot.coagInstrumName
        isEndo:     socketRoot.coagIsEndo

        // Перехватываем события от HalfSocket только для разворачивания
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketRoot.state === "collapsed") {
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

            AnchorChanges {
                target: rightRect
                anchors.left: middleRect.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
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

            AnchorChanges {
                target: rightRect
                anchors.left: parent.horizontalCenter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }
    ]
}
