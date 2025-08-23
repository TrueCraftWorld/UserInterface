import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: instrumRoot

    property bool isCoag
    property string instrumName: "Биполярный лапороскопический инструмент"
    property int instrumId

    signal instrumEditDialogRequest()

    Rectangle {
        id: instrum
        color: "black"
        Label {
            text: instrumName
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.Wrap
            // color: isCoag ? "white" : "black"
            color: "white"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 0
        }
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: isCoag ? instrImage.left : parent.right
            left: isCoag ? parent.left : instrImage.right
        }
    }
    Rectangle {
        id: instrImage
        color: "black"
        width: 0.3 * parent.width
        Image {
            id: theImage
            asynchronous: true
            source: isCoag ? "image://instrums/" + (instrumId+1)
                           :  "image://instrums/" + "Cut_No"
            // source: "qrc:/test.jpg"
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
        }
        anchors {
            left: isCoag ? undefined : parent.left
            right: isCoag ? parent.right : undefined
            bottom: parent.bottom
            top: parent.top
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: instrumRoot.instrumEditDialogRequest()
    }

}
