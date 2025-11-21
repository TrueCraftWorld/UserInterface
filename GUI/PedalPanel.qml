import QtQuick 2.15
import QtQuick.Controls 2.15
import BackEnd 1.0
//Item {

//}

 Rectangle {
     id: pedalPanel
    
     // Публичные свойства
     property bool panelExpanded: false
     property var socketModel: null
     property int expandedWidth: 400
     property int collapsedWidth: 85
     property int animationDuration: 300
     property int animationEasing: Easing.InOutQuad
    
     // Отслеживание изменений педалей
     property bool pedalsChanged: false
    
     // Свойство для отслеживания того, что панель была раскрыта из-за клика на педаль
     property bool openedByPedalClick: false
     property int lastClickedSocketIndex: -1
    
     width: panelExpanded ? expandedWidth : collapsedWidth
     color: "#2c2c2c"
    
     // Отслеживаем сворачивание панели для сохранения
     onPanelExpandedChanged: {
         if (!panelExpanded && pedalsChanged) {
             control.saveCurrentState()
             pedalsChanged = false
         }
        
         // Если панель только что раскрылась и это было из-за клика на педаль - открываем редактор
         if (panelExpanded && openedByPedalClick) {
             openedByPedalClick = false
             // Находим последнюю нажатую педаль и открываем для неё редактор
             openEditorForLastClickedPedal()
         }
     }
    
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
         z: 1  // Ниже педалей и редактора
         propagateComposedEvents: true
        
         // Принимаем событие по умолчанию, но разрешаем передачу дочерним элементам
         onClicked: {
             // Клик по пустому месту - ничего не делаем, просто перехватываем
             mouse.accepted = true
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
             anchors.right: parent.right
             anchors.rightMargin: 5
             // Начальная позиция по индексу, затем обновляется через updatePosition()
             y: socketIndex * 100
             z: 10  // Выше фонового MouseArea

             // Обработка клика по педали для открытия редактора
             Connections {
                 target: pedalDelegate
                 function onPedalMenuRequest() {
                     console.log("Pedal clicked, panel expanded:", pedalPanel.panelExpanded)
                    
                     // Разворачиваем панель если она свёрнута
                     if (!pedalPanel.panelExpanded) {
                         // Устанавливаем флаг, что раскрытие произошло из-за клика на педаль
                         pedalPanel.openedByPedalClick = true
                         // Сохраняем информацию о том, какая педаль была нажата
                         pedalPanel.lastClickedSocketIndex = socketIndex
                         pedalPanel.panelExpanded = true
                         console.log("Expand Pedalpanel")
                     } else {
                         console.log("Pedalpanel has been expanded")
                         // Панель уже раскрыта, сразу открываем редактор
                         globalPedalEditor.selectedPed = pedalDelegate.pedalStateIdx
                         globalPedalEditor.currentSocketIndex = socketIndex
                        
                         var availableTypes = [1, 2]
                         if (socketIndex === 1) {
                             availableTypes.push(3)
                         }
                         if (socketIndex === 2 || socketIndex === 3) {
                             availableTypes.push(4)
                         }
                        
                         globalPedalEditor.shownPedalsArray = availableTypes
                         globalPedalEditor.targetPedalY = pedalDelegate.y
                         globalPedalEditor.open()
                     }
                 }
             }
         }
     }
    
     FontMetrics {
         id: fontMetrics
         font.pixelSize: 24
         font.bold: true
     }
    
     // Таймер для открытия редактора после раскрытия панели
     Timer {
         id: openEditorTimer
         interval: 50
         repeat: false
         onTriggered: {
             if (lastClickedSocketIndex < 0) return
            
             // Находим нужную педаль в Repeater
             var pedalItem = null
             for (var i = 0; i < pedalRepeater.count; i++) {
                 var item = pedalRepeater.itemAt(i)
                 if (item && item.socketIndex === lastClickedSocketIndex) {
                     pedalItem = item
                     break
                 }
             }
            
             if (!pedalItem) return
            
             globalPedalEditor.selectedPed = pedalItem.pedalStateIdx
             globalPedalEditor.currentSocketIndex = lastClickedSocketIndex
            
             var availableTypes = [1, 2]
             if (lastClickedSocketIndex === 1) {
                 availableTypes.push(3)
             }
             if (lastClickedSocketIndex === 2 || lastClickedSocketIndex === 3) {
                 availableTypes.push(4)
             }
            
             globalPedalEditor.shownPedalsArray = availableTypes
             globalPedalEditor.targetPedalY = pedalItem.y
             globalPedalEditor.open()
         }
     }
    
     // Функция для определения номера сокета по клику
     function findSocketIndexByClick(mouseX, mouseY) {
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
        
         if (!socketContainer) return -1
        
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
        
         if (!repeater) return -1
        
         // Ищем сокет, в который попал клик
         for (var k = 0; k < repeater.count; k++) {
             var socket = repeater.itemAt(k)
             if (socket) {
                 // Получаем абсолютную позицию сокета
                 var socketAbsolutePos = socket.mapToItem(null, 0, 0)
                
                 // Проверяем, находится ли клик в пределах сокета
                 if (mouseY >= socketAbsolutePos.y && mouseY <= socketAbsolutePos.y + socket.height) {
                     return k
                 }
             }
         }
        
         return -1
     }
    
     // Функция для открытия редактора для последней нажатой педали
     function openEditorForLastClickedPedal() {
         if (lastClickedSocketIndex < 0) return
         // Запускаем таймер с небольшой задержкой, чтобы панель успела раскрыться
         openEditorTimer.restart()
     }
    
     // Глобальный редактор педалей внутри правой панели
     PedalEditor {
         id: globalPedalEditor
         property int currentSocketIndex: -1
         property real targetPedalY: 0
         socketNumber: currentSocketIndex  // Передаём номер педали в редактор
        
         parent: pedalPanel
         modal: false
         closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
         // Позиционируем на уровне выбранной педали с проверкой границ
         y: {
             var desiredY = targetPedalY
             var maxY = pedalPanel.height - height
            
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
         // Позиционируем слева от педали относительно parent (pedalPanel)
         x: 5
         // Ширина: вся панель минус место для педали (75px + отступы = 100px)
         width: pedalPanel.width - 100
         // Фиксированная высота
         height: 130
         z: 20  // Выше педалей и фонового MouseArea
        
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
                 console.log("panelState is changed")
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
                
                 // Отмечаем, что педали изменились
                 pedalPanel.pedalsChanged = true
             }
             globalPedalEditor.close()
         }
     }
 }

