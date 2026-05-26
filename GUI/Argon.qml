import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: argonRoot
    
    // Маркер для ArgonDrawer: интерактивные элементы получают события напрямую
    property bool hasInteractiveContent: true
    
    // Публичные свойства
    property bool cylinder1Connected: true      // Баллон 1 наполнен
    property bool cylinder2Connected: false     // Баллон 2 наполнен
    property int flowRate: 5               // Уровень расхода (л/мин) - установленный
    property int realFlowRate: 0           // Реальный расход аргона во время активации
    property bool isActivation: false      // Активация в данный момент
    property int minFlowRate: 1
    property int maxFlowRate: 80
    property bool showControls: true       // Показывать элементы управления (в развернутом состоянии)
    property bool compactOnLightBackground: false  // PeripheryPanel: белая карточка, тёмные подписи
    property bool activCylinderFirst: true // Активный баллон 1 (или 2)

    readonly property color compactLabelColor: compactOnLightBackground ? "#2c2c2c" : "white"
    
    // Эталонная ширина боковой панели; compactLayoutScale сохраняет пропорции баллонов при изменении ширины
    readonly property real compactReferenceWidth: 100
    readonly property real compactLayoutScale: showControls ? 1.0 : Math.max(1.0, width / compactReferenceWidth)
    property int step: showControls ? 16 : Math.round(12 * compactLayoutScale)
    readonly property int compactCylinderWidth: Math.min(Math.round(44 * compactLayoutScale),
                                                         Math.floor((width - 8) / 2))
    readonly property int compactCylinderHeight: Math.round(step * 9.5)
    readonly property int compactContentHeight: {
        if (showControls)
            return 0
        var bottom = Math.max(firstCylinder.y + firstCylinder.height,
                              argonFlowRect.y + argonFlowRect.height)
        return Math.max(1, Math.ceil(bottom + Math.round(4 * compactLayoutScale)))
    }

    // Внутреннее свойства для размеров кнопок
    readonly property int  buttonStep: 16
    readonly property int  flowButtonHeight: 56
    readonly property int  flowButtonMinWidth: 52
    readonly property int  flowButtonMaxWidth: 80
    
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
    
    component CustomButton: Rectangle {
        id: rootCustomBut
        property int delta
        property string iconText
        property bool isPressed: mouseArea.pressed
        
        signal pressed()

        radius: 16
        color: isPressed ? "#66BB6A" : "#8BC34A"
        border {
            color: "#00000030"
            width: 1
        }
        
        Text {
            anchors.centerIn: parent
            text: iconText
            font.pixelSize: 44
            font.bold: true
            color: "#111111"
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            
            onPressed: {
                // Первое срабатывание СРАЗУ при нажатии (как в ModePowerRect)
                rootCustomBut.pressed()
                // Запускаем таймер задержки перед автоповтором
                delayTimer.start()
            }
            
            onReleased: {
                delayTimer.stop()
                autoRepeatTimer.stop()
            }
            
            onCanceled: {
                delayTimer.stop()
                autoRepeatTimer.stop()
            }
        }
        
        // Таймер задержки перед началом автоповтора
        Timer {
            id: delayTimer
            interval: 500  // Задержка перед началом автоповтора (мс)
            repeat: false
            onTriggered: autoRepeatTimer.start()
        }
        
        // Таймер автоповтора
        Timer {
            id: autoRepeatTimer
            interval: 150  // Интервал повторения в миллисекундах
            repeat: true
            onTriggered: rootCustomBut.pressed()
        }
    }

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
            anchors.topMargin: showControls ? 5 : Math.round(7 * compactLayoutScale)
            anchors.horizontalCenter: parent.horizontalCenter
            text: showControls ? qsTr("РАСХОД АРГОНА") : qsTr("АРГОН")
            font.pixelSize: showControls ? 24 : Math.round(18 * compactLayoutScale)
            font.bold: true
            color: showControls ? "#2c2c2c" : argonRoot.compactLabelColor
        }

        ArgCylinder {
            id: firstCylinder
            isFirst: true;
            width: showControls ? 85 : compactCylinderWidth
            height: showControls ? (step * 12.5) : compactCylinderHeight
            anchors.top: arLabel.bottom
            anchors.topMargin: showControls ? 8 : Math.round(6 * compactLayoutScale)
            x: showControls ? 100 : Math.round(2 * compactLayoutScale)
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

        Item {
            id: flowControlsArea
            anchors.left: firstCylinder.right
            anchors.right: secondCylinder.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.verticalCenter: firstCylinder.verticalCenter
            height: flowButtonHeight
            visible: showControls
        }

        // Кнопка -10
        CustomButton {
            id: minus10BtnNew
            width: Math.max(flowButtonMinWidth,
                            Math.min(flowButtonMaxWidth, (flowControlsArea.width - argonFlowRect.width - 24) / 2))
            height: flowButtonHeight
            anchors.left: flowControlsArea.left
            anchors.verticalCenter: flowControlsArea.verticalCenter
            delta: -10
            iconText: "−"
            visible: showControls
            onPressed: {
                var newRate = Math.max(minFlowRate, flowRate + delta)
                if (newRate !== flowRate) {
                    isUserChange = true  // Устанавливаем флаг перед изменением
                    flowRate = newRate
                }
//                    console.log("Argon flowrate: ", flowRate, " ▼ 10");
            }
        }
//        // Кнопки увеличения над индикатором расхода
//        Row {
//            id: increaseButtons
//            anchors.bottom: argonFlowRect.top
//            anchors.bottomMargin: 5
//            anchors.horizontalCenter: parent.horizontalCenter
//            spacing: 10
//            visible: showControls
////            z: 100
            
//            // Кнопка +10
//            CustomButton {
//                id: plus10BtnNew
//                width: buttonStep * 6
//                height: buttonStep * 3.5
//                delta: 10
//                iconText: "−"
//                onClicked: {
//                    var newRate = flowRate + delta
//                    if (newRate >= 0) {
//                        isUserChange = true  // Устанавливаем флаг перед изменением
//                        flowRate = newRate
//                    }
//                }
//            }
//            CustomButton {
//                id: plus1BtnNew
//                width: buttonStep * 6
//                height: buttonStep * 3.5
//                delta: 1
//                iconText: "−"
//                onClicked: {
//                    var newRate = flowRate + delta
//                    if (newRate >= 0) {
//                        isUserChange = true  // Устанавливаем флаг перед изменением
//                        flowRate = newRate
//                    }
////                    console.log("Argon flowrate: ", flowRate, " ▲ 1");
//                }
//            }
//        }

        // Расход
        Rectangle {
            id: argonFlowRect
            width: showControls ? (step * 5) : parent.width
            height: step * 4
            // anchors.top: showControls ? arLabel.bottom : firstCylinderRect.bottom
            anchors.top: showControls ? undefined : firstCylinder.bottom
//            anchors.topMargin: showControls ? 0 : Math.round(2 * compactLayoutScale)
            anchors.left: showControls ? undefined : parent.left
            anchors.horizontalCenter: showControls ? flowControlsArea.horizontalCenter : undefined
            anchors.verticalCenter: showControls ? flowControlsArea.verticalCenter : undefined
            color: "transparent"

            Text {
                id: argonFlow
                anchors.top: parent.top
                anchors.topMargin: showControls ? 0 : -15
                anchors.horizontalCenter: parent.horizontalCenter
                // Во время активации показываем реальный расход, иначе установленный
                property int displayRate: isActivation ? realFlowRate : flowRate
                text: Math.floor(displayRate / 10)
//                text: Math.floor(displayRate / 10) + "." + (displayRate % 10)
                font.pixelSize: 56
//                font.pixelSize: step * 3
                font.bold: true
                // В развернутом виде — тёмный текст, в свернутом (PeripheryPanel) — светлый для тёмного фона
                color: isActivation
                       ? "#000000"
                       : (argonRoot.showControls ? "#2c2c2c" : argonRoot.compactLabelColor)
            }
            Text {
                id: litrPerMin
                anchors.top: argonFlow.bottom
                anchors.topMargin: showControls ? 0 : -10
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("л/мин")
                font.pixelSize: 24
//                font.pixelSize: showControls ? 20 : Math.round(20 * compactLayoutScale)
                font.bold: true
                color: argonRoot.showControls ? "#2c2c2c" : argonRoot.compactLabelColor
            }
        }

        // Кнопка +10
        CustomButton {
            id: plus10BtnNew
            width: minus10BtnNew.width
            height: flowButtonHeight
            anchors.right: flowControlsArea.right
            anchors.verticalCenter: flowControlsArea.verticalCenter
            delta: 10
            iconText: "+"
            visible: showControls
            onPressed: {
                var newRate = Math.min(maxFlowRate, flowRate + delta)
                if (newRate !== flowRate) {
                    isUserChange = true  // Устанавливаем флаг перед изменением
                    flowRate = newRate
                }
            }
        }
        
//        // Кнопки уменьшения под индикатором расхода
//        Row {
//            id: decreaseButtons
//            anchors.top: argonFlowRect.bottom
//            anchors.topMargin: 25
//            anchors.horizontalCenter: parent.horizontalCenter
//            spacing: 10
//            visible: showControls
////            z: 100
            
//            // Кнопка -10
//            CustomButton {
//                id: minus10BtnNew
//                width: buttonStep * 6
//                height: buttonStep * 3.5
//                delta: -10
//                iconText: "+"
//                onClicked: {
//                    var newRate = flowRate + delta
//                    if (newRate <= maxFlowRate) {
//                        isUserChange = true  // Устанавливаем флаг перед изменением
//                        flowRate = newRate
//                    }
////                    console.log("Argon flowrate: ", flowRate, " ▼ 10");
//                }
//            }
//            CustomButton {
//                id: minus1BtnNew
//                width: buttonStep * 6
//                height: buttonStep * 3.5
//                delta: -1
//                iconText: "+"
//                onClicked: {
//                    var newRate = flowRate + delta
//                    if (newRate <= maxFlowRate) {
//                        isUserChange = true  // Устанавливаем флаг перед изменением
//                        flowRate = newRate
//                    }
////                    console.log("Argon flowrate: ", flowRate, " ▼ 1");
//                }
//            }
//        }

        ArgCylinder {
            id: secondCylinder
            width: firstCylinder.width
            height: firstCylinder.height
            anchors.top: arLabel.bottom
            anchors.topMargin: showControls ? 8 : Math.round(7 * compactLayoutScale)
            x: showControls ? (parent.width - width - 100)
                            : (parent.width - width - Math.round(2 * compactLayoutScale))
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
                onPressed: {
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

