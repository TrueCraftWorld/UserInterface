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

    readonly property color socketColor: {
        if (modeId === 1000) {
            return "darkgray"
        }
        return isCoag ? "blue" : "yellow"
    }
    readonly property bool hasInstrImage: modeId !== 1000
                                          && instrumNum > 0
                                          && instrumNum !== 1000
    readonly property int endoCutEffect: Math.floor(modePower / 10)
    readonly property int endoCoagEffect: modePower % 10

    Canvas {
        id: socketBackground
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var radius = 20
            var x = 0
            var y = 0
            var w = width
            var h = height

            ctx.beginPath()

            if (halfSocketRoot.isCoag) {
                // Для коагуляции скругляем правые углы.
                ctx.moveTo(x, y)
                ctx.lineTo(w - radius, y)
                ctx.arcTo(w, y, w, radius, radius)
                ctx.lineTo(w, h - radius)
                ctx.arcTo(w, h, w - radius, h, radius)
                ctx.lineTo(x, h)
                ctx.lineTo(x, y)
            } else {
                // Для резания скругляем левые углы.
                ctx.moveTo(x + radius, y)
                ctx.lineTo(w, y)
                ctx.lineTo(w, h)
                ctx.lineTo(x + radius, h)
                ctx.arcTo(x, h, x, h - radius, radius)
                ctx.lineTo(x, radius)
                ctx.arcTo(x, y, x + radius, y, radius)
            }

            ctx.closePath()
            ctx.fillStyle = halfSocketRoot.socketColor
            ctx.fill()
        }
    }

    Connections {
        target: halfSocketRoot
        function onModeIdChanged() { socketBackground.requestPaint() }
        function onIsCoagChanged() { socketBackground.requestPaint() }
        function onWidthChanged() { socketBackground.requestPaint() }
        function onHeightChanged() { socketBackground.requestPaint() }
    }

    Image {
        id: collapsedInstrImage
        visible: halfSocketRoot.hasInstrImage
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        width: 150
        height: 150
        source: "image://instruments/"
                + (halfSocketRoot.isCoag ? "coaginstr" : "cutinstr")
                + halfSocketRoot.instrumNum
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        anchors.left: halfSocketRoot.isCoag ? parent.left : undefined
        anchors.leftMargin: halfSocketRoot.isCoag ? 4 : undefined
        anchors.right: halfSocketRoot.isCoag ? undefined : parent.right
        anchors.rightMargin: halfSocketRoot.isCoag ? undefined : 4
    }

    Label {
        id: modeLabel
        text: modeId === 1000 ? qsTr("режим не выбран") : halfSocketRoot.modeName
        color: (halfSocketRoot.isCoag || modeId === 1000) ? "white" : "black"
        font.pixelSize:  modeId === 1000 ? 24 : 36
        font.bold: true
        wrapMode: Text.Wrap
        lineHeight: 0.82
        lineHeightMode: Text.ProportionalHeight
        maximumLineCount: 2
        elide: Text.ElideRight
        horizontalAlignment: halfSocketRoot.isCoag ? Text.AlignRight : Text.AlignLeft
        verticalAlignment: Text.AlignTop
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: halfSocketRoot.isCoag ? collapsedInstrImage.right : parent.left
        anchors.leftMargin: halfSocketRoot.isCoag ? 6 : 8
        anchors.right: halfSocketRoot.isCoag ? parent.right : collapsedInstrImage.left
        anchors.rightMargin: halfSocketRoot.isCoag ? 8 : 6
    }

    Label {
        id: powerLabel
        text: halfSocketRoot.modePower
        visible: !halfSocketRoot.isEndo && halfSocketRoot.modeId !== 1000
        color: halfSocketRoot.isCoag ? "white" : "black"
        font.pixelSize: 60
        font.bold: true
        horizontalAlignment: halfSocketRoot.isCoag ? Text.AlignRight : Text.AlignLeft
        verticalAlignment: Text.AlignBottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: halfSocketRoot.isCoag ? collapsedInstrImage.right : parent.left
        anchors.leftMargin: halfSocketRoot.isCoag ? 6 : 8
        anchors.right: halfSocketRoot.isCoag ? parent.right : collapsedInstrImage.left
        anchors.rightMargin: halfSocketRoot.isCoag ? 8 : 6
    }

    Text {
        id: powerEndoLabel
        visible: halfSocketRoot.isEndo && halfSocketRoot.modeId !== 1000
        textFormat: Text.RichText
        color: halfSocketRoot.isCoag ? "white" : "black"
        text: "<span style='font-size:20px;'>эф.рез.</span> "
              + "<span style='font-size:60px; font-weight:700;'>"
              + halfSocketRoot.endoCutEffect
              + "</span> "
              + "<span style='font-size:20px;'>эф.коаг.</span> "
              + "<span style='font-size:60px; font-weight:700;'>"
              + halfSocketRoot.endoCoagEffect
              + "</span>"
        horizontalAlignment: halfSocketRoot.isCoag ? Text.AlignRight : Text.AlignLeft
        verticalAlignment: Text.AlignBottom
        wrapMode: Text.Wrap
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: halfSocketRoot.isCoag ? collapsedInstrImage.right : parent.left
        anchors.leftMargin: halfSocketRoot.isCoag ? 6 : 8
        anchors.right: halfSocketRoot.isCoag ? parent.right : collapsedInstrImage.left
        anchors.rightMargin: halfSocketRoot.isCoag ? 8 : 6
    }
}
