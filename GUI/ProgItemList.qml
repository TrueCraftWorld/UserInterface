import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Rectangle {
    id: recProgs

    signal clickedButton(int idx)
    signal programSelected(string scopeName, string progName)
    signal returnButtonPressed()

    color: "#F3F5F9"

    property var itemIdArr: []
    property var itemNameArr: []
    property bool loadClear: true
    required property bool recommended
    property bool editable: false

    readonly property color fotekBlue: "#264093"
    readonly property color fotekOrange: "#faa731"
    readonly property color uiMidGray: "#5A6478"
    readonly property color scopeSelectedBackground: fotekBlue
    readonly property color scopeSelectedText: "white"
    readonly property color progSelectedBackground: fotekOrange
    readonly property color progSelectedText: "black"
    readonly property int screenMargin: 20

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
        scopeList.curIndex = recomHandle.scopeIdx
    }

    Component.onCompleted: {
        recomHandle.isRecomProgs = recommended
    }

    Connections {
        target: recomHandle
        function onScopeNameListChanged() {
            init()
            updateModel()
        }
        function onScopeIdxChanged() {
            scopeList.curIndex = recomHandle.scopeIdx
        }
        function onProgNameListChanged() {
            updateModel()
        }
    }

    Rectangle {
        id: headerRect
        height: 78
        color: fotekBlue
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        Label {
            anchors.fill: parent
            anchors.leftMargin: screenMargin
            anchors.rightMargin: screenMargin
            text: recommended
                  ? qsTr("РЕКОМЕНДОВАННЫЕ ПРОГРАММЫ")
                  : qsTr("ПОЛЬЗОВАТЕЛЬСКИЕ ПРОГРАММЫ")
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 34
            font.bold: true
            color: "white"
        }
    }

    RowLayout {
        id: listsRow
        anchors {
            top: headerRect.bottom
            left: parent.left
            right: parent.right
            bottom: footer.top
            margins: 16
        }
        spacing: 9

        Rectangle {
            id: scopeRect
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 320
            color: "transparent"

            Label {
                text: qsTr("Выберите область")
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                font.bold: true
                color: uiMidGray
            }

            ItemList {
                id: scopeList
                anchors {
                    top: parent.top
                    topMargin: 28
                    left: parent.left
                    right: parent.right
                    bottom: scopeButtons.top
                }
                curIndex: recomHandle.scopeIdx
                editable: !recProgs.recommended
                noImage: true
                hideNoImageSymbol: true
                selectedBackgroundColor: scopeSelectedBackground
                selectedTextColor: scopeSelectedText
                unselectedTextColor: fotekBlue
                itemBackgroundColor: "transparent"
                selectedBorderColor: "transparent"
                itemBorderColor: "transparent"
                selectedBorderWidth: 0
                itemBorderWidth: 0
                itemCornerRadius: 8
                keepSelectedItemAtTop: true
                noAutoScrollItemId: 1000
                itemFontPixelSize: 22
            }

            RowLayout {
                id: scopeButtons
                height: 56
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("▲")
                    font.pixelSize: 24
                    background: Rectangle {
                        radius: 18
                        color: "white"
                        border.color: fotekBlue
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: fotekBlue
                        font.pixelSize: 24
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: scopeList.scrollUp()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("▼")
                    font.pixelSize: 24
                    background: Rectangle {
                        radius: 18
                        color: "white"
                        border.color: fotekBlue
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: fotekBlue
                        font.pixelSize: 24
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: scopeList.scrollDown()
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: "#C7CEDA"
        }

        Rectangle {
            id: progRect
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 320
            color: "transparent"

            Label {
                text: qsTr("Выберите программу")
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                font.bold: true
                color: uiMidGray
            }

            ItemList {
                id: progList
                anchors {
                    top: parent.top
                    topMargin: 28
                    left: parent.left
                    right: parent.right
                    bottom: progButtons.top
                }
                editable: !recProgs.recommended
                noImage: true
                hideNoImageSymbol: true
                scrollSelectsItem: false
                selectedBackgroundColor: progSelectedBackground
                selectedTextColor: progSelectedText
                unselectedTextColor: "white"
                itemBackgroundColor: fotekBlue
                selectedBorderColor: "transparent"
                itemBorderColor: "transparent"
                selectedBorderWidth: 0
                itemBorderWidth: 0
                itemCornerRadius: 8
                keepSelectedItemAtTop: true
                noAutoScrollItemId: 1000
                itemFontPixelSize: 22
            }

            RowLayout {
                id: progButtons
                height: 56
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("▲")
                    font.pixelSize: 24
                    background: Rectangle {
                        radius: 18
                        color: "white"
                        border.color: fotekBlue
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: fotekBlue
                        font.pixelSize: 24
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: progList.scrollUp()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("▼")
                    font.pixelSize: 24
                    background: Rectangle {
                        radius: 18
                        color: "white"
                        border.color: fotekBlue
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: fotekBlue
                        font.pixelSize: 24
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: progList.scrollDown()
                }
            }
        }
    }

    Rectangle {
        id: footer
        height: 86
        color: "transparent"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        DialogActionButton {
            id: retButton
            anchors.left: parent.left
            anchors.leftMargin: screenMargin
            anchors.verticalCenter: parent.verticalCenter
            width: 180
            height: 62
            text: qsTr("НАЗАД")
            secondaryColor: "white"
            secondaryBorderWidth: 2
            secondaryBorderColor: fotekBlue
            cornerRadius: 20
            labelPixelSize: 30
            labelColor: fotekBlue
            onPressed: recProgs.returnButtonPressed()
        }
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
            if (pid < 0)
                return
            if (!appControl.loadProgram(pid, loadClear))
                return

            var scopeName = ""
            scopeName = scopeList.curIndex >= 0 && scopeList.curIndex < scopeModel.count
                    ? scopeModel.get(scopeList.curIndex).itemName
                    : ""

            var progName = index >= 0 && index < progsModel.count
                    ? progsModel.get(index).itemName
                    : ""

            recProgs.programSelected(scopeName, progName)
            recProgs.clickedButton(-1)
        }
        function onDeleteItem(index) {
            recomHandle.deleteProgRequest(index)
        }
        function onEditItemName(index, name) {
            recomHandle.renameProgRequest(index, name)
        }
    }
}
