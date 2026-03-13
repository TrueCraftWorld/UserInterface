import QtQuick 2.15

Item {
    id: menuLoadRoot

    property alias source : menuLoader.source
    property bool shortcut : false
    property alias item : menuLoader.item
    readonly property var loader : menuLoader

    signal returnButtonPressed()
    signal closeMe()
    signal programSelected(string scopeName, string progName)
    signal freeSettingsModeActivated()
    signal deleteAllUserProgsRequested()
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
                    if (menuLoader.item.userButtonPressed) {
                        menuLoader.item.userButtonPressed.disconnect()
                    }
                } catch(e) {
                    // Игнорируем ошибки отключения
                }
                
                // Подключаемся к сигналам, которые есть во всех компонентах
                try {
                    if (menuLoader.item.recommendButtonPressed) {
                        menuLoader.item.recommendButtonPressed.connect(function() {

                             menuLoader.setSource("qrc:/ProgItemList.qml", {"recommended" : true})
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
                    if (menuLoader.item.userButtonPressed) {
                        menuLoader.item.userButtonPressed.connect(function() {
                            menuLoader.setSource("qrc:/ProgItemList.qml", {"recommended" : false})
                        })
                    }
                    if (menuLoader.item.freeSettingsButtonPressed) {
                        menuLoader.item.freeSettingsButtonPressed.connect(function() {
                            freeSettingsModeActivated()
                            closeMe()
                        })
                    }
                    if (menuLoader.item.serviceMenuButtonPressed) {
                        menuLoader.item.serviceMenuButtonPressed.connect(function() {
                            menuLoader.source = "qrc:/ServiceMenu.qml"
                        })
                    }
                    if (menuLoader.item.returnButtonPressed) {
                        menuLoader.item.returnButtonPressed.connect(function() {
                            returnButtonPressed()
                            // closeMe()
                        })
                    }
                    if (menuLoader.item.deleteAllUserProgsRequested) {
                        menuLoader.item.deleteAllUserProgsRequested.connect(function() {
                            deleteAllUserProgsRequested()
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
                        if (menuLoader.item.programSelected) {
                            menuLoader.item.programSelected.connect(function(scopeName, progName) {
                                menuLoadRoot.programSelected(scopeName, progName)
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
