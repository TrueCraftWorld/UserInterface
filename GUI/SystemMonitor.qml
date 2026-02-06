import QtQuick 2.15
import QtQuick.Controls 2.15

// Компонент мониторинга системы (CPU и температура)
// Показывает информацию в реальном времени
Rectangle {
    id: systemInfoPanel
    width: 100
    height: 55
    color: "#80000000"
    radius: 8
    border.color: "#4CAF50"
    border.width: 2
    
    // Свойство для управления видимостью
    property bool monitoringActive: false
    
    Component.onCompleted: {
        if (monitoringActive && typeof sysMonitor !== 'undefined') {
            sysMonitor.start()
        }
    }
    
    Component.onDestruction: {
        if (typeof sysMonitor !== 'undefined') {
            sysMonitor.stop()
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        
        // Загрузка CPU
        Row {
            width: parent.width
            spacing: 8
            
            Text {
                text: "CPU:"
                color: "#4CAF50"
                font.pixelSize: 14
                font.bold: true
//                width: 50
            }
            
            Text {
                text: (typeof sysMonitor !== 'undefined' ? sysMonitor.cpuUsage.toFixed(1) : "0.0") + "%"
                color: "white"
                font.pixelSize: 14
                font.bold: true
            }
            
//            // Индикатор загрузки
//            Rectangle {
//                width: 60
//                height: 10
//                anchors.verticalCenter: parent.verticalCenter
//                color: "#333333"
//                radius: 5
//                border.color: "#666666"
//                border.width: 1
                
//                Rectangle {
//                    anchors.left: parent.left
//                    anchors.top: parent.top
//                    anchors.bottom: parent.bottom
//                    width: parent.width * Math.min((typeof sysMonitor !== 'undefined' ? sysMonitor.cpuUsage : 0) / 100, 1.0)
//                    radius: 5
//                    color: {
//                        var usage = typeof sysMonitor !== 'undefined' ? sysMonitor.cpuUsage : 0
//                        if (usage < 50) return "#4CAF50"
//                        else if (usage < 80) return "#FFC107"
//                        else return "#F44336"
//                    }
//                }
//            }
        }
        
        // Температура
        Row {
            width: parent.width
            spacing: 8
            
            Text {
                text: "t:"
                color: "#2196F3"
                font.pixelSize: 14
                font.bold: true
//                width: 50
            }
            
            Text {
                text: (typeof sysMonitor !== 'undefined' ? sysMonitor.temperature.toFixed(1) : "0.0") + "°C"
                color: {
                    var temp = typeof sysMonitor !== 'undefined' ? sysMonitor.temperature : 0
                    if (temp < 60) return "white"
                    else if (temp < 80) return "#FFC107"
                    else return "#F44336"
                }
                font.pixelSize: 14
                font.bold: true
            }
            
//            // Температурный индикатор
//            Text {
//                text: {
//                    var temp = typeof sysMonitor !== 'undefined' ? sysMonitor.temperature : 0
//                    if (temp < 60) return "❄"
//                    else if (temp < 80) return "☀"
//                    else return "🔥"
//                }
//                color: "white"
//                font.pixelSize: 16
//                font.family: "Noto Color Emoji, Apple Color Emoji, Segoe UI Emoji, Symbola, DejaVu Sans, sans-serif"
//                anchors.verticalCenter: parent.verticalCenter
//            }
        }
    }
}
