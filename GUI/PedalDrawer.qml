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
    
    // Отключаем встроенную модальность, используем свой overlay для тачскрина
    modal: false
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: "darkgray"
    }

    // Отключаем встроенную интерактивность Drawer, чтобы использовать свой MouseArea
    interactive: false

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

    // Фоновый Rectangle с MouseArea для блокировки событий от прохождения ЗА drawer
    Rectangle {
        anchors.fill: parent
        color: "darkgray"
        z: -1  // Ниже всех элементов внутри drawer
        
        // MouseArea блокирует события от прохождения к элементам ЗА drawer
        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
            onReleased: mouse.accepted = true
            onClicked: mouse.accepted = true
            onPositionChanged: mouse.accepted = true
            onDoubleClicked: mouse.accepted = true
        }
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
    
    // MouseArea для обработки свайпов закрытия (свайп вправо)
    // Размещаем в конце, чтобы он был последним в z-order и получал события первым
    MouseArea {
        anchors.fill: parent
        z: 1000  // Выше всех элементов внутри drawer
        enabled: repeatRoot.opened
        propagateComposedEvents: true  // Позволяем событиям проходить к элементам внутри
        
        property real startX: 0
        property real startY: 0
        property bool isSwipeGesture: false
        property real minSwipeDistance: 50
        
        onPressed: {
            startX = mouse.x
            startY = mouse.y
            isSwipeGesture = false
            // Принимаем событие, чтобы получать onPositionChanged для отслеживания свайпов
            mouse.accepted = true
        }
        
        onPositionChanged: {
            if (pressed) {
                var deltaX = mouse.x - startX
                var deltaY = Math.abs(mouse.y - startY)
                
                // Определяем свайп: горизонтальное движение > 50px и в 2 раза больше вертикального
                if (deltaX > 50 && deltaX > deltaY * 2 && !isSwipeGesture) {
                    isSwipeGesture = true
                }
            }
        }
        
        onReleased: {
            var deltaX = mouse.x - startX
            var deltaY = Math.abs(mouse.y - startY)
            var totalMovement = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
            
            if (isSwipeGesture && deltaX > minSwipeDistance) {
                // Свайп вправо достиг порога - закрываем drawer
                repeatRoot.close()
            } else if (totalMovement < 20) {
                // Минимальное движение (<20px) - считаем кликом
                // Эмулируем клик: ищем MouseArea под курсором и вызываем его clicked signal
                var item = mainLayout.childAt(mouse.x - mainLayout.x, mouse.y - mainLayout.y - titleItem.height)
                if (item) {
                    // Ищем MouseArea в найденном элементе или его родителях (до 10 уровней)
                    for (var i = 0; i < 10; i++) {
                        if (item && item.children) {
                            for (var j = 0; j < item.children.length; j++) {
                                var child = item.children[j]
                                if (child.toString().indexOf("MouseArea") >= 0 && child.clicked) {
                                    // Найден MouseArea - эмулируем клик
                                    child.clicked({accepted: false, x: 0, y: 0})
                                    isSwipeGesture = false
                                    return
                                }
                            }
                        }
                        item = item.parent
                    }
                }
            }
            isSwipeGesture = false
        }
    }
}
