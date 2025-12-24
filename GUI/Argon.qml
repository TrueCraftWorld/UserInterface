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
    readonly property int  buttonStep: 16
    
    // Сигналы
    signal flowRateUpdated(int newRate)
    signal argonBlow()
    signal activCylinderToggled(bool first)
    
    // Отслеживание изменения showControls для отправки сигнала при сворачивании
    property int lastSentFlowRate: flowRate
    property bool isUserChange: false  // Флаг для отслеживания изменений пользователем
    
    onFlowRateChanged: {
        // Отправляем сигнал при изменении расхода пользователем (через кнопки)
        if (isUserChange && lastSentFlowRate !== flowRate) {
            flowRateUpdated(flowRate)
            lastSentFlowRate = flowRate
            isUserChange = false  // Сбрасываем флаг после отправки
        }
    }
    
    onShowControlsChanged: {
        // Когда панель сворачивается (showControls становится false)
        if (!showControls && lastSentFlowRate !== flowRate) {
            flowRateUpdated(flowRate)       // Отправляем сигнал об изменении расхода
            lastSentFlowRate = flowRate
        }
    }
    
    color: "transparent"
    
    // Пришлось переделать с Button на Rectangle, а то без MouseArea не работал кастомный свайп
    component CustomButton: Rectangle {
        id: rootCustomBut
        property int delta
        property string iconText
        property bool pressed: mouseArea.pressed
        
        signal clicked()

        radius: 6
        color: pressed ? "#9EFE9E" : "#BDBDBD"
        border {
            color: "#757575"
            width: 2
        }
        
        Text {
            anchors.centerIn: parent
            text: iconText
            font.pixelSize: buttonStep * 2
            font.bold: true
            color: "#2c2c2c"
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: rootCustomBut.clicked()
            
            // Эмуляция autoRepeat для зажатия кнопки
            property bool isPressed: false
            onPressed: {
                isPressed = true
                rootCustomBut.clicked()
                repeatTimer.start()
            }
            onReleased: {
                isPressed = false
                repeatTimer.stop()
            }
            
            Timer {
                id: repeatTimer
                interval: mouseArea.isPressed ? 200 : 200  // autoRepeatInterval
                repeat: true
                onTriggered: {
                    if (mouseArea.isPressed) {
                        rootCustomBut.clicked()
                    }
                }
            }
        }
    }

    // // MouseArea для перехвата всех событий в области компонента
    // MouseArea {
    //     anchors.fill: parent
    //     z: 0
    //     onPressed: mouse.accepted = true
    //     onReleased: mouse.accepted = true
    //     onClicked: mouse.accepted = true
    // }

    Rectangle {
        id: argonView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        // color: "grey"
        color: "transparent"
        // radius: 7
        // border.color: "orange"
        // z: 1
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

        ArgCylinder {
            id: firstCylinder
            isFirst: true;
            width: 85
            height: step * 12.5
            anchors.top: arLabel.bottom
            anchors.topMargin: 8
            x: showControls ? 100 : (parent.width - width) / 2
            cylConnected: cylinder1Connected
            cylSelected: activCylinderFirst
            interactive: showControls  // Баллоны кликабельны только в развернутом состоянии
        }
        Connections {
            target: firstCylinder
            function onCylClicked() {
                if (cylinder1Connected && !activCylinderFirst) {
                    activCylinderFirst = true;
                    console.log("Argon.qml: first cylinder selected");
                    activCylinderToggled(true);
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
            CustomButton {
                id: plus10BtnNew
                width: buttonStep * 6
                height: buttonStep * 3.5
                delta: 10
                iconText: "▲"
                onClicked: {
                    var newRate = flowRate + delta
                    if (newRate <= maxFlowRate) {
                        isUserChange = true  // Устанавливаем флаг перед изменением
                        flowRate = newRate
                    }
//                    console.log("Argon flowrate: ", flowRate, " ▲ 10");
                }
            }
            CustomButton {
                id: plus1BtnNew
                width: buttonStep * 6
                height: buttonStep * 3.5
                delta: 1
                iconText: "▲"
                onClicked: {
                    var newRate = flowRate + delta
                    if (newRate <= maxFlowRate) {
                        isUserChange = true  // Устанавливаем флаг перед изменением
                        flowRate = newRate
                    }
//                    console.log("Argon flowrate: ", flowRate, " ▲ 1");
                }
            }
        }

        // Расход
        Rectangle {
            id: argonFlowRect
            width: showControls ? (step * 7) : parent.width
            height: step * 4
            // anchors.top: showControls ? arLabel.bottom : firstCylinderRect.bottom
            anchors.top: showControls ? arLabel.bottom : firstCylinder.bottom
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
                // В развернутом виде — тёмный текст, в свернутом (PeripheryPanel) — светлый для тёмного фона
                color: isActivation
                       ? "#000000"
                       : (argonRoot.showControls ? "#2c2c2c" : "white")
            }
            Text {
                id: litrPerMin
                anchors.top: argonFlow.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("л/мин")
                font.pixelSize: 20
                font.bold: true
                color: argonRoot.showControls ? "#2c2c2c" : "white"
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
            CustomButton {
                id: minus10BtnNew
                width: buttonStep * 6
                height: buttonStep * 3.5
                delta: -10
                iconText: "▼"
                onClicked: {
                    var newRate = flowRate + delta
                    if (newRate >= 0) {
                        isUserChange = true  // Устанавливаем флаг перед изменением
                        flowRate = newRate
                    }
//                    console.log("Argon flowrate: ", flowRate, " ▼ 10");
                }
            }
            CustomButton {
                id: minus1BtnNew
                width: buttonStep * 6
                height: buttonStep * 3.5
                delta: -1
                iconText: "▼"
                onClicked: {
                    var newRate = flowRate + delta
                    if (newRate >= 0) {
                        isUserChange = true  // Устанавливаем флаг перед изменением
                        flowRate = newRate
                    }
//                    console.log("Argon flowrate: ", flowRate, " ▼ 1");
                }
            }
        }

        ArgCylinder {
            id: secondCylinder
            width: showControls ? (step * 7) : parent.width
            height: step * 12.5
            anchors.top: showControls ? arLabel.bottom : argonFlowRect.bottom
            anchors.topMargin: showControls ? 8 : 25
            x: showControls ? (parent.width - width - 100) : (parent.width - width) / 2
            isFirst: false;
            cylConnected: cylinder2Connected
            cylSelected: !activCylinderFirst
            interactive: showControls  // Баллоны кликабельны только в развернутом состоянии
        }

        Connections {
            target: secondCylinder
            function onCylClicked() {
                if (cylinder2Connected && activCylinderFirst) {
                    activCylinderFirst = false;
//                    console.log("Argon.qml: second cylinder selected");
                    activCylinderToggled(false);
                }
            }
        }
        
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

