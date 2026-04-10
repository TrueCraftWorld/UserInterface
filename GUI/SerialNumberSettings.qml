import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StratifyLabs.UI 2.0

Item {
    id: serialRoot
    signal returnButtonPressed()

    property string serialNumber: ""
    property string deviceType: ""
    property string featureNotes: ""
    readonly property int minSerialNumber: 260000
    readonly property int maxSerialNumber: 1000000
    property bool serialValid: false
    property string serialSaveStatus: ""
    function saveSettings() {
        if (!serialRoot.serialValid) {
            serialRoot.serialSaveStatus = qsTr("Введите серийный номер в диапазоне 260000-1000000")
            return
        }

        if (typeof savedJson !== "undefined" && savedJson) {
            savedJson.saveString("serialNumber", serialRoot.serialNumber)
            savedJson.saveString("deviceType", serialRoot.deviceType)
            savedJson.saveString("featureNotes", serialRoot.featureNotes)
        }

        if (typeof remoteUpdater !== "undefined" && remoteUpdater) {
            remoteUpdater.serialNumber = serialRoot.serialNumber
        }

        serialRoot.serialSaveStatus = qsTr("Сохранено")
    }

    Component.onCompleted: {
        if (typeof savedJson !== "undefined" && savedJson) {
            serialRoot.serialNumber = savedJson.readString("serialNumber", "")
            serialRoot.deviceType = savedJson.readString("deviceType", "")
            serialRoot.featureNotes = savedJson.readString("featureNotes", "")
        }
        serialRoot.serialValid = isSerialValid(serialRoot.serialNumber)
        serialRoot.serialSaveStatus = serialRoot.serialValid
                                   ? qsTr("Сохранено")
                                   : qsTr("Введите серийный номер в диапазоне 260000-1000000")
    }

    Component.onDestruction: {
        Qt.inputMethod.hide()
    }

    function isSerialValid(value) {
        if (!/^\d+$/.test(value)) {
            return false
        }
        var numeric = parseInt(value, 10)
        return numeric >= minSerialNumber && numeric <= maxSerialNumber
    }

    Rectangle {
        anchors.fill: parent
        color: "darkslategray"
    }

    SLabel {
        id: screenTitle
        style: "label-primary lg"
        text: qsTr("Параметры аппарата")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    ColumnLayout {
        anchors {
            top: screenTitle.bottom
            topMargin: 30
            left: parent.left
            right: parent.right
            margins: 40
        }
        spacing: 18

        SPanel {
            style: "panel-primary"
            heading: qsTr("Серийный номер")
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width - 30
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                TextField {
                    id: serialInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("Введите серийный номер")
                    text: serialRoot.serialNumber
                    validator: IntValidator {
                        bottom: serialRoot.minSerialNumber
                        top: serialRoot.maxSerialNumber
                    }
                    inputMethodHints: Qt.ImhDigitsOnly
                    onTextChanged: {
                        serialRoot.serialNumber = text
                        serialRoot.serialValid = serialRoot.isSerialValid(text)
                        if (serialRoot.serialValid) {
                            serialRoot.serialSaveStatus = qsTr("Не сохранено")
                        } else {
                            serialRoot.serialSaveStatus = qsTr("Введите серийный номер в диапазоне 260000-1000000")
                        }
                    }
                    color: "white"
                    background: Rectangle {
                        color: "#1a2a3a"
                        border.color: serialRoot.serialValid
                                      ? "#4ade80"
                                      : (serialInput.activeFocus ? "#f87171" : "#3a4a5a")
                        border.width: 2
                        radius: 5
                    }
                }

                SLabel {
                    Layout.fillWidth: true
                    style: "label-secondary sm"
                    text: serialRoot.serialSaveStatus
                    color: serialRoot.serialValid ? "#4ade80" : "#fbbf24"
                    wrapMode: Text.WordWrap
                }
            }
        }

        SPanel {
            style: "panel-primary"
            heading: qsTr("Тип аппарата (будущее поле)")
            Layout.fillWidth: true

            TextField {
                id: typeInput
                width: parent.width - 30
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Например: RK3566 Rev.A")
                text: serialRoot.deviceType
                onTextChanged: {
                    serialRoot.deviceType = text
                    if (serialRoot.serialValid) {
                        serialRoot.serialSaveStatus = qsTr("Не сохранено")
                    }
                }
                color: "white"
                background: Rectangle {
                    color: "#1a2a3a"
                    border.color: typeInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                    border.width: 2
                    radius: 5
                }
            }
        }

        SPanel {
            style: "panel-primary"
            heading: qsTr("Особенности (будущее поле)")
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: featuresInput
                width: parent.width - 30
                height: 180
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Комментарий: комплектация, ревизия, кастомные параметры")
                text: serialRoot.featureNotes
                wrapMode: Text.Wrap
                onTextChanged: {
                    serialRoot.featureNotes = text
                    if (serialRoot.serialValid) {
                        serialRoot.serialSaveStatus = qsTr("Не сохранено")
                    }
                }
                color: "white"
                background: Rectangle {
                    color: "#1a2a3a"
                    border.color: featuresInput.activeFocus ? "#4a9eff" : "#3a4a5a"
                    border.width: 2
                    radius: 5
                }
            }
        }

    }

    SButton {
        id: saveButton
        style: "btn-primary"
        text: qsTr("Сохранить")
        enabled: serialRoot.serialValid
        onPressed: {
            serialRoot.saveSettings()
        }
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 15
        }
    }

    SButton {
        id: retButton
        style: "btn-secondary"
        text: qsTr("Назад")
        onPressed: {
            serialInput.focus = false
            typeInput.focus = false
            featuresInput.focus = false
            Qt.inputMethod.hide()
            returnButtonPressed()
        }
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
    }
}
