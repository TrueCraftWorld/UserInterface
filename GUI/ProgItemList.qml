import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Rectangle {
	id: recProgs
	// property alias innerModel: repeatRoot.model
	signal clickedButton(int idx)
    signal programSelected(string scopeName, string progName)
	signal returnButtonPressed()
	color: "transparent"
	
	property var itemIdArr: []
	property var itemNameArr: []
	property bool loadClear: true
	required property bool recommended/*: true*/
	property bool editable: false
	
	ListModel {
		id: scopeModel
	}
	
	ListModel {
		id: progsModel
	}
	
	function updateModel() {
		progsModel.clear()
		itemNameArr = recomHandle.progNameList
		itemIdArr = recomHandle.progIdList
		if (itemIdArr.length !== itemNameArr.length) {
			console.warn("Lists from C++ have different lengths!")
			return
		}
		for (var i = 0; i < itemIdArr.length; i++) {
			progsModel.append({
								  itemId: itemIdArr[i],
								  itemName: itemNameArr[i],
								  rowIndex: i
							  })
		}
		progList.innerModel = progsModel
		progList.curIndex = -1
	}
	function init() {
        scopeModel.clear()
		itemNameArr = recomHandle.scopeNameList
		itemIdArr = recomHandle.scopeIdList
		if (itemIdArr.length !== itemNameArr.length) {
			console.warn("Lists from C++ have different lengths!")
			return
		}
		for (var i = 0; i < itemIdArr.length; i++) {
			scopeModel.append({
								  itemId: itemIdArr[i],
								  itemName: itemNameArr[i],
								  rowIndex: i
							  })
		}
		scopeList.innerModel = scopeModel
		recomHandle.scopeIdx = 0
	}
	
	
	Component.onCompleted: {
		recomHandle.isRecomProgs = recommended;
	}
	
	Connections {
		target: recomHandle
		function onScopeNameListChanged() {
//			console.log("[ProgFlow] ProgItemList onScopeNameListChanged")
			init();
			updateModel();
		}
		function onProgNameListChanged() {
//			console.log("[ProgFlow] ProgItemList onProgNameListChanged, progs:",
//						recomHandle.progNameList.length)
			updateModel();
		}
	}
	
	GradientBack {
		anchors.fill: parent
        startColor: "#0D1A3A"
        stopColor: "#1A2F5C"
        beamColor: "rgba(96, 132, 210, 0.45)"
	}
	
	Rectangle {
		id: headerRect
		height: 60
		color: "darkgray"
		anchors {
			left: parent.left
			top: parent.top
			right: parent.right
		}
		Text {
			anchors.fill: parent
			text: recommended
                  ? qsTr("РЕКОМЕНДОВАННЫЕ ПРОГРАММЫ")
                  : qsTr("ПОЛЬЗОВАТЕЛЬСКИЕ ПРОГРАММЫ")
			horizontalAlignment: Qt.AlignHCenter
			verticalAlignment: Qt.AlignVCenter
			font.pixelSize: 30
		}
	}
	
	Rectangle {
		id: scopeRect
		color: "transparent"
		width: parent.width * 0.42
		anchors {
			left: parent.left
			top: headerRect.bottom
			bottom: retButton.top
		}
		ItemList {
			id: scopeList
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: scopeButtons.top
			curIndex: recomHandle.scopeIdx
            noImage: true
            hideNoImageSymbol: true
            selectedBackgroundColor: "white"
            selectedTextColor: "black"
            // imageSourceTemplate: "image://scopes/scope%1"
        }

        RowLayout {
            id: scopeButtons
            height: 56
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 10

            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("▼")
                font.pixelSize: 24
                background: Rectangle {
                    radius: 10
                    color: "#22000000"
                    border.color: "#66ffffff"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#BDBDBD"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: scopeList.scrollDown()
            }
            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("▲")
                font.pixelSize: 24
                background: Rectangle {
                    radius: 10
                    color: "#22000000"
                    border.color: "#66ffffff"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#BDBDBD"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: scopeList.scrollUp()
            }
		}
		
	}
	Rectangle {
		id: progRect
		color: "transparent"
		anchors {
			left: border.right
			top: headerRect.bottom
			bottom: retButton.top
			right: parent.right
			leftMargin: 2
		}
		
		ItemList {
			id: progList
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: progButtons.top
			noImage: true
            hideNoImageSymbol: true
        }

        RowLayout {
            id: progButtons
            height: 56
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 10

            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("▼")
                font.pixelSize: 24
                background: Rectangle {
                    radius: 10
                    color: "#22000000"
                    border.color: "#66ffffff"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#BDBDBD"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: progList.scrollDown()
            }
            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("▲")
                font.pixelSize: 24
                background: Rectangle {
                    radius: 10
                    color: "#22000000"
                    border.color: "#66ffffff"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "#BDBDBD"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: progList.scrollUp()
            }
		}
	}
	Rectangle {
		id: border
		width: 2
		anchors {
			left: scopeRect.right
			top: headerRect.bottom
			bottom: retButton.top
			leftMargin: 2
			
		}
		color: "darkgray"
	}
	
	Button {
		id: retButton
		
		anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottomMargin: 12
        width: 180
        height: 62
		background: Rectangle {
            radius: 18
            color: "#808080"
		}

		contentItem: Text {
			text: retButton.text
			color: "white"
			font.pixelSize: 24
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}

		text: qsTr("НАЗАД")

		onPressed: recProgs.returnButtonPressed()
	}
	
	Connections {
		target: scopeList
		function onNewIndexSelected(index) {
			recomHandle.scopeIdx = index
			recProgs.updateModel()
		}
		function onDeleteItem(index) {
			recomHandle.deleteScopeRequest(index)
		}
		function onEditItemName(index, name) {
			recomHandle.renameScopeRequest(index, name)
		}
	}
	Connections {
		target: progList
		function onNewIndexSelected(index) {
			var pid = (index >= 0 && index < recomHandle.progIdList.length)
					? recomHandle.progIdList[index] : -1
//			console.log("[ProgFlow] ProgItemList progList onNewIndexSelected listIndex:", index,
//						"progId:", pid, "loadClear:", loadClear,
//						"scopeIdx:", recomHandle.scopeIdx,
//						"progIdList.length:", recomHandle.progIdList.length)
			recomHandle.loadRecommendedProg(index, loadClear)
            
            var scopeName = ""
            if (recommended) {
                scopeName = scopeList.curIndex >= 0 && scopeList.curIndex < scopeModel.count 
                    ? scopeModel.get(scopeList.curIndex).itemName 
                    : ""
            } else {
                scopeName = "Программы пользователя"
            }
            
            var progName = index >= 0 && index < progsModel.count 
                ? progsModel.get(index).itemName 
                : ""
            
            recProgs.programSelected(scopeName, progName)
			recProgs.clickedButton(-1);
		}
		function onDeleteItem(index) {
			recomHandle.deleteProgRequest(index)
		}
		function onEditItemName(index, name) {
			recomHandle.renameProgRequest(index, name)
		}
	}
}

