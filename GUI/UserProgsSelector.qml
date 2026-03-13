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


    ListModel {
        id: progModel
    }

    function updateModel() {
        progModel.clear()
        itemNameArr = recomHandle.userProgList

        for (var i = 0; i < itemNameArr.length; i++) {
            progModel.append({
                itemName: itemNameArr[i],
                rowIndex: i
            })
        }
        progList.innerModel = progModel
        progList.curIndex = -1
    }


    Component.onCompleted: {
        recomHandle.userProgs()
    }

    GradientBack {
        anchors.fill: parent
        startColor: "darkblue"
        stopColor: "darkcyan"
        beamColor: "rgba(80, 120, 255, 0.6)"
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
            text: qsTr("Пользовательсие программы")
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 30
        }
    }
    Rectangle {
        id: progRect
        color: "transparent"
        anchors {
            left: parent.left
            top: headerRect.bottom
            bottom: retButton.top
            right: parent.right
            leftMargin: 2
        }

        ItemList {
            anchors.fill: parent
            id: progList
            noImage: true
        }
    }

    Button {
        id: retButton

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 50
        background: Rectangle {
            radius: 8
            color: "black"
            border.color: "darkgray"
            border.width: 2
        }

        contentItem: Text {
            text: retButton.text
            font: retButton.font
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        text: qsTr("Назад")

        onClicked: recProgs.returnButtonPressed()
    }

    Connections {
        target: progList
        function onNewIndexSelected(index) {
            // recomHandle.loadUserProg(index)
            
            var progName = index >= 0 && index < progModel.count 
                ? progModel.get(index).itemName 
                : ""
            
            recProgs.programSelected("Программы пользователя", progName)
            recProgs.clickedButton(-1);
        }
    }
    Connections {
        target: recomHandle
        function onUserProgListChanged() {
            console.log("gotSignal")
            updateModel()
        }
    }
}

