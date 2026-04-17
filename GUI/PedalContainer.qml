import QtQuick 2.15
Rectangle {
    id: pedContainer

    property var innerModel
    signal pedMenuRequest(int socketId)
    readonly property int pedalSideMargin: 8
    readonly property int socketTopOffset: 65
    readonly property int socketSpacing: 10
    color: "#2c2c2c"
    clip: true

    function displaySocketName(name) {
        if (!name) {
            return ""
        }

        return String(name).replace(/\s+/g, "")
    }

    function uniformSocketHeight() {
        var socketCount = innerModel ? innerModel.rowCount() : 0
        if (socketCount <= 0) {
            return 0
        }

        return (height - socketTopOffset - socketCount * socketSpacing) / socketCount
    }

    function socketHeight(socketId) {
        var socketCount = innerModel ? innerModel.rowCount() : 0
        if (!innerModel || socketId < 0 || socketId >= socketCount) {
            return 0
        }
        return uniformSocketHeight()
    }

    function socketTop(socketId) {
        var top = socketTopOffset
        for (var i = 0; i < socketId; ++i) {
            top += socketHeight(i) + socketSpacing
        }
        return top
    }

    Repeater {
        id: repeat
        model: innerModel

        delegate: Item {
            id: socketPedalSlot
            visible: pedContainer.socketHeight(index) > 0
            x: 0
            y: pedContainer.socketTop(index)
            width: pedContainer.width
            height: pedContainer.socketHeight(index)

            Text {
                id: socketNameLabel
                width: Math.min(parent.width - 8, pedIcon.width + 60)
                height: Math.min(implicitHeight, Math.max(0, pedIcon.y - 6))
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 22
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
                text: pedContainer.displaySocketName(model.socketname)
                clip: true
            }

            Pedal {
                id: pedIcon
                width: Math.max(0, Math.min(parent.width - pedContainer.pedalSideMargin * 2, parent.height))
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                pedalStateIdx: model.socketpedal
                socketId: index
            }

            Connections {
                target: pedIcon
                function onPedalMenuRequest() {
                    pedContainer.pedMenuRequest(index)
                }
            }
        }
    }
}
