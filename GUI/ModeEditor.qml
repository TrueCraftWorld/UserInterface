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


    ListModel {
        id: combinedModel
    }

    // Function to update the model when C++ data changes
    function updateModel() {
        combinedModel.clear()

        if (itemIdArr.length !== itemNameArr.length) {
            console.warn("Lists from C++ have different lengths!")
            return
        }
        for (var i = 0; i < itemIdArr.length; i++) {
            combinedModel.append({
                itemId: itemIdArr[i],
                itemName: itemNameArr[i],
                rowIndex: i
            })
        }
        modeListView.innerModel = combinedModel
        // root.update()
    }

    onOpened: {
        modeEditor.initialize(socId, modeIndex, isCoag)

        itemNameArr = modeEditor.modeNames
        itemIdArr = modeEditor.modeNamesIds()
        updateModel()
        // modeListView.initialIndex = modeEditor.currentModeIndex
        modeEditor.currentModeIndex = modeIndex

    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        color: "darkgray"

        Label {
            id: titleLable
            text: qsTr("Выбор режим для выхода %1")
                    .arg(modeEditor.socketName)
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 28
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: parent.height / 2
            // anchors.bottom: parent.bottom
            width: parent.width * 0.8
        }
        Rectangle {
            id: titleLowerRect
            color: isCoag ? "blue" : "yellow"
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top: parent.top
            anchors.bottom: parent.bottom
            height: parent.height / 2
            width: titleLableLower.contentWidth + 50
        }

        Label {
            id: titleLableLower
            text: isCoag ? qsTr("КОАГУЛЯЦИЯ") : qsTr("РЕЗАНИЕ")

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 28
            font.bold: true
            color: isCoag ? "white" : "black"
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top: parent.top
            anchors.bottom: parent.bottom
            height: parent.height / 2
            width: parent.width * 0.8
        }

        Button {
            id: cancelButton
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: titleLable.right
            }
            Text {
                id: cancelText
                text: qsTr("X")
                font.pixelSize: 34
                font.bold: true
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            onClicked: {
                modeEditor.rollBack()
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
            Text {
                id: upText
                text: qsTr("▲")
                font.pixelSize: 34
                font.bold: true
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
        }
    }

    Rectangle {
        id: modeList
        color: "darkgray"
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
            imageSourceTemplate: "image://instrums/miniMode%1"
        }
        Rectangle {
            id: footer
            height: 100
            color: "darkgray"
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
                Text {
                    id: downText
                    text: qsTr("▼")
                    font.pixelSize: 34
                    font.bold: true
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
            }
            Button {
                id: acceptButton
                enabled: modeEditor.hasChanges
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: downButton.right
                    right: parent.right
                }
                Text {
                    id: acceptText
                    text: qsTr("Принять")
                    font.pixelSize: 34
                    font.bold: true
                    color: "green"
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
    }

    Rectangle {
        id: instrumPreview
        anchors {
            top: header.bottom
            bottom: parent.bottom
            right: parent.right
            left: modeList.right
        }
        color: "darkgray"
        Image {
            id: previewImage
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: ("image://instrums/maxiMode%1").arg(modeEditor.currentModeIndex)
            // source: "file"
            anchors {
                left: parent.left
                right: parent.right
                bottom: footer.top
                top: parent.top
                margins: 10
            }
        }
    }
    Connections {
        target: modeListView
        function onNewIndexSelected(index) {
            console.log("arrr", index)
            modeEditor.currentModeIndex = index
        }
    }
}
