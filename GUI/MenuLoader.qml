import QtQuick 2.15

Item {
    id: menuLoadRoot

    property alias source : menuLoader.source
    property bool shortcut : false
    property alias item : menuLoader.item

    signal returnButtonPressed()
    signal closeMe()
    Loader {
        id: menuLoader
        anchors.fill: parent
        source: "qrc:/MainMenu.qml"
        
        onItemChanged: {
            // Отключаем все предыдущие подключения
            if (menuLoader.item) {
                try {
                    if (menuLoader.item.recommendButtonPressed) {
                        menuLoader.item.recommendButtonPressed.disconnect()
                    }
                    if (menuLoader.item.settingsButtonPressed) {
                        menuLoader.item.settingsButtonPressed.disconnect()
                    }
                    if (menuLoader.item.returnButtonPressed) {
                        menuLoader.item.returnButtonPressed.disconnect()
                    }
                    if (menuLoader.item.clickedButton) {
                        menuLoader.item.clickedButton.disconnect()
                    }
                } catch(e) {
                    // Игнорируем ошибки отключения
                }
                
                // Подключаемся к сигналам, которые есть во всех компонентах
                try {
                    if (menuLoader.item.recommendButtonPressed) {
                        menuLoader.item.recommendButtonPressed.connect(function() {
                menuLoader.source = "qrc:/ProgItemList.qml"
                        })
            }
                    if (menuLoader.item.settingsButtonPressed) {
                        menuLoader.item.settingsButtonPressed.connect(function() {
                menuLoader.source = "qrc:/SettingsMain.qml"
                        })
            }
                    if (menuLoader.item.secretKeysButtonPressed) {
                        menuLoader.item.secretKeysButtonPressed.connect(function() {
                menuLoader.source = "qrc:/SecretKeysWindow.qml"
                        })
            }
                    if (menuLoader.item.exitButtonPressed) {
                        menuLoader.item.exitButtonPressed.connect(function() {
                            closeMe()
                        })
                    }
                } catch(e) {
                    // Игнорируем ошибки подключения
                }
                
                // Подключаемся к сигналам, которых нет в MainMenu
                if (menuLoader.source !== "qrc:/MainMenu.qml") {
                    try {
                        if (menuLoader.item.returnButtonPressed) {
                            menuLoader.item.returnButtonPressed.connect(function() {
                if (shortcut) {
                    shortcut = false
                    closeMe()
                                    if (menuLoader.item && menuLoader.item.loadClear !== undefined) {
                    menuLoader.item.loadClear = true;
                                    }
                    menuLoader.source = "qrc:/MainMenu.qml"
                } else {
                    menuLoader.source = "qrc:/MainMenu.qml"
                }
                            })
        }
                        if (menuLoader.item.clickedButton) {
                            menuLoader.item.clickedButton.connect(function(progId) {
            closeMe()
            menuLoader.source = "qrc:/MainMenu.qml"
                            })
                        }
                    } catch(e) {
                        // Игнорируем ошибки подключения
                    }
                }
            }
        }
    }

}
