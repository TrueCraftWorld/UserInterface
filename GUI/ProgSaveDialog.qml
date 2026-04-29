import QtQuick 2.15
import QtQuick.Controls 2.15
import StratifyLabs.UI 2.0
import BackEnd 1.0

Dialog {
	id: diagRoot
	readonly property string progName: progNameInput.text
	readonly property string scopeName: contRect.isNewScope ? newScopeNameInput.text : scopeNameBox.currentText
	property bool nameExists: false

	function updateKnownProgs() {
		recomHandle.scopeIdx = scopeNameBox.currentIndex
		contRect.knownProgNames = recomHandle.progNameList
	}
	function doesProgExist() {
		if (contRect.isNewScope) {
			diagRoot.nameExists = false;
			return
		}
		for (var i = 0; i < contRect.knownProgNames.length; i++) {
			if (progNameInput.text == contRect.knownProgNames[i]) {
				diagRoot.nameExists = true
				return
			}
			diagRoot.nameExists = false;
		}
	}

	title: qsTr("Сохранение программы")
	standardButtons: Dialog.Ok | Dialog.Cancel

	onOpened: {
		console.log("openSaveDia")
		recomHandle.isRecomProgs = false;
		scopeNameBox.model = recomHandle.scopeNameList
		progNameInput.text = qsTr("Программа 1")
		updateKnownProgs()
	}

	contentItem: Rectangle {
		id: contRect
		property bool isNewScope: false
		property var knownProgNames: []
		color: "transparent"

		SPanel {
			id: scopePanel
			style: "panel-primary";
			heading: qsTr("Выберите или добавьте категорию программы");
			width: 0.9 * parent.width
			anchors.top : contRect.top
			anchors.topMargin: 2
			anchors.horizontalCenter: parent.horizontalCenter

			SRow {
				SDropdown {
					id: scopeNameBox
					span: 8
					// model: ["ha","hahaha", "bu", "bububu"]
					visible: !contRect.isNewScope
				}
				SInput {
					id: newScopeNameInput
					span: 8
					placeholder: qsTr("Категория")
					visible: contRect.isNewScope
				}

				SButton{
					id: addScopeButton
					span: 4
					iconString: contRect.isNewScope ? Fa.Icon.chevron_left : Fa.Icon.plus_square;
					onClicked: {
						contRect.isNewScope = !contRect.isNewScope
						doesProgExist()
					}
				}
			}
		}

		SPanel {
			id: inputPanel
			style: diagRoot.nameExists ? "panel-warning" : "panel-naked";
			heading: diagRoot.nameExists ? qsTr("Укажите название программы (название уже существует)") : qsTr("Укажите название программы");
			// footer:  qsTr("Имя программы занято") : ""
			width: 0.9 * parent.width
			anchors.top : scopePanel.bottom
			anchors.topMargin: 10
			anchors.horizontalCenter: parent.horizontalCenter

			SInput {
				id: progNameInput
				placeholder: qsTr("Название");
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width * .9
			}
		}
	}

	Connections {
		target: scopeNameBox
		function onActiveTextChanged() {
			updateKnownProgs()
			doesProgExist()
		}
	}
	Connections {
		target: progNameInput
		function onTextEdited() {
			doesProgExist()
		}
	}
}
