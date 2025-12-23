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
    property int neutRadius: 12
    property alias radius : backRect.radius
    property bool divided
    property bool button: true
    property bool pressed: mouseArea.pressed  // Для совместимости с Button API
    
    signal clicked()

    Canvas {
        id: neutralBack
        width: 106
        height: 180
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = "purple"
            ctx.beginPath()
            
            // Начинаем с левой стороны
            ctx.moveTo(0, 20)
            
            // Закругление в верхнем левом углу (через точку (0,20) к (13,7) к (22,7))
            ctx.arcTo(0, 7, 13, 7, 13)
            ctx.lineTo(22, 7)
            
            // Закругление внутреннего выреза слева (от (22,7) через (27,12) к (27,27))
            ctx.arcTo(27, 7, 27, 12, 5)
            ctx.lineTo(27, 27)
            
            // Закругление нижней части внутреннего выреза слева (от (27,27) через (27,35) к (35,35))
            ctx.arcTo(27, 35, 35, 35, 8)
            ctx.lineTo(71, 35)
            
            // Закругление нижней части внутреннего выреза справа (от (71,35) через (79,35) к (79,27))
            ctx.arcTo(79, 35, 79, 27, 8)
            ctx.lineTo(79, 12)
            
            // Закругление внутреннего выреза справа (от (79,12) через (84,7) к (76,7))
            ctx.arcTo(79, 7, 84, 7, 5)
            ctx.lineTo(93, 7)
            
            // Закругление в верхнем правом углу (от (85,7) через (98,7) к (98,20))
            ctx.arcTo(106, 7, 106, 20, 13)
            ctx.lineTo(106, 172)

            // Закругление в нижнем правом углу
            ctx.arcTo(106, 180, 98, 180, 8)
            ctx.lineTo(8, 180)
            
            // Закругление в нижнем левом углу
            ctx.arcTo(0, 180, 0, 172, 8)
            
            // Замыкаем путь
            ctx.closePath()
            ctx.fill()
        }
    }

    component NeutHalf: Rectangle {
        color: "transparent"
        property bool isLeft
        transform: Scale {
            origin.x: width / 2
            origin.y: height / 2
            xScale: isLeft ? -1 : 1
        }
            Canvas {
            id: neutralDivLeft
            width: 106
            height: 180
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = "darkcyan"
                ctx.beginPath()

                ctx.moveTo(52, 0)
                ctx.lineTo(52, height - 18)

                ctx.arcTo(52, height - 13, 52 - 5, height - 13, 5)
                ctx.lineTo(20, height - 13)

                // Закругление снизу слева
                ctx.arcTo(9, height - 13, 9, height - 22, 9)
                ctx.lineTo(9, 59)

                // Верхний левый угол
                ctx.arcTo(9, 48, 18, 48, 9)
                ctx.lineTo(34, 48)

                // Внутренний угол
                ctx.arcTo(39, 48, 39, 43, 5)
                ctx.lineTo(39, 3)

                ctx.arcTo(39, 0, 42, 0, 3)

                // Замыкаем путь
                ctx.closePath()
                ctx.fill()
            }
        }
    }

    Rectangle {
        id: neutralBody
        color: "transparent"
        anchors.fill: parent
        
        // Расстояние между половинами: если divided=true, то разделены, если false - слиты
        property int centralOffset: divided ? -3 : 3
        
        NeutHalf {
            isLeft: true
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.centralOffset  // Левая половина сдвигается влево
            width: parent.width
            height: parent.height
        }

        NeutHalf {
            isLeft: false
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: parent.centralOffset  // Правая половина сдвигается вправо
            width: parent.width
            height: parent.height
        }
    }



    component DevHalf: Rectangle {
        id: divHalfRoot
        color: "transparent"
        property bool isLeft
        transform: Scale {
            origin.x: divHalfRoot.width / 2
            origin.y: divHalfRoot.height / 2
            xScale: divHalfRoot.isLeft ? -1 : 1
        }
        Rectangle {
            id: body
            radius: neutRadius
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 0
            }
            height: .75 * parent.height
            color: "transparent"
//            color: neutColor
        }
        Rectangle {
            id: handle
            radius: body.radius/2
            anchors {
                left: parent.left
                bottom: body.top
                top: parent.top
                margins: 0
                bottomMargin: -(1.1 * (handle.radius + body.radius))
            }
            width: nonDividedBody.width * .2
            color: "transparent"
//            color: neutColor
        }
    }

    color: theColor
    radius: 10
    border {
        color: borderColor
        width: borderWidth
    }

    Rectangle {
        id: backRect
        anchors.fill: parent
        anchors.margins: 0
        color: "transparent"
    }

    Rectangle {
        id: contentRect
        color: "transparent"
        anchors {
            fill: parent
            topMargin: parent.height * .1
            bottomMargin: parent.height * .1
            leftMargin: parent.width * .1
            rightMargin: parent.width * .1
        }
        Rectangle {
            id: darker
            visible: button
            anchors.centerIn: parent
            width: neutButRoot.width
            height: neutButRoot.height
            color: "black"
            opacity: neutButRoot.pressed ? 0.2 : 0
            radius: neutButRoot.radius
        }

        Label {
            id: optionalText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            visible: text.length != 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            color: innerTextColor
            font.pixelSize: innerTextFontSize
        }
        Rectangle {
            id: nonDividedRoot
            visible: !divided
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: optionalText.visible ? optionalText.height : 0
                bottomMargin: 0
                leftMargin: 0
                rightMargin: 0
            }
            Rectangle {
                id: nonDividedBody
                radius: neutRadius
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 0
                }
                height: .75 * parent.height
                color: "transparent"
//                color: neutColor
            }
            Rectangle {
                id: nonDividedHandle
                radius: neutRadius/2
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: nonDividedBody.top
                    top: parent.top
                    margins: 0
                    bottomMargin: -nonDividedHandle.radius
                }
                width: nonDividedBody.width * .2
                color: "transparent"
//                color: neutColor
            }
        }
        Rectangle {
            id: dividedRoot
            visible: divided
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: optionalText.visible ? optionalText.height : 0
                bottomMargin: 0
                leftMargin: 0
                rightMargin: 0
            }
            DevHalf {
                id: leftDivHalf
                isLeft: true
                anchors {
                    left: parent.left
                    right: parent.horizontalCenter
                    top: parent.top
                    bottom: parent.bottom
                    margins: 0
                    rightMargin: parent.width * .05
                }
            }
            DevHalf {
                id: rightDivHalf
                isLeft: false
                anchors {
                    right: parent.right
                    left: parent.horizontalCenter
                    top: parent.top
                    bottom: parent.bottom
                    margins: 0
                    leftMargin: parent.width * .05
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: neutButRoot.clicked()
    }
}
