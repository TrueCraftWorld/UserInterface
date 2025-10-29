import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.CuteKeyboard 1.0
import StratifyLabs.UI 2.0
import BackEnd 1.0
// import "/home/kikorik/FOTEK/UserInterface/GUI/ScreenOfSockets"

Window {
    id: container
    width: 1280
    height: 800
    visible: true
    title: qsTr("Ты волшебник, Гарри!")
    color: "black"

    // Константы для анимации панелей
    readonly property int panelAnimationDuration: 300
    readonly property var panelAnimationEasing: Easing.InOutQuad

    // Свойства для управления панелями
    property bool leftPanelExpanded: false
    property bool rightPanelExpanded: false

    // Свойство для нейтрального электрода
    property bool neutralConnected: false


    StatusBar {
        id: statusDummy
        //я искал панграммы для русского и хорошо так посмеялся с эфы
        text: qsTr("В бою с шипящими змеями — эфой и гадюкой — маленький, цепкий, храбрый ёж съел их")
        width: parent.width
        height: 85
        anchors {
            top: parent.top
        }
    }

    SocketContainerV2 {
        id: socketsDummy
        objectName: "socketContainer"
        innerModel: theModel
        width: parent.width - 170
        z: 5  // Ниже панелей, но выше фонового MouseArea
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            top: statusDummy.bottom
        }
        
        // Обработка изменений позиции сокетов для Activation popup
        Connections {
            target: socketsDummy
            function onSocketPositionChanged(socketId, x, y, width, height) {
                // Обновляем координаты если это активный сокет (даже если activation еще false)
                if (socketId === control.activeSocketId) {
                    control.activeSocketX = x
                    control.activeSocketY = y
                    control.activeSocketWidth = width
                    control.activeSocketHeight = height
                }
            }
        }
    }

    // Левая панель - перекрывает центральный контейнер
    LeftPanel {
        id: leftPanel
        panelExpanded: leftPanelExpanded
        expandedWidth: container.width / 2
        collapsedWidth: 85
        animationDuration: container.panelAnimationDuration
        animationEasing: container.panelAnimationEasing
        height: socketsDummy.height
        anchors.bottom: socketsDummy.bottom
        x: 0  // Всегда видима
        z: 15
        
        // Синхронизируем состояние панели с контейнером
        onPanelExpandedChanged: {
            leftPanelExpanded = panelExpanded
        }
    }

    // Правая панель - перекрывает центральный контейнер
    PedalPanel {
        id: rightPanel
        panelExpanded: rightPanelExpanded
        socketModel: theModel
        expandedWidth: container.width / 2
        collapsedWidth: 85
        animationDuration: container.panelAnimationDuration
        animationEasing: container.panelAnimationEasing
        height: socketsDummy.height
        anchors.bottom: socketsDummy.bottom
        x: container.width - width
        z: 15  // Поверх центрального контейнера
        
        // Синхронизируем состояние панели с контейнером
        onPanelExpandedChanged: {
            rightPanelExpanded = panelExpanded
        }
    }

//    Drawer {
//        id: leftDrawer
//        width: 0.8 * container.width
//        height: container.height

