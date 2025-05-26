import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200

    // Property to control the state
    property bool isExpanded: false

    // Name property
    property string socketName: "Collapsible"

    // Fixed height for collapsed state
    property int collapsedHeight: 40

    default property alias content: contentContainer.children

    // State definitions
    states: [
        State {
            name: "expanded"
            when: root.isExpanded
            PropertyChanges {
                target: container
                // height: contentContainer.childrenRect.height + nameLabel.height + 20 // 20 for padding
                color: "gray"
            }
            PropertyChanges {
                target: nameLabel
                color: "white"
            }
            PropertyChanges {
                target: contentContainer
                visible: true
            }
        },
        State {
            name: "collapsed"
            when: !root.isExpanded
            PropertyChanges {
                target: container
                height: root.collapsedHeight
                color: "darkgray"
            }
            PropertyChanges {
                target: nameLabel
                color: "black"
            }
            PropertyChanges {
                target: contentContainer
                visible: false
            }
        }
    ]

    // Transitions between states
    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"
            NumberAnimation { properties: "height"; duration: 200 }
            ColorAnimation { duration: 200 }
        },
        Transition {
            from: "expanded"
            to: "collapsed"
            NumberAnimation { properties: "height"; duration: 200 }
            ColorAnimation { duration: 200 }
        }
    ]

    // Main container rectangle
    Rectangle {
        id: container
        width: parent.width
        color: "darkgray"
        height: root.collapsedHeight
        clip: true

        // Name label
        Label {
            id: nameLabel
            text: root.socketName
            font.bold: true
            color: "black"
            anchors {
                top: parent.top
                left: parent.left
                margins: 10
            }
        }

        // Content container (for inserted content)
        Item {
            id: contentContainer
            anchors {
                top: nameLabel.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: 2
                bottomMargin: 2
            }
            visible: false

            // Default content (if none is provided)
            Text {
                text: "Insert content here"
                color: "white"
                width: parent.width
                wrapMode: Text.WordWrap
                visible: contentContainer.children.length === 1 // Only show if this is the only child
            }
        }

        // Toggle button
        Button {
            id: toggleButton
            text: root.isExpanded ? "▲" : "▼"
            width: 30
            height: 30
            anchors {
                right: parent.right
                verticalCenter: nameLabel.verticalCenter
                margins: 5
            }
            onClicked: root.isExpanded = !root.isExpanded
            background: Rectangle {
                color: "transparent"
                border.color: nameLabel.color
                radius: 3
            }
        }
    }
}
