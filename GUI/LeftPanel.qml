import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: leftPanel
    
    // Публичные свойства
    property bool panelExpanded: false
    property bool neutralConnected: false
    property int expandedWidth: 400
    property int collapsedWidth: 85
    property int animationDuration: 300
    property int animationEasing: Easing.InOutQuad
    
    width: panelExpanded ? expandedWidth : collapsedWidth
    color: "#2c2c2c"
    
    // Анимация изменения ширины (синхронизирована с rightPanel)
    Behavior on width {
        NumberAnimation { 
            duration: leftPanel.animationDuration
            easing.type: leftPanel.animationEasing
        }
    }
    
    // MouseArea для фона панели (перехватывает клики по пустому месту)
    MouseArea {
        anchors.fill: parent
        z: 1  // Ниже интерактивных компонентов
        propagateComposedEvents: true
        
        // Принимаем событие по умолчанию, но разрешаем передачу дочерним элементам
        onClicked: {
            // Клик по пустому месту - ничего не делаем, просто перехватываем
            mouse.accepted = true
        }
    }
    
    // В развернутом состоянии - полный блок аргона
    Rectangle {
        id: argonDummy
        radius: 8
        color: "lightgray"
        height: 100
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        border {
            color: "black"
            width: 1
        }
        visible: panelExpanded
        z: 10  // Выше фонового MouseArea

        Text {
            anchors.centerIn: parent
            text: "Argon"
            font.pixelSize: 16
            color: "black"
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Обработка клика по аргону
                mouse.accepted = true
            }
        }
    }

    // В свернутом состоянии - маленькая кнопка
    Rectangle {
        id: argonButton
        width: parent.width
        height: 100
        radius: 5
        color: "lightgray"
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
        }
        border {
            color: "black"
            width: 1
        }
        visible: !panelExpanded
        z: 10  // Выше фонового MouseArea

        Text {
            anchors.centerIn: parent
            text: "A"
            font.pixelSize: 12
            color: "black"
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Обработка клика по кнопке аргона
                mouse.accepted = true
            }
        }
    }

    // NeutralEl компонент
    NeutralEl {
        id: neutralEl
        height: panelExpanded ? 290 : 170
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 5
        }
        width: parent.width - anchors.margins * 2
        z: 10  // Выше фонового MouseArea

        // Передаем параметры
        neutralConnected: control.neutralElConnected
        showControls: panelExpanded

        // Обработчики сигналов
        onNeutralDividedChanged: {
            // Можно добавить обработку изменения типа
        }

        onNeutralSizeChanged: {
            // Можно добавить обработку изменения размера
        }
    }
}

