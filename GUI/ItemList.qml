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
	property int initialIndex: -1
	property bool editable: false
	
	signal newIndexSelected(int newIndex)
	signal deleteItem(int index)
	signal editItemName(int index, string name)


	color: "transparent"

	// Функции для прокрутки списка
	function scrollUp() {
        if (theView.currentIndex > 0) {
            theView.currentIndex -= 1
            theView.positionViewAtIndex(theView.currentIndex, ListView.Beginning)
		}
	}

	function scrollDown() {
        if (theView.currentIndex < theView.count - 1) {
            theView.currentIndex += 1
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
			spacing: 10
			clip: true
            onCurrentIndexChanged: {
                if (currentIndex >= 0 && currentIndex < count) {
                    positionViewAtIndex(currentIndex, ListView.Beginning)
                    itemList.newIndexSelected(currentIndex)
                }
            }

			delegate: Rectangle {
				id: itemRoot
				property bool isSelected: (index === curIndex)
				property bool isInitial: (index === initialIndex)
				height: 100
				width: ListView.view.width
				radius: 8
                color: isSelected ? "white" : "transparent"
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
                        left: noImage ? (hideNoImageSymbol ? parent.left : itemSymbol.right)
                                      : itemImageRect.right
                        right:  parent.right
                    }
                    Label {
                        anchors.fill: parent
                        text: model.itemName
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        wrapMode: Text.WordWrap
                        font.bold: true
                        font.pixelSize: 18
                        color: isSelected ? "black" : "white"
                    }
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
                    border.width: 0
                    radius: 8
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
			}
			TextEdit {
				id: edit
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.verticalCenter
				color: "black"
				horizontalAlignment: Qt.AlignCenter
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
