import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: argonRoot
    
    // Публичные свойства
    property bool cylinder1Сonnected: true      // Баллон 1 наполнен
    property bool cylinder2Connected: false     // Баллон 2 наполнен
    property int flowRate: 5               // Уровень расхода (л/мин)
    property int minFlowRate: 0
    property int maxFlowRate: 80
    property bool showControls: true       // Показывать элементы управления (в развернутом состоянии)
    property bool activCylinderFirst: true // Активный баллон 1 (или 2)
    
    // Сигналы
    signal flowRateUpdated(int newRate)

    
    color: "transparent"
//    radius: 7
//    border.color: "orange"

    Rectangle {
        id: argonView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: "grey"
        radius: 7
        border.color: "orange"
//        visible: !showControls
        
        // Иконка баллона
        Text {
            id: arLabel
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Ar"
            font.pixelSize: 24
            font.bold: true
            color: "#2c2c2c"
        }

        Rectangle {
            id: firstCylinderRect
            width: 85
            height: 150
            anchors.top: arLabel.bottom
            anchors.horizontalCenter: showControls ? undefined : parent.horizontalCenter
            color: "transparent"

            Rectangle {
                id: cylinder1Body
                width: 50
                height: 130
                radius: width / 2
                color: cylinder1Сonnected ? (activCylinderFirst ? "#40f020" : "#70f060") : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                border.color: "#d9d9d9"
                border.width: 6
            }
            Rectangle {
                id: cylinder1Neck
                width: 12
                height: 25
                radius: width / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cylinder1Body.top
                anchors.bottomMargin: -7
            }
            Rectangle {
                id: cylinder1Valve
                width: 34
                height: 10
                radius: height / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: cylinder1Neck.top
                anchors.topMargin: 3
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: "1"
                font.pixelSize: 24
                font.bold: true
                color: "black"
            }
            Label {
                id: empty1
                text: "X"
                anchors.fill: parent
                font.pixelSize: 60
                font.bold: true
                color: "yellow"
                visible: !cylinder1Сonnected
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }

        }

        // Расход
        Rectangle {
            id: argonFlowRect
            width: showControls ? 85 : parent.width
            height: 50
            anchors.top: showControls ? arLabel.bottom : firstCylinderRect.bottom
            anchors.topMargin: showControls ? 50 : 15
            anchors.left: showControls ? firstCylinderRect.right : parent.left
            color: "transparent"

            Text {
                id: argonFlow
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: flowRate
                font.pixelSize: 36
                font.bold: true
                color: "#2c2c2c"
            }
            Text {
                id: litrPerMin
                anchors.top: argonFlow.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("л/мин")
                font.pixelSize: 20
                font.bold: true
                color: "#2c2c2c"
            }
        }

        Rectangle {
            id: secondCylinderRect
            width: showControls ? 85 : parent.width
            height: 150
            anchors.top: showControls ? arLabel.bottom : argonFlowRect.bottom
            anchors.left: showControls ? argonFlowRect.right : parent.left
            anchors.topMargin: showControls ? 0 : 15
            color: "transparent"

            Rectangle {
                id: cylinder2Body
                width: 50
                height: 130
                radius: width / 2
                color: cylinder1Сonnected ? (activCylinderFirst ? "#40f020" : "#70f060") : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                border.color: "#d9d9d9"
                border.width: 6
            }
            Rectangle {
                id: cylinder2Neck
                width: 12
                height: 25
                radius: width / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: cylinder2Body.top
                anchors.bottomMargin: -7
            }

            Rectangle {
                id: cylinder2Valve
                width: 34
                height: 10
                radius: height / 2
                color: "#d9d9d9"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: cylinder2Neck.top
                anchors.topMargin: 3
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: "2"
                font.pixelSize: 24
                font.bold: true
                color: "black"
            }
            Label {
                id: empty2
                text: "X"
                anchors.fill: parent
                font.pixelSize: 60
                font.bold: true
                color: "yellow"
                visible: !cylinder2Connected
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }
        }
    }
}

