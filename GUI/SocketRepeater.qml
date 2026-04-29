import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import BackEnd 1.0


Repeater {

	id: repeatRoot

	required property int containerMargins
	required property int containerHeight
	required property int usedSpacing

	property int collapsedFixedHeight: 85

	signal modeDialogRequest(int socketId, int modeIndex, bool isCoag)
	signal instrumDialogRequest(int socketId, int modeIndex, bool isCoag)
	// signal socketPositionChanged(int socketId, int x, int y, int width, int height)

	function calculateExpandedHeight() {
		var totalFixedHeight = 0
		var expandedCount = 0
		var spacersHeight = (count) * repeatRoot.usedSpacing;
		for (var i = 0; i < count; i++) {
			if (!(itemAt(i) instanceof StatesSocket)) {
				console.log("oops")
				continue
			}
			if (itemAt(i).state === "expanded") {
				expandedCount++
			} else {
				totalFixedHeight += repeatRoot.collapsedFixedHeight
			}
		}
		return expandedCount > 0 ?
					(repeatRoot.containerHeight -
					 (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2))
					/ expandedCount
				  : 0
	}

	function calculateCollapsedHeight() {
		var totalFixedHeight = 0
		var expandedCount = 0
		var spacersHeight = (count) * repeatRoot.usedSpacing;
		for (var i = 0; i < count; i++) {
			if (!(itemAt(i) instanceof StatesSocket)) {
				continue
			}
			if (itemAt(i).state === "expanded") {
				expandedCount++
			}
		}
		if (expandedCount > 0) {
			return repeatRoot.collapsedFixedHeight
		} else {
			return (repeatRoot.containerHeight - (spacersHeight + repeatRoot.containerMargins*2))/count
		}
	}

	clip: true

	delegate: StatesSocket {
		id: delegateSoc
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop
		Layout.preferredHeight: state === "expanded" ?
									repeatRoot.calculateExpandedHeight() :
									repeatRoot.calculateCollapsedHeight()

		state: model.socketdisplaymode
		title: model.socketname
		socketId: index
		socketState: model.socketstatus

		cutInstrumNum:     model.cutmodeinstrnum
		cutMaxPower:       model.cutmodemaxpower
		cutModeId:         model.cutmodeid
		cutModeName:       model.cutmodename
		cutInstrumName:    model.cutmodeinstrname

		coagInstrumNum:    model.coagmodeinstrnum
		coagMaxPower:      model.coagmodemaxpower
		coagModeId:        model.coagmodeid
		coagModeName:      model.coagmodename
		coagInstrumName:   model.coagmodeinstrname

		coagIsEndo:        model.coagmodeisendo
		cutIsEndo:         model.cutmodeisendo

		// Прямой биндинг с защитой от циклов через проверку в onNewPower
		cutModePower: model.cutmodepower
		coagModePower: model.coagmodepower

		Component.onCompleted: {

			if (delegateSoc.socketId === (count-1)) {
				//создали последний item - теперь все они доступны для расчёты высоты и
				//надо триггернуть пересчёт.
				//почему этой проблемы нет при первичной прогрузке - хз.
				//почему получилось только через костыль с действительным изменение чего-то,
				//но не через сигналы - хз
				theModel.recalcCollapsed()
			}
		}

		Connections {
			target: delegateSoc
			function onInstrumEditDialogRequest(socketid, iscoag) {

				repeatRoot.instrumDialogRequest(socketid,
												iscoag ? model.coagmodeindex : model.cutmodeindex,
												iscoag)
			}

			function onModeEditDialogRequest(socketid, iscoag) {
				repeatRoot.modeDialogRequest(socketid,
											 iscoag ? model.coagmodeindex : model.cutmodeindex,
											 iscoag)
			}

			function onNewPower(socketid, pwr, iscoag) {
				//current power это всегда инт, модель их отдаёт интами
				var currentPowerInt = iscoag ? model.coagmodepower : model.cutmodepower
				//если мы не ошиблись нигде, то передаём в сигнал инт,
				var pwrInt = (pwr)
				//не нужна нам здесь строгая проверка - во первых в сокет не встанет больше допустимого в плюсах
				//во-вторых у нас слайдер ограничен только валидными значениями, третий уровнь проверок - перебор
				if (currentPowerInt !== pwrInt) {
					theModel.qmlSetData(index,
										pwrInt,
										(iscoag ? "coagmodepower" : "cutmodepower"))
				}
			}

			function onSocketCollapseRequest() {
				theModel.qmlSetData(index, 0, "socketdisplaymode")
			}

			function onSocketExpandRequest() {
				theModel.qmlSetData(index, 1, "socketdisplaymode")
			}
		}
	}
}

