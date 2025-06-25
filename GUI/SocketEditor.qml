import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0

Column {
    id: root
    width: parent.width
    spacing: 10

    property var editor: Editor
    // Editor { id: modeEditor }

    GridLayout {
        width: parent.width
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        // Power Control
        Label { text: qsTr("Мощность")}
        RowLayout {
            Slider {
                id: powerSlider
                Layout.fillWidth: true
                from: editor.currentMode.minpower
                to: editor.currentMode.maxpower
                stepSize: 1
                value: editor.currentMode.currentpower
                onMoved: editor.updateParameter("currentpower", value)
            }
            Label {
                text: powerSlider.value + qsTr(" Вт")
                Layout.minimumWidth: 60
            }
        }

        // Frequency Control
        Label { text: qsTr("Инструмент") }
        RowLayout {
            Rectangle{
                color: "magenta"
                Text {
                    id: txt
                    text: qsTr("Здесь моя реклама")
                    anchors.centerIn: parent
                }
            }

        }
    }
}
