import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: settingsMenuRoot

    signal returnButtonPressed()
    signal serviceMenuButtonPressed()
    signal logFileButtonPressed()
    signal infoButtonPressed()
    signal languageButtonPressed()
    signal dateTimeSettingsButtonPressed()

    property bool endoscopyEnabled: false
    property bool argonModesEnabled: false

    readonly property int menuButtonWidth: 550
    readonly property int menuButtonHeight: 96
    readonly property int menuColumnsSpacing: 24
    readonly property int unlockButtonFontSize: 24

    function readEndoscopyEnabled() {
        return typeof savedJson !== "undefined"
                && savedJson
                && savedJson.readString("endoscopyEnabled", "0") === "1"
    }

    function readArgonModesEnabled() {
        return typeof savedJson !== "undefined"
                && savedJson
                && savedJson.readString("argonModesEnabled", "0") === "1"
    }

    function isOnyxAm() {
        if (typeof savedJson === "undefined" || !savedJson) {
            return true
        }
        return String(savedJson.readString("deviceType", "ONYX-AM")).trim().toUpperCase() === "ONYX-AM"
    }

    function saveEndoscopyEnabled(enabled) {
        endoscopyEnabled = enabled
        if (typeof savedJson !== "undefined" && savedJson) {
            savedJson.saveString("endoscopyEnabled", enabled ? "1" : "0")
        }
    }

    function saveArgonModesEnabled(enabled) {
        argonModesEnabled = enabled
        if (typeof savedJson !== "undefined" && savedJson) {
            savedJson.saveString("argonModesEnabled", enabled ? "1" : "0")
        }
    }

    function isServiceMenuNoPasswordEnabled() {
        if (typeof savedJson === "undefined" || !savedJson) {
            return false
        }
        return savedJson.readString("serviceMenuNoPassword", "0") === "1"
    }

    function isServiceMenuPasswordValid(value) {
        var normalized = String(value).trim().toLowerCase()
        normalized = normalized.replace(/\u0430/g, "a")
        return normalized === "145a"
    }

    function requestServiceMenuAccess() {
        if (settingsMenuRoot.isServiceMenuNoPasswordEnabled()) {
            settingsMenuRoot.serviceMenuButtonPressed()
        } else {
            servicePasswordDialog.passwordError = ""
            servicePasswordDialog.open()
        }
    }

    function requestEndoscopyUnlock() {
        endoscopyPasswordDialog.passwordError = ""
        endoscopyPasswordDialog.open()
    }

    function requestArgonUnlock() {
        argonPasswordDialog.passwordError = ""
        argonPasswordDialog.open()
    }

    Component.onCompleted: {
        endoscopyEnabled = readEndoscopyEnabled()
        argonModesEnabled = readArgonModesEnabled()
    }

    Rectangle {
        anchors.fill: parent
        color: "darkslategray"
    }

    SLabel {
        id: screenTitle
        style: "label-primary lg"
        text: qsTr("Настройки")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    GridLayout {
        anchors {
            top: screenTitle.bottom
            topMargin: 36
            horizontalCenter: parent.horizontalCenter
        }
        columns: 2
        columnSpacing: settingsMenuRoot.menuColumnsSpacing
        rowSpacing: 20
        width: settingsMenuRoot.menuButtonWidth * 2 + settingsMenuRoot.menuColumnsSpacing

        SButton {
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("Сервисное меню")
            onPressed: settingsMenuRoot.requestServiceMenuAccess()
        }

        SButton {
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("Журнал событий")
            onPressed: settingsMenuRoot.logFileButtonPressed()
        }

        SButton {
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("ИНФО")
            onPressed: settingsMenuRoot.infoButtonPressed()
        }

        SButton {
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("RU / EN")
            onPressed: settingsMenuRoot.languageButtonPressed()
        }

        SButton {
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("Настройка даты и времени")
            onPressed: settingsMenuRoot.dateTimeSettingsButtonPressed()
        }

        SButton {
            visible: !settingsMenuRoot.endoscopyEnabled
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("Разблокировка эндоскопических функций")
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: settingsMenuRoot.unlockButtonFontSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
            }
            onPressed: settingsMenuRoot.requestEndoscopyUnlock()
        }

        SButton {
            visible: settingsMenuRoot.isOnyxAm() && !settingsMenuRoot.argonModesEnabled
            style: "btn-primary lg"
            Layout.preferredWidth: settingsMenuRoot.menuButtonWidth
            Layout.preferredHeight: settingsMenuRoot.menuButtonHeight
            text: qsTr("Разблокировка аргонусиленной коагуляции")
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: settingsMenuRoot.unlockButtonFontSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideNone
            }
            onPressed: settingsMenuRoot.requestArgonUnlock()
        }
    }

    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onPressed: settingsMenuRoot.returnButtonPressed()
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
    }

    Dialog {
        id: servicePasswordDialog
        property string passwordError: ""
        modal: true
        width: Math.min(settingsMenuRoot.width * 0.92, 760)
        height: 380
        x: (settingsMenuRoot.width - width) / 2
        y: (settingsMenuRoot.height - height) / 2
        title: ""

        contentItem: Rectangle {
            color: "white"
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Для доступа к сервисным функциям введите пароль")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 28
                    font.bold: true
                }

                TextField {
                    id: servicePasswordInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    placeholderText: qsTr("Пароль")
                    echoMode: TextInput.Password
                    selectByMouse: true
                    font.pixelSize: 24
                    color: "black"
                    background: Rectangle {
                        color: "#f5f5f5"
                        border.color: servicePasswordInput.activeFocus ? "#4a9eff" : "#7a7a7a"
                        border.width: 2
                        radius: 6
                    }
                    onAccepted: servicePasswordDialog.trySubmit()
                }

                Label {
                    Layout.fillWidth: true
                    visible: servicePasswordDialog.passwordError.length > 0
                    text: servicePasswordDialog.passwordError
                    color: "#dc2626"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 22
                }

                Item { Layout.fillHeight: true }
            }
        }

        function trySubmit() {
            if (settingsMenuRoot.isServiceMenuPasswordValid(servicePasswordInput.text)) {
                servicePasswordInput.text = ""
                servicePasswordDialog.passwordError = ""
                servicePasswordDialog.close()
                settingsMenuRoot.serviceMenuButtonPressed()
                return
            }
            servicePasswordDialog.passwordError = qsTr("Неверный пароль")
        }

        onOpened: {
            servicePasswordInput.text = ""
            servicePasswordDialog.passwordError = ""
            Qt.callLater(function() {
                servicePasswordInput.forceActiveFocus()
            })
        }

        onClosed: {
            servicePasswordInput.focus = false
            Qt.inputMethod.hide()
        }

        footer: Rectangle {
            color: "transparent"
            implicitHeight: 108

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                DialogActionButton {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    text: qsTr("ОТМЕНА")
                    onPressed: servicePasswordDialog.close()
                }

                Item { Layout.fillWidth: true }

                DialogActionButton {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    text: qsTr("ВОЙТИ")
                    primary: true
                    onPressed: servicePasswordDialog.trySubmit()
                }
            }
        }
    }

    Dialog {
        id: endoscopyPasswordDialog
        property string passwordError: ""
        modal: true
        width: Math.min(settingsMenuRoot.width * 0.92, 820)
        height: 380
        x: (settingsMenuRoot.width - width) / 2
        y: (settingsMenuRoot.height - height) / 2
        title: ""

        contentItem: Rectangle {
            color: "white"
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Для разблокировки эндоскопических функций введите пароль")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 28
                    font.bold: true
                }

                TextField {
                    id: endoscopyPasswordInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    placeholderText: qsTr("Пароль")
                    echoMode: TextInput.Password
                    selectByMouse: true
                    font.pixelSize: 24
                    color: "black"
                    background: Rectangle {
                        color: "#f5f5f5"
                        border.color: endoscopyPasswordInput.activeFocus ? "#4a9eff" : "#7a7a7a"
                        border.width: 2
                        radius: 6
                    }
                    onAccepted: endoscopyPasswordDialog.trySubmit()
                }

                Label {
                    Layout.fillWidth: true
                    visible: endoscopyPasswordDialog.passwordError.length > 0
                    text: endoscopyPasswordDialog.passwordError
                    color: "#dc2626"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 22
                }

                Item { Layout.fillHeight: true }
            }
        }

        function trySubmit() {
            if (settingsMenuRoot.isServiceMenuPasswordValid(endoscopyPasswordInput.text)) {
                endoscopyPasswordInput.text = ""
                endoscopyPasswordDialog.passwordError = ""
                settingsMenuRoot.saveEndoscopyEnabled(true)
                endoscopyPasswordDialog.close()
                return
            }
            endoscopyPasswordDialog.passwordError = qsTr("Неверный пароль")
        }

        onOpened: {
            endoscopyPasswordInput.text = ""
            endoscopyPasswordDialog.passwordError = ""
            Qt.callLater(function() {
                endoscopyPasswordInput.forceActiveFocus()
            })
        }

        onClosed: {
            endoscopyPasswordInput.focus = false
            Qt.inputMethod.hide()
        }

        footer: Rectangle {
            color: "transparent"
            implicitHeight: 108

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                DialogActionButton {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    text: qsTr("ОТМЕНА")
                    onPressed: endoscopyPasswordDialog.close()
                }

                Item { Layout.fillWidth: true }

                DialogActionButton {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true
                    text: qsTr("РАЗБЛОКИРОВАТЬ")
                    primary: true
                    onPressed: endoscopyPasswordDialog.trySubmit()
                }
            }
        }
    }

    Dialog {
        id: argonPasswordDialog
        property string passwordError: ""
        modal: true
        width: Math.min(settingsMenuRoot.width * 0.92, 820)
        height: 380
        x: (settingsMenuRoot.width - width) / 2
        y: (settingsMenuRoot.height - height) / 2
        title: ""

        contentItem: Rectangle {
            color: "white"
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Для разблокировки аргонусиленной коагуляции введите пароль")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 28
                    font.bold: true
                }

                TextField {
                    id: argonPasswordInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    placeholderText: qsTr("Пароль")
                    echoMode: TextInput.Password
                    selectByMouse: true
                    font.pixelSize: 24
                    color: "black"
                    background: Rectangle {
                        color: "#f5f5f5"
                        border.color: argonPasswordInput.activeFocus ? "#4a9eff" : "#7a7a7a"
                        border.width: 2
                        radius: 6
                    }
                    onAccepted: argonPasswordDialog.trySubmit()
                }

                Label {
                    Layout.fillWidth: true
                    visible: argonPasswordDialog.passwordError.length > 0
                    text: argonPasswordDialog.passwordError
                    color: "#dc2626"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 22
                }

                Item { Layout.fillHeight: true }
            }
        }

        function trySubmit() {
            if (settingsMenuRoot.isServiceMenuPasswordValid(argonPasswordInput.text)) {
                argonPasswordInput.text = ""
                argonPasswordDialog.passwordError = ""
                settingsMenuRoot.saveArgonModesEnabled(true)
                argonPasswordDialog.close()
                return
            }
            argonPasswordDialog.passwordError = qsTr("Неверный пароль")
        }

        onOpened: {
            argonPasswordInput.text = ""
            argonPasswordDialog.passwordError = ""
            Qt.callLater(function() {
                argonPasswordInput.forceActiveFocus()
            })
        }

        onClosed: {
            argonPasswordInput.focus = false
            Qt.inputMethod.hide()
        }

        footer: Rectangle {
            color: "transparent"
            implicitHeight: 108

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                DialogActionButton {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    text: qsTr("ОТМЕНА")
                    onPressed: argonPasswordDialog.close()
                }

                Item { Layout.fillWidth: true }

                DialogActionButton {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true
                    text: qsTr("РАЗБЛОКИРОВАТЬ")
                    primary: true
                    onPressed: argonPasswordDialog.trySubmit()
                }
            }
        }
    }
}
