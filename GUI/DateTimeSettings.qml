import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StratifyLabs.UI 2.0

Item {
    id: dateTimeRoot

    signal returnButtonPressed()

    property string saveStatus: ""
    property bool fieldsReady: false
    property color fotekBlue: "#264093"
    property color fotekOrange: "#faa731"
    readonly property int screenMargin: 34
    readonly property int cardRadius: 24
    readonly property int fieldHeight: 92
    readonly property int fieldFontSize: 40
    readonly property bool inputValid: fieldsReady && isInputValid()

    function pad2(value) {
        return value < 10 ? "0" + value : "" + value
    }

    function fieldNumber(field) {
        return parseInt(field.text, 10)
    }

    function isInputValid() {
        var year = fieldNumber(yearInput)
        var month = fieldNumber(monthInput)
        var day = fieldNumber(dayInput)
        var hour = fieldNumber(hourInput)
        var minute = fieldNumber(minuteInput)
        var second = fieldNumber(secondInput)

        if (isNaN(year) || isNaN(month) || isNaN(day)
                || isNaN(hour) || isNaN(minute) || isNaN(second)) {
            return false
        }

        var candidate = new Date(year, month - 1, day, hour, minute, second)
        return candidate.getFullYear() === year
                && candidate.getMonth() === month - 1
                && candidate.getDate() === day
                && candidate.getHours() === hour
                && candidate.getMinutes() === minute
                && candidate.getSeconds() === second
    }

    function markUnsaved() {
        if (dateTimeRoot.inputValid) {
            dateTimeRoot.saveStatus = qsTr("Не сохранено")
        } else {
            dateTimeRoot.saveStatus = qsTr("Проверьте дату и время")
        }
    }

    function setFieldsFromCurrentTime() {
        var now = new Date()
        yearInput.text = now.getFullYear()
        monthInput.text = pad2(now.getMonth() + 1)
        dayInput.text = pad2(now.getDate())
        hourInput.text = pad2(now.getHours())
        minuteInput.text = pad2(now.getMinutes())
        secondInput.text = pad2(now.getSeconds())
        dateTimeRoot.saveStatus = qsTr("Текущее время загружено")
    }

    function saveDateTime() {
        if (!dateTimeRoot.inputValid) {
            dateTimeRoot.saveStatus = qsTr("Проверьте дату и время")
            return
        }

        if (typeof dateTimeController === "undefined" || !dateTimeController) {
            dateTimeRoot.saveStatus = qsTr("Контроллер даты и времени недоступен")
            return
        }

        var ok = dateTimeController.setDateTime(fieldNumber(yearInput),
                                                fieldNumber(monthInput),
                                                fieldNumber(dayInput),
                                                fieldNumber(hourInput),
                                                fieldNumber(minuteInput),
                                                fieldNumber(secondInput))
        dateTimeRoot.saveStatus = ok
                ? qsTr("Дата и время сохранены")
                : dateTimeController.lastError
    }

    function openValuePopup(title, minValue, maxValue, targetField, padValue) {
        valuePopup.titleText = title
        valuePopup.minValue = minValue
        valuePopup.maxValue = maxValue
        valuePopup.targetField = targetField
        valuePopup.padValue = padValue
        valuePopup.open()
    }

    Component.onCompleted: {
        if (typeof dateTimeController !== "undefined" && dateTimeController) {
            dateTimeController.refresh()
        }
        setFieldsFromCurrentTime()
        dateTimeRoot.fieldsReady = true
    }

    Component.onDestruction: {
        Qt.inputMethod.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#F3F5F9"
    }

    Text {
        id: screenTitle
        text: qsTr("НАСТРОЙКА ДАТЫ И ВРЕМЕНИ")
        color: dateTimeRoot.fotekBlue
        font.pixelSize: 46
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: parent.top
            topMargin: dateTimeRoot.screenMargin - 8
            left: parent.left
            right: parent.right
            leftMargin: dateTimeRoot.screenMargin
            rightMargin: dateTimeRoot.screenMargin
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: typeof dateTimeController !== "undefined" && dateTimeController
        onTriggered: dateTimeController.refresh()
    }

    Popup {
        id: valuePopup

        property string titleText: ""
        property int minValue: 0
        property int maxValue: 0
        property bool padValue: false
        property var targetField: null
        readonly property int valuesCount: maxValue - minValue + 1
        readonly property int gridColumns: valuesCount > 32 ? 10 : 7

        width: Math.min(dateTimeRoot.width - dateTimeRoot.screenMargin * 2, 900)
        height: Math.min(dateTimeRoot.height - dateTimeRoot.screenMargin * 2, 620)
        x: (dateTimeRoot.width - width) / 2
        y: (dateTimeRoot.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 24

        function formatted(value) {
            return valuePopup.padValue && value < 10 ? "0" + value : "" + value
        }

        function selectValue(value) {
            if (valuePopup.targetField) {
                valuePopup.targetField.text = valuePopup.formatted(value)
                dateTimeRoot.markUnsaved()
            }
            valuePopup.close()
        }

        background: Rectangle {
            radius: dateTimeRoot.cardRadius
            color: "white"
            border.width: 2
            border.color: dateTimeRoot.fotekBlue
        }

        contentItem: ColumnLayout {
            spacing: 18

            Text {
                Layout.fillWidth: true
                text: valuePopup.titleText
                color: dateTimeRoot.fotekBlue
                font.pixelSize: 38
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: valuePopup.gridColumns
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: valuePopup.valuesCount

                    DialogActionButton {
                        property int numericValue: valuePopup.minValue + index

                        Layout.preferredWidth: valuePopup.valuesCount > 32 ? 76 : 104
                        Layout.preferredHeight: 70
                        text: valuePopup.formatted(numericValue)
                        secondaryColor: valuePopup.targetField && valuePopup.targetField.text === text
                                        ? dateTimeRoot.fotekOrange
                                        : "#F8FAFC"
                        secondaryBorderWidth: 1
                        secondaryBorderColor: dateTimeRoot.fotekBlue
                        labelColor: dateTimeRoot.fotekBlue
                        labelPixelSize: valuePopup.valuesCount > 32 ? 25 : 30
                        cornerRadius: 16
                        onPressed: valuePopup.selectValue(numericValue)
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    ColumnLayout {
        anchors {
            top: screenTitle.bottom
            topMargin: 26
            left: parent.left
            right: parent.right
            bottom: footerArea.top
            bottomMargin: 20
            leftMargin: dateTimeRoot.screenMargin
            rightMargin: dateTimeRoot.screenMargin
        }
        spacing: 22

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            radius: dateTimeRoot.cardRadius
            color: "white"
            border.width: 1
            border.color: "#D8DEE9"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: qsTr("ТЕКУЩЕЕ СИСТЕМНОЕ ВРЕМЯ")
                    color: "#6B7280"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: (typeof dateTimeController !== "undefined" && dateTimeController)
                          ? dateTimeController.currentDateTime
                          : qsTr("Недоступно")
                    color: dateTimeRoot.fotekBlue
                    font.pixelSize: 54
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: dateTimeRoot.cardRadius
            color: "white"
            border.width: 1
            border.color: "#D8DEE9"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 18
                    rowSpacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("ГОД")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("МЕСЯЦ")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("ДЕНЬ")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        id: yearInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("ГОД"), 2026, 2046, yearInput, false)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: yearInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: yearInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: monthInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("МЕСЯЦ"), 1, 12, monthInput, true)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: monthInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: monthInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: dayInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("ДЕНЬ"), 1, 31, dayInput, true)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: dayInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: dayInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 18
                    rowSpacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("ЧАСЫ")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("МИНУТЫ")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("СЕКУНДЫ")
                        color: "#6B7280"
                        font.pixelSize: 26
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        id: hourInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("ЧАСЫ"), 0, 23, hourInput, true)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: hourInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: hourInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: minuteInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("МИНУТЫ"), 0, 59, minuteInput, true)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: minuteInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: minuteInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: secondInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: dateTimeRoot.fieldHeight
                        onPressed: dateTimeRoot.openValuePopup(qsTr("СЕКУНДЫ"), 0, 59, secondInput, true)
                        background: Rectangle {
                            color: "#F8FAFC"
                            border.color: secondInput.down ? dateTimeRoot.fotekOrange : "#C7D0DD"
                            border.width: 2
                            radius: 18
                        }
                        contentItem: Text {
                            text: secondInput.text
                            color: dateTimeRoot.fotekBlue
                            font.pixelSize: dateTimeRoot.fieldFontSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: dateTimeRoot.saveStatus
                    color: dateTimeRoot.inputValid ? "#2E7D32" : "#B45309"
                    font.pixelSize: 28
                    font.bold: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Item {
        id: footerArea
        height: 72
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: dateTimeRoot.screenMargin
            rightMargin: dateTimeRoot.screenMargin
            bottomMargin: dateTimeRoot.screenMargin
        }

        DialogActionButton {
            id: retButton
            width: 180
            height: parent.height
            text: qsTr("НАЗАД")
            secondaryColor: dateTimeRoot.fotekBlue
            secondaryBorderWidth: 1
            secondaryBorderColor: "#1E3274"
            cornerRadius: 20
            labelPixelSize: 30
            onPressed: {
                yearInput.focus = false
                monthInput.focus = false
                dayInput.focus = false
                hourInput.focus = false
                minuteInput.focus = false
                secondInput.focus = false
                Qt.inputMethod.hide()
                dateTimeRoot.returnButtonPressed()
            }
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }

        DialogActionButton {
            id: loadCurrentButton
            width: 260
            height: parent.height
            text: qsTr("ТЕКУЩЕЕ")
            secondaryColor: "white"
            secondaryBorderWidth: 1
            secondaryBorderColor: dateTimeRoot.fotekBlue
            cornerRadius: 20
            labelPixelSize: 30
            labelColor: dateTimeRoot.fotekBlue
            onPressed: setFieldsFromCurrentTime()
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
        }

        DialogActionButton {
            id: saveButton
            width: 220
            height: parent.height
            text: qsTr("СОХРАНИТЬ")
            primary: true
            enabled: dateTimeRoot.inputValid
            primaryEnabledColor: dateTimeRoot.fotekOrange
            primaryDisabledColor: "#FAD39A"
            cornerRadius: 20
            labelPixelSize: 30
            onPressed: dateTimeRoot.saveDateTime()
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
