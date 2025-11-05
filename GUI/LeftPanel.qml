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
        onPressed: {
            // Не принимаем событие - пусть дочерние элементы его обработают
            mouse.accepted = false
        }
        onClicked: {
            // Клик по пустому месту - ничего не делаем, просто перехватываем
            mouse.accepted = false
        }
    }
    
    Label {
        id: argonChoice
        visible: panelExpanded
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("НАСТРОЙКА ГАЗОВОГО ТРАКТА")
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
    // Компонент аргона
    Argon {
        id: argonControl
        height: panelExpanded ? 350 : 430
        anchors {
            left: parent.left
            right: parent.right
            top: panelExpanded ? argonChoice.bottom : parent.top
            topMargin: 5
            leftMargin: panelExpanded ? 10 : 5
            rightMargin: panelExpanded ? 10 : 5
        }
        z: 10  // Выше фонового MouseArea
        
        // Передаем параметры из control
        showControls: panelExpanded
        cylinder1Connected: control.argonCylinder1Connected
        cylinder2Connected: control.argonCylinder2Connected
        flowRate: control.argonFlowRate
        activCylinderFirst: control.activCylinderFirst
        
        // Обработчик изменения расхода
        onFlowRateUpdated: {
            // Обновляем значение в control
            control.argonFlowRate = newRate
        }
        
        // Обработчик продувки аргона
        onArgonBlow: {
            // Вызываем метод продувки в control
            control.argonBlow()
        }
    }


    // NeutralEl компонент
    NeutralEl {
        id: neutralEl
        height: panelExpanded ? 260 : 165
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

    Label {
        id: neutralChoice
        visible: panelExpanded
        anchors {
            bottom: neutralEl.top
            bottomMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Qt.AlignHCenter
        text: qsTr("ВЫБОР НЕЙТРАЛЬНОГО ЭЛЕКТРОДА")
        color: "white"
        font.pixelSize: 16
        font.bold: true
    }
}

