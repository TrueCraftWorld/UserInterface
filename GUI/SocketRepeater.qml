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

    signal modeDialogRequest(int socketId, int modeIndex, bool isCoag)
    signal instrumDialogRequest(int socketId, int modeIndex, bool isCoag)

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

    function calculateCollapsedHeight() {
        var totalFixedHeight = 0
        var expandedCount = 0
        var spacersHeight = (count) * repeatRoot.usedSpacing;
        for (var i = 0; i < count; i++) {
            if (itemAt(i).state === "expanded") {
                expandedCount++
            }
        }
        if (expandedCount > 0) {
            return 60
        } else {
            return (repeatRoot.containerHeight - (spacersHeight + repeatRoot.containerMargins*2))/count
        }
    }

    clip: true

    delegate: StatesSocket {
        id: delegateSoc
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: state === "expanded" ?
                                    repeatRoot.calculateExpandedHeight() :
                                    repeatRoot.calculateCollapsedHeight()
        title: model.socketname
        socketId: index

        cutInstrumId:      model.cutmodeinstrid
        cutMaxPower:       model.cutmodemaxpower
        cutModePower:      model.cutmodepower
        cutModeId:      model.cutmodeid
        cutModeName:       model.cutmodename
        cutInstrumName:    model.cutmodeinstrname

        coagInstrumId:     model.coagmodeinstrid
        coagMaxPower:      model.coagmodemaxpower
        coagModePower:     model.coagmodepower
        coagModeId:     model.coagmodeid
        coagModeName:      model.coagmodename
        coagInstrumName:   model.coagmodeinstrname

        state:              model.socketdisplaymode

        Connections {
            target: delegateSoc
            function onInstrumEditDialogRequest(socketid, iscoag) {

                repeatRoot.instrumDialogRequest(socketid,
                                                iscoag ? model.coagmodeindex : model.cutmodeindex,
                                                iscoag)
                console.log("prosim dislog instrumenta ", iscoag)
            }
            function onModeEditDialogRequest(socketid, iscoag) {

                repeatRoot.modeDialogRequest(socketid,
                                            iscoag ? model.coagmodeindex : model.cutmodeindex,
                                            iscoag)
                console.log("prosim dialog rezhima")
            }
        }
        Connections {
            target: delegateSoc
            function onNewPower(socketid, pwr, iscoag) {
                theModel.qmlSetData(index,
                                    pwr,
                                    (iscoag ? "coagmodepower" : "cutmodepower"))
            }
        }
        Connections {
            target: delegateSoc
            function onSocketCollapseRequest() {
                theModel.qmlSetData(index, 0, "socketdisplaymode")
            }
        }
        Connections {
            target: delegateSoc
            function onSocketExpandRequest() {
                theModel.qmlSetData(index, 1, "socketdisplaymode")
            }
        }
    }
}

