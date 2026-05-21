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
	property bool hideNoImageSymbol: false
	property bool editable: false
	property color selectedBackgroundColor: "transparent"
	property color selectedTextColor: "white"
	property color unselectedTextColor: "white"
	property color itemBackgroundColor: "transparent"
	property color selectedBorderColor: "transparent"
	property color itemBorderColor: "transparent"
	property int selectedBorderWidth: 0
	property int itemBorderWidth: 0
	property bool keepSelectedItemAtTop: false
	property int noAutoScrollItemId: -1
	property int itemFontPixelSize: 18
	property int itemCornerRadius: 8
	property int listItemHeight: 100
	property int listItemSpacing: 10

	signal newIndexSelected(int newIndex)
	signal deleteItem(int index)
	signal editItemName(int index, string name)


	color: "transparent"

	function selectIndex(index) {
		if (!theView.model || index < 0 || index >= theView.count)
			return
		theView.currentIndex = index
		positionSelectedItem()
		newIndexSelected(index)
	}

	function scrollUp() {
		if (theView.currentIndex > 0)
			selectIndex(theView.currentIndex - 1)
	}

	function scrollDown() {
		if (theView.currentIndex < theView.count - 1)
			selectIndex(theView.currentIndex + 1)
	}

	function currentItemId() {
		if (!theView.model || theView.currentIndex < 0 || theView.currentIndex >= theView.count
				|| typeof theView.model.get !== "function") {
			return -1
		}
		return parseInt(theView.model.get(theView.currentIndex).itemId)
	}

	function positionSelectedItem() {
		if (!keepSelectedItemAtTop || theView.count <= 0) {
			return
		}

		if (currentItemId() === noAutoScrollItemId) {
			theView.positionViewAtIndex(0, ListView.Beginning)
			return
		}

		if (theView.currentIndex >= 0 && theView.currentIndex < theView.count) {
			theView.positionViewAtIndex(theView.currentIndex, ListView.Beginning)
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
			spacing: listItemSpacing
			clip: true
			onCurrentIndexChanged: itemList.positionSelectedItem()
			onHeightChanged: {
				if (itemList.keepSelectedItemAtTop)
					itemList.positionSelectedItem()
			}
			onCountChanged: {
				if (itemList.keepSelectedItemAtTop)
					Qt.callLater(itemList.positionSelectedItem)
			}

			footer: Item {
				width: theView.width
				height: itemList.keepSelectedItemAtTop
						? Math.max(0, theView.height - itemList.listItemHeight - theView.spacing)
						: 0
			}

			delegate: Rectangle {
				id: itemRoot
				property bool isSelected: (index === curIndex)
				readonly property bool showImage: !noImage && imageSourceTemplate !== "" && itemImage.status === Image.Ready
				readonly property bool reserveLeftSymbolSpace: noImage && !hideNoImageSymbol
				readonly property bool showEditPanel: itemList.editable
				height: itemList.listItemHeight
				width: ListView.view.width
				radius: itemList.itemCornerRadius
				color: isSelected ? selectedBackgroundColor : itemBackgroundColor
				border.width: isSelected ? selectedBorderWidth : itemBorderWidth
				border.color: isSelected ? selectedBorderColor : itemBorderColor
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
					visible: showImage
					radius: 8
					anchors {
						top:parent.top
						left: parent.left
					}
					color: "transparent"
					Image {
						id: itemImage
						asynchronous: true
						source: imageSourceTemplate.replace("%1", model.itemId)
						anchors.fill: parent
						fillMode: Image.PreserveAspectFit
					}
				}
				Rectangle {
					id: itemSymbol
					height: parent.height
					width: parent.height
					visible: noImage && !hideNoImageSymbol
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
						left: showImage ? itemImageRect.right
						                : (reserveLeftSymbolSpace ? itemSymbol.right : parent.left)
						right: showEditPanel ? itemEditRect.left : parent.right
						leftMargin: showImage || reserveLeftSymbolSpace ? 10 : 0
						rightMargin: showEditPanel ? 10 : 0
					}
					Label {
						anchors.fill: parent
						text: model.itemName
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						wrapMode: Text.WordWrap
						font.bold: true
						font.pixelSize: itemList.itemFontPixelSize
						color: isSelected ? selectedTextColor : unselectedTextColor
					}
					MouseArea {
						anchors.fill: parent
						onClicked: itemList.selectIndex(index)
					}
				}
				Rectangle {
					id: itemEditRect
					property bool engaged : false
					color: "#22000000"
					border.color: "#55ffffff"
					border.width: 1
					radius: 8
					width: engaged ? 3 * height : height
					visible: showEditPanel
					clip: true
					anchors {
						top: parent.top
						bottom: parent.bottom
						right:  parent.right
						margins: 10
					}
					SButton {
						id: engageEditButton
						style: "btn-naked"
						visible: !itemEditRect.engaged
						anchors.fill: parent
						anchors.margins: 5
						iconString: Fa.Icon.chevron_left;
						onClicked: {
							itemEditRect.engaged = true;
						}
					}
					Rectangle {
						id: editVariantBox
						visible: itemEditRect.engaged
						color: "transparent"
						anchors.fill: parent
						anchors.margins: 5
						RowLayout {
							anchors.fill: parent
							spacing: 5
							anchors.margins: 0
							SButton {
								id: deleteButton
								style: "btn-naked"
								Layout.fillHeight: true
								Layout.fillWidth: true
								iconString: Fa.Icon.trash;
								text: "";
								onClicked: {
									deleteItem(index)
								}
							}
							SButton {
								id: renameButton
								style: "btn-naked"
								Layout.fillHeight: true
								Layout.fillWidth: true
								iconString: Fa.Icon.pencil_square_o;
								text: "";
								onClicked: {
									nameDialog.editingIndex = index
									nameDialog.initialName = model.itemName
									nameDialog.open()
								}
							}
							SButton {
								id: cancelButton
								style: "btn-naked"
								Layout.fillHeight: true
								Layout.fillWidth: true
								iconString: Fa.Icon.chevron_right;
								text: "";
								onClicked: {
									itemEditRect.engaged = false;
								}
							}
						}
					}
				}
				Rectangle {
					id: spacer
					height: 2
					width: parent.width
					gradient: Gradient.SolidStone
					opacity: 0.5
					anchors.bottom: parent.bottom
                    anchors.bottomMargin: -6
				}
			}
		}
	}

	Dialog {
		id: nameDialog
		property int editingIndex
		property string initialName: ""
		function submitRename() {
			var newName = edit.text.trim()
			edit.focus = false
			Qt.inputMethod.hide()
			if (newName.length > 0 && editingIndex >= 0) {
				editItemName(editingIndex, newName)
			}
			close()
		}
		width: 600
		height: 320
		parent: Overlay.overlay
		modal: true
		x: (parent.width - width) / 2
		y: Math.max(20, Math.round(parent.height * 0.14))
		title: qsTr("Редактирование названия")
		Overlay.modal: Rectangle {
			color: "#70000000"
		}
		onOpened: {
			edit.text = initialName
			Qt.callLater(function() {
				edit.forceActiveFocus()
				edit.deselect()
				edit.cursorPosition = edit.text.length
			})
		}
		contentItem: Rectangle {
			id: contentRect
			color: "white"

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 24
				spacing: 18

				Label {
					id: editLabel
					Layout.fillWidth: true
					horizontalAlignment: Qt.AlignCenter
					verticalAlignment: Qt.AlignVCenter
					text: qsTr("Укажите новое имя:")
					color: "black"
					font.pixelSize: 24
					font.bold: true
					wrapMode: Text.WordWrap
				}

				TextField {
					id: edit
					Layout.fillWidth: true
					Layout.preferredHeight: 64
					color: "black"
					horizontalAlignment: Text.AlignLeft
					verticalAlignment: Text.AlignVCenter
					selectByMouse: true
					inputMethodHints: Qt.ImhNoPredictiveText
					font.pixelSize: 24
					background: Rectangle {
						color: "#f5f5f5"
						border.color: edit.activeFocus ? "#4a9eff" : "#7a7a7a"
						border.width: 2
						radius: 6
					}
				}

				Item {
					Layout.fillHeight: true
				}
			}
		}
		footer: Rectangle {
			color: "transparent"
			implicitHeight: 108

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 20
				anchors.rightMargin: 20
				anchors.topMargin: 20
				anchors.bottomMargin: 20
				spacing: 16

				DialogActionButton {
					Layout.preferredWidth: 180
					Layout.fillHeight: true
					text: qsTr("ОТМЕНА")
					onPressed: nameDialog.reject()
				}

				Item { Layout.fillWidth: true }

				DialogActionButton {
					Layout.preferredWidth: 180
					Layout.fillHeight: true
					text: qsTr("ПРИНЯТЬ")
					primary: true
					enabled: edit.text.trim().length > 0
					onPressed: nameDialog.submitRename()
				}
			}
		}
		onAccepted: {
			nameDialog.submitRename()
		}
		onRejected: {
			edit.focus = false
			Qt.inputMethod.hide()
			close()
		}
		onClosed: {
			edit.focus = false
			Qt.inputMethod.hide()
			initialName = ""
			editingIndex = -1
			edit.text = ""
		}
	}
}
