import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Popup {
    property int socId
    property int modeIndex
    property bool isCoag
    property var modeEditor: Editor
    // property string imageNameTemplate

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
    property var itemBriefArr: []
    property var itemDescriptArr: []
    property bool changed: false
    
    // Определяем префикс для изображения на основе типа сокета
    property string imagePrefix: {
        // socId: 0 = БИ1, 1 = БИ2, 2 = МОНО1, 3 = МОНО2
        return (socId <= 1) ? "bimode" : "monomode"
    }
    
    // Получаем Num текущего режима
    property int currentModeNum: {
        if (modeEditor.currentModeIndex < 0 || modeEditor.currentModeIndex >= itemNumArr.length)
            return 0
        return parseInt(itemNumArr[modeEditor.currentModeIndex])
    }
    
    // Получаем краткое описание текущего режима
    property string currentModeBrief: {
        if (modeEditor.currentModeIndex < 0 || modeEditor.currentModeIndex >= itemBriefArr.length)
            return ""
        return itemBriefArr[modeEditor.currentModeIndex]
    }
    
    // Получаем полное описание текущего режима
    property string currentModeDescript: {
        if (modeEditor.currentModeIndex < 0 || modeEditor.currentModeIndex >= itemDescriptArr.length)
            return ""
        return itemDescriptArr[modeEditor.currentModeIndex]
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
                rowIndex: i
            })
        }
        modeListView.innerModel = combinedModel
    }

    onOpened: {
        modeEditor.initialize(socId, modeIndex, isCoag)

        itemNameArr = modeEditor.modeNames
        itemIdArr = modeEditor.modeNamesIds()
        itemNumArr = modeEditor.modeNamesNums()
        itemBriefArr = modeEditor.modeNamesBriefs()
        itemDescriptArr = modeEditor.modeNamesDescripts()
        
        console.log("Mode briefs loaded:", itemBriefArr.length)
        console.log("Mode descripts loaded:", itemDescriptArr.length)
        console.log("Current mode index:", modeIndex)
        console.log("Current brief:", itemBriefArr[modeIndex])
        console.log("Current descript:", itemDescriptArr[modeIndex])
        
        updateModel()
        modeEditor.currentModeIndex = modeIndex
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        color: "black"

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
                color: "black"
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
                changed = false
                root.close()
            }
        }
        Button {
            id: upButton
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: titleLable.left
            }
            background: Rectangle {
                color: "black"
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
        }
    }

    Rectangle {
        id: modeList
        color: "black"
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: header.bottom
        }
        width: .3 * parent.width
        ItemList {
            id: modeListView
            curIndex: modeEditor.currentModeIndex
            anchors {
                top: parent.top
                bottom: footer.top
                left: parent.left
                right: parent.right
            }
            // innerModel: combinedModel
            imageSourceTemplate: "image://instrums/" + imagePrefix + "%1"
        }
        Rectangle {
            id: footer
            height: 100
            color: "black"
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            Button {
                id: downButton
                width: upButton.width
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                background: Rectangle {
                    color: "black"
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
            }
        }
    }

    Rectangle {
        id: instrumPreview
        anchors {
            top: header.bottom
            bottom: parent.bottom
            right: parent.right
            left: modeList.right
        }
        color: "black"
        
        // Описание режима
        Rectangle {
            id: descriptContainer
            anchors {
                left: parent.left
                right: previewImage.left
                top: parent.top
                bottom: previewImage.bottom
                margins: 10
            }
            color: "transparent"
            border.color: "white"
            border.width: 2
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // Краткое описание
                Rectangle {
                    id: briefRect
                    width: parent.width
                    height: parent.height * 0.3
                    color: "transparent"
                    border.color: "cyan"
                    border.width: 1
                    radius: 5
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 5
                        clip: true
                        
                        Label {
                            id: briefText
                            text: currentModeBrief
                            color: "cyan"
                            font.pixelSize: 16
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: briefRect.width - 10
                            
                            Component.onCompleted: {
                                console.log("briefText initialized, text:", text)
                            }
                            
                            onTextChanged: {
                                console.log("briefText changed to:", text)
                            }
                        }
                    }
                }
                
                // Полное описание
                Rectangle {
                    id: descriptRect
                    width: parent.width
                    height: parent.height * 0.65
                    color: "transparent"
                    border.color: "white"
                    border.width: 1
                    radius: 5
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 5
                        clip: true
                        
                        Label {
                            id: descriptText
                            text: currentModeDescript
                            color: "white"
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            width: descriptRect.width - 10
                            
                            Component.onCompleted: {
                                console.log("descriptText initialized, text:", text)
                            }
                            
                            onTextChanged: {
                                console.log("descriptText changed to:", text)
                            }
                        }
                    }
                }
            }
        }
        
        Image {
            id: previewImage
            width: 150
            height: width
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: ("image://instrums/" + imagePrefix + "%1").arg(currentModeNum)
            // source: "file"
            anchors {
                right: parent.right
                top: parent.top
                margins: 10
            }
        }
    }

    Button {
        id: declineButton
//        visible: modeEditor.hasChanges
        width: parent.width * .2
        height: parent.height * .15
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            left: modeList.right
            leftMargin: 20
        }
        background: Rectangle {
            color: "black"
            border.width: 2
            border.color: "darkred"
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
            changed = false
            root.close()
        }
    }

    Button {
        id: acceptButton
        width: parent.width * .2
        height: parent.height * .15
//        enabled: modeEditor.hasChanges
        visible: changed
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            left: declineButton.right
            leftMargin: 80
        }
        background: Rectangle {
            color: "black"
            border.width: 2
            border.color: "green"
            radius: 8
        }
        Text {
            id: acceptText
            text: qsTr("ПРИНЯТЬ")
            font.pixelSize: 34
            font.bold: true
            color: "green"
            anchors.fill: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
        onClicked: {
            modeEditor.commitChanges()
            changed = false
            root.close();
        }
    }

    Connections {
        target: modeListView
        function onNewIndexSelected(index) {
            modeEditor.currentModeIndex = index
            changed = true
        }
    }
}
