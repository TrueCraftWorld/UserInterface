import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutralEl
    color: "transparent"

    // Свойства компонента
    property int neutralSize: 0      // 0 = Small, 1 = Medium, 2 = Large
    property bool neutralDivided: true  // НЭ разделённый или нет - привязка к ControlCenter
    property bool neutralConnected: false  // Передается снаружи
    property bool showControls: false      // Показывать ли кнопки управления
    // property bool neutralDivided: periphHandle.neutralElDivided  // НЭ разделённый или нет - привязка к ControlCenter

    // Обновляем ControlCenter при изменении neutralDivided
    // onNeutralDividedChanged: {
    //     if (control.neutralElDivided !== neutralDivided) {
    //         control.neutralElDivided = neutralDivided
    //     }
    // }

    // Блок НЭ

    component MassSelectionBut: Button {
        id: rootCustomBut
        required property int type
        property string iconText
        autoRepeat: true
        autoRepeatDelay: 200
        autoRepeatInterval: 200
        height: parent.height * .26
        width: parent.width * .6

        background: null
        contentItem: Rectangle {
            id: backGround
            anchors.fill: parent
            radius: 10
            color: neutralSize === type
                ? (rootCustomBut.pressed ? "darkcyan" : "cyan" )
                : (rootCustomBut.pressed ? "gray" : "lightgray" )
            border {
                color: neutralSize === type ? "white" : "transparent"
                width: neutralSize === type ? 3 : 0
            }
            Text {
                anchors.centerIn: parent
                text: iconText
                font.pixelSize: buttonStep * 2
                font.bold: true
                color: "#2c2c2c"
                horizontalAlignment: Text.AlignHCenter
            }
        }
        onClicked: {
            neutralSize = type
        }
    }

    Rectangle {
        id: neutralImage
        property string neColor: neutralConnected ? "lightgreen" : "red"

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height
        width: showControls ? 160 : parent.width
        color: neutralConnected ? "gray" : "white"
        radius: showControls ? 14 : 7
        border.color: "orange"

        Text {
            id: neutralLabel
            color: "black"
            font.pixelSize: showControls ? 20 : 15
            font.bold: false
            anchors.top: parent.top
            anchors.topMargin: showControls ? 5 : 3
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (neutralSize === 0)
                    qsTr("< 5кг\nМакс.50")
                else if (neutralSize === 1)
                    qsTr("5-15кг\nМакс.75")
                else if (neutralSize === 2)
                    qsTr("> 15кг\nМакс.400")
            }
            horizontalAlignment: Text.AlignHCenter
        }

        // Неразделённый
        Rectangle {
            id: notDividedNeutral
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: showControls ? 15 :7
            color: neutralImage.neColor
            width: parent.width * .7
            height: parent.height * .56
            radius: showControls ? 14 : 7
            visible: !neutralDivided
        }
        Rectangle {
            id: notDividedNeutral2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: notDividedNeutral.top
            anchors.bottomMargin: -1
            color: neutralImage.neColor
            width: notDividedNeutral.width * .3
            height: notDividedNeutral.height * .2
            visible: !neutralDivided
        }

        // Разделённый
        Rectangle {
            id: dividedNeutral
            anchors.fill: parent
            visible: neutralDivided
            color: "transparent"
            Rectangle {
                id: leftDivided
            anchors {
                left: parent.left
                    leftMargin: showControls ? 15 :7
                    bottom: parent.bottom
                    bottomMargin: showControls ? 15 :7
                }
                color: neutralImage.neColor
                width: parent.width * .35
                height: parent.height * .55
                radius: showControls ? 14 : 7
            }
            Rectangle {
                id: leftDivided2
                anchors {
                    right: leftDivided.right
                    bottom: leftDivided.top
                    bottomMargin: -10
                }
                color: neutralImage.neColor
                width: parent.width * .15
                height: parent.height * .15
        }

        Rectangle {
                id: rightDivided
            anchors {
                right: parent.right
                    rightMargin: showControls ? 15 :7
                    bottom: parent.bottom
                    bottomMargin: showControls ? 15 :7
                }
                color: neutralImage.neColor
                width: parent.width * .35
                height: parent.height * .55
                radius: showControls ? 14 : 7
            }
            Rectangle {
                id: rightDivided2
                anchors {
                    left: rightDivided.left
                    bottom: rightDivided.top
                    bottomMargin: -10
                }
                color: neutralImage.neColor
                width: parent.width * .15
                height: parent.height * .15
            }
        }
    }

    // Контейнер для кнопок управления (только когда showControls = true)
    Rectangle {
        id: neutralControlContainer
        anchors {
            left: neutralImage.right
            bottom: neutralImage.bottom
            right: parent.right
            leftMargin: 5
            rightMargin: 5
        }
        height: parent.height
        color: "transparent"
        radius: 10
        border.color: "white"
//        width: showControls ? undefined : 1
        visible: showControls
        z: 20  // Выше любых MouseArea

        // Кнопки выбора типа
        Rectangle {
            id: buttonDivided
            color: neutralDivided ? "cyan" : "lightgray"
            height: parent.height * .43
            width: parent.width * .33
            radius: 10
            border.color: neutralDivided ? "white" : "transparent"
            border.width: neutralDivided ? 3 : 0
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: 10
                topMargin: 10
            }
            Rectangle {
                id: lftDivided
                anchors {
                    left: parent.left
                    leftMargin: 7
                    bottom: parent.bottom
                    bottomMargin: 7
                }
                color: "green"
                width: parent.width * .4
                height: parent.height * .7
                radius: 14
            }
            Rectangle {
                id: lftDivided2
                anchors {
                    right: lftDivided.right
                    bottom: lftDivided.top
                    bottomMargin: -10
                }
                color: "green"
                width: parent.width * .15
                height: parent.height * .2
            }

            Rectangle {
                id: rghtDivided
                anchors {
                    right: parent.right
                    rightMargin: 7
                    bottom: parent.bottom
                    bottomMargin: 7
                }
                color: "green"
                width: parent.width * .4
                height: parent.height * .7
                radius: 14
            }
            Rectangle {
                id: rghtDivided2
                anchors {
                    left: rghtDivided.left
                    bottom: rghtDivided.top
                    bottomMargin: -10
                }
                color: "green"
                width: parent.width * .15
                height: parent.height * .2
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    neutralDivided = true
                    mouse.accepted = true
                }
            }
        }

        Rectangle {
            id: buttonNotDivided
            height: parent.height * .43
            width: parent.width * .33
            color: neutralDivided ? "lightgray" : "cyan"
            radius: 10
            border.color: !neutralDivided ? "white" : "transparent"
            border.width: !neutralDivided ? 3 : 0
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: 10
                bottomMargin: 10
            }
            // Неразделённый
            Rectangle {
                id: ntDividedNeutral
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7
                color: "green"
                width: parent.width * .7
                height: parent.height * .7
                radius: 14
            }
            Rectangle {
                id: ntDividedNeutral2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: ntDividedNeutral.top
                anchors.bottomMargin: -1
                color: "green"
                width: ntDividedNeutral.width * .2
                height: ntDividedNeutral.height * .2
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    neutralDivided = false
                    mouse.accepted = true
                }
            }
        }

        // Кнопка выбора размера Small (< 5кг)
        MassSelectionBut {
            id: smallNeutralSize
            type: 0
            iconText: qsTr("Младенец: < 5 кг\n Максимальная мощность 50")
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 10
                topMargin: 10
            }
        }
        MassSelectionBut {
            id: mediumNeutralSize
            type: 1
            iconText: qsTr("Ребёнок: 5-15 кг\nМаксимальная мощность 75")
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
        }
        MassSelectionBut {
            id: largeNeutralSize
            type: 2
            iconText: qsTr("Взрослый: > 15 кг\nМаксимальная мощность 400")
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: 10
                bottomMargin: 10
            }
        }
    }
}
