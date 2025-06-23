import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import StratifyLabs.UI 2.0

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

        SocketView {
            id: repeat
            editor: socEdit
            repeatModel: theModel
            containerMargins: layout.anchors.margins
            containerHeight: layout.height
            usedSpacing: layout.spacing
        }

        Item {
            Layout.fillHeight: true
        }
    }
    SocketEditor {
        id: socEdit
        anchors.centerIn: repeat
        parent: repeat
        height: repeat.height * 0.75
        width: repeat.width * 0.75
    }

}
