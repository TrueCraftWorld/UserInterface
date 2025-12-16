import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import BackEnd 1.0

Drawer {
//с одной стороный многовато из-за необходимости репитер городить ради доступа к индексам
//с другой строны - всё ещё короче чем ручная передача параметров
    id: repeatRoot

    property int socketId: 0
    property var innerModel
    property int usedSpacing: 10

    background: Rectangle {
        color: "darkgray"
    }

    property int containerMargins: mainLayout.anchors.margins
    property int containerHeight:  leftColumn.height - leftColumn.spacing - titleItem.height
    // required property int usedSpacing

    property int collapsedFixedHeight: 85

    signal pedalMenuRequest()

    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (localRepeater.count) * repeatRoot.usedSpacing;
        for (var i = 0; i < localRepeater.count; i++) {
            if (!(localRepeater.itemAt(i) instanceof Rectangle)) {
                // console.log("oops")
                continue
            }
            if (localRepeater.itemAt(i).state === "expanded") {
                expandedCount++
            } else {
                totalFixedHeight += repeatRoot.collapsedFixedHeight
            }
        }
        return expandedCount > 0 ?
            (repeatRoot.containerHeight -
                (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2))
                    / expandedCount
            : 0
    }

    function calculateCollapsedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (localRepeater.count) * repeatRoot.usedSpacing;
        // console.log(count, "col")
        for (var i = 0; i < localRepeater.count; i++) {
            if (!(localRepeater.itemAt(i) instanceof Rectangle)) {
                continue
            }
            if (localRepeater.itemAt(i).state === "expanded") {
                expandedCount++
            }
        }
        if (expandedCount > 0) {
            return repeatRoot.collapsedFixedHeight
        } else {
            return (repeatRoot.containerHeight - (spacersHeight + repeatRoot.containerMargins*2))
            /(localRepeater.count)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "darkgray"
    }
    
    Rectangle {
        id: titleItem
        height: 120
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "transparent"
        Label {
            anchors.fill: parent
            text: {
                var socketName = "";
                if (innerModel && socketId >= 0) {
                    var socketIndex = innerModel.index(socketId, 0);
                    if (socketIndex.valid) {
                        socketName = innerModel.data(socketIndex, SocketModel.SocketName) || "";
                    }
                    return qsTr("ВЫБОР ИСТОЧНИКА АКТИВАЦИИ\nДЛЯ ВЫХОДА %1").arg(socketName || "X");
                }
                else {
                    return qsTr("ВЫБОР ИСТОЧНИКА АКТИВАЦИИ")
                }
            }
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 24
            color: "white"
        }
    }
    RowLayout {
        id: mainLayout
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: titleItem.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 10
        spacing: 20

        // Левая часть - PedalEditor для выбранного сокета
        ColumnLayout {
            id: leftColumn
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width * 0.6
            spacing: 10

            Repeater {
                id: localRepeater
                model: innerModel
                clip: true
                delegate: Rectangle {
                    id: rect
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: state === "expanded" ?
                                            repeatRoot.calculateExpandedHeight() :
                                            repeatRoot.calculateCollapsedHeight()

                    property string state: model.socketdisplaymode
                    color: "transparent"
                    // property int socketId: index
                    PedalEditor {
                        id: pedEditor
                        visible: rect.state === "expanded"
                        shownPedalsArray: model.socketallowedpedal
                        selectedPed: model.socketpedal
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Connections {
                        target: pedEditor
                        function onPedSelected (pedal) {
                            theModel.qmlSetData(socketId, pedal, "socketpedal");
                            repeatRoot.close()
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }

        // Правая часть - список всех сокетов с их педалями
        Rectangle {
            id: rightPanel
            Layout.preferredWidth: parent.width * 0.25
            Layout.fillHeight: true
            color: "transparent"

            ColumnLayout {
                id: rightLayout
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                spacing: leftColumn.spacing

//                // Невидимый элемент для выравнивания с titleItem в leftColumn
//                Rectangle {
//                    height: titleItem.height
//                    Layout.fillWidth: true
//                    color: "transparent"
//                }

                Repeater {
                    id: allPedalsRepeater
                    model: innerModel
                    delegate: Rectangle {
                        id: pedalRect
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredHeight: {
                            var leftRect = localRepeater.itemAt(index);
                            if (leftRect) {
                                return leftRect.Layout.preferredHeight;
                            }
                            return state === "expanded" ?
                                   repeatRoot.calculateExpandedHeight() :
                                   repeatRoot.calculateCollapsedHeight();
                        }
                        color: "transparent"
                        state: model.socketdisplaymode

                        Pedal {
                            id: pedIcon
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.rightMargin: 2
                            anchors.margins: 0
                            pedalStateIdx: model.socketpedal
                            socketId: index
                        }
                        
                        Connections {
                            target: pedIcon
                            function onPedalMenuRequest() {
                                // Устанавливаем socketId для открытия соответствующего PedalEditor
                                repeatRoot.socketId = index;
                                // Разворачиваем выбранный сокет и сворачиваем остальные
                                theModel.qmlSetData(index, 1, "socketdisplaymode");
                                // Сворачиваем все остальные сокеты
                                for (var i = 0; i < innerModel.rowCount(); i++) {
                                    if (i !== index) {
                                        theModel.qmlSetData(i, 0, "socketdisplaymode");
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
