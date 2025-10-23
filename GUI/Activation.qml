import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: activationPopup
    
    // Привязка к данным из ControlCenter
    property string socketName: control.activeSocketName
    property string modeName: control.activeModeName
    property int power: control.activePower
    property bool isCoag: control.activeIsCoag
    
    // Настройки popup
    modal: true
    closePolicy: Popup.NoAutoClose  // Закрывается только программно
    parent: Overlay.overlay
    anchors.centerIn: parent
    
    width: 400
    height: 300
    
    // Перехватываем все события мыши
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        preventStealing: true
        
        onPressed: mouse.accepted = true
        onReleased: mouse.accepted = true
        onClicked: mouse.accepted = true
        onDoubleClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }
    
    // Фон в зависимости от режима
    background: Rectangle {
        id: backgroundRect
        color: isCoag ? "#0066CC" : "#FFB300"  // Синий для коагуляции, жёлтый для резки
        radius: 20
        border.color: "white"
        border.width: 3
        
        // Пульсирующая анимация
        SequentialAnimation on opacity {
            running: activationPopup.visible
            loops: Animation.Infinite
            
            NumberAnimation {
                from: 0.9
                to: 1.0
                duration: 600
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                from: 1.0
                to: 0.9
                duration: 600
                easing.type: Easing.InOutSine
            }
        }
    }
    
    contentItem: Item {
        // Главный контейнер с информацией
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            // Заголовок "АКТИВАЦИЯ"
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "АКТИВАЦИЯ"
                font.pixelSize: 36
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "black"
            }
            
            // Разделитель
            Rectangle {
                width: 350
                height: 2
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Название сокета
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: socketName
                font.pixelSize: 28
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "black"
            }
            
            // Название режима
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modeName
                font.pixelSize: 24
                color: "white"
                style: Text.Outline
                styleColor: "black"
            }
            
            // Мощность
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                
                Text {
                    text: "Мощность:"
                    font.pixelSize: 28
                    font.bold: true
                    color: "white"
                    style: Text.Outline
                    styleColor: "black"
                }
                
                Text {
                    text: power + " Вт"
                    font.pixelSize: 32
                    font.bold: true
                    color: "yellow"
                    style: Text.Outline
                    styleColor: "black"
                }
            }
        }
        
        // Анимированная рамка по краям
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: "transparent"
            border.color: "white"
            border.width: 3
            radius: 15
            opacity: 0.7
            
            SequentialAnimation on border.width {
                running: activationPopup.visible
                loops: Animation.Infinite
                
                NumberAnimation {
                    from: 3
                    to: 6
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: 6
                    to: 3
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    
    // Открытие/закрытие с анимацией
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
        }
        NumberAnimation {
            property: "scale"
            from: 0.8
            to: 1.0
            duration: 200
            easing.type: Easing.OutBack
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 150
        }
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.8
            duration: 150
            easing.type: Easing.InBack
        }
    }
    
    // Синхронизация с control.activation
    Connections {
        target: control
        
        function onActivationChanged(active) {
            if (active) {
                activationPopup.open()
            } else {
                activationPopup.close()
            }
        }
    }
}

