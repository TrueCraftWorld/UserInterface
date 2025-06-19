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

            Collapsible {
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
                // anchors {
                //     horizontalCenter: parent.horizontalCenter
                //     topMargin: 15
                //     bottomMargin: 5
                // }

                contentItem: DummySocket {
                    width: parent.width
                    height: socketRoot.expanded ?
                                repeat.calculateExpandedHeight() :
                                0

                    cutModeName: model.cutmodename
                    coagModeName: model.coagmodename
                    cutModePower: "%1".arg(model.cutmodepower)
                    coagModePower: "%1".arg(model.coagmodepower)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
