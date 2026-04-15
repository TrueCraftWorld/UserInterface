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

    signal socketEditorRequest(int socketId, int modeIndex, bool isCoag)

    function calculateCollapsedHeight() {
        if (count <= 0) {
            return 0
        }
        var spacersHeight = count * repeatRoot.usedSpacing
        return (repeatRoot.containerHeight - (spacersHeight + repeatRoot.containerMargins * 2)) / count
    }

    clip: true

    delegate: StatesSocket {
        id: delegateSoc
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: repeatRoot.calculateCollapsedHeight()

        state: "collapsed"
        title: model.socketname
        socketId: index
        socketState: model.socketstatus

        cutInstrumNum:     model.cutmodeinstrnum
        cutMaxPower:       model.cutmodemaxpower
        cutModeId:         model.cutmodeid
        cutModeName:       model.cutmodename
        cutInstrumName:    model.cutmodeinstrname

        coagInstrumNum:    model.coagmodeinstrnum
        coagMaxPower:      model.coagmodemaxpower
        coagModeId:        model.coagmodeid
        coagModeName:      model.coagmodename
        coagInstrumName:   model.coagmodeinstrname

        coagIsEndo:        model.coagmodeisendo
        cutIsEndo:         model.cutmodeisendo

        // Прямой биндинг с защитой от циклов через проверку в onNewPower
        cutModePower: model.cutmodepower
        coagModePower: model.coagmodepower

        Component.onCompleted: {
            
            if (delegateSoc.socketId === (count-1)) {
                //создали последний item - теперь все они доступны для расчёты высоты и
                //надо триггернуть пересчёт.
                //почему этой проблемы нет при первичной прогрузке - хз.
                //почему получилось только через костыль с действительным изменение чего-то,
                //но не через сигналы - хз
                theModel.recalcCollapsed()
            }
        }

        Connections {
            target: delegateSoc
            function onSocketEditorRequest(socketid, iscoag) {
                repeatRoot.socketEditorRequest(socketid,
                                               iscoag ? model.coagmodeindex : model.cutmodeindex,
                                               iscoag)
            }
        }
    }
}

