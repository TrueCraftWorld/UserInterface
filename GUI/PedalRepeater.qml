import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import BackEnd 1.0

Repeater {
    id: repeatRoot
    required property int containerMargins
    required property int containerHeight
    required property int usedSpacing

    property int collapsedFixedHeight: 85

    signal pedalMenuRequest(int socketId)

    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * repeatRoot.usedSpacing;
        for (var i = 0; i < count; i++) {
            if (!(itemAt(i) instanceof Rectangle)) {
                console.log("oops")
                continue
            }
            if (itemAt(i).state === "expanded") {
                expandedCount++
            } else {
                totalFixedHeight += repeatRoot.collapsedFixedHeight
            }
        }
        return expandedCount > 0 ?
            ( (repeatRoot.containerHeight -
                (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2) )
                    / expandedCount )
            : 0
    }

    function calculateCollapsedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * repeatRoot.usedSpacing;
        for (var i = 0; i < count; i++) {
            if (!(itemAt(i) instanceof Rectangle)) {
                continue
            }
            if (itemAt(i).state === "expanded") {
                expandedCount++
            }
        }
        if (expandedCount > 0) {
            return repeatRoot.collapsedFixedHeight
        } else {
            return (repeatRoot.containerHeight
                    - (spacersHeight + repeatRoot.containerMargins*2) ) / count
        }
    }

    clip: true

    delegate: Rectangle {
        id: delegateSoc
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
        Layout.preferredHeight: state === "expanded" ?
                                    repeatRoot.calculateExpandedHeight() :
                                    repeatRoot.calculateCollapsedHeight()
        color: "transparent"
        state: model.socketdisplaymode
        Pedal {
            id: pedIcon
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 2
            anchors.margins: 0
            pedalStateIdx: model.socketpedal
            socketId: index
        }
        Connections {
            target: pedIcon
            function onPedalMenuRequest() {
                theModel.qmlSetData(pedIcon.socketId, 1, "socketdisplaymode")
                repeatRoot.pedalMenuRequest(pedIcon.socketId)
            }
        }
    }
}
