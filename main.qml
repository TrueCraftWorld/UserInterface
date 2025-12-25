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
   readonly property int panelAnimationDuration: 150
   readonly property int panelAnimationEasing: Easing.InOutQuad

   // Свойства для управления панелями
   property bool leftPanelExpanded: false
   property bool rightPanelExpanded: false

   // Свойство для нейтрального электрода
   property bool neutralConnected: false

   // Массив строк из файла с поздравлениями
   property var congratsArray: []
   property string currentCongrat: "С Новым Годом!"

   function activationEnable() {
         periphHandle.enableActivation = !(pedDrawer.opened
                                    | leftDrawer.opened
                                    | argNeutDrawer.opened
                                    | socketsDummy.modeDialogOpened
                                    | socketsDummy.instrDialogOpened)
   }

   // Функция загрузки поздравлений из файла
   function loadCongrats() {
      var xhr = new XMLHttpRequest()
      xhr.open("GET", "file:///home/kikorik/FOTEK/congrat.txt")
      xhr.onreadystatechange = function() {
         if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 0 || xhr.status === 200) {
               var text = xhr.responseText
               congratsArray = text.split('\n').filter(function(line) {
                  return line.trim().length > 0  // Убираем пустые строки
               })
               if (congratsArray.length > 0) {
                  showRandomCongrat()
               }
            }
         }
      }
      xhr.send()
   }

   // Функция выбора случайной строки
   function showRandomCongrat() {
      if (congratsArray.length > 0) {
         var randomIndex = Math.floor(Math.random() * congratsArray.length)
         currentCongrat = congratsArray[randomIndex]
      }
   }

   Component.onCompleted: {
      loadCongrats()
   }

   // Таймер для смены поздравлений
   Timer {
      interval: 8000  // 8 секунд
      running: true
      repeat: true
      onTriggered: showRandomCongrat()
   }

   StatusBar {
      id: statusDummy
//      text: qsTr("В бою с шипящими змеями — эфой и гадюкой — маленький, цепкий, храбрый ёж съел их")
      text: container.currentCongrat
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
      width: parent.width - 180
      anchors {
         horizontalCenter: parent.horizontalCenter
         bottom: parent.bottom
         top: statusDummy.bottom
      }
   }

   PeripheryPanel {
      id: argNeutralPanel
      anchors {
         left: parent.left
         bottom: parent.bottom
         top: statusDummy.bottom
         right: socketsDummy.left
      }
   }
   Connections {
      target: argNeutralPanel
      function onOpenPeriphDrawer() {
         argNeutDrawer.open()
      }
   }
   PeripheryDrawer {
      id: argNeutDrawer
      width: .5 * container.width
      height: container.height
      edge: Qt.LeftEdge
   }

   PedalContainer {
      id: pedalContainer
      innerModel: theModel
      anchors {
         left: socketsDummy.right
         right: parent.right
         bottom: parent.bottom
         top: statusDummy.bottom
      }
   }

   PedalDrawer {
      id: pedDrawer
      innerModel: theModel
      width: .5 * container.width
      height: container.height
      edge: Qt.RightEdge
   }

   Drawer {
      id: leftDrawer
      width: 0.8 * container.width
      height: container.height
      edge: Qt.LeftEdge
      
      // Отключаем встроенную модальность, используем свою
      modal: false
      closePolicy: Popup.NoAutoClose
      
      MenuLoader {
         id: menuLoad
         anchors.fill: parent
      }
   }

   // Overlay для закрытия drawer'ов при касании вне их
   Item {
      id: drawerOverlay
      anchors.fill: parent
      z: 1  // Выше основного контента, но drawer'ы будут иметь z намного выше (по умолчанию 10000)
      visible: argNeutDrawer.opened || pedDrawer.opened || leftDrawer.opened
      
      Rectangle {
         anchors.fill: parent
         color: "black"
         opacity: 0.5
         
         MouseArea {
            anchors.fill: parent
            onPressed: {
               mouse.accepted = true
            }
            onReleased: {
               if (argNeutDrawer.opened) argNeutDrawer.close()
               if (pedDrawer.opened) pedDrawer.close()
               if (leftDrawer.opened) leftDrawer.close()
               mouse.accepted = true
            }
         }
      }
   }

   Connections {
      target: leftDrawer
      function onOpenedChanged() {
         container.activationEnable()
      }
   }
   Connections {
      target: pedDrawer
      function onOpenedChanged() {
         container.activationEnable()
      }
   }
   Connections {
      target: argNeutDrawer
      function onOpenedChanged() {
         container.activationEnable()
      }
   }
   Connections {
      target: socketsDummy
      function onModeDialogOpenedChanged() {
         container.activationEnable()
      }
   }
   Connections {
      target: socketsDummy
      function onInstrDialogOpenedChanged() {
         container.activationEnable()
      }
   }

   Connections {
      target: pedalContainer
      function onPedMenuRequest(socketId) {
         pedDrawer.socketId = socketId
         pedDrawer.open()
      }
   }
   Connections {
      target: argNeutralPanel
      function onOpenPeriphDrawer() {
         argNeutDrawer.open()
      }
   }

    // MouseArea для обработки свайпов в области PeripheryPanel
    MouseArea {
       id: peripherySwipeArea
       anchors {
          left: parent.left
          top: statusDummy.bottom
          bottom: parent.bottom
       }
       width: 200
       z: 10  // Выше других элементов
       propagateComposedEvents: true  // Ключевое свойство для пропуска событий
       
       property real startX: 0
       property real startY: 0
       property bool isSwipeGesture: false
       property bool hadSwipeGesture: false
       property real minSwipeDistance: 50
       
       onPressed: {
          startX = mouse.x
          startY = mouse.y
          isSwipeGesture = false
          hadSwipeGesture = false
       }
       
       onPositionChanged: {
          if (pressed) {
             var deltaX = mouse.x - startX
             var deltaY = Math.abs(mouse.y - startY)
             // Если горизонтальное движение больше вертикального и больше 30px вправо
             if (deltaX > 30 && Math.abs(deltaX) > deltaY) {
                isSwipeGesture = true
                hadSwipeGesture = true
                mouse.accepted = true
             } else if (isSwipeGesture) {
                mouse.accepted = true
             } else {
                mouse.accepted = false
             }
          }
       }
       
       onReleased: {
          if (isSwipeGesture) {
             var deltaX = mouse.x - startX
             // Если свайп вправо больше порога, открываем drawer
             if (deltaX > minSwipeDistance) {
                argNeutDrawer.open()
                mouse.accepted = true
                isSwipeGesture = false
                hadSwipeGesture = false
                return
             }
          }
          // Если был свайп, но не достиг порога, блокируем событие
          if (hadSwipeGesture) {
             mouse.accepted = true
          } else {
             // Если не было свайпа, пропускаем событие для клика
             mouse.accepted = false
          }
          isSwipeGesture = false
       }
       
       onClicked: {
          // Если это был свайп (даже не завершенный), принимаем событие, чтобы оно не проходило дальше
          // Если это обычный клик, пропускаем событие (propagateComposedEvents сработает)
          mouse.accepted = hadSwipeGesture
          hadSwipeGesture = false
       }
    }

   // MouseArea для обработки свайпов в области PedalContainer
   MouseArea {
      id: pedalSwipeArea
      anchors {
         right: parent.right
         top: statusDummy.bottom
         bottom: parent.bottom
      }
      width: 200
      z: 10  // Выше других элементов
      propagateComposedEvents: true
      
      property real startX: 0
      property real startY: 0
      property bool isSwipeGesture: false
      property bool hadSwipeGesture: false  // Сохраняем информацию о свайпе для onClicked
      property real minSwipeDistance: 50
      
      onPressed: {
         startX = mouse.x
         startY = mouse.y
         isSwipeGesture = false
         hadSwipeGesture = false
      }
      
      onPositionChanged: {
         if (pressed) {
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            // Если горизонтальное движение больше вертикального и больше 30px влево
            if (deltaX < -30 && Math.abs(deltaX) > deltaY) {
               isSwipeGesture = true
               hadSwipeGesture = true
               // Принимаем событие, чтобы оно не проходило дальше
               mouse.accepted = true
            } else if (isSwipeGesture) {
               // Если уже был свайп, продолжаем принимать события
               mouse.accepted = true
            } else {
               mouse.accepted = false
            }
         }
      }
      
      onReleased: {
         if (isSwipeGesture) {
            var deltaX = mouse.x - startX
            // Если свайп влево больше порога, открываем drawer
            if (deltaX < -minSwipeDistance) {
               // Ищем expanded сокет
               var expandedSocketId = -1
               if (theModel) {
                  for (var i = 0; i < theModel.rowCount(); i++) {
                     var socketIndex = theModel.index(i, 0)
                     if (socketIndex.valid) {
                        var displayMode = theModel.data(socketIndex, SocketModel.SocketDisplayMode)
                        if (displayMode === "expanded") {
                           expandedSocketId = i
                           break
                        }
                     }
                  }
               }
               pedDrawer.socketId = expandedSocketId
               pedDrawer.open()
               mouse.accepted = true  // Блокируем событие при успешном свайпе
               isSwipeGesture = false
               hadSwipeGesture = false
               return
            }
         }
         // Если был свайп, но не достиг порога, все равно блокируем событие
         if (hadSwipeGesture) {
            mouse.accepted = true
         } else {
            // Если не было свайпа, пропускаем событие для клика
            mouse.accepted = false
         }
         isSwipeGesture = false
         // hadSwipeGesture сохраняем для onClicked
      }
      
      onClicked: {
         // Если это был свайп (даже не завершенный), принимаем событие, чтобы оно не проходило дальше
         // Если это обычный клик, пропускаем событие для клика по педалям
         mouse.accepted = hadSwipeGesture
         hadSwipeGesture = false
      }
   }

   Connections {
      target: statusDummy
      function onDrawerCalled() {
         leftDrawer.open()
      }
   }
   Connections {
      target: menuLoad
      function onCloseMe() {
         leftDrawer.close()
      }
   }
   Connections {
      target: socketsDummy
      function onProgAddRequest(addType) {
         switch (addType) {
            case 0:
            {
               recomHandle.copyCurrent();
               break;
            }
            case 1:
            {
               menuLoad.shortcut = true;
               menuLoad.source = "qrc:/ProgItemList.qml"
               menuLoad.item.loadClear = false;
               leftDrawer.open()
               break;
            }
            case 2:
            {
               recomHandle.addEmptyDefault();
               break;
            }
         }
      }
   }

    //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   // Новогодняя гирлянда
   Item {
      id: garlandEffect
      anchors.fill: parent
      z: 99999  // Под снегом, но поверх всего остального
      
      // Компонент лампочки
      component GarlandBulb: Rectangle {
         id: bulb
         width: 12
         height: 16
         radius: 6
         
         property int colorIndex: 0
         property int animationDelay: 0
         readonly property var colors: ["#FF0000", "#FFD700", "#00FF00", "#0080FF", "#FF00FF"]
         property color baseColor: colors[colorIndex % colors.length]
         
         color: baseColor
         border.color: Qt.darker(baseColor, 1.5)
         border.width: 1
         
         // Эффект свечения
         Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.6
            radius: width / 2
            color: "white"
            opacity: 0.5
         }
         
         // Анимация мигания
         SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: true
            
            PauseAnimation { duration: bulb.animationDelay }
            NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
         }
      }
      
      // Компонент вертикальной гирлянды
      component VerticalGarland: Item {
         id: vGarland
         width: 80
         
         property real phaseShift: 0  // Сдвиг фазы для изгибов
         property int colorOffset: 0  // Смещение цветов
         property int animationSeed: 0  // Базовое значение для случайности анимации
         
         readonly property int bulbCount: Math.ceil(container.height / 50) - 2
         readonly property real bulbSpacing: (container.height - 100) / bulbCount
         
         Repeater {
            model: vGarland.bulbCount
            
            Item {
               id: bulbContainer
               
               property real centerY: 50 + (index + 0.5) * vGarland.bulbSpacing
               property real swayAmount: 30
               property real normalizedPos: index / (vGarland.bulbCount - 1)
               property real sway: swayAmount * Math.sin(normalizedPos * Math.PI * 2 + vGarland.phaseShift)
               
               x: 30 + sway
               y: centerY - 8
               
               GarlandBulb {
                  colorIndex: index + vGarland.colorOffset
                  animationDelay: ((index + vGarland.animationSeed) * 137) % 1000
               }
               
               Canvas {
                  visible: index < vGarland.bulbCount - 1
                  anchors.fill: parent
                  width: 60
                  height: vGarland.bulbSpacing + 20
                  
                  property real nextNormalizedPos: (index + 1) / (vGarland.bulbCount - 1)
                  property real nextSway: bulbContainer.swayAmount * Math.sin(nextNormalizedPos * Math.PI * 2 + vGarland.phaseShift)
                  property real nextX: nextSway - bulbContainer.sway
                  property real nextCenterY: vGarland.bulbSpacing
                  
                  onPaint: {
                     var ctx = getContext("2d")
                     ctx.reset()
                     ctx.strokeStyle = "#2F4F2F"
                     ctx.lineWidth = 2
                     ctx.beginPath()
                     ctx.moveTo(6, 8)
                     ctx.quadraticCurveTo(nextX / 2, nextCenterY / 2, nextX + 6, nextCenterY)
                     ctx.stroke()
                  }
                  
                  Component.onCompleted: requestPaint()
               }
            }
         }
      }
      
      // Верхняя гирлянда с провисанием
      Item {
         id: topGarland
         anchors { top: parent.top; left: parent.left; right: parent.right }
         height: 120
         
         property int bulbCount: Math.ceil(container.width / 40)
         property real bulbSpacing: container.width / bulbCount
         
         Repeater {
            model: topGarland.bulbCount
            
            Item {
               id: bulbContainer
               property real centerX: (index + 0.5) * topGarland.bulbSpacing
               property real sagAmount: 60
               property real normalizedPos: index / (topGarland.bulbCount - 1)
               property real sag: sagAmount * Math.sin(normalizedPos * Math.PI)
               
               x: centerX - 6
               y: 10 + sag
               
               GarlandBulb {
                  colorIndex: index
                  animationDelay: (index * 123) % 1000
               }
               
               Canvas {
                  visible: index < topGarland.bulbCount - 1
                  anchors.fill: parent
                  
                  property real nextCenterX: (index + 1.5) * topGarland.bulbSpacing - bulbContainer.x
                  property real nextNormalizedPos: (index + 1) / (topGarland.bulbCount - 1)
                  property real nextSag: bulbContainer.sagAmount * Math.sin(nextNormalizedPos * Math.PI)
                  property real nextY: nextSag - bulbContainer.sag
                  
                  onPaint: {
                     var ctx = getContext("2d")
                     ctx.reset()
                     ctx.strokeStyle = "#2F4F2F"
                     ctx.lineWidth = 2
                     ctx.beginPath()
                     ctx.moveTo(6, 0)
                     ctx.quadraticCurveTo((nextCenterX - 6) / 2, nextY / 2, nextCenterX - 6, nextY)
                     ctx.stroke()
                  }
                  
                  Component.onCompleted: requestPaint()
               }
            }
         }
      }
      
      // Левая вертикальная гирлянда с изгибами
      VerticalGarland {
         anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
         phaseShift: 0
         colorOffset: 1
         animationSeed: 5
      }
      
      // Правая вертикальная гирлянда с изгибами
      VerticalGarland {
         anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
         phaseShift: Math.PI
         colorOffset: 2
         animationSeed: 10
      }
   }

   // Анимация падающего снега
   Item {
      id: snowEffect
      anchors.fill: parent
      z: 100000  // Поверх всего
      
      // Количество снежинок
      readonly property int snowflakeCount: 100
      
      Repeater {
         model: snowEffect.snowflakeCount
         
         Rectangle {
            id: snowflake
            width: Math.random() * 4 + 2  // Размер от 2 до 6
            height: width
            radius: width / 2
            color: "white"
            opacity: Math.random() * 0.6 + 0.4  // Прозрачность от 0.4 до 1.0
            
            // Случайные начальные параметры
            property real randomX: Math.random() * container.width
            property real randomDuration: Math.random() * 10000 + 8000  // 8-18 секунд
            property real randomDelay: Math.random() * 5000  // Задержка 0-5 секунд
            property real swingAmplitude: Math.random() * 30 + 20  // Амплитуда качания 20-50
            property real swingDuration: Math.random() * 2000 + 2000  // Период качания 2-4 секунды
            
            x: randomX
            y: -height
            
            Component.onCompleted: {
               // Запускаем анимацию после случайной задержки
               fallTimer.start()
            }
            
            Timer {
               id: fallTimer
               interval: snowflake.randomDelay
               running: false
               repeat: false
               onTriggered: {
                  fallAnimation.start()
                  swingAnimation.start()
               }
            }
            
            // Анимация падения
            NumberAnimation on y {
               id: fallAnimation
               from: -snowflake.height
               to: container.height + snowflake.height
               duration: snowflake.randomDuration
               running: false
               loops: Animation.Infinite
               easing.type: Easing.Linear
            }
            
            // Анимация качания (горизонтальное движение)
            SequentialAnimation on x {
               id: swingAnimation
               running: false
               loops: Animation.Infinite
               
               NumberAnimation {
                  from: snowflake.randomX
                  to: snowflake.randomX + snowflake.swingAmplitude
                  duration: snowflake.swingDuration / 2
                  easing.type: Easing.InOutSine
               }
               NumberAnimation {
                  from: snowflake.randomX + snowflake.swingAmplitude
                  to: snowflake.randomX - snowflake.swingAmplitude
                  duration: snowflake.swingDuration
                  easing.type: Easing.InOutSine
               }
               NumberAnimation {
                  from: snowflake.randomX - snowflake.swingAmplitude
                  to: snowflake.randomX
                  duration: snowflake.swingDuration / 2
                  easing.type: Easing.InOutSine
               }
            }
         }
      }
   }

}
