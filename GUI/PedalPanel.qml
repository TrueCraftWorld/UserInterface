import QtQuick 2.15
import QtQuick.Controls 2.15
import BackEnd 1.0

Rectangle {
    id: pedalPanel
    
    // Публичные свойства
    property bool panelExpanded: false
    property var socketModel: null
    property int expandedWidth: 400
    property int collapsedWidth: 85
    property int animationDuration: 300
    property var animationEasing: Easing.InOutQuad
    
    width: panelExpanded ? expandedWidth : collapsedWidth
    color: "#2c2c2c"
    
    // Анимация изменения ширины (синхронизирована с leftPanel)
    Behavior on width {
        NumberAnimation { 
            duration: pedalPanel.animationDuration
            easing.type: pedalPanel.animationEasing
        }
    }
    
    // MouseArea для фона панели (перехватывает клики по пустому месту)
    MouseArea {
        anchors.fill: parent
        z: 1  // Ниже педалей и кнопок, но перехватывает клики по фону
        
        onClicked: {
            if (panelExpanded) {
                pedalPanel.panelExpanded = false
            } else {
                pedalPanel.panelExpanded = true
            }
        }
    }
    
    Label {
        id: pedalChoice
        visible: panelExpanded
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 5
        }
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("ВЫБОР УСТРОЙСТВА АКТИВАЦИИ")
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
//    // Кнопка сворачивания для развернутой панели
//    Rectangle {
//        id: collapseButton
//        visible: panelExpanded
//        width: 40
//        height: 40
//        radius: 8
//        color: "#404040"
//        border.color: "white"
//        border.width: 1
//        anchors {
//            top: parent.top
//            left: parent.left
//            margins: 5
//        }
//        z: 30  // Выше swipeArea
        
//        Text {
//            anchors.centerIn: parent
//            text: "◀"
//            color: "white"
//            font.pixelSize: 20
//            font.bold: true
//        }
        
//        MouseArea {
//            anchors.fill: parent
//            onClicked: {
//                pedalPanel.panelExpanded = false
//            }
//            hoverEnabled: true
//            onEntered: parent.color = "#505050"
//            onExited: parent.color = "#404040"
//        }
//    }
    
    // 4 объекта pedal, привязанные к положению сокетов
    Repeater {
        id: pedalRepeater
        model: socketModel
        delegate: Pedal {
            id: pedalDelegate
            property int socketIndex: index
            
            // Привязываем состояние педали к модели
            pedalStateIdx: model.socketpedal

            // Находим целевой сокет и подписываемся на его сигнал
            Component.onCompleted: {
                searchTimer.start()
            }

            // Timer для задержки поиска сокета
            Timer {
                id: searchTimer
                interval: 100  // 100 мс задержки
                repeat: false
                onTriggered: {
                    findAndConnectToSocket()
                }
            }

            // Функция для поиска сокета и подключения к сигналу
            function findAndConnectToSocket() {
                try {
                    // Ищем socketContainer среди детей родителя
                    var socketContainer = null
                    if (pedalPanel.parent && pedalPanel.parent.children) {
                        for (var i = 0; i < pedalPanel.parent.children.length; i++) {
                            var child = pedalPanel.parent.children[i]
                            if (child && child.objectName === "socketContainer") {
                                socketContainer = child
                                break
                            }
                        }
                    }
                    
                    if (!socketContainer) {
                        retrySearch()
                        return
                    }
                    
                    var repeater = null
                    if (socketContainer.children.length > 0) {
                        var layout = socketContainer.children[0]
                        
                        // Ищем SocketRepeater в layout
                        for (var j = 0; j < layout.children.length; j++) {
                            var child2 = layout.children[j]
                            if (child2 && typeof child2.itemAt === 'function') {
                                repeater = child2
                                break
                            }
                        }
                    }

                    if (!repeater) {
                        retrySearch()
                        return
                    }

                    if (repeater.count > socketIndex) {
                        var socket = repeater.itemAt(socketIndex)
                        if (socket) {
                            // Подписываемся на сигнал
                            socket.absolutePositionChanged.connect(function(socketId, absoluteY) {
                                if (socketId === socketIndex) {
                                    updatePosition(absoluteY)
                                }
                            })

                            // Получаем начальную позицию сокета
                            var initialAbsoluteY = socket.mapToItem(null, 0, 0).y
                            updatePosition(initialAbsoluteY)
                        } else {
                            retrySearch()
                        }
                    } else {
                        retrySearch()
                    }
                } catch (error) {
                    retrySearch()
                }
            }

            // Функция для повторной попытки поиска
            function retrySearch() {
                Qt.callLater(function() {
                    findAndConnectToSocket()
                })
            }

            // Функция для обновления позиции педали
            function updatePosition(absoluteY) {
                try {
                    var panelAbsoluteY = pedalPanel.mapToItem(null, 0, 0).y
                    pedalDelegate.y = absoluteY - panelAbsoluteY
                } catch (error) {
                    // Ошибка при обновлении позиции педали
                }
            }

            // Размеры и позиционирование педали
            width: 75  // Фиксированная ширина педали
            height: 85
            anchors.right: parent.right
            anchors.rightMargin: 5
            // Начальная позиция по индексу, затем обновляется через updatePosition()
            y: socketIndex * 100
            z: 30  // Выше фонового MouseArea

            // Обработка клика по педали для открытия редактора
            Connections {
                target: pedalDelegate
                function onPedalMenuRequest() {
                    // Разворачиваем панель если она свёрнута
                    if (!pedalPanel.panelExpanded) {
                        pedalPanel.panelExpanded = true
                    }
                    
                    globalPedalEditor.selectedPed = pedalDelegate.pedalStateIdx
                    globalPedalEditor.shownPedalsArray = [1,2,3,4]
                    globalPedalEditor.currentSocketIndex = socketIndex
                    // Устанавливаем позицию редактора на уровне педали
                    globalPedalEditor.targetPedalY = pedalDelegate.y
                    globalPedalEditor.open()
                }
            }
        }
    }
    
    FontMetrics {
        id: fontMetrics
        font.pixelSize: 24
        font.bold: true
    }
    
    // Глобальный редактор педалей внутри правой панели
    PedalEditor {
        id: globalPedalEditor
        property int currentSocketIndex: -1
        property real targetPedalY: 0
        
        parent: pedalPanel
//        visible: panelExpanded ? true : false
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        z: 35  // Выше всех элементов
        
        // Позиционируем на уровне выбранной педали с проверкой границ
        y: {
            var desiredY = targetPedalY
            var maxY = pedalPanel.height - height
//            console.log("desiredY %1, maxY %2", desiredY, maxY)
            
            // Проверяем, чтобы не выходил за нижнюю границу
            if (desiredY > maxY) {
                return maxY
            }
            // Проверяем, чтобы не выходил за верхнюю границу
            if (desiredY < 0) {
                return 0
            }
            return desiredY
        }
        x: 0
        // Ширина зависит от состояния панели
        width: pedalPanel.width * 0.8
//        width: panelExpanded ? pedalPanel.width * 0.9 : pedalPanel.width
        // Высота адаптируется к содержимому, но не больше доступной высоты
        height: 150
        
        // Анимация появления
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
        }
        
        // Закрываем редактор при сворачивании панели
        Connections {
            target: pedalPanel
            function onPanelExpandedChanged() {
                if (!panelExpanded && globalPedalEditor.opened) {
                    globalPedalEditor.close()
                }
            }
        }
    }
    
    // Обработка выбора педали
    Connections {
        target: globalPedalEditor
        function onPedSelected(idx) {
            if (idx >= 0 && idx <= 4 && globalPedalEditor.currentSocketIndex >= 0) {
                socketModel.qmlSetData(globalPedalEditor.currentSocketIndex, idx, "socketpedal")
            }
            globalPedalEditor.close()
        }
    }
}

