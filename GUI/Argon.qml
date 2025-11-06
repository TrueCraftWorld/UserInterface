import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: argonRoot
    
    // Публичные свойства
    property bool cylinder1Connected: true      // Баллон 1 наполнен
    property bool cylinder2Connected: false     // Баллон 2 наполнен
    property int flowRate: 5               // Уровень расхода (л/мин) - установленный
    property int realFlowRate: 0           // Реальный расход аргона во время активации
    property bool isActivation: false      // Активация в данный момент
    property int minFlowRate: 0
    property int maxFlowRate: 80
    property bool showControls: true       // Показывать элементы управления (в развернутом состоянии)
    property bool activCylinderFirst: true // Активный баллон 1 (или 2)
    
    // Внутренние свойства для размеров
    property int step: showControls ? 16 : 12  // Базовый шаг размера: 12 свёрнуто, 16 развёрнуто

    // Внутреннее свойства для размеров кнопок
    property int  buttonStep: 16
    
    // Сигналы
    signal flowRateUpdated(int newRate)
    signal argonBlow()
    
    // Отслеживание изменения showControls для отправки сигнала при сворачивании
    property int lastSentFlowRate: flowRate
    
    onShowControlsChanged: {
        // Когда панель сворачивается (showControls становится false)
        if (!showControls && lastSentFlowRate !== flowRate) {
            flowRateUpdated(flowRate)       // Отправляем сигнал об изменении расхода
            lastSentFlowRate = flowRate
        }
    }
    
    color: "transparent"
    
    // MouseArea для перехвата всех событий в области компонента
    MouseArea {
        anchors.fill: parent
        z: 0
        onPressed: mouse.accepted = true
        onReleased: mouse.accepted = true
        onClicked: mouse.accepted = true
    }

    Rectangle {
        id: argonView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: "grey"
        radius: 7
        border.color: "orange"
        z: 1
//        visible: !showControls
        
        // Иконка баллона
        Text {
            id: arLabel
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: showControls ? qsTr("РАСХОД АРГОНА") : "Ar"
            font.pixelSize: 24
            font.bold: true
            color: "#2c2c2c"
        }

        Rectangle {
            id: firstCylinderRect
            width: 85
            height: step * 12.5
            anchors.top: arLabel.bottom
            anchors.topMargin: 8
            x: showControls ? 100 : (parent.width - width) / 2
            color: "transparent"

            Rectangle {
                id: cylinder1Body
                width: step * 4
                height: step * 11
                radius: width / 2
                color: cylinder1Connected ? (activCylinderFirst ? "#30f020" : "#80f070") : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                border.color: "#d9d9d9"
                border.width: 6
            }
            Rectangle {
                id: cylinder1Neck
                width: step
                height: step * 2
                radius: width / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cylinder1Body.top
                anchors.bottomMargin: -(step / 2)
            }
            Rectangle {
                id: cylinder1Valve
                width: step * 3
                height: step
                radius: height / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: cylinder1Neck.top
                anchors.topMargin: 3
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: "1"
                font.pixelSize: (cylinder1Connected & activCylinderFirst) ? (step * 3) : step * 2
                font.bold: true
                color: "black"
            }
            Label {
                id: empty1
                text: "X"
                anchors.fill: parent
                font.pixelSize: step * 5
                font.bold: true
                color: "yellow"
                visible: !cylinder1Connected
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }

            MouseArea {
                id: cylinder1MA
                anchors.fill: parent
                onClicked: {
                    if (cylinder1Connected && !activCylinderFirst)
                        activCylinderFirst = true;
                }
            }
        }

        // Кнопки увеличения над индикатором расхода
        Row {
            id: increaseButtons
            anchors.bottom: argonFlowRect.top
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            visible: showControls
//            z: 100
            
            // Кнопка +10
            Rectangle {
                id: plus10Btn
                width: buttonStep * 6
                height: buttonStep * 3.5
                radius: 5
                property bool isPressed: false
                color: isPressed ? "#9EFE9E" : "#BDBDBD"
                border {
                    color: "#757575"
                    width: 2
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "▲"
                    font.pixelSize: buttonStep * 2
                    font.bold: true
                    color: "#2c2c2c"
                }
                
                MouseArea {
                    id: plus10MA
                    anchors.fill: parent
                    onClicked: {
                        // Визуальная обратная связь
                        plus10Btn.isPressed = true
                        plus10Timer.restart()
                        
                        // Логика увеличения
                        var newRate = flowRate + 10
                        if (newRate <= maxFlowRate) {
                            flowRate = newRate
                        }
                    }
                }
                
                Timer {
                    id: plus10Timer
                    interval: 200
                    repeat: false
                    onTriggered: plus10Btn.isPressed = false
                }
            }
            
            // Кнопка +1
            Rectangle {
                id: plus1Btn
                width: buttonStep * 6
                height: buttonStep * 3.5
                radius: 5
                property bool isPressed: false
                color: isPressed ? "#9EFE9E" : "#BDBDBD"
                border {
                    color: "#757575"
                    width: 2
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "▲"
                    font.pixelSize: buttonStep * 2
                    font.bold: true
                    color: "#2c2c2c"
                }
                
                MouseArea {
                    id: plus1MA
                    anchors.fill: parent
                    onClicked: {
                        // Визуальная обратная связь
                        plus1Btn.isPressed = true
                        plus1Timer.restart()
                        
                        // Логика увеличения
                        if (flowRate < maxFlowRate) {
                            flowRate++
                        }
                    }
                }
                
                Timer {
                    id: plus1Timer
                    interval: 200
                    repeat: false
                    onTriggered: plus1Btn.isPressed = false
                }
            }
        }

        // Расход
        Rectangle {
            id: argonFlowRect
            width: showControls ? (step * 7) : parent.width
            height: step * 4
            anchors.top: showControls ? arLabel.bottom : firstCylinderRect.bottom
            anchors.topMargin: showControls ? (step * 4) : 0
            anchors.left: showControls ? undefined : parent.left
            anchors.horizontalCenter: showControls ? parent.horizontalCenter : undefined
            color: "transparent"

            Text {
                id: argonFlow
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                // Во время активации показываем реальный расход, иначе установленный
                property int displayRate: isActivation ? realFlowRate : flowRate
                text: Math.floor(displayRate / 10) + "." + (displayRate % 10)
                font.pixelSize: step * 3
                font.bold: true
                color: isActivation ? "#000000" : "#2c2c2c"  // чёрный во время активации
            }
            Text {
                id: litrPerMin
                anchors.top: argonFlow.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("л/мин")
                font.pixelSize: 20
                font.bold: true
                color: "#2c2c2c"
            }
        }
        
        // Кнопки уменьшения под индикатором расхода
        Row {
            id: decreaseButtons
            anchors.top: argonFlowRect.bottom
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            visible: showControls
//            z: 100
            
            // Кнопка -10
            Rectangle {
                id: minus10Btn
                width: buttonStep * 6
                height: buttonStep * 3.5
                radius: 5
                property bool isPressed: false
                color: isPressed ? "#9EFE9E" : "#BDBDBD"
                border {
                    color: "#757575"
                    width: 2
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    font.pixelSize: buttonStep * 2
                    font.bold: true
                    color: "#2c2c2c"
                }
                
                MouseArea {
                    id: minus10MA
                    anchors.fill: parent
                    onClicked: {
                        // Визуальная обратная связь
                        minus10Btn.isPressed = true
                        minus10Timer.restart()
                        
                        // Логика уменьшения
                        var newRate = flowRate - 10
                        if (newRate >= minFlowRate) {
                            flowRate = newRate
                        }
                    }
                }
                
                Timer {
                    id: minus10Timer
                    interval: 200
                    repeat: false
                    onTriggered: minus10Btn.isPressed = false
                }
            }
            
            // Кнопка -1
            Rectangle {
                id: minus1Btn
                width: buttonStep * 6
                height: buttonStep * 3.5
                radius: 5
                property bool isPressed: false
                color: isPressed ? "#9EFE9E" : "#BDBDBD"
                border {
                    color: "#757575"
                    width: 2
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    font.pixelSize: buttonStep * 2
                    font.bold: true
                    color: "#2c2c2c"
                }
                
                MouseArea {
                    id: minus1MA
                    anchors.fill: parent
                    onClicked: {
                        // Визуальная обратная связь
                        minus1Btn.isPressed = true
                        minus1Timer.restart()
                        
                        // Логика уменьшения
                        if (flowRate > minFlowRate) {
                            flowRate--
                        }
                    }
                }
                
                Timer {
                    id: minus1Timer
                    interval: 200
                    repeat: false
                    onTriggered: minus1Btn.isPressed = false
                }
            }
        }

        Rectangle {
            id: secondCylinderRect
            width: showControls ? (step * 7) : parent.width
            height: step * 12.5
            anchors.top: showControls ? arLabel.bottom : argonFlowRect.bottom
            anchors.topMargin: showControls ? 8 : 25
            x: showControls ? (parent.width - width - 100) : (parent.width - width) / 2
            color: "transparent"

            Rectangle {
                id: cylinder2Body
                width: step * 4
                height: step * 11
                radius: width / 2
                color: cylinder2Connected ? (activCylinderFirst ? "#80f070" : "#30f020") : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                border.color: "#d9d9d9"
                border.width: 6
            }
            Rectangle {
                id: cylinder2Neck
                width: step
                height: step * 2
                radius: width / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cylinder2Body.top
                anchors.bottomMargin: -(step / 2)
            }

            Rectangle {
                id: cylinder2Valve
                width: step * 3
                height: step
                radius: height / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: cylinder2Neck.top
                anchors.topMargin: 3
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: "2"
                font.pixelSize: (cylinder2Connected & !activCylinderFirst) ? (step * 3) : step * 2
                font.bold: true
                color: "black"
            }
            Label {
                id: empty2
                text: "X"
                anchors.fill: parent
                font.pixelSize: step * 5
                font.bold: true
                color: "yellow"
                visible: !cylinder2Connected
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }

            MouseArea {
                id: cylinder2MA
                anchors.fill: parent
                onClicked: {
                    if (cylinder2Connected && activCylinderFirst)
                        activCylinderFirst = false;
                }
            }
        }
        
        // Кнопка продувки
        Rectangle {
            id: blowButton
            width: parent.width - 40
            height: buttonStep * 4.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            radius: 10
            visible: showControls
            property bool isPressed: false
            color: isPressed ? "#4CAF50" : "#8BC34A"
            border {
                color: "#558B2F"
                width: 3
            }
            
            Text {
                anchors.centerIn: parent
                text: qsTr("ПРОДУВКА")
                font.pixelSize: buttonStep * 2
                font.bold: true
                color: "#1B5E20"
            }
            
            MouseArea {
                id: blowMA
                anchors.fill: parent
                onClicked: {
                    // Визуальная обратная связь
                    blowButton.isPressed = true
                    blowTimer.restart()
                    
                    // Отправка сигнала
                    argonBlow()
                }
            }
            
            Timer {
                id: blowTimer
                interval: 300
                repeat: false
                onTriggered: blowButton.isPressed = false
            }
        }
    }
}

