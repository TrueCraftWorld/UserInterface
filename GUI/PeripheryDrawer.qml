import QtQuick 2.15
import QtQuick.Controls 2.15

import BackEnd 1.0

Drawer {

    id: peripheryRoot
    property var handle: periphHandle
    
    // Отключаем встроенную интерактивность Drawer, чтобы использовать свой MouseArea
    interactive: false
    
    // Отключаем встроенную модальность, используем свой overlay для тачскрина
    modal: false
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: "darkgray"
    }

    // Фоновый Rectangle с MouseArea для блокировки событий от прохождения ЗА drawer
    Rectangle {
        anchors.fill: parent
        color: "darkgray"
        z: -1  // Ниже всех элементов внутри drawer
        
        // MouseArea блокирует события от прохождения к элементам ЗА drawer
        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
            onReleased: mouse.accepted = true
            onClicked: mouse.accepted = true
            onPositionChanged: mouse.accepted = true
            onDoubleClicked: mouse.accepted = true
        }
    }

    Rectangle {
        id: wrapRect
        anchors.fill: parent
        color: "transparent"

        Label {
            id: argonChoice
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("НАСТРОЙКА ГАЗОВОГО ТРАКТА")
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
        Argon {
            id: argonView
            anchors {
                top: argonChoice.bottom
                left: parent.left
                right: parent.right
            }
            height: 350
            showControls: true
            //не передаём ибо у меня нет стм
            cylinder1Connected: periphHandle.argonCylinder1Connected
            cylinder2Connected: periphHandle.argonCylinder2Connected
            flowRate: periphHandle.argonFlowRate
            realFlowRate: periphHandle.argonRealRate
            isActivation: periphHandle.activation
            activCylinderFirst: periphHandle.activCylinderFirst
        }
        NeutralEl {
            id: neutralView
            height: 260
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 5
            }
            // neutralConnected: periphHandle.neutralElConnected
            showControls: true
        }
        Label {
            id: neutralChoice
            // visible: panelExpanded
            anchors {
                // top: argonView.bottom
                bottom: neutralView.top
                left: parent.left
                right: parent.right
                bottomMargin: 5
                topMargin: 15
                // horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("ВЫБОР НЕЙТРАЛЬНОГО ЭЛЕКТРОДА")
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
    }

    // MouseArea для обработки свайпов закрытия (свайп влево)
    // Размещаем в конце, чтобы он был последним в z-order и получал события первым
    MouseArea {
        anchors.fill: parent
        z: 1000  // Выше всех элементов внутри drawer
        enabled: peripheryRoot.opened
        propagateComposedEvents: true  // Позволяем событиям проходить к элементам внутри
        
        property real startX: 0
        property real startY: 0
        property bool isSwipeGesture: false
        property real minSwipeDistance: 50
        
        onPressed: {
            startX = mouse.x
            startY = mouse.y
            isSwipeGesture = false
            // Принимаем событие, чтобы получать onPositionChanged для отслеживания свайпов
            mouse.accepted = true
        }
        
        onPositionChanged: {
            if (pressed) {
                var deltaX = mouse.x - startX
                var deltaY = Math.abs(mouse.y - startY)
                
                // Определяем свайп: горизонтальное движение влево > 50px и в 2 раза больше вертикального
                if (deltaX < -50 && Math.abs(deltaX) > deltaY * 2 && !isSwipeGesture) {
                    isSwipeGesture = true
                }
            }
        }
        
        onReleased: {
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            var totalMovement = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
            
            if (isSwipeGesture && deltaX < -minSwipeDistance) {
                // Свайп влево достиг порога - закрываем drawer
                peripheryRoot.close()
            } else if (totalMovement < 20) {
                // Минимальное движение (<20px) - считаем кликом
                // Эмулируем клик: ищем MouseArea под курсором и вызываем его clicked signal
                var item = wrapRect.childAt(mouse.x - wrapRect.x, mouse.y - wrapRect.y)
                if (item) {
                    // Ищем MouseArea в найденном элементе или его родителях (до 10 уровней)
                    for (var i = 0; i < 10; i++) {
                        if (item && item.children) {
                            for (var j = 0; j < item.children.length; j++) {
                                var child = item.children[j]
                                if (child.toString().indexOf("MouseArea") >= 0 && child.clicked) {
                                    // Найден MouseArea - эмулируем клик
                                    child.clicked({accepted: false, x: 0, y: 0})
                                    isSwipeGesture = false
                                    return
                                }
                            }
                        }
                        item = item.parent
                    }
                }
            }
            isSwipeGesture = false
        }
    }

    Connections {
        target: argonView
        function onFlowRateUpdated(newRate) {
            periphHandle.argonFlowRate = newRate
        }
        function onArgonBlow() {
            periphHandle.argonBlow()
        }
        function onActivCylinderToggled(first) {
//            console.log("PeripheryDrawer.qml: onActivCylinderToggled", first)
            periphHandle.activCylinderFirst = first
        }
    }
    Connections {
        target: neutralView
        function onNeutralDividedToggled(divided) {
//            console.log("PeripheryDrawer.qml: onNeutralDividedToggled", divided)
            periphHandle.neutralElDivided = divided
        }
        function onNeutralSizeSelected(size) {
//            console.log("PeripheryDrawer.qml: onNeutralSizeSelected", size)
            periphHandle.neutralSize = size
        }
    }
}
