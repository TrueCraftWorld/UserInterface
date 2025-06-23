import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import StratifyLabs.UI 2.0

Popup {

    id: editorRoot

    function powerDecrement() {
        var temp = currentValue - stepSize;
        currentValue = temp >= minValue ? temp : minValue
    }
    function powerIncrement() {
        var temp = currentValue + stepSize;
        currentValue = temp <= maxValue ? temp : maxValue
    }

    property string title: "Settings"
    property var dropDownModel: ["Option 1", "Option 2", "Option 3"]
    property int initialValue: 50
    property int minValue: 0
    property int maxValue: 100
    property int stepSize: 1
    property int currentValue: initialValue

    signal accepted()
    signal rejected()

    modal: true
    focus: true
    padding: 20


    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    SColumn {
        anchors {
            left: parent.left
            right: parent.right
            top:parent.top
            bottom: controlButtons.top
        }

        SLabel {
            id: titleLabel
            text: editorRoot.title

        }

        SDropdown {

            model: editorRoot.dropDownModel
        }

        SRow {
            // width: parent.width
            SButton {
                span: 3
                text: "-"
                onClicked: {
                    editorRoot.powerDecrement()
                }
            }
            SBadge {
                span: 6
                text:  editorRoot.currentValue
            }

            SButton {
                span: 3
                text: "+"
                onClicked: {
                    editorRoot.powerIncrement()
                }
            }

        }
    }
    SContainer {
        id: controlButtons
        height: editorRoot.height * .1
        // width: editor.width
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        SButton {
            anchors {
                left: parent.left
                bottom: parent.bottom
                top: parent.top
            }
            text: qsTr("OK")

            onClicked: {
                editorRoot.accepted()
            }
        }
        SButton {
            anchors {
                right: parent.right
                bottom: parent.bottom
                top: parent.top
            }
            text: qsTr("Cancel")
            onClicked: {
                editorRoot.rejected()
            }
        }
    }
}
