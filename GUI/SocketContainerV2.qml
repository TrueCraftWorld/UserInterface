import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property var innerModel
    // anchors.fill: parent
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        SocketRepeater {
            id: repeat
            model: innerModel
            containerMargins: layout.anchors.margins
            containerHeight: layout.height
            usedSpacing: layout.spacing
        }
        Item {
            Layout.fillHeight: true
        }
    }

    InstrumEditor {
        id: dialog
    }

    Connections {
        target: repeat
        function onInstrumDialogRequest(soc, mod, iscoag) {
            dialog.socId = soc
            dialog.modeIndex = mod
            dialog.isCoag = iscoag
            dialog.open()
        }
    }
}

