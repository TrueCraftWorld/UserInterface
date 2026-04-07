import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

import StratifyLabs.UI 2.0

Rectangle {
	id: itemList
	property alias innerModel: theView.model
	property string imageSourceTemplate
	property alias curIndex: theView.currentIndex
	property bool noImage: false
	property int initialIndex: -1
	property bool editable: false
	signal newIndexSelected(int newIndex)

	signal deleteItem(int index)
	signal editItemName(int index, string name)


	color: "transparent"

	// Функции для прокрутки списка
	function scrollUp() {
		if (theView.currentIndex > 3) {
			theView.currentIndex -= 3
		}
	}

	function scrollDown() {
		if (theView.currentIndex < theView.count - 3) {
			theView.currentIndex += 2
		}
	}
	ColumnLayout {
		id: layout
		anchors.fill: parent
		anchors.margins: 5
		spacing: 5

		ListView {
			id: theView
			Layout.fillHeight: true
			Layout.fillWidth: true
			layoutDirection: Qt.LeftToRight
			verticalLayoutDirection: ListView.TopToBottom
			displayMarginBeginning: 15
			displayMarginEnd: 15
			spacing: 10
			clip: true

			delegate: Rectangle {
				id: itemRoot
				property bool isSelected: (index === curIndex)
				property bool isInitial: (index === initialIndex)
				height: 100
				width: ListView.view.width
				radius: 8
				color: "transparent"
				Rectangle {
					id: itemImageRectBorder
					width: 10
					color: "transparent"

					anchors {
						top:parent.top
						bottom: parent.bottom
						right: itemImageRect.right
					}
				}
				Rectangle {
					id: itemNameRectBorder
					width: 10
					color: "transparent"
					anchors {
						top:parent.top
						bottom: parent.bottom
						left: itemNameRect.left
					}
				}
				Rectangle {
					id: itemImageRect
					height: parent.height
					width: parent.height
					visible: !noImage
					radius: 8
					anchors {
						top:parent.top
						left: parent.left
					}
					color: "transparent"
					Image {
						id: itemImage
						asynchronous: true
						source: imageSourceTemplate.arg(model.itemId)
						anchors.fill: parent
						fillMode: Image.PreserveAspectFit
					}
				}
				Rectangle {
					id: itemSymbol
					height: parent.height
					width: parent.height
					visible: noImage
					radius: 8
					anchors {
						top:parent.top
						left: parent.left
					}
					color: "transparent"
					Rectangle {
						height: parent.height/3
						width: parent.height/3
						color: "darkcyan"
						border.width: 3
						border.color: "darkgray"
						radius: width
						anchors.centerIn: parent
					}

				}
				Rectangle {
					id: itemNameRect
					color: "transparent"
					radius: 8
					anchors {
						top:parent.top
						bottom: parent.bottom
						left: itemImageRect.right
						right:  itemEditRect.left
					}
					Label {
						anchors.fill: parent
						text: model.itemName
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						wrapMode: Text.WordWrap
						font.bold: true
						font.pixelSize: 18
						color: "white"
					}
					MouseArea {
						anchors.fill: parent
						onClicked: {
							theView.currentIndex = index
							itemList.newIndexSelected(index)
						}
					}
				}
				Rectangle {
					id: itemEditRect
					property bool engaged : false
					color: "transparent"
					width: engaged ? 3 * itemNameRect.height : itemNameRect.height
					visible: itemList.editable
					anchors {
						top: parent.top
						bottom: parent.bottom
						right:  parent.right
					}
					Button {
						id: engageEditButton
						visible: !itemEditRect.engaged
						anchors.fill: parent
						anchors.margins: 5
						onClicked: {
							itemEditRect.engaged = true;
						}
					}
					Rectangle {
						id: editVariantBox
						visible: itemEditRect.engaged
						anchors.fill: parent
						// anchors.margins: 5
						SRow {
							anchors.fill: parent
							rowSpacing: 4
							anchors.margins: 0
							Button {
								Layout.fillHeight: true
								id: deleteButton
								onClicked: {
									deleteItem(index)
								}
							}
							Button {
								id: renameButton
								Layout.fillHeight: true
								onClicked: {
									nameDialog.editingIndex = index
									nameDialog.open()
								}
							}
							Button {
								id: cancelButton
								Layout.fillHeight: true
								onClicked: {
									itemEditRect.engaged = false;
								}
							}
						}
					}
					// onClicked:
				}

				Rectangle {
					id: spacer
					height: 2
					width: parent.width
					gradient: Gradient.SolidStone/*Gradient {
						GradientStop { position: 0.0; color: "transparent" }
						GradientStop { position: 0.5; color: "white" }
						GradientStop { position: 1.0; color: "transparent" }
					}*/
					z: 0
					opacity: 0.5
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 0
				}
				Rectangle {
					id: selectionBorder
					anchors.fill: parent
					color: "transparent"
					border.width: (isSelected || (isInitial && !isSelected)) ? 3 : 0
					radius: 8
					// Розовая рамка только для изначального элемента, если он не выбран сейчас
					// Белая рамка для текущего выбранного элемента
					border.color: (isInitial && !isSelected) ? "grey" : "white"
				}
			}
		}
	}

	Dialog {
		id: nameDialog
		property int editingIndex
		width: 600
		height: 200
		parent: Overlay.overlay
		anchors.centerIn: parent
		title: qsTr("Редактирование названия")
		standardButtons: Dialog.Ok | Dialog.Cancel
		contentItem: Rectangle {
			id: contentRect
			color: "white"
			anchors.fill: parent
			Label {
				id: editLabel
				anchors {
					top: parent.top
					left: parent.left
					right: parent.right
					bottom: parent.verticalCenter
					bottomMargin: 15
				}

				horizontalAlignment: Qt.AlignCenter
				verticalAlignment: Qt.AlignBottom
				text: "Укажите новое имя:"
				color: "black"
				// }

			}
			TextEdit {
				id: edit
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.verticalCenter
				color: "black"
				horizontalAlignment: Qt.AlignCenter
				// Text.color: "black"
				// text: qsTr("Укажите новое имя:")

			}
		}

		onAccepted: {
			editItemName(editingIndex, edit.text)
			close();
		}
		onRejected: {
			close()
		}

	}
}
