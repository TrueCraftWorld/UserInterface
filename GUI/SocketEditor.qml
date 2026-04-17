import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Popup {
    id: root
    modal: true
    parent: Overlay.overlay
    width: parent.width
    height: parent.height
    x: 0
    y: 0

    property int socId: -1
    property int modeIndex: -1
    property bool isCoag: false
    readonly property var modeEditor: Editor

    property int initiallySelectedMode: -1
    property int initiallySelectedInstr: -1
    property var modeNums: []
    property var instrNums: []
    property string centerView: "power" // power, modePreview, instrPreview
    property int committedModeIndex: -1
    property int committedInstrIndex: -1
    property bool internalIndexChange: false
    property bool openingInProgress: false
    property int pendingAutoMode: -1
    property string autoModeConfirmText: ""
    property var autoModeBaseline: [0, 0, 0, 0]
    property int autoDelayBaseline: 0
    property int socketAutoModeState: 0
    readonly property int controlButtonHeight: 72
    readonly property int recommendedButtonHeight: 90
    readonly property int recommendedEndoButtonHeight: 70
    readonly property color powerStepButtonBg: isCoag ? "#1565C0" : "#F9D648"
    readonly property color powerStepButtonText: isCoag ? "white" : "#111111"
    readonly property int powerStepButtonWidth: 96
    readonly property color uiMidGray: "#BBBBBB"
    readonly property color autoBtnOnFill: "#1565C0"
    readonly property color autoBtnOnBorder: "#E3F2FD"
    readonly property color autoBtnOffBorder: "#99FFFFFF"
    readonly property color autoBtnOffText: "#B0BEC5"

    function modeImagePrefix() {
        return socId <= 1 ? "bimode" : "monomode"
    }

    function updateModeModel() {
        modeModel.clear()
        modeNums = modeEditor.modeNamesNums()
        var modeNames = modeEditor.modeNames
        for (var i = 0; i < modeNames.length; ++i) {
            modeModel.append({
                                 itemId: i < modeNums.length ? modeNums[i] : "0",
                                 itemName: modeNames[i]
                             })
        }
        modeListView.innerModel = modeModel
    }

    function updateInstrModel() {
        instrModel.clear()
        instrNums = modeEditor.instrListNums()
        var instrNames = modeEditor.instrList
        for (var i = 0; i < instrNames.length; ++i) {
            instrModel.append({
                                  itemId: i < instrNums.length ? instrNums[i] : "0",
                                  itemName: instrNames[i]
                              })
        }
        instrListView.innerModel = instrModel
    }

    function nextPowerUp(power, maxPower) {
        var value = power
        if (value < 20) value += 1
        else if (value < 50) value += 2
        else if (value < 100) value += 5
        else if (value < 200) value += 10
        else if (value < 400) value += 25
        return Math.min(value, maxPower)
    }

    function nextPowerDown(power) {
        var value = power
        if (value <= 1) value = 1
        else if (value <= 20) value -= 1
        else if (value <= 50) value -= 2
        else if (value <= 100) value -= 5
        else if (value <= 200) value -= 10
        else if (value <= 400) value -= 25
        return Math.max(value, 1)
    }

    property bool powerRepeatIncrease: false

    function stepMainPower(increase) {
        if (!modeSelected() || modeEditor.isEndo || modeEditor.currentMode.maxpower <= 0) {
            return
        }
        if (increase) {
            modeEditor.updateParameter("currentpower",
                                       nextPowerUp(modeEditor.currentPower, modeEditor.currentMode.maxpower))
        } else {
            modeEditor.updateParameter("currentpower", nextPowerDown(modeEditor.currentPower))
        }
    }

    function startMainPowerRepeat(increase) {
        powerRepeatIncrease = increase
        stepMainPower(increase)
        powerRepeatDelay.restart()
    }

    function stopMainPowerRepeat() {
        powerRepeatDelay.stop()
        powerRepeatTick.stop()
    }

    Timer {
        id: powerRepeatDelay
        interval: 1500
        repeat: false
        onTriggered: powerRepeatTick.start()
    }

    Timer {
        id: powerRepeatTick
        interval: 120
        repeat: true
        onTriggered: stepMainPower(powerRepeatIncrease)
    }

    function modeTitleText() {
        var currentMode = modeEditor.currentMode
        if (!currentMode || currentMode.name === undefined || currentMode.name === null) {
            return ""
        }
        return currentMode.name
    }

    function currentInstrName() {
        if (modeEditor.currentInstrIndex < 0 || modeEditor.currentInstrIndex >= modeEditor.instrList.length) {
            return ""
        }
        return modeEditor.instrList[modeEditor.currentInstrIndex]
    }

    function instrumentSelected() {
        if (modeEditor.currentInstrIndex < 0 || modeEditor.currentInstrIndex >= instrNums.length) {
            return false
        }
        return parseInt(instrNums[modeEditor.currentInstrIndex]) !== 1000
    }

    function socketAutoMode() {
        return socketAutoModeState
    }

    function setSocketAutoMode(mode) {
        socketAutoModeState = mode
        periphHandle.setAutoMode(socId, mode)
    }

    function requestAutoMode(mode, confirmationText) {
        var currentMode = socketAutoMode()
        if (currentMode === mode) {
            setSocketAutoMode(0)
            return
        }
        pendingAutoMode = mode
        autoModeConfirmText = confirmationText
        autoModeConfirmPopup.open()
    }

    function isSoftMode() {
        return currentModeId() === 21
    }

    function isBiCoagMode() {
        return currentModeId() === 5
    }

    function captureAutoModeBaseline() {
        autoModeBaseline = [periphHandle.autoMode(0), periphHandle.autoMode(1),
                            periphHandle.autoMode(2), periphHandle.autoMode(3)]
        autoDelayBaseline = periphHandle.autoDelayMs
    }

    function syncAutoModeDirtyFromAuto() {
        var diff = false
        for (var i = 0; i < 4; i++) {
            if (periphHandle.autoMode(i) !== autoModeBaseline[i]) {
                diff = true
                break
            }
        }
        if (!diff && periphHandle.autoDelayMs !== autoDelayBaseline) {
            diff = true
        }
        modeEditor.setAutoModeDirty(diff)
    }

    function restoreAutoModesFromBaseline() {
        for (var i = 0; i < 4; i++) {
            periphHandle.setAutoMode(i, autoModeBaseline[i])
        }
        periphHandle.setAutoDelayMs(autoDelayBaseline)
        socketAutoModeState = periphHandle.autoMode(socId)
    }

    function cancelEditorAndClose() {
        restoreAutoModesFromBaseline()
        modeEditor.setAutoModeDirty(false)
        modeEditor.rollBack()
        root.close()
    }

    function currentModeId() {
        var currentMode = modeEditor.currentMode
        if (!currentMode || currentMode.id === undefined || currentMode.id === null) {
            return -1
        }
        return parseInt(currentMode.id)
    }

    function modeSelected() {
        if (modeEditor.currentModeIndex < 0) {
            return false
        }
        if (modeEditor.modeNames.length > 0 && modeEditor.currentModeIndex === modeEditor.modeNames.length - 1) {
            return false
        }
        var currentMode = modeEditor.currentMode
        if (currentMode && currentMode.id !== undefined && currentMode.id !== null) {
            return currentMode.id !== 1000
        }
        return true
    }

    function endoCutEffect() {
        return Math.floor(modeEditor.currentPower / 10)
    }

    function endoCoagEffect() {
        return modeEditor.currentPower % 10
    }

    function setEndoPower(cutEffect, coagEffect) {
        var cut = Math.max(1, Math.min(3, cutEffect))
        var coag = Math.max(1, Math.min(3, coagEffect))
        modeEditor.updateParameter("currentpower", cut * 10 + coag)
    }

    function normalizeEndoCurrentPower() {
        if (!modeEditor.isEndo) {
            return
        }
        var cut = endoCutEffect()
        var coag = endoCoagEffect()
        var cutClamped = Math.max(1, Math.min(3, cut))
        var coagClamped = Math.max(1, Math.min(3, coag))
        var packed = cutClamped * 10 + coagClamped
        if (packed !== modeEditor.currentPower) {
            modeEditor.updateParameter("currentpower", packed)
        }
    }

    function restoreCommittedSelection() {
        internalIndexChange = true
        modeEditor.currentModeIndex = committedModeIndex
        modeEditor.currentInstrIndex = committedInstrIndex
        modeListView.curIndex = committedModeIndex
        instrListView.curIndex = committedInstrIndex
        internalIndexChange = false
        centerView = "power"
    }

    function applyPreviewSelection() {
        committedModeIndex = modeEditor.currentModeIndex
        committedInstrIndex = modeEditor.currentInstrIndex
        centerView = "power"
    }

    onOpened: {
        openingInProgress = true
        internalIndexChange = true
        modeEditor.initialize(socId, modeIndex, isCoag)
        updateModeModel()
        updateInstrModel()
        initiallySelectedMode = modeEditor.currentModeIndex
        initiallySelectedInstr = modeEditor.currentInstrIndex
        committedModeIndex = modeEditor.currentModeIndex
        committedInstrIndex = modeEditor.currentInstrIndex
        centerView = "power"
        socketAutoModeState = periphHandle.autoMode(socId)
        captureAutoModeBaseline()
        modeEditor.setAutoModeDirty(false)
        modeListView.curIndex = modeEditor.currentModeIndex
        instrListView.curIndex = modeEditor.currentInstrIndex
        normalizeEndoCurrentPower()
        Qt.callLater(function() {
            internalIndexChange = false
            openingInProgress = false
        })
    }

    ListModel { id: modeModel }
    ListModel { id: instrModel }

    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"

        GradientBack {
            anchors.fill: parent
            startColor: isCoag ? "#000066" : "#443300"
            stopColor: isCoag ? "#0000aa" : "#665500"
            beamColor: isCoag ? "#5078FF" : "#B4963C"
        }

        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 78
            color: isCoag ? "#0B4FB3" : "#F4D13D"

            Label {
                id: titleLabel
                text: isCoag
                      ? qsTr("Настройка КОАГУЛЯЦИИ для выхода %1").arg(modeEditor.socketName)
                      : qsTr("Настройка РЕЗАНИЯ для выхода %1").arg(modeEditor.socketName)
                anchors.centerIn: parent
                width: parent.width * 0.85
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 28
                font.bold: true
                color: isCoag ? "white" : "black"
            }

            Button {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 120
                background: Rectangle { color: "transparent" }
                onPressed: cancelEditorAndClose()
                contentItem: Text {
                    text: qsTr("X")
                    font.pixelSize: 34
                    font.bold: true
                    color: isCoag ? "white" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        RowLayout {
            anchors.top: header.bottom
            anchors.bottom: centerView === "power" ? footer.top : parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 9

            Rectangle {
                id: modeRect
                Layout.fillHeight: true
                Layout.preferredWidth: 320
                color: "transparent"

                Label {
                    text: previewRect.visible ? qsTr("Выберите режим") : qsTr("Режим")
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                    font.bold: true
                    color: previewRect.visible ? "white" : uiMidGray
                }

                ItemList {
                    id: modeListView
                    anchors.top: parent.top
                    anchors.topMargin: 28
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: modeButtons.top
                    curIndex: modeEditor.currentModeIndex
                    initialIndex: initiallySelectedMode
                    imageSourceTemplate: "image://modes/" + modeImagePrefix() + "%1"
                }

                RowLayout {
                    id: modeButtons
                    height: 56
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: 10

                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("▼")
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 10
                            color: "#22000000"
                            border.color: "#66ffffff"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#BDBDBD"
                            font.pixelSize: 24
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onPressed: modeListView.scrollDown()
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("▲")
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 10
                            color: "#22000000"
                            border.color: "#66ffffff"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#BDBDBD"
                            font.pixelSize: 24
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onPressed: modeListView.scrollUp()
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: "#55FFFFFF"
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 320
                color: "transparent"

                Label {
                    text: previewRect.visible ? qsTr("Выберите инструмент") : qsTr("Инструмент")
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                    font.bold: true
                    color: previewRect.visible ? "white" : uiMidGray
                }

                ItemList {
                    id: instrListView
                    anchors.top: parent.top
                    anchors.topMargin: 28
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: instrButtons.top
                    curIndex: modeEditor.currentInstrIndex
                    initialIndex: initiallySelectedInstr
                    noImage: true
                    hideNoImageSymbol: true
                    // imageSourceTemplate: "image://instruments/minstr%1"
                }

                RowLayout {
                    id: instrButtons
                    height: 56
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: 10

                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("▼")
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 10
                            color: "#22000000"
                            border.color: "#66ffffff"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#BDBDBD"
                            font.pixelSize: 24
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onPressed: instrListView.scrollDown()
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("▲")
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 10
                            color: "#22000000"
                            border.color: "#66ffffff"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#BDBDBD"
                            font.pixelSize: 24
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onPressed: instrListView.scrollUp()
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: "#55FFFFFF"
            }

            Rectangle {
                id: centerPanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: centerView === "power" ? "transparent" : "white"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: modeEditor.isEndo ? 11 : 14
                    opacity: centerView === "power" ? 1.0 : 0.2

                    Label {
                        Layout.fillWidth: true
                        text: modeTitleText()
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 28
                        font.bold: true
                        color: "white"
                    }

                    Item {
                        height: 50
                        visible: !modeEditor.isEndo && !isBiCoagMode()
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Установите мощность")
                        horizontalAlignment: Text.AlignHCenter
                        visible: modeSelected() && !modeEditor.isEndo
                        color: uiMidGray
                        font.pixelSize: 20
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: controlButtonHeight
                        spacing: 16
                        visible: modeSelected() && !modeEditor.isEndo
                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("−")
                            enabled: modeEditor.currentMode.maxpower > 0
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: enabled ? powerStepButtonBg : "#555555"
                                border.width: 1
                                border.color: enabled ? "#00000030" : "transparent"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: enabled ? powerStepButtonText : "#AAAAAA"
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: startMainPowerRepeat(false)
                            onReleased: stopMainPowerRepeat()
                            onCanceled: stopMainPowerRepeat()
                        }
                        Label {
                            Layout.preferredWidth: 140
                            text: modeEditor.currentPower
                            font.pixelSize: 52
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                        }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("+")
                            enabled: modeEditor.currentMode.maxpower > 0
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: enabled ? powerStepButtonBg : "#555555"
                                border.width: 1
                                border.color: enabled ? "#00000030" : "transparent"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: enabled ? powerStepButtonText : "#AAAAAA"
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: startMainPowerRepeat(true)
                            onReleased: stopMainPowerRepeat()
                            onCanceled: stopMainPowerRepeat()
                        }
                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Установите эффект резания")
                        visible: modeSelected() && modeEditor.isEndo
                        horizontalAlignment: Text.AlignHCenter
                        color: uiMidGray
                        font.pixelSize: 20
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: controlButtonHeight
                        spacing: 16
                        visible: modeSelected() && modeEditor.isEndo

                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("−")
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: powerStepButtonBg
                                border.width: 1
                                border.color: "#00000030"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: powerStepButtonText
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: setEndoPower(endoCutEffect() - 1, endoCoagEffect())
                        }
                        Label {
                            Layout.preferredWidth: 140
                            text: endoCutEffect()
                            color: "white"
                            font.pixelSize: 52
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("+")
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: powerStepButtonBg
                                border.width: 1
                                border.color: "#00000030"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: powerStepButtonText
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: setEndoPower(endoCutEffect() + 1, endoCoagEffect())
                        }
                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Установите эффект коагуляции")
                        visible: modeSelected() && modeEditor.isEndo
                        horizontalAlignment: Text.AlignHCenter
                        color: uiMidGray
                        font.pixelSize: 20
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: controlButtonHeight
                        spacing: 16
                        visible: modeSelected() && modeEditor.isEndo

                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("−")
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: powerStepButtonBg
                                border.width: 1
                                border.color: "#00000030"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: powerStepButtonText
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: setEndoPower(endoCutEffect(), endoCoagEffect() - 1)
                        }
                        Label {
                            Layout.preferredWidth: 140
                            text: endoCoagEffect()
                            color: "white"
                            font.pixelSize: 52
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Button {
                            Layout.preferredWidth: powerStepButtonWidth
                            Layout.preferredHeight: controlButtonHeight
                            text: qsTr("+")
                            flat: true
                            background: Rectangle {
                                radius: 16
                                color: powerStepButtonBg
                                border.width: 1
                                border.color: "#00000030"
                            }
                            contentItem: Text {
                                text: parent.text
                                color: powerStepButtonText
                                font.pixelSize: 44
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onPressed: setEndoPower(endoCutEffect(), endoCoagEffect() + 1)
                        }
                        Item { Layout.fillWidth: true; Layout.minimumWidth: 24 }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Рекомендуемый уровень\nдля выбранного инструмента")
                        visible: modeSelected() && instrumentSelected()
                        horizontalAlignment: Text.AlignHCenter
                        color: uiMidGray
                        font.pixelSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: modeEditor.isEndo ? recommendedEndoButtonHeight : recommendedButtonHeight
                        visible: modeSelected()
                        spacing: 8
                        PowerRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: modeEditor.isEndo ? recommendedEndoButtonHeight : recommendedButtonHeight
                            borderColor: "#A5D6A7"
                            power: modeEditor.lowPowerBound
                            selected: modeEditor.currentPower === power
                            isEndo: modeEditor.isEndo
                            onPowerChosen: modeEditor.updateParameter("currentpower", pwr)
                        }
                        PowerRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: modeEditor.isEndo ? recommendedEndoButtonHeight : recommendedButtonHeight
                            borderColor: "#78D87C"
                            power: modeEditor.midPowerBound
                            selected: modeEditor.currentPower === power
                            isEndo: modeEditor.isEndo
                            onPowerChosen: modeEditor.updateParameter("currentpower", pwr)
                        }
                        PowerRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: modeEditor.isEndo ? recommendedEndoButtonHeight : recommendedButtonHeight
                            borderColor: "#51D456"
                            power: modeEditor.highPowerBound
                            selected: modeEditor.currentPower === power
                            isEndo: modeEditor.isEndo
                            onPowerChosen: modeEditor.updateParameter("currentpower", pwr)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: modeSelected() && isCoag
                                 && ((socId <= 1 && isBiCoagMode())
                                     || (socId >= 2 && socId <= 3 && isSoftMode()))

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            spacing: 12
                            visible: socId <= 1 && isBiCoagMode()

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 62
                                text: qsTr("АВТОСТОП")
                                flat: true
                                background: Rectangle {
                                    radius: 14
                                    border.width: socketAutoMode() === 1 ? 2 : 1
                                    border.color: socketAutoMode() === 1 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: socketAutoMode() === 1 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: socketAutoMode() === 1 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: requestAutoMode(1, qsTr("В режиме АВТОСТОП инструмент активируется с помощью педали.\nПо завершении коагуляции процесс прекращается автоматически"))
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 62
                                text: qsTr("АВТОСТАРТ/СТОП")
                                flat: true
                                background: Rectangle {
                                    radius: 14
                                    border.width: socketAutoMode() === 2 ? 2 : 1
                                    border.color: socketAutoMode() === 2 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: socketAutoMode() === 2 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: socketAutoMode() === 2 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: requestAutoMode(2, qsTr("В режиме АВТОСТАРТ/СТОП активация происходит автоматически без нажатия педали!"))
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            spacing: 12
                            visible: socId >= 2 && socId <= 3 && isSoftMode()

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 62
                                text: qsTr("АВТОСТОП")
                                flat: true
                                background: Rectangle {
                                    radius: 14
                                    border.width: socketAutoMode() === 1 ? 2 : 1
                                    border.color: socketAutoMode() === 1 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: socketAutoMode() === 1 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: socketAutoMode() === 1 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: requestAutoMode(1, qsTr("В режиме АВТОСТОП инструмент активируется с помощью педали или держателя инструментов.\nПо завершении коагуляции процесс прекращается автоматически"))
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Задержка автозапуска")
                            visible: socId <= 1 && isBiCoagMode() && socketAutoMode() === 2
                            horizontalAlignment: Text.AlignHCenter
                            color: uiMidGray
                            font.pixelSize: 20
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                            spacing: 8
                            visible: socId <= 1 && isBiCoagMode() && socketAutoMode() === 2

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                text: qsTr("0 сек")
                                flat: true
                                background: Rectangle {
                                    radius: 12
                                    border.width: periphHandle.autoDelayMs === 0 ? 2 : 1
                                    border.color: periphHandle.autoDelayMs === 0 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: periphHandle.autoDelayMs === 0 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: periphHandle.autoDelayMs === 0 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 18
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: periphHandle.setAutoDelayMs(0)
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                text: qsTr("0.5 сек")
                                flat: true
                                background: Rectangle {
                                    radius: 12
                                    border.width: periphHandle.autoDelayMs === 500 ? 2 : 1
                                    border.color: periphHandle.autoDelayMs === 500 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: periphHandle.autoDelayMs === 500 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: periphHandle.autoDelayMs === 500 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 18
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: periphHandle.setAutoDelayMs(500)
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                text: qsTr("1.0 сек")
                                flat: true
                                background: Rectangle {
                                    radius: 12
                                    border.width: periphHandle.autoDelayMs === 1000 ? 2 : 1
                                    border.color: periphHandle.autoDelayMs === 1000 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: periphHandle.autoDelayMs === 1000 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: periphHandle.autoDelayMs === 1000 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 18
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: periphHandle.setAutoDelayMs(1000)
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                text: qsTr("1.5 сек")
                                flat: true
                                background: Rectangle {
                                    radius: 12
                                    border.width: periphHandle.autoDelayMs === 1500 ? 2 : 1
                                    border.color: periphHandle.autoDelayMs === 1500 ? root.autoBtnOnBorder : root.autoBtnOffBorder
                                    color: periphHandle.autoDelayMs === 1500 ? root.autoBtnOnFill : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: periphHandle.autoDelayMs === 1500 ? "white" : root.autoBtnOffText
                                    font.pixelSize: 18
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: periphHandle.setAutoDelayMs(1500)
                            }
                        }
                    }

                    EndoChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        Layout.topMargin: 8
                        visible: modeSelected() && modeEditor.isEndo
                        cutEffect: endoCutEffect()
                        coagEffect: endoCoagEffect()
                        modeName: modeTitleText()
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Визуализация для справки")
                        visible: modeSelected() && modeEditor.isEndo
                        horizontalAlignment: Text.AlignHCenter
                        color: uiMidGray
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillHeight: true }
                }

                Rectangle {
                    id: previewRect
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 16
                    color: "white"
                    border.color: "#B0BEC5"
                    border.width: 1
                    visible: centerView !== "power"

                    ColumnLayout {
                        id: previewContent
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            Layout.fillWidth: true
                            text: centerView === "modePreview" ? modeTitleText() : currentInstrName()
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "#111111"
                            font.pixelSize: 28
                            font.bold: true
                        }

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 150
                            visible: centerView === "modePreview"
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            source: modeEditor.currentModeIndex >= 0 && modeEditor.currentModeIndex < modeNums.length
                                    ? ("image://modes/" + modeImagePrefix() + "%1").arg(modeNums[modeEditor.currentModeIndex]) : ""
                        }

                        Image {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 320
                            visible: centerView === "instrPreview"
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            source: modeEditor.currentInstrIndex >= 0 && modeEditor.currentInstrIndex < instrNums.length
                                    ? ("image://instruments/instrum%1").arg(instrNums[modeEditor.currentInstrIndex]) : ""
                        }

                        Rectangle {
                            id: descriptionContainer
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            clip: true

                            Flickable {
                                id: descriptionFlick
                                anchors.fill: parent
                                contentWidth: width
                                contentHeight: descriptionText.paintedHeight
                                boundsBehavior: Flickable.StopAtBounds
                                clip: true

                                Text {
                                    id: descriptionText
                                    width: descriptionContainer.width
                                    text: centerView === "modePreview"
                                          ? ("<b>" + modeEditor.modeBrief + "</b><br><br>" + modeEditor.modeDescript)
                                          : ("<b>" +
                                                (modeEditor.instrBrief === currentInstrName()
                                                 ? ""
                                                 : modeEditor.instrBrief)  + "</b>")  // Если описание совпадает с названием, то не выводим
                                    textFormat: Text.RichText
                                    wrapMode: Text.WordWrap
                                    color: "#263238"
                                    font.pixelSize: 22
                                }

                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            spacing: 16

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                text: qsTr("ОТМЕНА")
                                background: Rectangle {
                                    radius: 18
                                    color: "#808080"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 24
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: restoreCommittedSelection()
                            }
                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                text: qsTr("ПРИНЯТЬ")
                                background: Rectangle {
                                    radius: 18
                                    color: "#2E7D32"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 24
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onPressed: applyPreviewSelection()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 86
            color: "transparent"
            visible: centerView === "power"

            Button {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width: 180
                height: 62
                text: qsTr("ОТМЕНА")
                background: Rectangle {
                    radius: 18
                    color: "#808080"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: cancelEditorAndClose()
            }

            Button {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width: 180
                height: 62
                text: qsTr("ПРИНЯТЬ")
                enabled: modeEditor.hasChanges
                background: Rectangle {
                    radius: 18
                    color: parent.enabled ? "#2E7D32" : "#2E7D3270"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onPressed: {
                    modeEditor.commitChanges()
                    root.close()
                }
            }
        }
    }

    Connections {
        target: modeListView
        function onNewIndexSelected(index) {
            if (internalIndexChange || openingInProgress) {
                return
            }
            if (index === modeEditor.currentModeIndex && centerView === "modePreview") {
                return
            }
            modeEditor.currentModeIndex = index
            modeListView.curIndex = index
            instrListView.curIndex = modeEditor.currentInstrIndex
            centerView = "modePreview"
        }
    }

    Connections {
        target: instrListView
        function onNewIndexSelected(index) {
            if (internalIndexChange || openingInProgress) {
                return
            }
            if (index === modeEditor.currentInstrIndex && centerView === "instrPreview") {
                return
            }
            modeEditor.currentInstrIndex = index
            instrListView.curIndex = index
            centerView = "instrPreview"
        }
    }

    Connections {
        target: modeEditor
        function onCurrentModeIndexChanged() {
            internalIndexChange = true
            updateInstrModel()
            instrListView.curIndex = modeEditor.currentInstrIndex
            internalIndexChange = false
            if (!openingInProgress && socketAutoModeState !== 0) {
                setSocketAutoMode(0)
            }
            normalizeEndoCurrentPower()
        }
        function onCurrentParamsChanged() {
            normalizeEndoCurrentPower()
        }
    }

    Connections {
        target: periphHandle
        function onAutoModeChanged(socketId, mode) {
            if (socketId === socId) {
                socketAutoModeState = mode
            }
            syncAutoModeDirtyFromAuto()
        }
        function onAutoDelayMsChanged(delayMs) {
            syncAutoModeDirtyFromAuto()
        }
    }

    Popup {
        id: autoModeConfirmPopup
        parent: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: Overlay.overlay
        width: Math.min(root.width * 0.72, 760)
        height: 320

        background: Rectangle {
            radius: 16
            color: "#F4F4F4"
            border.width: 1
            border.color: "#8A8A8A"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 18

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: autoModeConfirmText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "#111111"
                font.pixelSize: 24
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: qsTr("ОТМЕНА")
                    background: Rectangle {
                        radius: 14
                        color: "#808080"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: {
                        pendingAutoMode = -1
                        autoModeConfirmPopup.close()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    text: qsTr("ПРИНЯТЬ")
                    background: Rectangle {
                        radius: 14
                        color: "#2E7D32"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onPressed: {
                        if (pendingAutoMode >= 0) {
                            setSocketAutoMode(pendingAutoMode)
                        }
                        pendingAutoMode = -1
                        autoModeConfirmPopup.close()
                    }
                }
            }
        }
    }
}
