import QtQuick 2.15
import QtQuick.Layouts 1.15
// import com.melije.pulltorefresh 2.0
import StratifyLabs.UI 2.0
import BackEnd 1.0

ListView {
    id: socketView
    width: parent.width

    model: SocControl.getSocketModel
    // property var passwordPopUp: null
    // signal networkChosen(ssid: string, passwd: string)
    // signal updateMe




    layoutDirection: Qt.LeftToRight
    verticalLayoutDirection: ListView.TopToBottom
    displayMarginBeginning: 15
    displayMarginEnd: 15
    spacing: 5

    clip: false

    // header: Item { width: parent.width; height: 15 }
    // footer: Item { width: parent.width; height: 15 }

    delegate: Collapsible {
        id: socketRoot
        property var view: ListView.view
        // property bool isCurrent: ListView.isCurrentItem
        headerHeight: 40
        Layout.fillWidth: true
        // Layout.fillHeight: expanded
        Layout.preferredHeight: expanded ?
            repeat.calculateExpandedHeight() :
            headerHeight
        Layout.alignment: Qt.AlignTop

        title: socketname
        expanded: true

        // style: isconnected ? "btn-success lg":"btn-outline-secondary lg"
        anchors
        {
            horizontalCenter: parent.horizontalCenter
            topMargin: 15
            bottomMargin: 5
        }

        contentItem: DummySocket {
            width: parent.width
            height: section.expanded ?
                        repeat.calculateExpandedHeight() :
                        0

            cutModeName: cutmodename
            coagModeName: coagmodename
            cutModePower: "%1".arg(cutmodepower)
            coagModePower: "%1".arg(coagmodepower)

        }
    }

    // PullToRefreshHandler
    // {
    //     onPullDownRelease:
    //     {
    //        updateMe() // Add your handling code here:
    //     }
    // }
}
