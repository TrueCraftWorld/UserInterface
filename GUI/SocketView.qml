import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import BackEnd 1.0


Repeater {
    id: repeatRoot

    required property int containerMargins
    required property int containerHeight
    required property int usedSpacing

    signal socketDialogRequest(int socketId, int modeIndex, bool isCoag)

    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * repeatRoot.usedSpacing;

        for (var i = 0; i < count; i++) {
            if (itemAt(i).expanded) {
                expandedCount++
            } else {
                totalFixedHeight += 40
            }
        }

        return expandedCount > 0 ?
            (repeatRoot.containerHeight -
                (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2))
                    / expandedCount
            : 0
    }

    clip: true

    delegate: Collapsible {
        id: socketRoot
        headerHeight: 40
        expanded: model.socketenabled
        expansionAllowed: model.socketallowed

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: socketRoot.expanded ?
                                    repeatRoot.calculateExpandedHeight() :
                                    headerHeight
        title: model.socketname

        contentItem: DummySocket {
            id: soc
            width: parent.width
            height: socketRoot.expanded ?
                        repeatRoot.calculateExpandedHeight() :
                        0

            cutModeName: model.cutmodename
            coagModeName: model.coagmodename
            cutModePower: model.cutmodepower
            coagModePower: model.coagmodepower
            cutInstrumName: model.cutmodeinstrname
            coagInstrumName: model.coagmodeinstrname
            coagInstrumNum: model.coagmodeinstrnum
            cutInstrumNum: model.cutmodeinstrnum
            socketId: model.socketpolarity
            socketDispMode: model.socketdisplaymode
        }
        Connections {
            target: soc
            function onCutEditDialogRequest() {
                repeatRoot.socketDialogRequest((soc.socketId - 1), soc.cutModeIndex, false)
            }
            function onCoagEditDialogRequest() {
                repeatRoot.socketDialogRequest((soc.socketId - 1), soc.coagModeIndex, true)
            }
        }

    }
}

