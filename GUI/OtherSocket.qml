import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: socketRoot
    property string cutModeName
    property string coagModeName
    property int cutModePower
    property int coagModePower
    property int socketId
    property int cutInstrumId
    property int coagInstrumId
    property string cutInstrumName: qsTr("не выбран")
    property string coagInstrumName: qsTr("не выбран")
    property bool collapsed
    property string socketName

    signal cutModeEditDialogRequest()
    signal coagModeEditDialogRequest()
    signal cutInstrumEditDialogRequest()
    signal coagInstrumDialogRequest()

    HalfSocket {
        id: cutMain
        anchors.left: parent.left
    }
    HalfSocket {
        id: coagMain
        anchors.right: parent.right
    }
    Rectangle {
        id: socketName
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            anchors.fill: parent
            text: socketName
        }
    }

    states: [
        State {
            name: "collapsed"
            PropertyChanges { target: cutMain; state: "collapsed" }
            PropertyChanges { target: coagMain; state: "collapsed" }
            PropertyChanges { target: cutMain; width: (parent.width - socketName.width)/2}
            PropertyChanges { target: coagMain; width: (parent.width - socketName.width)/2}
            AnchorChanges { target: power; anchors.left: undefined}
            AnchorChanges { target: power; anchors.right: undefined}
            AnchorChanges { target: mode; anchors.horizontalCenter: parent.horizontalCenter}
            AnchorChanges { target: mode; anchors.left: undefined}
            AnchorChanges { target: mode; anchors.right: undefined}
        },
        State {
            name: "expanded"
            PropertyChanges { target: cutMain; state: "expanded" }
            PropertyChanges { target: coagMain; state: "expanded" }
            PropertyChanges { target: cutMain; width: (parent.width)/2}
            PropertyChanges { target: coagMain; width: (parent.width)/2}
            AnchorChanges { target: power; anchors.horizontalCenter: undefined}
            AnchorChanges { target: power; anchors.left: isCoag ? parent.right : undefined}
            AnchorChanges { target: power; anchors.right: isCoag ? undefined : parent.left}
            AnchorChanges { target: mode; anchors.horizontalCenter: undefined}
            AnchorChanges { target: mode; anchors.right: isCoag ? parent.right : undefined}
            AnchorChanges { target: mode; anchors.left: isCoag ? undefined : parent.left}
        }
    ]
}
