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
    }

    // Левая панель - перекрывает центральный контейнер
    LeftPanel {
        id: leftPanel
        panelExpanded: leftPanelExpanded
        neutralConnected: container.neutralConnected
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

            console.log("SwipeArea pressed at x:", mouse.x, "leftEdge:", leftPanelRightEdge, "rightEdge:", rightPanelLeftEdge)

            // Если панели открыты и клик вне их области - обрабатываем
            if (leftPanelExpanded && mouse.x > leftPanelRightEdge) {
                console.log("Outside left panel - accepting")
                mouse.accepted = true
                return
            }
            
            if (rightPanelExpanded && mouse.x < rightPanelLeftEdge) {
                console.log("Outside right panel - accepting")
                mouse.accepted = true
                return
            }

            // Проверяем области для свайпа:
            if ((mouse.x < 100) ||
               (mouse.x > container.width - 100) ||
               (leftPanelExpanded && mouse.x <= leftPanelRightEdge) ||
               (rightPanelExpanded && mouse.x >= rightPanelLeftEdge)) {
                console.log("Swipe zone detected - accepting")
                isSwipeGesture = true
                mouse.accepted = true
            } else {
                // Центральная область (панели закрыты) - пропускаем событие к сокетам
                console.log("Center area - passing to sockets")
                mouse.accepted = false
            }
        }

        onReleased: {
            if (!isSwipeGesture) {
                console.log("Not a swipe gesture, skipping")
                return
            }

            var deltaX = mouse.x - startX
            var threshold = 50
            var swipeThreshold = Math.abs(deltaX)

            console.log("Swipe released: deltaX=", deltaX, "threshold=", threshold)

            if (swipeThreshold > threshold) {
                // Закрытие панелей имеет приоритет
                if (leftPanelExpanded && deltaX < -threshold) {
                    console.log("Closing left panel")
                    leftPanelExpanded = false
                    mouse.accepted = true
                } else if (rightPanelExpanded && deltaX > threshold) {
                    console.log("Closing right panel")
                    rightPanelExpanded = false
                    mouse.accepted = true
                }
                // Открытие панелей
                else if (!leftPanelExpanded && !rightPanelExpanded && startX < 100 && deltaX > threshold) {
                    console.log("Opening left panel")
                    leftPanelExpanded = true
                    mouse.accepted = true
                } else if (!leftPanelExpanded && !rightPanelExpanded && startX > container.width - 100 && deltaX < -threshold) {
                    console.log("Opening right panel")
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
                rightPanelExpanded = true
                mouse.accepted = true
                return
            }
            
            // Центральная область или внутри панели - пропускаем к дочерним элементам
            mouse.accepted = false
        }

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
