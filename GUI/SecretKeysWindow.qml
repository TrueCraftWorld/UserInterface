import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.CuteKeyboard 1.0 as CuteKeyboardUi
import CuteKeyboard 1.0

import StratifyLabs.UI 2.0

Item {
    id: secretKeysRoot
    signal returnButtonPressed()

    readonly property var deviceTypeOptions: ["ONYX-M", "ONYX-AM"]
    readonly property var featureKeyOptions: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

    function featureCodeForKeyOption(keyOption) {
        return String(keyOption)
    }

    function uiLanguage() {
        if (typeof container !== "undefined" && container.language !== undefined)
            return container.normalizedLanguage(container.language)
        return "ru"
    }

    function keyboardPrimaryLayout() {
        var lang = uiLanguage()
        if (lang === "en")
            return "En"
        if (lang === "es")
            return "Es"
        return "Ru"
    }

    function availableKeyboardLayouts() {
        var lang = uiLanguage()
        if (lang === "en")
            return ["En"]
        if (lang === "es")
            return ["Es", "En"]
        return ["Ru", "En"]
    }

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
            topMargin: 5
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
                topMargin: 5
            }
            spacing: 15
            width: 1000
            
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
                            text: qsTr("Серийный номер:")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        TextField {
                            id: serialNumberInput
                            width: 150
                            height: 40
                            font.pixelSize: 16
                            placeholderText: "260000"
                            validator: IntValidator { bottom: 260000; top: 1000000 }
                            inputMethodHints: Qt.ImhDigitsOnly
                            color: "white"
                            background: Rectangle {
                                color: "#1a2a3a"
                                border.color: serialNumberInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                                border.width: 2
                                radius: 5
                            }
                        }

                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Тип аппарата:")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ComboBox {
                            id: generationDeviceType
                            width: 150
                            height: 40
                            model: secretKeysRoot.deviceTypeOptions
                            currentIndex: 1
                        }
                    }

                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter

                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Номер ключа:")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ComboBox {
                            id: generationFeatureKey
                            width: 80
                            height: 40
                            model: secretKeysRoot.featureKeyOptions
                            currentIndex: 0
                        }
                    }
                    
                    SButton {
                        style: "btn-primary"
                        text: qsTr("Сгенерировать ключ")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            if (serialNumberInput.text !== "") {
                                var serial = parseInt(serialNumberInput.text)
                                var key = keyGenerator.generateUnlockKey(serial,
                                                                         generationDeviceType.currentText,
                                                                         secretKeysRoot.featureCodeForKeyOption(generationFeatureKey.currentText))
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
                            width: 240
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
                            placeholderText: "260000"
                            validator: IntValidator { bottom: 260000; top: 1000000 }
                            inputMethodHints: Qt.ImhDigitsOnly
                            color: "white"
                            background: Rectangle {
                                color: "#1a2a3a"
                                border.color: checkSerialInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                                border.width: 2
                                radius: 5
                            }
                        }

                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Тип аппарата:")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ComboBox {
                            id: validationDeviceType
                            width: 150
                            height: 40
                            model: secretKeysRoot.deviceTypeOptions
                            currentIndex: 1
                        }
                    }

                    Row {
                        spacing: 15
                        anchors.horizontalCenter: parent.horizontalCenter

                        SLabel {
                            style: "label-secondary sm"
                            text: qsTr("Номер ключа:")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ComboBox {
                            id: validationFeatureKey
                            width: 80
                            height: 40
                            model: secretKeysRoot.featureKeyOptions
                            currentIndex: 0
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
                            width: 240
                            height: 40
                            font.pixelSize: 16
                            placeholderText: "123456789012"
                            maximumLength: 12
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
                                var isValid = keyGenerator.validateUnlockKey(serial,
                                                                            validationDeviceType.currentText,
                                                                            secretKeysRoot.featureCodeForKeyOption(validationFeatureKey.currentText),
                                                                            keyToValidate.text)
                                
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
                        text: qsTr("• Для каждого типа аппарата и номера ключа формируется отдельный 12-значный код")
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
    CuteKeyboardUi.InputPanel {
        id: inputPanel

        function tuneKeyboardTree(node) {
            if (!node)
                return
            if (node.autoRepeat !== undefined) {
                node.autoRepeat = node.btnKey !== undefined && node.btnKey === Qt.Key_Backspace
            }
            if (node.inputPanelRef !== undefined && !node.inputPanelRef)
                node.inputPanelRef = inputPanel
            if (node.item)
                tuneKeyboardTree(node.item)
            if (!node.children)
                return
            for (var i = 0; i < node.children.length; ++i) {
                tuneKeyboardTree(node.children[i])
            }
        }

        function keyboardFontFamily() {
            var fontName = STheme.font_family_base.name
            return fontName ? fontName : "DejaVu Sans"
        }

        function applyKeyboardFont() {
            var fontName = keyboardFontFamily()
            btnTextFontFamily = fontName
            InputPanel.btnTextFontFamily = fontName
        }

        function applyKeyboardUppercase() {
            InputEngine.uppercase = true
            Qt.callLater(function() { InputEngine.uppercase = true })
        }

        function applyTouchTuning() {
            applyKeyboardFont()
            applyKeyboardUppercase()
            tuneKeyboardTree(inputPanel)
        }

        function syncKeyboardLocales() {
            var layouts = secretKeysRoot.availableKeyboardLayouts()
            var primary = secretKeysRoot.keyboardPrimaryLayout()
            availableLanguageLayouts = layouts
            InputPanel.availableLanguageLayouts = layouts
            languageLayout = primary
            InputPanel.languageLayout = primary
            applyKeyboardFont()
            applyKeyboardUppercase()
        }

        z: 999
        y: secretKeysRoot.height
        languageLayout: secretKeysRoot.keyboardPrimaryLayout()
        availableLanguageLayouts: secretKeysRoot.availableKeyboardLayouts()
        btnTextFontFamily: STheme.font_family_base.name || "DejaVu Sans"
        anchors.left: parent.left
        anchors.right: parent.right

        onActiveChanged: {
            if (active) {
                syncKeyboardLocales()
                keyboardTuningTimer.restart()
                keyboardUppercaseTimer.restart()
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

        Timer {
            id: keyboardUppercaseTimer
            interval: 120
            repeat: false
            onTriggered: inputPanel.applyKeyboardUppercase()
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
