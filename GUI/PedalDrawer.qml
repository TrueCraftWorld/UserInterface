import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import BackEnd 1.0

Drawer {
//с одной стороный многовато из-за необходимости репитер городить ради доступа к индексам
//с другой строны -
    id: repeatRoot

    property int socketId: 0
    property var innerModel
    property int usedSpacing: 10

    property int containerMargins: layout.anchors.margins
    property int containerHeight:  layout.height - layout.spacing - titleItem.height
    // required property int usedSpacing

    property int collapsedFixedHeight: 85

    signal pedalMenuRequest()

    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (localRepeater.count) * repeatRoot.usedSpacing;
        for (var i = 0; i < localRepeater.count; i++) {
            if (!(localRepeater.itemAt(i) instanceof Rectangle)) {
                console.log("oops")
                continue
            }
            if (localRepeater.itemAt(i).state === "expanded") {
                expandedCount++
            } else {
                totalFixedHeight += repeatRoot.collapsedFixedHeight
            }
        }
        return expandedCount > 0 ?
            (repeatRoot.containerHeight -
                (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2))
                    / expandedCount
            : 0
    }

    function calculateCollapsedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (localRepeater.count) * repeatRoot.usedSpacing;
        // console.log(count, "col")
        for (var i = 0; i < localRepeater.count; i++) {
            if (!(localRepeater.itemAt(i) instanceof Rectangle)) {
                continue
            }
            if (localRepeater.itemAt(i).state === "expanded") {
                expandedCount++
            }
        }
        if (expandedCount > 0) {
            return repeatRoot.collapsedFixedHeight
        } else {
            return (repeatRoot.containerHeight - (spacersHeight + repeatRoot.containerMargins*2))
            /(localRepeater.count)
        }
    }


    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        spacing: 10
        Rectangle {
            id: titleItem
            height: 100
            Layout.fillWidth: true
            color: "transparent"
            Label {
                anchors.fill: parent
                text: "Выбор источника активации"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
                font.bold: true
                font.pixelSize: 18
                color: "white"
            }
        }
        Repeater {
            id: localRepeater
            model: innerModel
            clip: true
            delegate: Rectangle {
                id: rect
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: state === "expanded" ?
                                        repeatRoot.calculateExpandedHeight() :
                                        repeatRoot.calculateCollapsedHeight()

                property string state: model.socketdisplaymode
                color: "transparent"
                // property int socketId: index
                PedalEditor {
                    id: pedEditor
                    visible: rect.state === "expanded"
                    shownPedalsArray: model.socketallowedpedal
                    selectedPed: model.socketpedal
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                }
                Connections {
                    target: pedEditor
                    function onPedSelected (pedal) {
                        theModel.qmlSetData(socketId, pedal, "socketpedal");
                        repeatRoot.close()
                    }
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
