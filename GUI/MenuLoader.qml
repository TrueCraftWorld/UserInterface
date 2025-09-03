import QtQuick 2.15

Item {
    signal returnButtonPressed()
    Loader {
        id: menuLoader
        anchors.fill: parent
        source: "qrc:/MainMenu.qml"
    }
    Connections {
        target: menuLoader.item // Подключаемся к сигналам загруженного компонента

        function onRecommendButtonPressed() {
            if (menuLoader.item instanceof MainMenu) { // Проверяем, что загружен именно Text
                menuLoader.source = "ProgItemList.qml"
            }
        }
        function onSettingsButtonPressed() {
            if (menuLoader.item instanceof MainMenu) { // Проверяем, что загружен именно Text
                menuLoader.source = "SettingsMain.qml"
            }
        }
        function onReturnButtonPressed() {
            if (menuLoader.item instanceof MainMenu)
                ;
            else
                menuLoader.source = "MainMenu.qml"
        }
    }

}
