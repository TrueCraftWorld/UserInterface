import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

import StratifyLabs.UI 2.0

Window {
    id: container
    width: 1280
    height: 800
    visible: true
    title: qsTr("Hello World")

    // Rectangle {
    //     id: container
    //     width: 400
    //     height: 600
    //     color: "#f5f5f5"
    //     border.color: "#cccccc"
    //     border.width: 1

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5

            Repeater {
                id: repeat
                model: 4
                function calculateExpandedHeight() {
                    var totalFixedHeight = 0
                    var expandedCount = 0

                    // Calculate total fixed height and count expanded items
                    for (var i = 0; i < count; i++) {

                        if (itemAt(i).expanded) {
                            expandedCount++
                        } else {
                            totalFixedHeight += 40
                        }
                    }

                    // Add spacing (n-1 spacings for n items)
                    // totalFixedHeight += (children.length - 1) * spacing

                    return expandedCount > 0 ?
                        (container.height - totalFixedHeight) / expandedCount : 0
                }

                Collapsible {
                    id: section
                    property int headerHeight: 40
                    Layout.fillWidth: true
                    Layout.fillHeight: expanded
                    Layout.preferredHeight: expanded ?
                        (container.height - layout.anchors.margins*2 - (layout.spacing*3) - (headerHeight*4)) / 4 + headerHeight :
                        headerHeight

                    title: "Section " + (index + 1)
                    expanded: false
                    contentItem: Rectangle {
                        width: parent.width

                        height: section.expanded ?
                                    repeat.calculateExpandedHeight() :
                                    0
                        // Layout.fillHeight: expanded
                        // height: section.expanded ?
                        //     (container.height - layout.anchors.margins*2 - (layout.spacing*3) - (section.headerHeight*4)) / 4 :
                        //     0
                        color: "green"
                        border.color: "blue"
                        border.width: 1
                    }

                    // onExpandedChanged: {
                    //     contentItem.height = section.expanded ?
                    //                 repeat.calculateExpandedHeight() :
                    //                 0
                    // }
                }
            }
        }
    // }

    // ColumnLayout {
    //     id: workingArea
    //     anchors.fill: parent
    //     spacing: 5
    //     function calculateExpandedHeight() {
    //         var totalFixedHeight = 0
    //         var expandedCount = 0

    //         // Calculate total fixed height and count expanded items
    //         for (var i = 0; i < children.length; i++) {
    //             var child = children[i]
    //             if (child.expanded) {
    //                 expandedCount++
    //             } else {
    //                 totalFixedHeight += child.collapsedHeight
    //             }
    //         }

    //         // Add spacing (n-1 spacings for n items)
    //         totalFixedHeight += (children.length - 1) * spacing

    //         return expandedCount > 0 ?
    //             (height - totalFixedHeight) / expandedCount : 0
    //     }
    //     Collapsible {
    //         // anchors.fill: parent
    //         anchors.margins: 25
    //         // expanded: false
    //         Layout.fillWidth: true
    //         // Layout.preferredHeight: collapsedHeight + (expanded ? parent.calculateExpandedHeight() : 0)
    //         Layout.fillHeight: expanded
    //         Layout.alignment: Qt.AlignTop

    //         contentItem: DummySocket {
    //             // anchors.fill: parent
    //             height: parent.expanded ? parent.calculateExpandedHeight() : parent.collapsedHeight
    //             width: parent.width
    //             anchors.margins: 100
    //             coagModeName: "FORCE"
    //             coagModePower: "80"
    //             cutModeName: "CUT"
    //             cutModePower: "300"
    //         }
    //     }
    //     Collapsible {
    //         // anchors.fill: parent
    //         anchors.margins: 25
    //         // expanded: false
    //         Layout.fillWidth: true
    //         // Layout.preferredHeight: collapsedHeight + (expanded ? parent.calculateExpandedHeight() : 0)
    //         Layout.fillHeight: expanded
    //         Layout.alignment: Qt.AlignTop

    //         contentItem: DummySocket {
    //             // anchors.fill: parent
    //             height: parent.expanded ? parent.calculateExpandedHeight() : parent.collapsedHeight
    //             width: parent.width
    //             // anchors.margins: 100
    //             coagModeName: "FORCE"
    //             coagModePower: "80"
    //             cutModeName: "CUT"
    //             cutModePower: "300"
    //         }
    //     }
    //     Collapsible {
    //         // anchors.fill: parent
    //         anchors.margins: 25
    //         // expanded: false
    //         Layout.fillWidth: true
    //         // Layout.preferredHeight: collapsedHeight + (expanded ? parent.calculateExpandedHeight() : 0)
    //         Layout.fillHeight: expanded
    //         Layout.alignment: Qt.AlignTop

    //         contentItem: DummySocket {
    //             // anchors.fill: parent
    //             height: parent.expanded ? parent.calculateExpandedHeight() : parent.collapsedHeight
    //             width: parent.width
    //             // anchors.margins: 100
    //             coagModeName: "FORCE"
    //             coagModePower: "80"
    //             cutModeName: "CUT"
    //             cutModePower: "300"
    //         }
    //     }
    //     Collapsible {
    //         // anchors.fill: parent
    //         anchors.margins: 25
    //         // expanded: false
    //         Layout.fillWidth: true
    //         // Layout.preferredHeight:collapsedHeight + (expanded ? parent.calculateExpandedHeight() : 0)
    //         Layout.fillHeight: expanded
    //         Layout.alignment: Qt.AlignTop

    //         contentItem: DummySocket {
    //             // anchors.fill: parent
    //             height: parent.expanded ? parent.calculateExpandedHeight() : parent.collapsedHeight
    //             width: parent.width
    //             anchors.margins: 100
    //             coagModeName: "FORCE"
    //             coagModePower: "80"
    //             cutModeName: "CUT"
    //             cutModePower: "300"
    //         }
    //     }
    // }



}
