import QtQuick 2.15
import QtQuick.Layouts 1.15
// import StratifyLabs.UI 2.0
import BackEnd 1.0

Repeater {
    id: repeat

    required property int containerMargins
    required property int containerHeight
    required property int usedSpacing
    // required property var view
    // model: theModel
    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * usedSpacing;

        for (var i = 0; i < count; i++) {
            if (itemAt(i).expanded) {
                expandedCount++
            } else {
                totalFixedHeight += 40
            }
        }

        return expandedCount > 0 ?
            (containerHeight - (totalFixedHeight + spacersHeight + containerMargins*2)) / expandedCount : 0
    }
    clip: true

    Collapsible {
        id: socketRoot
        // property var view: ListView.view
        headerHeight: 40
        expanded: true

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: expanded ?
            repeat.calculateExpandedHeight() :
            headerHeight

        title: model.socketname

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
