import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: activationPopup
    
    // Привязка к данным из ControlCenter
    property string socketName /*control.activeSocketName || "Неизвестный сокет"*/
    property string modeName /*control.activeModeName || "Режим не выбран"*/
    property int power /*control.activePower || 0*/
    property bool isCoag /*control.activeIsCoag || false*/
    property bool isEndo: false
    
    // Настройки popup
    modal: true  // Модальный - блокируем касания
    closePolicy: Popup.NoAutoClose  // Закрывается только программно
    // parent: Overlay.overlay
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
    
    // Привязка к координатам и размерам активного сокета
    // x: control.activeSocketX || 0
    // y: control.activeSocketY || 0
    // width: control.activeSocketWidth || 350
    // height: control.activeSocketHeight || 400
    
    // Перехватываем все события мыши
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        preventStealing: true
        
        // onPressed: mouse.accepted = true
        // onReleased: mouse.accepted = true
        // onClicked: mouse.accepted = true
        // onDoubleClicked: mouse.accepted = true
        // onWheel: wheel.accepted = true
    }
    
    // Фон в зависимости от режима
    background: Rectangle {
        id: backgroundRect
        color: isCoag ? "#0f58fa" : "#ffd900"  // Синий для коагуляции, жёлтый для резания
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
                text: qsTr("АКТИВАЦИЯ ") + socketName
                font.pixelSize: 32
                font.bold: true
                color: isCoag ? "white" : "black"
                style: Text.Outline
                styleColor: isCoag ? "black" : "white"
            }
            
            // Разделитель
            Rectangle {
                width: 350
                height: 2
                color: isCoag ? "white" : "black"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Название режима
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modeName
                font.pixelSize: 48
                color: isCoag ? "white" : "black"
                style: Text.Outline
                styleColor: isCoag ? "black" : "white"
            }

            // Мощность
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(360, powerText.implicitWidth)
                height: endoRow.visible ? endoRow.implicitHeight : powerText.implicitHeight

                Text {
                    id: powerText
                    anchors.centerIn: parent
                    text: power
                    visible: !isEndo
                    font.pixelSize: 80
                    color: isCoag ? "yellow" : "brown"
                    style: Text.Outline
                    styleColor: isCoag ? "black" : "white"
                }

                Row {
                    id: endoRow
                    anchors.centerIn: parent
                    visible: isEndo
                    spacing: 16

                    Column {
                        spacing: 4
                        Text {
                            id: effCutLabel
                            text: qsTr("эффект резания")
                            font.pixelSize: 28
                            color: isCoag ? "white" : "black"
                            horizontalAlignment: Text.AlignHCenter
                            width: Math.max(effCutLabel.implicitWidth, effCutValue.implicitWidth)
                        }
                        Text {
                            id: effCutValue
                            text: Math.floor(power / 10)
                            font.pixelSize: 70
                            font.bold: true
                            color: isCoag ? "yellow" : "brown"
                            style: Text.Outline
                            styleColor: isCoag ? "black" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            width: effCutLabel.width
                        }
                    }

                    Column {
                        spacing: 4
                        Text {
                            id: effCoagLabel
                            text: qsTr("эффект коагуляции")
                            font.pixelSize: 28
                            color: isCoag ? "white" : "black"
                            horizontalAlignment: Text.AlignHCenter
                            width: Math.max(effCoagLabel.implicitWidth, effCoagValue.implicitWidth)
                        }
                        Text {
                            id: effCoagValue
                            text: power % 10
                            font.pixelSize: 70
                            font.bold: true
                            color: isCoag ? "white" : "black"
                            style: Text.Outline
                            styleColor: isCoag ? "black" : "white"
                            horizontalAlignment: Text.AlignHCenter
                            width: effCoagLabel.width
                        }
                    }
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
            duration: 50
        }
        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 50
            easing.type: Easing.OutQuad
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 50
        }
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.9
            duration: 50
            easing.type: Easing.InQuad
        }
    }
    
    // Синхронизация с control.activation
    // Connections {
    //     target: control
        
    //     function onActivationChanged(active) {
    //         if (active) {
    //             activationPopup.open()
    //         } else {
    //             activationPopup.close()
    //         }
    //     }
    // }
}

