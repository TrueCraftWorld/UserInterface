import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: neutralEl
    color: "transparent"

    // Свойства компонента
    property int neutralSize: 0      // 0 = Small, 1 = Medium, 2 = Large
    property bool neutralDivided: true  // НЭ разделённый или нет
    // property bool neutralDivided: periphHandle.neutralElDivided  // НЭ разделённый или нет - привязка к ControlCenter

    property bool neutralConnected: false  // Передается снаружи
    property bool showControls: false      // Показывать ли кнопки управления


    component MassSelectionBut: Button {
        id: rootCustomBut
        required property int type
        property string iconText
        autoRepeat: true
        autoRepeatDelay: 200
        autoRepeatInterval: 200
        height: parent.height * .26
        width: parent.width * .6

        background: null
        contentItem: Rectangle {
            id: backGround
            anchors.fill: parent
            radius: 10
            color: neutralSize === type
                ? ( "cyan" )
                : ("lightgray" )
            border {
                color: neutralSize === type ? "white" : "transparent"
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
                anchors.centerIn: parent
                text: iconText
                font.bold: true
                color: "#2c2c2c"
                horizontalAlignment: Text.AlignHCenter
            }
        }
        onClicked: {
            neutralSize = type
        }
    }

    Connections {
        target: buttonDivided
        function onClicked() {
            ///TODO перекомментировать в реальном использовании
            neutralDivided = true
            // periphHandle.neutralDivided = true
        }
    }
    Connections {
        target: buttonNotDivided
        function onClicked() {
            ///TODO перекомментировать в реальном использовании
            neutralDivided = false
            // periphHandle.neutralDivided = false
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
        border.color: "white"
        visible: showControls

        NeutralButton {
            id: buttonDivided
            height: parent.height * .43
            width: parent.width * .33
            borderColor: neutralDivided ? "white" : "transparent"
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
            borderColor: !neutralDivided ? "white" : "transparent"
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