//        // Loader
//        // SettingsMain {
//        MenuLoader {
//            id: menuLoad
//            anchors.fill: parent
//        }
//    }

    // Область для свайпов и закрытия панелей
    MouseArea {
        id: swipeArea
        anchors.fill: parent
        z: 25  // Всегда выше панелей для обработки свайпов
        propagateComposedEvents: true

        property real startX: 0
        property bool isSwipeGesture: false
        property real startTime: 0

        onPressed: {
            startX = mouse.x
            startTime = Date.now()
            isSwipeGesture = false

            // Вычисляем границы панелей
            var rightPanelLeftEdge = rightPanelExpanded ? (container.width - rightPanel.expandedWidth) : (container.width - 85)
            var leftPanelRightEdge = leftPanelExpanded ? (container.width / 2) : 85

            // Если панели открыты и клик вне их области - обрабатываем
            if (leftPanelExpanded && mouse.x > leftPanelRightEdge) {
                mouse.accepted = true
                return
            }
            
            if (rightPanelExpanded && mouse.x < rightPanelLeftEdge) {
                mouse.accepted = true
                return
            }

            // Проверяем области для свайпа:
            if ((mouse.x < 100) ||
               (mouse.x > container.width - 100) ||
               (leftPanelExpanded && mouse.x <= leftPanelRightEdge) ||
               (rightPanelExpanded && mouse.x >= rightPanelLeftEdge)) {
                isSwipeGesture = true
                mouse.accepted = true
            } else {
                // Центральная область (панели закрыты) - пропускаем событие к сокетам
                mouse.accepted = false
            }
        }

        onReleased: {
            if (!isSwipeGesture) {
                return
            }

            var deltaX = mouse.x - startX
            var threshold = 50
            var swipeThreshold = Math.abs(deltaX)

            if (swipeThreshold > threshold) {
                // Закрытие панелей имеет приоритет
                if (leftPanelExpanded && deltaX < -threshold) {
                    leftPanelExpanded = false
                    mouse.accepted = true
                } else if (rightPanelExpanded && deltaX > threshold) {
                    rightPanelExpanded = false
                    mouse.accepted = true
                }
                // Открытие панелей
                else if (!leftPanelExpanded && !rightPanelExpanded && startX < 100 && deltaX > threshold) {
                    leftPanelExpanded = true
                    mouse.accepted = true
                } else if (!leftPanelExpanded && !rightPanelExpanded && startX > container.width - 100 && deltaX < -threshold) {
                    rightPanelExpanded = true
                    mouse.accepted = true
                }
            }
        }

        onClicked: {
            var deltaX = Math.abs(mouse.x - startX)
            
            // Вычисляем границу правой панели (независимо от анимации)
            var rightPanelLeftEdge = rightPanelExpanded ? (container.width - rightPanel.expandedWidth) : (container.width - 85)
            var leftPanelRightEdge = leftPanelExpanded ? (container.width / 2) : 85

            // Игнорируем клики, которые являются частью свайпа
            if (deltaX > 30) {
                mouse.accepted = true
                return
            }

            // Закрываем ЛЕВУЮ панель при клике вне её области
            if (leftPanelExpanded && startX > leftPanelRightEdge) {
                leftPanelExpanded = false
                mouse.accepted = true
                return
            }
            
            // Закрываем ПРАВУЮ панель при клике вне её области (слева от панели)
            if (rightPanelExpanded && startX < rightPanelLeftEdge) {
                rightPanelExpanded = false
                mouse.accepted = true
                return
            }

            // Клик по свёрнутой левой панели - разворачиваем
            if (!leftPanelExpanded && startX <= 85) {
                leftPanelExpanded = true
                mouse.accepted = true
                return
            }
            
            // Клик по свёрнутой правой панели - разворачиваем
            if (!rightPanelExpanded && startX >= container.width - 85) {
                // Используем функцию из PedalPanel для определения сокета по клику
                var socketIndex = rightPanel.findSocketIndexByClick(mouse.x, mouse.y)
                
                if (socketIndex >= 0) {
                    rightPanel.lastClickedSocketIndex = socketIndex
                    rightPanel.openedByPedalClick = true
                }
                
                rightPanelExpanded = true
                mouse.accepted = true
                return
            }
            
            // Центральная область или внутри панели - пропускаем к дочерним элементам
            mouse.accepted = false
        }

    }
    
    // Индикатор активации
    Activation {
        id: activationIndicator
    }

//    Connections {
//        target: statusDummy
//        function onDrawerCalled() {
//            leftDrawer.open()
//        }
//    }
//    Connections {
//        target: menuLoad
//        function onCloseMe() {
//            leftDrawer.close()
//        }
//    }

}
