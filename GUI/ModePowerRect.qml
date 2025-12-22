import QtQuick 2.15
import QtQuick.Controls 2.15

Canvas {
    id: modePowerRect

    property bool isCoag
    property string modeName
    property int modeId
    property int modePower
    property int maxPower
    property bool isEndo: false

    signal modeEditDialogRequest()
    signal newPower(int pwr)

    function colorFromId() {
        if (modePowerRect.modeId == 1000)
            return "darkgray"
        return isCoag ? "blue" : "yellow"
    }

    function changePower(direction) {
        var changedPower = modePower
        if (direction === "up") {
            if (modePower < 20) changedPower += 1
            else if (modePower < 50) changedPower +=2
            else if (modePower < 100) changedPower +=5
            else if (modePower < 200) changedPower +=10
            else if (modePower < 400) changedPower +=25
        }
        if (direction === "down") {
            if (modePower <= 1) changedPower = 1
            else if (modePower <= 20) changedPower -= 1
            else if (modePower <= 50) changedPower -=2
            else if (modePower <= 100) changedPower -=5
            else if (modePower <= 200) changedPower -=10
            else if (modePower <= 400) changedPower -=25
        }
        return changedPower
    }

    function changePowerEndoCut(direction) {
        var changedPower = modePower
        if (direction === "up") {
            if (modePower < 30) changedPower += 10
        }
        if (direction === "down") {
            if (modePower >= 20) changedPower -= 10
        }
        return changedPower
    }

    function changePowerEndoCoag(direction) {
        var changedPower = modePower
        if (direction === "up") {
            if ((modePower % 10) < 3) changedPower += 1
        }
        if (direction === "down") {
            if ((modePower % 10) >= 2) changedPower -= 1
        }
        return changedPower
    }

    // Функция для округления значения до ближайшего допустимого шага
    function roundToStep(value) {
        if (value <= 0) return 1

        if (value <= 20) {
            return Math.round(value) // шаг 1
        } else if (value <= 50) {
            return Math.round(value / 2) * 2 // шаг 2
        } else if (value <= 100) {
            return Math.round(value / 5) * 5 // шаг 5
        } else if (value <= 200) {
            return Math.round(value / 10) * 10 // шаг 10
        } else if (value <= 400) {
            return Math.round(value / 25) * 25 // шаг 25
        } else {
            return 1 // шаг 25
        }
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        var radius = 20;
        var x = 0;
        var y = 0;
        var w = width;
        var h = height;

        ctx.beginPath();

        if (isCoag) {
            if (parent.parent.state === "expanded") {
                // Правый сокет расширен - закруглен только нижний правый угол
                ctx.moveTo(x, y);
                ctx.lineTo(w, y);
                ctx.lineTo(w, h - radius);
                ctx.arcTo(w, h, w - radius, h, radius);
                ctx.lineTo(x, h);
                ctx.lineTo(x, y);
            }
            else {
                // Правый сокет сжат - закруглены правые углы
                ctx.moveTo(x, y);
                ctx.lineTo(w - radius, y);
                ctx.arcTo(w, y, w, radius, radius);
                ctx.lineTo(w, h - radius);
                ctx.arcTo(w, h, w - radius, h, radius);
                ctx.lineTo(x, h);
                ctx.lineTo(x, y);
            }
        } else {
            if (parent.parent.state === "expanded") {
                // Левый сокет расширен - закруглен только нижний левый угол
                ctx.moveTo(x, y);
                ctx.lineTo(w, y);
                ctx.lineTo(w, h);
                ctx.lineTo(x + radius, h);
                ctx.arcTo(x, h, x, h - radius, radius);
            }
            else {
                // Левый сокет сжат - закруглены левые углы
                ctx.moveTo(x + radius, y);
                ctx.lineTo(w, y);
                ctx.lineTo(w, h);
                ctx.lineTo(x + radius, h);
                ctx.arcTo(x, h, x, h - radius, radius);
                ctx.lineTo(x, radius);
                ctx.arcTo(x, y, x + radius, y, radius);
            }
        }

        ctx.closePath();
        ctx.fillStyle = colorFromId();
        ctx.fill();
    }

    Connections {
        target: modePowerRect
        function onModeIdChanged() {
            modePowerRect.requestPaint()
        }
    }

    Connections {
        target: modePowerRect
        function onIsEndoChanged() {
            modePowerRect.requestPaint()
        }
    }

    Rectangle {
        id: mode
        color: "transparent"
        Label {
            id: modeLabel
            text: modeName
            font.pixelSize: 22
            font.bold: true
            wrapMode: Text.Wrap
            height: 60
            color: isCoag ? "white" : "black"
            // verticalAlignment: Qt.AlignVCenter
            anchors {
                margins: 10
                fill: parent
            }

            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }
        }


        MouseArea {
            id: modeSelectButton
            anchors {
                fill: parent
                topMargin: 10
                leftMargin: 60
                rightMargin: 60
                bottomMargin: 90
            }
            onClicked: modePowerRect.modeEditDialogRequest()
        }

    }

    Item {
        id: powerControls
        anchors.fill: parent
        visible: !isEndo

        Rectangle {
            id: power
            color: "transparent"
            height: powerPlusButton.height
            anchors.verticalCenter: powerPlusButton.verticalCenter
            Label {
                id: powerLabel
                text: modePower
                visible: (modeId != 1000)
                width: fontMetrics.advanceWidth("999")
                font.pixelSize: 50
                font.bold: true
                color: isCoag ? "white" : "black"
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
//                // Поведенческая анимация для размера шрифта
//                Behavior on font.pixelSize {
//                    NumberAnimation {
//                        duration: 300
//                        easing.type: Easing.OutCubic
//                    }
//                }
            }
            FontMetrics {
                id: fontMetrics
                font: powerLabel.font
            }
        }
        Rectangle {
            id: powerPlusButton
            width: 60
            height: 60
            color: "transparent"
            radius: 8
            border {
                color: modePowerRect.isCoag ? "white" : "color"
                width: 2
            }
            anchors.margins: 95
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            Label {
                anchors {
                    margins: 10
                    fill: parent
                }
                color: modePowerRect.isCoag ? "white" : "color"
                font.pixelSize: 30
                font.bold: true
                text: "+"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                onClicked: modePowerRect.newPower(changePower("up"));
            }
        }

        Rectangle {
            id: powerMinusButton
            width: 60
            height: 60
            color: "transparent"
            radius: 8
            border {
                color: modePowerRect.isCoag ? "white" : "color"
                width: 2
            }
            anchors.margins: 95
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            Label {
                anchors {
                    margins: 10
                    fill: parent
                }
                color: modePowerRect.isCoag ? "white" : "color"
                font.pixelSize: 30
                font.bold: true
                text: "-"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                onClicked: modePowerRect.newPower(changePower("down"));
            }
        }

        Slider {
            id: powerSlider
            property real _sliderValue: modePower
            value: modePowerRect.isEndo ? _sliderValue : modePower
            enabled: !modePowerRect.isEndo
            opacity: 1
            anchors.bottomMargin: 15
            anchors.leftMargin: 25
            anchors.rightMargin:  25
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            from: 1
            to: maxPower
            onValueChanged: {
                // Не обрабатываем изменения слайдера в эндоскопическом режиме
                if (modePowerRect.isEndo) {
                    _sliderValue = value
                    return
                }
                var roundedValue = roundToStep(value)
                if (roundedValue !== modePower) {
                    modePowerRect.newPower(roundedValue)
                }
            }
        }
    }

    Item {
        id: powerEndoControls
        anchors.fill: parent
        visible: isEndo

        Row {
            id: endoRow
            anchors.centerIn: parent
            spacing: 30

            // Минимальный отступ слева
            Item {
                width: 5
            }

            Rectangle {
                id: powerMinusEndoCut
                width: 60
                height: 60
                color: "transparent"
                radius: 8
                border {
                    color: modePowerRect.isCoag ? "white" : "black"
                    width: 2
                }
                Label {
                    anchors {
                        margins: 10
                        fill: parent
                    }
                    color: modePowerRect.isCoag ? "white" : "black"
                    font.pixelSize: 30
                    font.bold: true
                    text: "-"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: modePowerRect.newPower(changePowerEndoCut("down"));
                }
            }

            Item {
                width: fontMetricsEndo.advanceWidth("9")
                height: 60
                clip: false
                
                anchors.verticalCenter: powerMinusEndoCut.verticalCenter
                
                Label {
                    id: cutEffect
                    text: qsTr("эффект резания")
                    font.pixelSize: 14
                    color: isCoag ? "white" : "black"
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: powerEndoCutLabel.top
                    anchors.bottomMargin: 10
                    horizontalAlignment: Qt.AlignHCenter
                }
                
                Label {
                    id: powerEndoCutLabel
                    text: Math.floor(modePower / 10)
                    visible: (modeId != 1000)
                    width: parent.width
                    height: 60
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 50
                    font.bold: true
                    color: isCoag ? "white" : "black"
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }

            Rectangle {
                id: powerPlusEndoCut
                width: 60
                height: 60
                color: "transparent"
                radius: 8
                border {
                    color: modePowerRect.isCoag ? "white" : "black"
                    width: 2
                }
                Label {
                    anchors {
                        margins: 10
                        fill: parent
                    }
                    color: modePowerRect.isCoag ? "white" : "black"
                    font.pixelSize: 30
                    font.bold: true
                    text: "+"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: modePowerRect.newPower(changePowerEndoCut("up"));
                }
            }

            // Увеличенный отступ между Cut и Coag группами
            Rectangle {
                id: dummyRect
                width: 5
                height: 60
                color: "transparent"
            }

            Rectangle {
                id: powerMinusEndoCoag
                width: 60
                height: 60
                color: "transparent"
                radius: 8
                border {
                    color: modePowerRect.isCoag ? "white" : "black"
                    width: 2
                }
                Label {
                    anchors {
                        margins: 10
                        fill: parent
                    }
                    color: modePowerRect.isCoag ? "white" : "black"
                    font.pixelSize: 30
                    font.bold: true
                    text: "-"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var newValue = changePowerEndoCoag("down");
                        if (newValue !== modePower) {
                            modePowerRect.newPower(newValue);
                        }
                    }
                }
            }

            Item {
                width: fontMetricsEndo.advanceWidth("9")
                height: 60
                clip: false
                
                anchors.verticalCenter: powerMinusEndoCoag.verticalCenter
                
                Label {
                    id: coagEffect
                    text: qsTr("эффект коагуляции")
                    font.pixelSize: 14
                    color: isCoag ? "white" : "black"
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: powerEndoCoagLabel.top
                    anchors.bottomMargin: 10
                    horizontalAlignment: Qt.AlignHCenter
                }
                
                Label {
                    id: powerEndoCoagLabel
                    text: modePower % 10
                    visible: (modeId != 1000)
                    width: parent.width
                    height: 60
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 50
                    font.bold: true
                    color: isCoag ? "white" : "black"
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }

            Rectangle {
                id: powerPlusEndoCoag
                width: 60
                height: 60
                color: "transparent"
                radius: 8
                border {
                    color: modePowerRect.isCoag ? "white" : "black"
                    width: 2
                }
                Label {
                    anchors {
                        margins: 10
                        fill: parent
                    }
                    color: modePowerRect.isCoag ? "white" : "black"
                    font.pixelSize: 30
                    font.bold: true
                    text: "+"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var newValue = changePowerEndoCoag("up");
                        if (newValue !== modePower) {
                            modePowerRect.newPower(newValue);
                        }
                    }
                }
            }

            // Минимальный отступ справа
            Item {
                width: 5
            }
        }

        FontMetrics {
            id: fontMetricsEndo
            font: powerLabel.font
        }
    }

    Rectangle {
        id: powerEndo
        color: "transparent"
        visible: isEndo
        anchors.left: {modePowerRect.isCoag ? powerControls.left : undefined}
        anchors.right: {modePowerRect.isCoag ? undefined : powerControls.right}
        anchors.top: powerControls.top
        anchors.bottom: powerControls.bottom
        Label {
            id: powerLabelEndoCollapse
            text: Math.floor(modePower/10) + "-" + (modePower%10)
            visible: (modeId != 1000)
            width: fontMetrics2.advanceWidth("999")
            height: 31
            font.pixelSize: 50
            font.bold: true
            color: isCoag ? "white" : "black"
            // verticalAlignment: Qt.AlignVCenter
            anchors {
                margins: 10
                fill: parent
            }
            horizontalAlignment: isCoag ? Text.AlignLeft : Text.AlignRight
            verticalAlignment: Text.AlignVCenter

//            // Поведенческая анимация для размера шрифта
//            Behavior on font.pixelSize {
//                NumberAnimation {
//                    duration: 300
//                    easing.type: Easing.OutCubic
//                }
//            }
        }
        FontMetrics {
            id: fontMetrics2
            font: powerLabel.font
        }
    }

    states: [
        State {
            name: "collapsed"
            PropertyChanges { target: powerPlusButton;  visible: false }
            PropertyChanges { target: powerMinusButton; visible: false }
            PropertyChanges { target: powerSlider;      visible: false }
            PropertyChanges { target: powerEndoControls; visible: false }
//            PropertyChanges { target: powerPlusEndoCut;  visible: false }
//            PropertyChanges { target: powerMinusEndoCut; visible: false }
//            PropertyChanges { target: powerPlusEndoCoag;  visible: false }
//            PropertyChanges { target: powerMinusEndoCoag; visible: false }
//            PropertyChanges { target: cutEffect; visible: false }
//            PropertyChanges { target: coagEffect; visible: false }
            PropertyChanges {
                target: powerLabel;
                horizontalAlignment: isCoag ? Text.AlignLeft : Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.bottomMargin: 10
                anchors.topMargin: 10
//                font.pixelSize: 50
            }
            PropertyChanges {
                target: modeLabel;
                horizontalAlignment: isCoag ? Text.AlignRight : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 25
            }
            PropertyChanges {
                target: power;
                anchors.topMargin: undefined
            }
            PropertyChanges {
                target: modeSelectButton;
                enabled: false
            }
            AnchorChanges {
                target: power
                anchors.left: {modePowerRect.isCoag ? powerControls.left : undefined}
                anchors.right: {modePowerRect.isCoag ? undefined : powerControls.right}
//                anchors.top: powerControls.top
//                anchors.bottom: powerControls.bottom
            }
            AnchorChanges {
                target: mode
                anchors.left: {modePowerRect.isCoag ? powerControls.right : modePowerRect.left}
                anchors.right: {modePowerRect.isCoag ? modePowerRect.right : powerControls.left}
                anchors.top: powerControls.top
                anchors.bottom: powerControls.bottom
            }
            AnchorChanges {
                target: powerPlusButton
                anchors.right: undefined
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: powerMinusButton
                anchors.left: undefined
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: powerSlider
                anchors.left: undefined
                anchors.right: undefined
                anchors.verticalCenter: undefined
            }
        },
        State {
            name: "expanded"
            PropertyChanges { target: powerPlusButton;  visible: (modeId != 1000) }
            PropertyChanges { target: powerMinusButton; visible: (modeId != 1000) }
            PropertyChanges { target: powerSlider;      visible: (modeId != 1000) }
            PropertyChanges { target: powerEndo;  visible: false }
            PropertyChanges {
                target: powerLabel;
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                anchors.bottomMargin: 40
                anchors.topMargin: -20
//                font.pixelSize: 50
            }
            PropertyChanges {
                target: modeLabel;
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                font.pixelSize: 28
            }
            PropertyChanges {
                target: power;
                anchors.topMargin: 100
            }
            PropertyChanges {
                target: modeSelectButton;
                enabled: true
            }
//            AnchorChanges {
//                target: powerPlusButton
//                anchors.right: modePowerRect.right
//                anchors.bottom: power.bottom
//            }
//            AnchorChanges {
//                target: powerMinusButton
//                anchors.left: modePowerRect.left
//                anchors.bottom: power.bottom
//            }
//            AnchorChanges {
//                target: powerSlider
//                anchors.bottom: parent.bottom
//            }
            AnchorChanges {
                target: mode
                anchors.left: modePowerRect.left
                anchors.right: modePowerRect.right
                anchors.top: modePowerRect.top
                anchors.bottom: undefined
            }
            AnchorChanges {
                target: power
                anchors.left: powerControls.left
                anchors.right: powerControls.right
//                anchors.top: powerControls.top
//                anchors.left: undefined
//                anchors.right: undefined
//                anchors.top: undefined
//                anchors.bottom: undefined
//                anchors.verticalCenter: powerPlusButton.verticalCenter
            }
        }
    ]
//    transitions: [
//        Transition {
//            from: "collapsed"
//            to: "expanded"
//            NumberAnimation {  duration: 100; easing.type: Easing.InQuad }
//        },
//        Transition {
//            from: "expanded"
//            to: "collapsed"
//            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
//        }
//    ]
}
