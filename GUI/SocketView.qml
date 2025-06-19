import QtQuick 2.15
import QtQuick.Layouts 1.15
// import StratifyLabs.UI 2.0
import BackEnd 1.0

Repeater {

    id: socketViewRoot
    property int spacing

    function calculateExpandedHeight() {
        console.log("tryCalculate")
        var totalFixedHeight = 0
        var expandedCount = 0

        var spacersHeight = (model.count) * layout.spacing;

        for (var i = 0; i < model.count; i++) {
        // for (var i = 0; i < 4; i++) {

            if (itemAt(i).expanded) {
                expandedCount++
            } else {
                totalFixedHeight += 40
            }
        }

        return expandedCount > 0 ?
            ((socketViewRoot.height
                    - (totalFixedHeight + spacersHeight + socketViewRoot.anchors.margins*2))
                    / expandedCount )
            : 0
    }

    spacing: 5
    width: parent.width

    clip: false

    Collapsible {
        id: socketRoot
        property var view: ListView.view
        headerHeight: 40
        expanded: true

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: expanded ?
            socketViewRoot.calculateExpandedHeight() :
            headerHeight

        title: model.socketname

        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: 15
            bottomMargin: 5
        }

        contentItem: DummySocket {
            width: parent.width
            height: socketRoot.expanded ?
                        socketViewRoot.calculateExpandedHeight() :
                        0

            cutModeName: model.cutmodename
            coagModeName: model.coagmodename
            cutModePower: "%1".arg(model.cutmodepower)
            coagModePower: "%1".arg(model.coagmodepower)
        }
    }
}
