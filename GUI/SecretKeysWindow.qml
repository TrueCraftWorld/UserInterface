import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.CuteKeyboard 1.0

import StratifyLabs.UI 2.0

Item {
    id: secretKeysRoot
    signal returnButtonPressed()
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: "darkslategray"
    }
    
    SLabel {
        id: screenTitle
        style: "label-primary lg"
        text: qsTr("Секретные ключи")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    
    SButton {
        id: returnButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onClicked: secretKeysRoot.returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
    }
    
    // Контейнер для содержимого
    Item {
        id: contentArea
        anchors {
            top: screenTitle.bottom
            topMargin: 25
            left: parent.left
            right: parent.right
            bottom: returnButton.top
            margins: 20
        }
        
        // Колонка с элементами управления
        Column {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 20
            }
            spacing: 30
            width: 600
            
            // Секция генерации ключа
            Rectangle {
                width: parent.width
                height: generationColumn.height + 40
                color: "#2a4a5a"
                radius: 10
                border.color: "#3d5a6a"
                border.width: 2
                
                Column {
                    id: generationColumn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        margins: 20
                    }
                    spacing: 15
                    width: parent.width - 40
                    
                    SLabel {
                        style: "label-primary md"
                        text: qsTr("Генерация ключа")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Серийный номер (0-999999):")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        TextField {
                            id: serialNumberInput
                            width: 150
                            height: 40
                            font.pixelSize: 16
                            placeholderText: "123456"
                            validator: IntValidator { bottom: 0; top: 999999 }
                            inputMethodHints: Qt.ImhDigitsOnly
                            color: "white"
                            background: Rectangle {
                                color: "#1a2a3a"
                                border.color: serialNumberInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                                border.width: 2
                                radius: 5
                            }
                        }
                    }
                    
                    SButton {
                        style: "btn-primary"
                        text: qsTr("Сгенерировать ключ")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            if (serialNumberInput.text !== "") {
                                var serial = parseInt(serialNumberInput.text)
                                var key = keyGenerator.generateKey(serial)
                                generatedKeyDisplay.text = key
                                generationResult.text = qsTr("✓ Ключ сгенерирован успешно!")
                                generationResult.color = "#4ade80"
                            } else {
                                generationResult.text = qsTr("✗ Введите серийный номер")
                                generationResult.color = "#f87171"
                            }
                        }
                    }
                    
                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Сгенерированный ключ:")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        TextField {
                            id: generatedKeyDisplay
                            width: 200
                            height: 40
                            font.pixelSize: 18
                            font.bold: true
                            readOnly: true
                            color: "#4ade80"
                            background: Rectangle {
                                color: "#0a1a2a"
                                border.color: "#4a9eff"
                                border.width: 2
                                radius: 5
                            }
                        }
                    }
                    
                    SLabel {
                        id: generationResult
                        style: "label-secondary sm"
                        text: ""
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            // Секция проверки ключа
            Rectangle {
                width: parent.width
                height: validationColumn.height + 40
                color: "#2a4a5a"
                radius: 10
                border.color: "#3d5a6a"
                border.width: 2
                
                Column {
                    id: validationColumn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        margins: 20
                    }
                    spacing: 15
                    width: parent.width - 40
                    
                    SLabel {
                        style: "label-primary md"
                        text: qsTr("Проверка ключа")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Серийный номер:")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        TextField {
                            id: checkSerialInput
                            width: 150
                            height: 40
                            font.pixelSize: 16
                            placeholderText: "123456"
                            validator: IntValidator { bottom: 0; top: 999999 }
                            inputMethodHints: Qt.ImhDigitsOnly
                            color: "white"
                            background: Rectangle {
                                color: "#1a2a3a"
                                border.color: checkSerialInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                                border.width: 2
                                radius: 5
                            }
                        }
                    }
                    
                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Ключ для проверки:")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        TextField {
                            id: keyToValidate
                            width: 200
                            height: 40
                            font.pixelSize: 16
                            placeholderText: "1234567890"
                            maximumLength: 10
                            inputMethodHints: Qt.ImhDigitsOnly
                            color: "white"
                            background: Rectangle {
                                color: "#1a2a3a"
                                border.color: keyToValidate.activeFocus ? "#4a9eff" : "#3a4a5a"
                                border.width: 2
                                radius: 5
                            }
                        }
                    }
                    
                    SButton {
                        style: "btn-info"
                        text: qsTr("Проверить ключ")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            if (checkSerialInput.text !== "" && keyToValidate.text !== "") {
                                var serial = parseInt(checkSerialInput.text)
                                var isValid = keyGenerator.validateKey(serial, keyToValidate.text)
                                
                                if (isValid) {
                                    validationResult.text = qsTr("✓ КЛЮЧ ВЕРНЫЙ! Проверка пройдена успешно")
                                    validationResult.color = "#4ade80"
                                } else {
                                    validationResult.text = qsTr("✗ КЛЮЧ НЕВЕРНЫЙ! Проверка не пройдена")
                                    validationResult.color = "#f87171"
                                }
                            } else {
                                validationResult.text = qsTr("✗ Заполните все поля")
                                validationResult.color = "#fbbf24"
                            }
                        }
                    }
                    
                    SLabel {
                        id: validationResult
                        style: "label-secondary md"
                        text: ""
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            // Информационная панель
            Rectangle {
                width: parent.width
                height: infoColumn.height + 30
                color: "#1a2a3a"
                radius: 10
                border.color: "#2a3a4a"
                border.width: 1
                
                Column {
                    id: infoColumn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        margins: 15
                    }
                    spacing: 8
                    width: parent.width - 30
                    
                    SLabel {
                        style: "label-secondary sm"
                        text: qsTr("ℹ️ Информация:")
                        font.bold: true
                    }
                    
                    SLabel {
                        style: "label-secondary sm"
                        text: qsTr("• Ключи генерируются криптографическим алгоритмом SHA-256")
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    SLabel {
                        style: "label-secondary sm"
                        text: qsTr("• Каждый серийный номер имеет уникальный 10-значный ключ")
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    SLabel {
                        style: "label-secondary sm"
                        text: qsTr("• Соседние номера гарантированно имеют различные ключи")
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }
    
    // Виртуальная клавиатура CuteKeyboard
    InputPanel {
        id: inputPanel

        function tuneKeyboardTree(node) {
            if (!node)
                return
            if (node.autoRepeat !== undefined) {
                node.autoRepeat = false
            }
            if (node.alternativeKeys !== undefined) {
                node.alternativeKeys = []
            }
            if (!node.children)
                return
            for (var i = 0; i < node.children.length; ++i) {
                tuneKeyboardTree(node.children[i])
            }
        }

        function applyTouchTuning() {
            tuneKeyboardTree(inputPanel)
        }
        
        z: 999
        y: secretKeysRoot.height
        availableLanguageLayouts: ["Ru","En"]
        anchors.left: parent.left
        anchors.right: parent.right

        onActiveChanged: {
            if (active) {
                keyboardTuningTimer.restart()
            }
        }

        onLanguageLayoutChanged: keyboardTuningTimer.restart()

        Timer {
            id: keyboardTuningTimer
            interval: 40
            repeat: false
            onTriggered: {
                inputPanel.applyTouchTuning()
                Qt.callLater(inputPanel.applyTouchTuning)
            }
        }

        states: State {
            name: "visible"
            when: Qt.inputMethod.visible
            PropertyChanges {
                target: inputPanel
                y: secretKeysRoot.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
