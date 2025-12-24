import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutButRoot
    property color borderColor
    property int borderWidth
    property color neutColor
    property color theColor
    property color innerTextColor
    property alias innerText: optionalText.text
    property int innerTextFontSize: 14  // Размер шрифта для innerText
    property bool divided
    property bool button: true
    property bool pressed: mouseArea.pressed  // Для совместимости с Button API
    
    signal clicked()

    color: theColor
    radius: 10
    border {
        color: borderColor
        width: borderWidth
    }

    Rectangle {
        id: contentRect
        color: "transparent"
        anchors {
            fill: parent
        }
        Canvas {
            id: neutralBack
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = neutColor
                ctx.beginPath()

                // Используем единый масштаб для сохранения пропорций
                var scaleX = width / 70
                var scaleY = height / 110
                // Масштаб надо делать целочисленным, иначе всё поедет
                var scale = Math.floor(Math.min(scaleX, scaleY))

                // Вычисляем смещения для центрирования по горизонтали и привязки к низу
                var offsetX = (width - 70 * scale) / 2
                var margin = 5  // Отступ снизу
                var offsetY = height - 110 * scale - margin

                // Начинаем с левой стороны
                ctx.moveTo(offsetX + 0, offsetY + 12 * scale)

                // Закругление в верхнем левом углу
                ctx.arcTo(offsetX + 0, offsetY + 6 * scale, offsetX + 6 * scale, offsetY + 6 * scale, 6 * scale)
                ctx.lineTo(offsetX + 18 * scale, offsetY + 6 * scale)
                ctx.lineTo(offsetX + 18 * scale, offsetY + 13 * scale)

                ctx.arcTo(offsetX + 18 * scale, offsetY + 19 * scale, offsetX + 24 * scale, offsetY + 19 * scale, 6 * scale)
                ctx.lineTo(offsetX + 47 * scale, offsetY + 19 * scale)

                ctx.arcTo(offsetX + 53 * scale, offsetY + 19 * scale, offsetX + 53 * scale, offsetY + 13 * scale, 6 * scale)
                ctx.lineTo(offsetX + 53 * scale, offsetY + 6 * scale)
                ctx.lineTo(offsetX + 64 * scale, offsetY + 6 * scale)

                ctx.arcTo(offsetX + 70 * scale, offsetY + 6 * scale, offsetX + 70 * scale, offsetY + 12 * scale, 6 * scale)
                ctx.lineTo(offsetX + 70 * scale, offsetY + 104 * scale)

                ctx.arcTo(offsetX + 70 * scale, offsetY + 110 * scale, offsetX + 64 * scale, offsetY + 110 * scale, 6 * scale)
                ctx.lineTo(offsetX + 6 * scale, offsetY + 110 * scale)

                ctx.arcTo(offsetX + 0, offsetY + 110 * scale, offsetX + 0, offsetY + 104 * scale, 6 * scale)

                // Замыкаем путь
                ctx.closePath()
                ctx.fill()
            }
            
            // Перерисовываем при изменении цвета или размеров
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
        
        // Перерисовываем neutralBack при изменении цвета
        Connections {
            target: neutButRoot
            function onNeutColorChanged() {
                neutralBack.requestPaint()
            }
        }

        Canvas {
            id: neutralBody
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                // Используем единый масштаб для сохранения пропорций
                var scaleX = width / 70
                var scaleY = height / 110
                // Масштаб надо делать целочисленным, иначе всё поедет
                var scale = Math.floor(Math.min(scaleX, scaleY))

                // Вычисляем смещения для центрирования по горизонтали и привязки к низу
                var offsetX = (width - 70 * scale) / 2
                var margin = 5  // Отступ снизу
                var offsetY = height - 110 * scale - margin
                
                // Создаём градиент, имитирующий серебро (вертикальный)
                var gradient = ctx.createLinearGradient(
                    offsetX + 35 * scale, offsetY + 0,
                    offsetX + 35 * scale, offsetY + 102 * scale
                )
                gradient.addColorStop(0, "#808080")    // Тёмно-серый
                gradient.addColorStop(0.15, "#c0c0c0")    // Светло-серый
                gradient.addColorStop(0.35, "#f0f0f0") // Почти белый (блик)
                gradient.addColorStop(0.6, "#a8a8a8")  // Средне-серый
                gradient.addColorStop(0.8, "#d0d0d0") // Серебристый
                gradient.addColorStop(1, "#b0b0b0")    // Тёмно-серый
                
                ctx.fillStyle = gradient
                ctx.beginPath()

                if (divided) {
                    // Левая половина
                    ctx.moveTo(offsetX + 25 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 33 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 33 * scale, offsetY + 102 * scale)
                    ctx.lineTo(offsetX + 14 * scale, offsetY + 102 * scale)

                    ctx.arcTo(offsetX + 8 * scale, offsetY + 102 * scale, offsetX + 8 * scale, offsetY + 96 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 8 * scale, offsetY + 31 * scale)

                    ctx.arcTo(offsetX + 8 * scale, offsetY + 25 * scale, offsetX + 14 * scale, offsetY + 25 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 20 * scale, offsetY + 25 * scale)
                    ctx.arcTo(offsetX + 25 * scale, offsetY + 25 * scale, offsetX + 25 * scale, offsetY + 20 * scale, 5 * scale)

                    // Замыкаем путь
                    ctx.closePath()
                    ctx.fill()

                    // Правая половина
                    ctx.beginPath()
                    ctx.moveTo(offsetX + 45 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 37 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 37 * scale, offsetY + 102 * scale)
                    ctx.lineTo(offsetX + 56 * scale, offsetY + 102 * scale)

                    ctx.arcTo(offsetX + 62 * scale, offsetY + 102 * scale, offsetX + 62 * scale, offsetY + 96 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 62 * scale, offsetY + 31 * scale)

                    ctx.arcTo(offsetX + 62 * scale, offsetY + 25 * scale, offsetX + 56 * scale, offsetY + 25 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 50 * scale, offsetY + 25 * scale)
                    ctx.arcTo(offsetX + 45 * scale, offsetY + 25 * scale, offsetX + 45 * scale, offsetY + 20 * scale, 5 * scale)
                }
                // Неразделённый нейтральник
                else {
                    ctx.moveTo(offsetX + 28 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 42 * scale, offsetY + 0)
                    ctx.lineTo(offsetX + 42 * scale, offsetY + 20 * scale)

                    ctx.arcTo(offsetX + 42 * scale, offsetY + 25 * scale, offsetX + 47 * scale, offsetY + 25 * scale, 5 * scale)
                    ctx.lineTo(offsetX + 56 * scale, offsetY + 25 * scale)

                    ctx.arcTo(offsetX + 62 * scale, offsetY + 25 * scale, offsetX + 62 * scale, offsetY + 31 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 62 * scale, offsetY + 96 * scale)

                    ctx.arcTo(offsetX + 62 * scale, offsetY + 102 * scale, offsetX + 56 * scale, offsetY + 102 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 14 * scale, offsetY + 102 * scale)

                    ctx.arcTo(offsetX + 8 * scale, offsetY + 102 * scale, offsetX + 8 * scale, offsetY + 96 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 8 * scale, offsetY + 31 * scale)

                    ctx.arcTo(offsetX + 8 * scale, offsetY + 25 * scale, offsetX + 14 * scale, offsetY + 25 * scale, 6 * scale)
                    ctx.lineTo(offsetX + 23 * scale, offsetY + 25 * scale)
                    ctx.arcTo(offsetX + 28 * scale, offsetY + 25 * scale, offsetX + 28 * scale, offsetY + 20 * scale, 5 * scale)
                }

                // Замыкаем путь
                ctx.closePath()
                ctx.fill()
            }
        }

        // Перерисовываем Canvas при изменении типа электрода
        Connections {
            target: neutButRoot
            function onDividedChanged() {
                neutralBody.requestPaint()
            }
        }

        Label {
            id: optionalText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            visible: text.length != 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 7
            color: innerTextColor
            font.pixelSize: innerTextFontSize
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: neutButRoot.clicked()
    }
}
