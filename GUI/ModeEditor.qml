import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Popup {
    property int socId
    property int modeIndex
    property bool isCoag
    property var modeEditor: Editor

    id: root
    modal: true
    parent: Overlay.overlay
    width: parent.width
    height: parent.height
    x: 0
    y: 0

    property var itemIdArr: []
    property var itemNameArr: []
    property var itemNumArr: []
    property bool changed: false
    

    property string imagePrefix: {
        // socId: 0 = БИ1, 1 = БИ2, 2 = МОНО1, 3 = МОНО2
        /*return*/ (socId <= 1) ? "bimode" : "monomode"
    }
    
    // Получаем Num текущего режима
    property int currentModeNum: {
        if (modeEditor.currentModeIndex < 0 || modeEditor.currentModeIndex >= itemNumArr.length)
            return 0
        return parseInt(itemNumArr[modeEditor.currentModeIndex])
    }
    
    ListModel {
        id: combinedModel
    }

    // Function to update the model when C++ data changes
    function updateModel() {
        combinedModel.clear()

        if (itemIdArr.length !== itemNameArr.length || itemIdArr.length !== itemNumArr.length) {
            console.warn("Lists from C++ have different lengths!")
            return
        }
        for (var i = 0; i < itemIdArr.length; i++) {
            combinedModel.append({
                itemId: itemNumArr[i],  // Используем Num вместо ID для изображений
                itemName: itemNameArr[i],
                rowIndex: i
            })
        }
        modeListView.innerModel = combinedModel
    }

    onOpened: {
        // Запрещаем активацию при открытии popup
        control.enableActivation = false
        
        modeEditor.initialize(socId, modeIndex, isCoag)

        itemNameArr = modeEditor.modeNames
        itemIdArr = modeEditor.modeNamesIds()
        itemNumArr = modeEditor.modeNamesNums()
        
        updateModel()

        modeEditor.currentModeIndex = modeIndex
        modeListView.selectedIndex = modeEditor.currentModeIndex
    }
    
    onClosed: {
        // Разрешаем активацию при закрытии popup
        control.enableActivation = true
    }

    Rectangle {
        id: back
        anchors.fill: parent
        color: "#0a0a0a"
        
        // Слой 1: Базовый градиент (зависит от режима)
        Rectangle {
            id: baseLayer
            anchors.fill: parent
            
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { 
                    position: 0.0
                    color: isCoag ? "#000066" : "#443300"
                }
                GradientStop { 
                    position: 1.0
                    color: isCoag ? "#0000aa" : "#665500"
                }
            }
        }
        
        // Слой 2: Пульсирующий цветовой слой
        Rectangle {
            id: pulseLayer
            anchors.fill: parent
            opacity: 0.5
            
            property real pulsePhase: 0.0
            
            // Вычисляем цвета на основе pulsePhase и isCoag
            property color topColor: {
                var intensity = 0.4 + pulsePhase * 0.3  // 0.4 - 0.7
                if (isCoag) {
                    return Qt.rgba(0, intensity * 0.3, intensity, 1)  // Синий
                } else {
                    return Qt.rgba(intensity * 0.6, intensity * 0.5, 0, 1)  // Приглушённый жёлто-коричневый
                }
            }
            
            property color bottomColor: {
                var intensity = 0.5 + pulsePhase * 0.4  // 0.5 - 0.9
                if (isCoag) {
                    return Qt.rgba(0, intensity * 0.4, intensity, 1)  // Светло-синий
                } else {
                    return Qt.rgba(intensity * 0.7, intensity * 0.6, 0, 1)  // Приглушённый жёлтый
                }
            }
            
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: pulseLayer.topColor }
                GradientStop { position: 0.5; color: "#000000" }
                GradientStop { position: 1.0; color: pulseLayer.bottomColor }
            }
            
            // Анимация фазы пульсации
            SequentialAnimation on pulsePhase {
                running: true
                loops: Animation.Infinite
                
                NumberAnimation {
                    to: 1.0
                    duration: 4000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 0.0
                    duration: 4000
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        // Слой 3: Диагональный луч света
        Canvas {
            id: diagonalBeam
            anchors.fill: parent
            opacity: 0.2
            
            property real beamPosition: -0.5
            property bool useCoagColors: isCoag
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                // Создаём диагональный градиент
                var x1 = width * beamPosition - 150
                var y1 = -150
                var x2 = width * beamPosition + height
                var y2 = height
                
                var gradient = ctx.createLinearGradient(x1, y1, x2, y2)
                
                // Прозрачный → яркий → прозрачный
                gradient.addColorStop(0, "rgba(0, 0, 0, 0)")
                gradient.addColorStop(0.4, "rgba(0, 0, 0, 0)")
                
                // Явно задаём цвет луча для каждого режима
                if (useCoagColors) {
                    gradient.addColorStop(0.5, "rgba(80, 120, 255, 0.6)")  // Синий луч
                } else {
                    gradient.addColorStop(0.5, "rgba(180, 150, 60, 0.5)")  // Приглушённый жёлтый луч
                }
                
                gradient.addColorStop(0.6, "rgba(0, 0, 0, 0)")
                gradient.addColorStop(1, "rgba(0, 0, 0, 0)")
                
                ctx.fillStyle = gradient
                ctx.fillRect(0, 0, width, height)
            }
            
            SequentialAnimation on beamPosition {
                running: true
                loops: Animation.Infinite
                
                NumberAnimation {
                    to: 1.5
                    duration: 8000
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    to: -1.0
                    duration: 0
                }
            }
            
            onBeamPositionChanged: {
                requestPaint()
            }
            
            onUseCoagColorsChanged: {
                requestPaint()
            }
        }
        
        // Слой 4: Мягкое пульсирующее сияние в центре
        Rectangle {
            id: centerGlow
            anchors.fill: parent
            opacity: 0.25
            
            property real glowIntensity: 0.0
            
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { 
                    position: 0.5
                    color: Qt.rgba(
                        isCoag ? 0.1 : 0.7,
                        isCoag ? 0.4 : 0.6,
                        isCoag ? 1.0 : 0.1,
                        centerGlow.glowIntensity
                    )
                }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            SequentialAnimation on glowIntensity {
                running: true
                loops: Animation.Infinite
                
                NumberAnimation {
                    to: 0.5
                    duration: 3500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 0.1
                    duration: 3500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
            color: "transparent"

            Label {
                id: titleLable
                text: !isCoag ? (qsTr("Выбор режима РЕЗАНИЯ для выхода %1")
                        .arg(modeEditor.socketName)) :
                               (qsTr("Выбор режима КОАГУЛЯЦИИ для выхода %1")
                        .arg(modeEditor.socketName))
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                height: parent.height / 2
                width: parent.width * 0.8
                color: isCoag ? "white" : "black"
                background: Rectangle {
                    id: titleRect
                    color: isCoag ? "blue" : "yellow"
                    anchors.fill: parent
                }
            }

            Button {
                id: cancelButton
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    left: titleLable.right
                }
                background: Rectangle {
                    color: "transparent"
                    radius: 8
                }

                Text {
                    id: cancelText
                    text: qsTr("X")
                    font.pixelSize: 34
                    font.bold: true
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    color: "white"
                }
                onClicked: {
                    modeEditor.rollBack()
                    // changed = false
                    root.close()
                }
            }
        }

        Rectangle {
            id: modeList
            color: "transparent"
            anchors {
                left: parent.left
                bottom: parent.bottom
                top: header.bottom
            }
            width: .3 * parent.width
            ItemList {
                id: modeListView
                curIndex: modeEditor.currentModeIndex
                color: "transparent"
                anchors {
                    top: parent.top
                    bottom: footer.top
                    left: parent.left
                    right: parent.right
                }
                // innerModel: combinedModel
                imageSourceTemplate: "image://instrums/" + imagePrefix + "%1"
            }
            Rectangle {
                id: footer
                height: 100
                color: "transparent"
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                Button {
                    id: downButton
                    width: modeList.width * .4
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                    }
                    Text {
                        id: downText
                        text: qsTr("▼")
                        font.pixelSize: 34
                        font.bold: true
                        anchors.fill: parent
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        color: "white"
                    }
                    onClicked: {
                        modeListView.scrollDown()
                    }
                }
                Button {
                    id: upButton
                    width: downButton.width
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: downButton.right
                        leftMargin: 20
                    }
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                    }
                    Text {
                        id: upText
                        text: qsTr("▲")
                        font.pixelSize: 34
                        font.bold: true
                        anchors.fill: parent
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        color: "white"
                    }
                    onClicked: {
                        modeListView.scrollUp()
                    }
                }
            }
        }

        Rectangle {
            id: modePreview
            anchors {
                top: header.bottom
                bottom: declineButton.top
                right: parent.right
                left: modeList.right
            }
            color: "transparent"

            // Краткое описание
            Rectangle {
                id: briefRect
                height: previewImage.height
                anchors {
                    top: parent.top
                    left: parent.left
                    right: previewImage.left
                    margins: 20
                }

                color: "transparent"
                border.color: "cyan"
                border.width: 1
                radius: 5

                // ScrollView {
                //     anchors.fill: parent
                //     anchors.margins: 10
                //     ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                //     clip: true

                    Label {
                        id: briefText
                        text: modeEditor.modeBrief
                        color: "cyan"
                        font.pixelSize: 21
                        font.bold: true
                        wrapMode: Text.WordWrap
                        // width: briefRect.width - 10
                        anchors.margins: 10
                        anchors.fill: parent
                    }
                // }
            }

            Image {
                id: previewImage
                width: 150
                height: width
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: ("image://instrums/" + imagePrefix + "%1").arg(currentModeNum)
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
            }
            // Полное описание
            Rectangle {
                id: descriptRect
                // width: parent.width
                anchors {
                    left: parent.left
                    top: previewImage.bottom
                    bottom: parent.bottom
                    right: parent.right
                    margins: 20
                }

                color: "transparent"


                // ScrollView {
                //     anchors.fill: parent
                //     anchors.margins: 10
                //     ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                //     clip: true

                    Label {
                        id: descriptText
                        text: modeEditor.modeDescript
                        color: "white"
                        font.pixelSize: 24
                        wrapMode: Text.WordWrap
                        // width: descriptRect.width - 10
                        anchors.margins: 10
                        anchors.fill: parent
                    }
                // }
            }
        }

        Button {
            id: declineButton
            visible: modeEditor.hasChanges
            width: parent.width * .2
            height: parent.height * .15
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                left: modeList.right
                leftMargin: 20
            }
            background: Rectangle {
                color: "transparent"
                border.width: 3
                border.color: "white"
                radius: 8
            }

            Text {
                id: declineText
                text: qsTr("ОТМЕНА")
                font.pixelSize: 34
                font.bold: true
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                color: "white"
            }
            onClicked: {
                modeEditor.rollBack()
                // changed = false
                root.close()
            }
        }

        Button {
            id: acceptButton
            width: parent.width * .2
            height: parent.height * .15
            //так надо оставиь только проверять в плюсах равенство нормально
            enabled: modeEditor.hasChanges
            // visible: changed
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                left: declineButton.right
                leftMargin: 80
            }
            background: Rectangle {
                color: "transparent"
                border.width: 3
                border.color: "lightgreen"
                radius: 8
            }
            Text {
                id: acceptText
                text: qsTr("ПРИНЯТЬ")
                font.pixelSize: 34
                font.bold: true
                color: "lightgreen"
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            onClicked: {
                modeEditor.commitChanges()
                // changed = false
                root.close();
            }
        }
    }

    Connections {
        target: modeListView
        function onNewIndexSelected(index) {
            modeEditor.currentModeIndex = index
            // changed = true
        }
    }
}
