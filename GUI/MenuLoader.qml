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
    }
    Connections {
        target: menuLoader.item // Подключаемся к сигналам загруженного компонента
        enabled: menuLoader.item !== null
        ignoreUnknownSignals: true

        function onRecommendButtonPressed() {
            menuLoader.source = "qrc:/ProgItemList.qml"
        }
        
        function onSettingsButtonPressed() {
            menuLoader.source = "qrc:/SettingsMain.qml"
        }
        
        function onUserButtonPressed() {
            menuLoader.source = "qrc:/UserProgsSelector.qml"
        }
        
        function onExitButtonPressed() {
            closeMe()
        }

        function onReturnButtonPressed() {
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
        }
        
        function onClickedButton(progId) {
            closeMe()
            menuLoader.source = "qrc:/MainMenu.qml"
        }
    }

}
