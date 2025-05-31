import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

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
            model: 4
            function calculateExpandedHeight() {
                var totalFixedHeight = 0
                var expandedCount = 0
                var spacersHeight = (count*1) * layout.spacing;

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

            Collapsible {
                id: section
                headerHeight: 40
                Layout.fillWidth: true
                // Layout.fillHeight: expanded
                Layout.preferredHeight: expanded ?
                    repeat.calculateExpandedHeight() :
                    headerHeight
                Layout.alignment: Qt.AlignTop

                title: "socket " + (index + 1)
                expanded: true

                contentItem: DummySocket {
                    width: parent.width
                    height: section.expanded ?
                                repeat.calculateExpandedHeight() :
                                0

                    cutModeName: "CUT"
                    coagModeName: "FORCE"
                    cutModePower: "150"
                    coagModePower: "300"

                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
