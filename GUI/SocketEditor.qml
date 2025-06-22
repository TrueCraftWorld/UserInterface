import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// import StratifyLabs.UI 2.0

Popup {
    id: root
    modal: true
    focus: true
    padding: 20

    width: 500
    height: 200

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    signal accepted(string selectedItem, int selectedValue)
    // Input properties
    property string title: "Settings"
    property var dropDownModel: ["Option 1", "Option 2", "Option 3"]
    property int initialValue: 50
    property int minValue: 0
    property int maxValue: 100
    property int stepSize: 1

    // Output signals
    // signal rejected()

    // onClosed: {
    //     if (!acceptedFlag) {
    //         rejected()
    //     }
    // }

    // property bool acceptedFlag: false
    property int currentValue: initialValue
    property string currentSelection: dropDownModel.length > 0 ? dropDownModel[0] : ""

    background: Rectangle {
        color: "#ffffff"
        radius: 8
        border.color: "#cccccc"
    }

    contentItem: ColumnLayout {
        spacing: 15

        Label {
            text: title
            font.bold: true
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        // Dropdown section
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "Selection:"
                font.pixelSize: 14
            }

            ComboBox {
                id: dropdown
                Layout.fillWidth: true
                model: root.dropDownModel
                currentIndex: 0
                onActivated: root.currentSelection = dropDownModel[index]
            }
        }

        // Value control section
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "Value: " + root.currentValue
                font.pixelSize: 14
            }

            RowLayout {
                spacing: 10

                Button {
                    text: "-"
                    onClicked: {
                        root.currentValue = Math.max(root.minValue, root.currentValue - root.stepSize)
                    }
                    implicitWidth: 40
                }

                Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: root.minValue
                    to: root.maxValue
                    value: root.currentValue
                    stepSize: root.stepSize
                    onMoved: root.currentValue = value
                }

                Button {
                    text: "+"
                    onClicked: {
                        root.currentValue = Math.min(root.maxValue, root.currentValue + root.stepSize)
                    }
                    implicitWidth: 40
                }
            }
        }

        // Button row
        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignRight

            Button {
                text: "Cancel"
                onClicked: {
                    root.close()
                }
            }

            Button {
                text: "OK"
                highlighted: true
                onClicked: {
                    // root.acceptedFlag = true
                    root.accepted(root.currentSelection, root.currentValue)
                    root.close()
                }
            }
        }
    }

    // function open() {
    //     acceptedFlag = false
    //     currentValue = initialValue
    //     currentSelection = dropDownModel.length > 0 ? dropDownModel[0] : ""
    //     dropdown.currentIndex = 0
    //     slider.value = initialValue
    //     popup.open()
    // }
}
