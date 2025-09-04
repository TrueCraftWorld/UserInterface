import QtQuick 2.15

Item {
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
                menuLoader.source = "ProgItemList.qml"
                // menuLoader.item.innerModel = 55
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
        function onClickedButton(progId) {
            ProgHandle.loadRecommendedProg(progId + 1)
            closeMe()
            menuLoader.source = "MainMenu.qml"
        }
    }

}
