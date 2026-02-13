import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: fontTestRoot
    width: 800
    height: 600
    color: "white"
    
    property var testFonts: [
        "Noto Color Emoji",
        "Apple Color Emoji", 
        "Segoe UI Emoji",
        "Symbola",
        "DejaVu Sans",
        "sans-serif"
    ]
    
    property var testSymbols: ["⏮", "⏸", "▶", "⏹", "⏭", "🔉", "🔊", "✕", "☰"]
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        
        Column {
            spacing: 20
            width: parent.width
            
            Text {
                text: "Тест отображения эмодзи в разных шрифтах"
                font.pixelSize: 24
                font.bold: true
            }
            
            Repeater {
                model: fontTestRoot.testFonts
                
                Rectangle {
                    width: parent.width
                    height: 200
                    border.color: "gray"
                    border.width: 1
                    color: "lightgray"
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Text {
                            text: "Шрифт: " + modelData
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Row {
                            spacing: 15
                            
                            Repeater {
                                model: fontTestRoot.testSymbols
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    border.color: "black"
                                    border.width: 1
                                    color: "white"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 40
                                        font.family: parent.parent.parent.parent.parent.modelData
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "Строка: " + fontTestRoot.testSymbols.join(" ")
                            font.pixelSize: 30
                            font.family: modelData
                        }
                    }
                }
            }
        }
    }
}

