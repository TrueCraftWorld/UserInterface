import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtQuick.Layouts 1.15
import StratifyLabs.UI 2.0

// Popup {
Rectangle {
    // property alias pedTitle : title.text
    property var shownPedalsArray: []
    property int selectedPed
    property int socketNumber: -1  // Номер сокета (0-3)
    signal pedSelected(int index)

    id: pedalSelectRoot
    color: "#6a6a6a"

    // function calcDimensions() {
    //     var rowMargins = 30  //
    //     var itemCount = pedalSelectRoot.shownPedalsArray.length + 1  // +1 для emptyPed
        
    //     // Доступная высота (элементы квадратные)
    //     var availableHeight = pedalSelectRoot.height - rowMargins
        
    //     // Доступная ширина с минимальным spacing = 5px
    //     var minSpacing = 5
    //     var totalMinSpacing = minSpacing * (itemCount + 1)
    //     var availableWidthForItems = pedalSelectRoot.width - rowMargins - totalMinSpacing
    //     var widthPerItem = availableWidthForItems / itemCount
        
    //     // Размер элемента = минимум из доступной ширины и высоты
    //     var size = Math.min(widthPerItem, availableHeight)
    //     return Math.floor(size)
    // }
    
    // function calcSpacing() {
    //     var rowMargins = 30
    //     var itemCount = pedalSelectRoot.shownPedalsArray.length + 1
    //     var elementSize = calcDimensions()
        
    //     // Вычисляем фактический spacing на основе размера элементов
    //     var totalItemsWidth = elementSize * itemCount
    //     var availableWidth = pedalSelectRoot.width - rowMargins
    //     var remainingSpace = availableWidth - totalItemsWidth
        
    //     // Распределяем оставшееся пространство между элементами
    //     if (itemCount > 1) {
    //         var spacing = remainingSpace / (itemCount + 1)
    //         // Гарантируем минимум 5px
    //         return Math.floor(Math.max(5, spacing))
    //     }
    //     return 5
    // }


    // // Позиционирование и размеры задаются в PedalPanel.qml
    // // modal: false
    // // focus: true
    
    // background: Rectangle {
    //     color: "#3c3c3c"
    //     radius: 8
    //     border.color: "white"
    //     border.width: 2
    // }

    // onOpened: {
    //     singlePed.visible = false;
    //     doublePed.visible = false;
    //     biHandle.visible = false;
    //     monoHandle.visible = false;
        
    //     for (var idx = 0; idx < shownPedalsArray.length; ++idx) {
    //         if (shownPedalsArray[idx] === 1) {
    //             singlePed.visible = true;
    //         }
    //         if (shownPedalsArray[idx] === 2) {
    //             doublePed.visible = true;
    //         }
    //         // кнопка термошва доступна только для сокета с номером 1 (БИ2)
    //         if (shownPedalsArray[idx] === 3 && socketNumber === 1) {
    //             biHandle.visible = true;
    //         }
    //         // держатель с кнопками доступен только для монополярных сокетов
    //         if (shownPedalsArray[idx] === 4 && (socketNumber === 2 || socketNumber === 3)) {
    //             monoHandle.visible = true;
    //         }
    //     }
    //     layoutRow.elementSize = calcDimensions()
    //     layoutRow.spacing = calcSpacing()
    // }
    onShownPedalsArrayChanged: {
        singlePed.visible = false;
        doublePed.visible = false;
        biHandle.visible = false;
        monoHandle.visible = false;
//        console.log("onShownPedalsArrayChanged", shownPedalsArray)
        for (var idx = 0; idx < shownPedalsArray.length; ++idx) {
            if (shownPedalsArray[idx] === 1) {
                singlePed.visible = true;
            }
            if (shownPedalsArray[idx] === 2) {
                doublePed.visible = true;
            }
            // кнопка термошва доступна только для сокета с номером 1 (БИ2)
            if (shownPedalsArray[idx] === 3 ) {
                biHandle.visible = true;
            }
            // держатель с кнопками доступен только для монополярных сокетов
            if (shownPedalsArray[idx] === 4 ) {
                monoHandle.visible = true;
            }
        }
    }

    Row {
        id: layoutRow
        property int elementSize: 100
        // spacing: layoutRow.spacing
        spacing: 15
        anchors.fill: parent
        anchors.margins: 5
        Rectangle {
            id: emptyPed
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 0 ? "cyan" : "transparent"
            radius: 8

            border {
                width: 1
                color: "white"
            }
            
            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: parent.height * 0.6
                font.bold: true
                color: "gray"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            MouseArea {
                anchors.fill: parent
                onPressed: pedalSelectRoot.pedSelected(0)
            }
        }
        Rectangle {
            id: singlePed
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 1 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "blue"
                border {
                    width: 1
                    color: "white"
                }
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: pedalSelectRoot.pedSelected(1)
            }
        }
        Rectangle {
            id: doublePed
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 2 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "yellow"
                border {
                    width: 1
                    color: "black"
                }
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: parent.width * 0.13
                }
            }
            Rectangle {
                width: parent.width * .3
                height: parent.height * .75
                radius: 6
                color: "blue"
                border {
                    width: 1
                    color: "white"
                }
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: parent.width * 0.13
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: pedalSelectRoot.pedSelected(2)
            }
        }
        Rectangle {
            id: biHandle
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 3 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .65
                height: parent.height * .65
                radius: width/2
                color: "purple"
                border {
                    width: 2
                    color: "white"
                }
                anchors.centerIn: parent;
            }

            MouseArea {
                anchors.fill: parent
                onPressed: pedalSelectRoot.pedSelected(3)
            }
        }
        Rectangle {
            id: monoHandle
            width: layoutRow.elementSize
            height: layoutRow.elementSize
            color: pedalSelectRoot.selectedPed === 4 ? "cyan" : "transparent"
            radius: 8
            border {
                width: 1
                color: "white"
            }
            Rectangle {
                width: parent.width * .42
                height: parent.height * .42
                radius: width/2
                color: "yellow"
                border {
                    width: 2
                    color: "black"
                }
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: parent.width * .085
                }
            }
            Rectangle {
                width: parent.width * .42
                height: parent.height * .42
                radius: width/2
                color: "blue"
                border {
                    width: 2
                    color: "white"
                }
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: parent.width * .085
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: pedalSelectRoot.pedSelected(4)
            }
        }
    }
}
