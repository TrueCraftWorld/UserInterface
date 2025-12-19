import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Popup {
    property int socId
    property int modeIndex
    property bool isCoag
    readonly property var modeEditor: Editor

    id: root
    modal: true
    parent: Overlay.overlay
    width: parent.width
    height: parent.height
    x: 0
    y: 0

    property var itemIdArr: []
    property var itemNameArr: []
    property var itemNumArr: []
    property int initiallySelectedItem
    
    // Определяем префикс для изображения на основе типа сокета
    property string imagePrefix: (socId <= 1) ? "bimode" : "monomode"
    // property string imagePrefix: {
    //     // socId: 0 = БИ1, 1 = БИ2, 2 = МОНО1, 3 = МОНО2
    //     return (socId <= 1) ? "bimode" : "monomode"
    // }
    
    // Получаем Num текущего режима
    property int currentModeNum: {
        if (modeIndex < 0
            || modeIndex >= itemNumArr.length)
            return 0
        return itemNumArr[modeIndex]
    }
    

    ListModel {
        id: combinedModel
    }

    // Function to update the model when C++ data changes
    function updateModel() {
        combinedModel.clear()

        if (itemIdArr.length !== itemNameArr.length || itemIdArr.length !== itemNumArr.length) {
            console.warn("Lists from C++ have different lengths!")
            return
        }
        for (var i = 0; i < itemIdArr.length; i++) {
            combinedModel.append({
                itemId: itemNumArr[i],  // Используем Num вместо ID для изображений
                itemName: itemNameArr[i],
                // rowIndex: i
            })
        }
        modeListView.innerModel = combinedModel
    }

    onOpened: {
        modeEditor.initialize(socId, modeIndex, isCoag)

        itemNameArr = modeEditor.modeNames
        itemIdArr = modeEditor.modeNamesIds()
        itemNumArr = modeEditor.modeNamesNums()
        
        updateModel()
        modeEditor.currentModeIndex = root.modeIndex
        modeListView.curIndex = modeEditor.currentModeIndex

        initiallySelectedItem = root.modeIndex
    }
    
    onClosed: {
        // Активация управляется централизованно через main.qml
    }

    Rectangle {
        id: back
        anchors.fill: parent
        color: "#0a0a0a"
        
        GradientBack {
            id: gradientBack
            anchors.fill: parent
            startColor: isCoag ? "#000066" : "#443300"
            stopColor: isCoag ? "#0000aa" : "#665500"
            beamColor: isCoag ? "#5078FF" : "#B4963C"
        }

        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
            color: "transparent"

            Label {
                id: titleLable
                text: !isCoag ? (qsTr("Выбор режима РЕЗАНИЯ для выхода %1")
                        .arg(modeEditor.socketName)) :
                               (qsTr("Выбор режима КОАГУЛЯЦИИ для выхода %1")
                        .arg(modeEditor.socketName))
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                height: parent.height / 2
                width: parent.width * 0.8
                color: isCoag ? "white" : "black"
                background:
                    Rectangle {
                        id: titleRect
                        color: isCoag ? "blue" : "yellow"
                        anchors.fill: parent
                    }
            }

            Button {
                id: cancelButton
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    left: titleLable.right
                }
                background: Rectangle {
                    color: "transparent"
                    radius: 8
                }

                Text {
                    id: cancelText
                    text: qsTr("X")
                    font.pixelSize: 34
                    font.bold: true
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    color: "white"
                }
                onClicked: {
                    modeEditor.rollBack()
                    root.close()
                }
            }
        }

        Rectangle {
            id: modeList
            color: "transparent"
            anchors {
                left: parent.left
                bottom: parent.bottom
                top: header.bottom
            }
            width: .3 * parent.width
            ItemList {
                id: modeListView
                initialIndex: initiallySelectedItem
                curIndex: modeEditor.currentModeIndex
                color: "transparent"
                anchors {
                    top: parent.top
                    bottom: footer.top
                    left: parent.left
                    right: parent.right
                }
                imageSourceTemplate: "image://modes/" + imagePrefix + "%1"
            }
            Rectangle {
                id: footer
                height: 100
                color: "transparent"
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                Button {
                    id: downButton
                    width: modeList.width * .4
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                    }
                    Text {
                        id: downText
                        text: qsTr("▼")
                        font.pixelSize: 34
                        font.bold: true
                        anchors.fill: parent
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        color: "white"
                    }
                    onClicked: {
                        modeListView.scrollDown()
                    }
                }
                Button {
                    id: upButton
                    width: downButton.width
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: downButton.right
                        leftMargin: 20
                    }
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                    }
                    Text {
                        id: upText
                        text: qsTr("▲")
                        font.pixelSize: 34
                        font.bold: true
                        anchors.fill: parent
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        color: "white"
                    }
                    onClicked: {
                        modeListView.scrollUp()
                    }
                }
            }
        }

        Rectangle {
            id: instrumPreview
            anchors {
                top: header.bottom
                bottom: declineButton.top
                right: parent.right
                left: modeList.right
            }
            color: "transparent"

            // Краткое описание
            Rectangle {
                id: briefRect
                height: previewImage.height
                anchors {
                    top: parent.top
                    left: parent.left
                    right: previewImage.left
                    margins: 10
                }

                color: "transparent"
                border.color: "cyan"
                border.width: 1
                radius: 5
                //я не знаю зачем именно так - но так можно улистать
                // весть текст вбок так что его не видно
                // ScrollView {
                //     anchors.fill: parent
                //     anchors.margins: 10
                //     clip: true

                    Label {
                        anchors.fill: parent
                        anchors.margins: 10
                        id: briefText
                        text: modeEditor.modeBrief
                        color: "cyan"
                        font.pixelSize: 21
                        font.bold: true
                        wrapMode: Text.WordWrap
                        width: briefRect.width - 10

                    }
                // }
            }

            Image {
                id: previewImage
                width: 150
                height: width
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: ("image://modes/" + imagePrefix + "%1").arg(currentModeNum)
                // source: "file"
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
            }
            // Полное описание
            Rectangle {
                id: descriptRect
                width: parent.width
                anchors {
                    left: parent.left
                    top: previewImage.bottom
                    bottom: parent.bottom
                    margins: 10
                }

                color: "transparent"

                // ScrollView {
                //     anchors.fill: parent
                //     anchors.margins: 10
                //     clip: true

                    Label {
                        id: descriptText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: modeEditor.modeDescript
                        color: "white"
                        font.pixelSize: 24
                        wrapMode: Text.WordWrap
                        width: descriptRect.width - 10
                    }
                // }
            }
        }

        Button {
            id: declineButton
            // visible: modeEditor.hasChanges
            width: parent.width * .2
            height: parent.height * .15
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                left: modeList.right
                leftMargin: 20
            }
            background: Rectangle {
                color: "transparent"
                border.width: 3
                border.color: "white"
                radius: 8
            }

            Text {
                id: declineText
                text: qsTr("ОТМЕНА")
                font.pixelSize: 34
                font.bold: true
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                color: "white"
            }
            onClicked: {
                modeEditor.rollBack()
                root.close()
            }
        }

        Button {
            id: acceptButton
            width: parent.width * .2
            height: parent.height * .15
            visible: modeEditor.hasChanges
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                left: declineButton.right
                leftMargin: 80
            }
            background: Rectangle {
                color: "transparent"
                border.width: 3
                border.color: "lightgreen"
                radius: 8
            }
            Text {
                id: acceptText
                text: qsTr("ПРИНЯТЬ")
                font.pixelSize: 34
                font.bold: true
                color: "lightgreen"
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            onClicked: {
                modeEditor.commitChanges()
                root.close();
            }
        }
    }

    Connections {
        target: modeListView
        function onNewIndexSelected(index) {
            modeEditor.currentModeIndex = index
        }
    }
}
