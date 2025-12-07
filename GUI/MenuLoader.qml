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

        function onRecommendButtonPressed() {
            if (menuLoader.item instanceof MainMenu) { // Проверяем, что загружен именно Text
                menuLoader.source = "qrc:/ProgItemList.qml"
                // menuLoader.item.innerModel = 55
            }
        }
        function onSettingsButtonPressed() {
            if (menuLoader.item instanceof MainMenu) { // Проверяем, что загружен именно Text
                menuLoader.source = "qrc:/SettingsMain.qml"
            }
        }
        function onReturnButtonPressed() {
            if (menuLoader.item instanceof MainMenu)
                ;
            else {
                if (shortcut) {
                    shortcut = false
                    closeMe()
                    menuLoader.item.loadClear = true;
                    menuLoader.source = "qrc:/MainMenu.qml"
                } else {
                    menuLoader.source = "qrc:/MainMenu.qml"
                }
            }
        }
        function onClickedButton(progId) {
            closeMe()
            menuLoader.source = "qrc:/MainMenu.qml"
        }
    }

}
