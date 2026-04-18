import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.CuteKeyboard 1.0
import StratifyLabs.UI 2.0
import BackEnd 1.0


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
										  | argNeutDrawer.opened
										  | sockets.modeDialogOpened
										  | sockets.instrDialogOpened)
	}

	StatusBar {
		id: statusBar
		//я искал панграммы для русского и хорошо так посмеялся с эфы
		text: qsTr("В бою с шипящими змеями — эфой и гадюкой — маленький, цепкий, храбрый ёж съел их")
		width: parent.width
		height: 85
		anchors {
			top: parent.top
		}
	}

	SocketContainerV2 {
		id: sockets
		objectName: "socketContainer"
		innerModel: theModel
		width: parent.width - 180
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			top: statusBar.bottom
		}
	}

	PeripheryPanel {
		id: argNeutralPanel
		anchors {
			left: parent.left
			bottom: parent.bottom
			top: statusBar.bottom
			right: sockets.left
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
			left: sockets.right
			right: parent.right
			bottom: parent.bottom
			top: statusBar.bottom
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
		width: container.width
		//      width: 0.8 * container.width
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

	ProgSaveDialog {
		id: saveProgDialog
		anchors.centerIn: parent
		width: 0.8 * parent.width
		height: 350

	}
	Connections {
		target: saveProgDialog
		function onAccepted() {
			recomHandle.saveProg(saveProgDialog.scopeName,
								 saveProgDialog.progName)
		}
		// function onOpened() {
		//     // saveProgDialog.progName = ""
		// }
	}
	// Overlay для закрытия drawer'ов при касании вне их

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
		target: sockets
		function onModeDialogOpenedChanged() {
			container.activationEnable()
		}
	}
	Connections {
		target: sockets
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

	///TODO если уж неизбежно использовать кастом свайпы - надо вынести свайп зону как комппонент, принимающий в себя направление свайпа
	// MouseArea для обработки свайпов в области PeripheryPanel
	MouseArea {
		id: peripherySwipeArea
		anchors {
			left: parent.left
			top: statusBar.bottom
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
			top: statusBar.bottom
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
		target: statusBar
		function onDrawerCalled() {
			leftDrawer.open()
		}
		function onSaveCalled() {
			saveProgDialog.open()
		}
	}
	Connections {
		target: menuLoad
		function onCloseMe() {
			leftDrawer.close()
		}
	}
	Connections {
		target: sockets
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
				menuLoad.loader.setSource("qrc:/ProgItemList.qml",
										  {"recommended" : true,
											  "loadClear" : false})
				leftDrawer.open()
				break;
			}
			case 2:
			{
				recomHandle.addEmptyDefault();
				break;
			}
			case 3:
			{
				menuLoad.shortcut = true;
				menuLoad.loader.setSource("qrc:/ProgItemList.qml",
										  {"recommended" : false,
											  "loadClear" : false})
				leftDrawer.open()
				break;
			}
			}
		}
	}

	// Монитор системы в правом нижнем углу
	SystemMonitor {
		id: systemMonitor
		anchors {
			right: parent.right
			bottom: parent.bottom
			margins: 10
		}
		z: 9999  // Поверх всего
		monitoringActive: true

		// MouseArea для пропуска событий сквозь монитор
		MouseArea {
			anchors.fill: parent
			enabled: false  // Отключаем перехват событий - все проходят сквозь
		}
	}
}
