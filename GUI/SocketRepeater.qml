import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
// import BackEnd 1.0


Repeater {
    id: repeatRoot

    required property int containerMargins
    required property int containerHeight
    required property int usedSpacing

    signal socketDialogRequest(int dialogType, int socketId, bool isCoag)

    function calculateExpandedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * repeatRoot.usedSpacing;

        for (var i = 0; i < count; i++) {
            if (itemAt(i).state === "expanded") {
                expandedCount++
            } else {
                totalFixedHeight += 60
            }
        }

        return expandedCount > 0 ?
            (repeatRoot.containerHeight -
                (totalFixedHeight + spacersHeight + repeatRoot.containerMargins*2))
                    / expandedCount
            : 0
    }

    clip: true

    delegate: StatesSocket {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: state === "expanded" ?
                                    repeatRoot.calculateExpandedHeight() :
                                    60
        // title: "WAGU " + index
        title: model.socketname
        socketId: index + 1

        cutInstrumId:      model.cutmodeinstrid
        cutMaxPower:       model.cutmodemaxpower
        cutModePower:      model.cutmodepower
        cutModeName:       model.cutmodename
        cutInstrumName:    model.cutmodeinstrname

        coagInstrumId:     model.coagmodeinstrid
        coagMaxPower:      model.coagmodemaxpower
        coagModePower:     model.coagmodepower
        coagModeName:      model.coagmodename
        coagInstrumName:   model.coagmodeinstrname

        state:             model.socketdisplaymode

        onModeEditDialogRequest: console.log("prosim dialog rezhima")
        onInstrumEditDialogRequest: console.log("prosim dislog instrumenta")
    }
}

