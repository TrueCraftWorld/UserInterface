import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Item {
    id: specialCommandsRoot

    signal returnButtonPressed()
    signal deleteAllUserProgsRequested()

    property bool endoscopyEnabled: false
    property bool argonModesEnabled: false

    readonly property int menuButtonWidth: 550
    readonly property int menuButtonHeight: 112
    readonly property int menuColumnsSpacing: 24

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
        text: qsTr("СПЕЦ КОМАНДЫ")
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
        columnSpacing: specialCommandsRoot.menuColumnsSpacing
        rowSpacing: 20
        width: specialCommandsRoot.menuButtonWidth * 2 + specialCommandsRoot.menuColumnsSpacing

        SButton {
            id: endoscopyButton
            style: specialCommandsRoot.endoscopyEnabled ? "btn-primary lg" : "btn-danger lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: specialCommandsRoot.endoscopyEnabled
                  ? qsTr("Эндоскопия: ВКЛ") : qsTr("Эндоскопия: ВЫКЛ")
            onPressed: specialCommandsRoot.saveEndoscopyEnabled(!specialCommandsRoot.endoscopyEnabled)
        }

        SButton {
            id: argonModesButton
            style: specialCommandsRoot.argonModesEnabled ? "btn-primary lg" : "btn-danger lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: specialCommandsRoot.argonModesEnabled
                  ? qsTr("Режимы с аргоном: ВКЛ") : qsTr("Режимы с аргоном: ВЫКЛ")
            onPressed: specialCommandsRoot.saveArgonModesEnabled(!specialCommandsRoot.argonModesEnabled)
        }

        SButton {
            id: debugButton
            style: (typeof appControl !== "undefined" && appControl && appControl.debugUartEnabled)
                   ? "btn-danger lg" : "btn-primary lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: (typeof appControl !== "undefined" && appControl && appControl.debugUartEnabled)
                  ? qsTr("UART: ВКЛ") : qsTr("Вывод UART")
            onPressed: {
                if (typeof appControl === "undefined" || !appControl)
                    return
                appControl.debugUartEnabled = !appControl.debugUartEnabled
            }
        }

        SButton {
            id: monitorButton
            style: (typeof appControl !== "undefined" && appControl && appControl.cpuMonitorVisible)
                   ? "btn-danger lg" : "btn-primary lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: (typeof appControl !== "undefined" && appControl && appControl.cpuMonitorVisible)
                  ? qsTr("ЦП: ВКЛ") : qsTr("Вывод загрузки ЦП")
            onPressed: {
                if (typeof appControl === "undefined" || !appControl)
                    return
                appControl.cpuMonitorVisible = !appControl.cpuMonitorVisible
            }
        }

        SButton {
            id: poweroffButton
            style: "btn-danger lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: qsTr("Выкл")
            onPressed: {
                if (typeof appControl === "undefined" || !appControl)
                    return
                appControl.shutdownSystemFromUi()
            }
        }

        SButton {
            id: exitButton
            style: "btn-danger lg"
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth
            Layout.preferredHeight: specialCommandsRoot.menuButtonHeight
            text: qsTr("Выход в Linux")
            onPressed: {
                if (typeof remoteUpdater === "undefined" || !remoteUpdater)
                    return
                remoteUpdater.stopDemo1UserServiceAndQuit()
            }
        }

        SButton {
            id: deleteAllUserProgsButton
            style: "btn-danger lg"
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            Layout.preferredWidth: specialCommandsRoot.menuButtonWidth * 2 + specialCommandsRoot.menuColumnsSpacing
            Layout.preferredHeight: 106
            text: qsTr("Удалить все пользовательские программы")
            onPressed: confirmDeleteDialog.open()
        }
    }

    SButton {
        id: returnButton
        style: "btn-secondary"
        text: qsTr("Назад")
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15
        }
        onPressed: specialCommandsRoot.returnButtonPressed()
    }

    Dialog {
        id: confirmDeleteDialog
        title: qsTr("Подтверждение удаления")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent

        Label {
            text: qsTr("Удалить все пользовательские программы?\nЭто действие необратимо.")
            font.pixelSize: 20
        }

        onAccepted: specialCommandsRoot.deleteAllUserProgsRequested()
    }
}
