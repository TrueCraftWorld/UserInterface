import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutralEl
    color: "transparent"

    // Свойства компонента
    property int neutralSize: 0      // 0 = Small, 1 = Medium, 2 = Large
    property bool neutralDivided: periphHandle.neutralElDivided  // НЭ разделённый или нет - привязка к ControlCenter
    property bool neutralConnected: false  // Передается снаружи
    property bool showControls: false      // Показывать ли кнопки управления

    // Обновляем ControlCenter при изменении neutralDivided
    onNeutralDividedChanged: {
        if (control.neutralElDivided !== neutralDivided) {
            control.neutralElDivided = neutralDivided
        }
    }

    // Блок НЭ
    Rectangle {
        id: neutralImage
        property string neColor: neutralConnected ? "lightgreen" : "red"

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height
        width: panelExpanded ? 160 : parent.width
        color: neutralConnected ? "gray" : "white"
        radius: panelExpanded ? 14 : 7
        border.color: "orange"

        Text {
            id: neutralLabel
            color: "black"
            font.pixelSize: panelExpanded ? 20 : 15
            font.bold: false
            anchors.top: parent.top
            anchors.topMargin: panelExpanded ? 5 : 3
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
            anchors.bottomMargin: panelExpanded ? 15 :7
            color: neutralImage.neColor
            width: parent.width * .7
            height: parent.height * .56
            radius: panelExpanded ? 14 : 7
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
                    leftMargin: panelExpanded ? 15 :7
                    bottom: parent.bottom
                    bottomMargin: panelExpanded ? 15 :7
                }
                color: neutralImage.neColor
                width: parent.width * .35
                height: parent.height * .55
                radius: panelExpanded ? 14 : 7
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
                    rightMargin: panelExpanded ? 15 :7
                    bottom: parent.bottom
                    bottomMargin: panelExpanded ? 15 :7
                }
                color: neutralImage.neColor
                width: parent.width * .35
                height: parent.height * .55
                radius: panelExpanded ? 14 : 7
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
        Rectangle {
            id: smallNeutralSize
            height: parent.height * .26
            width: parent.width * .6
            color: neutralSize === 0 ? "cyan" : "lightgray"
            radius: 10
            border.color: neutralSize === 0 ? "white" : "transparent"
            border.width: neutralSize === 0 ? 3 : 0
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 10
                topMargin: 10
            }
            
            Label {
                anchors.centerIn: parent
                text: qsTr("Младенец: < 5 кг\n Максимальная мощность 50")
                color: "black"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    neutralSize = 0
                    mouse.accepted = true
                }
            }
        }

        // Кнопка выбора размера Medium (5-15кг)
        Rectangle {
            id: mediumNeutralSize
            height: parent.height * .26
            width: parent.width * .6
            color: neutralSize === 1 ? "cyan" : "lightgray"
            radius: 10
            border.color: neutralSize === 1 ? "white" : "transparent"
            border.width: neutralSize === 1 ? 3 : 0
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
            
            Label {
                anchors.centerIn: parent
                text: qsTr("Ребёнок: 5-15 кг\nМаксимальная мощность 75")
                color: "black"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    neutralSize = 1
                    mouse.accepted = true
                }
            }
        }

        // Кнопка выбора размера Large (> 15кг)
        Rectangle {
            id: largeNeutralSize
            height: parent.height * .26
            width: parent.width * .6
            color: neutralSize === 2 ? "cyan" : "lightgray"
            radius: 10
            border.color: neutralSize === 2 ? "white" : "transparent"
            border.width: neutralSize === 2 ? 3 : 0
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: 10
                bottomMargin: 10
            }
            
            Label {
                anchors.centerIn: parent
                text: qsTr("Взрослый: > 15 кг\nМаксимальная мощность 400")
                color: "black"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    neutralSize = 2
                    mouse.accepted = true
                }
            }
        }
    }
}
