import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutralEl
    color: "transparent"

    // Свойства компонента
    property int neutralSize: periphHandle ? periphHandle.neutralSize : 0      // 0 = Small, 1 = Medium, 2 = Large
    // property bool neutralDivided: true  // НЭ разделённый или нет
    property bool neutralDivided: periphHandle ? periphHandle.neutralElDivided : true  // НЭ разделённый или нет - привязка к ControlCenter

    // property bool neutralConnected: false  // Передается снаружи
    property bool neutralConnected: periphHandle.neutralElConnected  // Передается снаружи
    property bool showControls: false      // Показывать ли кнопки управления

    // Сигналы для синхронизации с PeriphHandler
    // Используем другие имена, чтобы не конфликтовать с автоматическими сигналами свойств
    signal neutralDividedToggled(bool divided)
    signal neutralSizeSelected(int size)

    component MassSelectionBut: Button {
        id: rootCustomBut
        required property int type
        property string iconText
        autoRepeat: true
        autoRepeatDelay: 200
        autoRepeatInterval: 200
        height: parent.height * .26
        width: parent.width * .55  // Уменьшена ширина, чтобы не перекрывать кнопки типа слева

        background: null
        contentItem: Rectangle {
            id: backGround
            anchors.fill: parent
            radius: 10
            color: neutralSize === type
                ? ( "cyan" )
                : ("lightgray" )
            border {
                color: neutralSize === type ? "orange" : "transparent"
                width: neutralSize === type ? 3 : 0
            }
            Rectangle {
                id: darker
                anchors.fill: parent
                color: "black"
                opacity: rootCustomBut.pressed ? 0.2 : 0
                radius: backGround.radius
            }
            Text {
                anchors.fill: parent
                anchors.margins: 5
                text: iconText
                font.bold: true
                font.pixelSize: Math.min(parent.height / 4, parent.width / 12)  // Адаптивный размер шрифта
                color: "#2c2c2c"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap  // Перенос текста
            }
        }
        onClicked: {
            if (neutralSize !== type) {
                neutralSize = type
                neutralSizeSelected(type)
            }
        }
    }

    Connections {
        target: buttonDivided
        function onClicked() {
            if (neutralDivided !== true) {
                neutralDivided = true
                neutralDividedToggled(true)
            }
        }
    }
    Connections {
        target: buttonNotDivided
        function onClicked() {
            if (neutralDivided !== false) {
                neutralDivided = false
                neutralDividedToggled(false)
            }
        }
    }

    NeutralButton {
        id: neutralImage

        borderColor: "orange"
        borderWidth: 3
        divided: neutralDivided
        neutColor: neutralConnected ? "lightgreen" : "red"
        theColor: neutralConnected ? "gray" : "white"

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height
        width: showControls ? 160 : parent.width
        neutRadius: showControls ? 12 : 8
        button: false
        innerTextFontSize: showControls ? 18 : 14  // Меньший шрифт в компактном режиме (PeripheryPanel)
        innerText: {
            if (neutralSize === 0)
                qsTr("< 5кг\nМакс.50")
            else if (neutralSize === 1)
                qsTr("5-15кг\nМакс.75")
            else if (neutralSize === 2)
                qsTr("> 15кг\nМакс.400")
        }
    }


    // Контейнер для кнопок управления (только когда showControls = true)
    Rectangle {
        id: neutralControlContainer
        anchors {
            left: neutralImage.right
            bottom: neutralImage.bottom
            right: parent.right
            leftMargin: 5
            rightMargin: 5
        }
        height: parent.height
        color: "transparent"
        radius: 10
        border.color: "orange"
        visible: showControls

        NeutralButton {
            id: buttonDivided
            height: parent.height * .43
            width: parent.width * .33
            borderColor: neutralDivided ? "orange" : "transparent"
            borderWidth: neutralDivided ? 3 : 0
            divided: true
            neutColor: "green"
            theColor: !neutralDivided ? "lightgray" : "cyan"
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: 10
                topMargin: 10
            }
        }
        NeutralButton {
            id: buttonNotDivided
            height: parent.height * .43
            width: parent.width * .33
            borderColor: !neutralDivided ? "orange" : "transparent"
            borderWidth: !neutralDivided ? 3 : 0
            divided: false
            neutColor: "green"
            theColor: neutralDivided ? "lightgray" : "cyan"
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: 10
                bottomMargin: 10
            }
        }
        // Кнопка выбора размера Small (< 5кг)
        MassSelectionBut {
            id: smallNeutralSize
            type: 0
            iconText: qsTr("Младенец: < 5 кг\n Максимальная мощность 50")
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 10
                topMargin: 10
            }
        }
        MassSelectionBut {
            id: mediumNeutralSize
            type: 1
            iconText: qsTr("Ребёнок: 5-15 кг\nМаксимальная мощность 75")
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
        }
        MassSelectionBut {
            id: largeNeutralSize
            type: 2
            iconText: qsTr("Взрослый: > 15 кг\nМаксимальная мощность 400")
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: 10
                bottomMargin: 10
            }
        }
    }
}
