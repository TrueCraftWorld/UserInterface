import QtQuick 2.15
import StratifyLabs.UI 2.0

Rectangle {
    id: statusRoot
    signal drawerCalled()
    signal savePressed()
    property alias text: mainText.text

    border {
        width: 1
        color: "black"
    }
    radius: 8

    SButton {
        id: drawerButton
        height: parent.height
        width: height
        anchors.left: parent.left
        iconString: Fa.Icon.bars
        style: "btn-naked"

            onClicked: {
                statusRoot.drawerCalled()
            }


    }
    SText {
        id: mainText
        height: parent.height
        anchors.left: drawerButton.right
        anchors.right: saveButton.left
        horizontalAlignment: SText.AlignHCenter
        font.capitalization: Font.AllUppercase
        font.bold: true
        font.pixelSize: 32

//        elide: SText.ElideRight  // Добавит "..." в конце
        wrapMode: SText.WordWrap // Или перенесёт на новую строку

        // Плавная смена цвета через новогодние оттенки
        SequentialAnimation on color {
            loops: Animation.Infinite
            running: true
            ColorAnimation { to: "#AA0000"; duration: 2000; easing.type: Easing.InOutQuad }  // Красный
            ColorAnimation { to: "#AA9000"; duration: 2000; easing.type: Easing.InOutQuad }  // Золотой
            ColorAnimation { to: "#00AA00"; duration: 2000; easing.type: Easing.InOutQuad }  // Зеленый
            ColorAnimation { to: "#008080"; duration: 2000; easing.type: Easing.InOutQuad }  // Синий
            ColorAnimation { to: "#AA00AA"; duration: 2000; easing.type: Easing.InOutQuad }  // Фиолетовый
            ColorAnimation { to: "#004000"; duration: 2000; easing.type: Easing.InOutQuad }  // Белый
        }
    }
    SButton {
        id: saveButton
        height: parent.height
        width: height
        anchors.right: parent.right
        iconString: Fa.Icon.save
        style: "btn-naked"

            onClicked: {
                statusRoot.savePressed()
            }
    }

}
