import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import StratifyLabs.UI 2.0

Rectangle {
    id: containerRoot

    border {
        width: 1
        color: "black"
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Repeater {
            id: repeat
            model: theModel
            function calculateExpandedHeight() {
                var totalFixedHeight = 0
                var expandedCount = 0
                var spacersHeight = (count) * layout.spacing;

                for (var i = 0; i < count; i++) {

                    if (itemAt(i).expanded) {
                        expandedCount++
                    } else {
                        totalFixedHeight += 40
                    }
                }

                return expandedCount > 0 ?
                    (containerRoot.height - (totalFixedHeight + spacersHeight + containerRoot.anchors.margins*2)) / expandedCount : 0
            }
            clip: true

            delegate: Collapsible {
                id: socketRoot
                property var view: ListView.view
                headerHeight: 40
                expanded: true

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: expanded ?
                    repeat.calculateExpandedHeight() :
                    headerHeight

                title: model.socketname

                contentItem: DummySocket {
                    id: soc
                    width: parent.width
                    height: socketRoot.expanded ?
                                repeat.calculateExpandedHeight() :
                                0

                    cutModeName: model.cutmodename
                    coagModeName: model.coagmodename
                    cutModePower: "%1".arg(model.cutmodepower)
                    coagModePower: "%1".arg(model.coagmodepower)
                }

                Connections {
                    target: soc
                    function onCutEditDialogRequest() {
                        editor.title = model.socketname;
                        editor.dropDownModel = model.cutmodesnames;
                        editor.initialValue = soc.cutModePower;
                        // editor.minValue =
                        // editor.maxValue =  100
                        editor.stepSize = 1
                        editor.open()
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
    // SocketEditor {
    Popup {

        id: editor
        modal: true
        focus: true
        padding: 20

        width: 500
        height: 200

        property string title: "Settings"
        property var dropDownModel: ["Option 1", "Option 2", "Option 3"]
        property int initialValue: 50
        property int minValue: 0
        property int maxValue: 100
        property int stepSize: 1

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        // onAccepted: {
        //     theModel.acceptChange(title, currentSelection, currentValue)
        // }
        SDropdown {
            anchors.fill: parent
            model: editor.dropDownModel
        }
    }
}
