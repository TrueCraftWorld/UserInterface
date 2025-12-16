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

   function activationEnable() {
         periphHandle.enableActivation = !(pedDrawer.opened
                                    | leftDrawer.opened
                                    | argNeutDrawer.opened)
   }

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
      MenuLoader {
         id: menuLoad
         anchors.fill: parent
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
      propagateComposedEvents: true
      
      property real startX: 0
      property real startY: 0
      property bool isSwipeGesture: false
      property real minSwipeDistance: 50
      
      onPressed: {
         startX = mouse.x
         startY = mouse.y
         isSwipeGesture = false
      }
      
      onPositionChanged: {
         if (pressed) {
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            // Если горизонтальное движение больше вертикального и больше 30px вправо
            if (deltaX > 30 && deltaX > deltaY) {
               isSwipeGesture = true
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
               return
            }
         }
         // Если не было свайпа, пропускаем событие для клика
         mouse.accepted = false
         isSwipeGesture = false
      }
      
      onClicked: {
          // Если это не было частью свайпа, пропускаем событие
          mouse.accepted = false
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
      property real minSwipeDistance: 50
      
      onPressed: {
         startX = mouse.x
         startY = mouse.y
         isSwipeGesture = false
      }
      
      onPositionChanged: {
         if (pressed) {
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            // Если горизонтальное движение больше вертикального и больше 30px влево
            if (deltaX < -30 && Math.abs(deltaX) > deltaY) {
               isSwipeGesture = true
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
               mouse.accepted = true
               return
            }
         }
         // Если не было свайпа, пропускаем событие для клика
         mouse.accepted = false
         isSwipeGesture = false
      }
      
      onClicked: {
         // Если это не было частью свайпа, пропускаем событие для клика по педалям
         mouse.accepted = false
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
   // Область для свайпов и закрытия панелей
   // MouseArea {
   //    id: swipeArea
   //    anchors.fill: parent
   //    z: 25  // Всегда выше панелей для обработки свайпов
   //    propagateComposedEvents: true

   //    property real startX: 0
   //    property bool isSwipeGesture: false
   //    property real startTime: 0

   //    onPressed: {
   //       startX = mouse.x
   //       startTime = Date.now()
   //       isSwipeGesture = false

   //       // Вычисляем границы панелей
   //       var rightPanelLeftEdge = rightPanelExpanded ? (container.width - rightPanel.expandedWidth) : (container.width - 85)
   //       var leftPanelRightEdge = leftPanelExpanded ? (container.width / 2) : 85

   //       // Если панели открыты и клик вне их области - обрабатываем
   //       if (leftPanelExpanded && mouse.x > leftPanelRightEdge) {
   //          mouse.accepted = true
   //          return
   //       }

   //       if (rightPanelExpanded && mouse.x < rightPanelLeftEdge) {
   //          mouse.accepted = true
   //          return
   //       }

   //       // Проверяем области для свайпа:
   //       if ((mouse.x < 100) ||
   //             (mouse.x > container.width - 100) ||
   //             (leftPanelExpanded && mouse.x <= leftPanelRightEdge) ||
   //             (rightPanelExpanded && mouse.x >= rightPanelLeftEdge)) {
   //          isSwipeGesture = true
   //          mouse.accepted = true
   //       } else {
   //          // Центральная область (панели закрыты) - пропускаем событие к сокетам
   //          mouse.accepted = false
   //       }
   //    }

   //    onReleased: {
   //       if (!isSwipeGesture) {
   //          return
   //       }

   //       var deltaX = mouse.x - startX
   //       var threshold = 50
   //       var swipeThreshold = Math.abs(deltaX)

   //       if (swipeThreshold > threshold) {
   //          // Закрытие панелей имеет приоритет
   //          if (leftPanelExpanded && deltaX < -threshold) {
   //             leftPanelExpanded = false
   //             mouse.accepted = true
   //          } else if (rightPanelExpanded && deltaX > threshold) {
   //             rightPanelExpanded = false
   //             mouse.accepted = true
   //          }
   //          // Открытие панелей
   //          else if (!leftPanelExpanded && !rightPanelExpanded && startX < 100 && deltaX > threshold) {
   //             leftPanelExpanded = true
   //             mouse.accepted = true
   //          } else if (!leftPanelExpanded && !rightPanelExpanded && startX > container.width - 100 && deltaX < -threshold) {
   //             rightPanelExpanded = true
   //             mouse.accepted = true
   //          }
   //       }
   //    }

   //    onClicked: {
   //       var deltaX = Math.abs(mouse.x - startX)

   //       // Вычисляем границу правой панели (независимо от анимации)
   //       var rightPanelLeftEdge = rightPanelExpanded ? (container.width - rightPanel.expandedWidth) : (container.width - 85)
   //       var leftPanelRightEdge = leftPanelExpanded ? (container.width / 2) : 85

   //       // Игнорируем клики, которые являются частью свайпа
   //       if (deltaX > 30) {
   //          mouse.accepted = true
   //          return
   //       }

   //       // Закрываем ЛЕВУЮ панель при клике вне её области
   //       if (leftPanelExpanded && startX > leftPanelRightEdge) {
   //          leftPanelExpanded = false
   //          mouse.accepted = true
   //          return
   //       }

   //       // Закрываем ПРАВУЮ панель при клике вне её области (слева от панели)
   //       if (rightPanelExpanded && startX < rightPanelLeftEdge) {
   //          rightPanelExpanded = false
   //          mouse.accepted = true
   //          return
   //       }

   //       // Клик по свёрнутой левой панели - разворачиваем
   //       if (!leftPanelExpanded && startX <= 85) {
   //          leftPanelExpanded = true
   //          mouse.accepted = true
   //          return
   //       }

   //       // Клик по свёрнутой правой панели - разворачиваем
   //       if (!rightPanelExpanded && startX >= container.width - 85) {
   //          // Используем функцию из PedalPanel для определения сокета по клику
   //          var socketIndex = rightPanel.findSocketIndexByClick(mouse.x, mouse.y)

   //          if (socketIndex >= 0) {
   //             rightPanel.lastClickedSocketIndex = socketIndex
   //             rightPanel.openedByPedalClick = true
   //          }

   //          rightPanelExpanded = true
   //          mouse.accepted = true
   //          return
   //       }

   //       // Центральная область или внутри панели - пропускаем к дочерним элементам
   //       mouse.accepted = false
   //    }

   // }

}
