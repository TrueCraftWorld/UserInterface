import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutralEl
    color: "transparent"

    // Маркер для PeripheryDrawer: этот компонент имеет интерактивные элементы и должен получать события напрямую
    property bool hasInteractiveContent: true

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

    component MassSelectionBut: Rectangle {
        id: rootCustomBut
        required property int type
        property string iconText
        property bool pressed: mouseArea.pressed
        
        signal clicked()
        
        height: parent.height * .27
        width: parent.width * .7  // Уменьшена ширина, чтобы не перекрывать кнопки типа слева
        radius: 10
        
        color: neutralSize === type ? "cyan" : "lightgray"
        border {
            color: neutralSize === type ? "purple" : "transparent"
            width: neutralSize === type ? 3 : 0
        }
        
        Rectangle {
            id: darker
            anchors.fill: parent
            color: "black"
            opacity: rootCustomBut.pressed ? 0.2 : 0
            radius: rootCustomBut.radius
        }
        
        Text {
            anchors.fill: parent
            anchors.margins: 5
            text: iconText
            textFormat: Text.StyledText  // Поддержка HTML-разметки
            font.pixelSize: Math.min(parent.height / 4, parent.width / 12)  // Адаптивный размер шрифта
            color: "#2c2c2c"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap  // Перенос текста
            lineHeight: 1.3  // Увеличенный межстрочный интервал (1.0 = нормальный, 1.3 = +30%)
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                rootCustomBut.clicked()
                if (neutralSize !== type) {
                    neutralSize = type
                    neutralSizeSelected(type)
                }
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
        visible: !showControls
        borderColor: "purple"
        borderWidth: 3
        divided: neutralDivided
        neutColor: neutralConnected ? "green" : "red"
        theColor: neutralConnected ? "lightgray" : "white"

        anchors.fill: parent
        button: false
        innerTextFontSize: 24
//        innerTextFontSize: showControls ? 18 : 14  // Меньший шрифт в компактном режиме (PeripheryPanel)
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
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            leftMargin: 5
            rightMargin: 5
        }
        height: parent.height
        color: "transparent"
        radius: 10
        border.color: "purple"
        border.width: 2
        visible: showControls

        NeutralButton {
            id: buttonDivided
            height: parent.height * .45
            width: parent.width * .22
            borderColor: neutralDivided ? "purple" : "transparent"
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
            height: parent.height * .45
            width: parent.width * .22
            borderColor: !neutralDivided ? "purple" : "transparent"
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
            iconText: qsTr("Младенец: &lt; <b>5</b> кг<br>Макс. мощность <b>50</b>")
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
            iconText: qsTr("Ребёнок: <b>5-15</b> кг<br>Макс. мощность <b>75</b>")
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
        }
        MassSelectionBut {
            id: largeNeutralSize
            type: 2
            iconText: qsTr("Взрослый: &gt; <b>15</b> кг<br>Макс. мощность <b>400</b>")
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: 10
                bottomMargin: 10
            }
        }
    }
}
