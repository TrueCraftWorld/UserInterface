import QtQuick 2.15

Rectangle {
    property color startColor
    property color stopColor
    property string beamColor
    property bool bright: true
    color: "transparent"

    // Слой 1: Базовый градиент (зависит от режима)
    Rectangle {
        id: baseLayer
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: startColor
            }
            GradientStop {
                position: 1.0
                color: stopColor
            }
        }
    }

    // Слой 2: Пульсирующий цветовой слой
    Rectangle {
        id: pulseLayer
        anchors.fill: parent
        opacity: 0.5

        property real pulsePhase: 0.0

        // Вычисляем цвета на основе pulsePhase и isCoag
        property color topColor: {
            var intensity = 0.4 + pulsePhase * 0.3  // 0.4 - 0.7
            if (!bright) {
                return Qt.rgba(0, intensity * 0.3, intensity, 1)  // Синий
            } else {
                return Qt.rgba(intensity * 0.6, intensity * 0.5, 0, 1)  // Приглушённый жёлто-коричневый
            }
        }

        property color bottomColor: {
            var intensity = 0.5 + pulsePhase * 0.4  // 0.5 - 0.9
            if (!bright) {
                return Qt.rgba(0, intensity * 0.4, intensity, 1)  // Светло-синий
            } else {
                return Qt.rgba(intensity * 0.7, intensity * 0.6, 0, 1)  // Приглушённый жёлтый
            }
        }

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: pulseLayer.topColor }
            GradientStop { position: 0.5; color: "#000000" }
            GradientStop { position: 1.0; color: pulseLayer.bottomColor }
        }

        // Анимация фазы пульсации
        SequentialAnimation on pulsePhase {
            running: true
            loops: Animation.Infinite

            NumberAnimation {
                to: 1.0
                duration: 4000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                to: 0.0
                duration: 4000
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Слой 3: Диагональный луч света
    Canvas {
        id: diagonalBeam
        anchors.fill: parent
        opacity: 0.2

        property real beamPosition: -0.5
        property bool useCoagColors: isCoag

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            // Создаём диагональный градиент
            var x1 = width * beamPosition - 150
            var y1 = -150
            var x2 = width * beamPosition + height
            var y2 = height

            var gradient = ctx.createLinearGradient(x1, y1, x2, y2)

            // Прозрачный → яркий → прозрачный
            gradient.addColorStop(0, "rgba(0, 0, 0, 0)")
            gradient.addColorStop(0.4, "rgba(0, 0, 0, 0)")

            // Явно задаём цвет луча для каждого режима
            // if (useCoagColors) {
            //     gradient.addColorStop(0.5, "rgba(80, 120, 255, 0.6)")  // Синий луч
            // } else {
            //     gradient.addColorStop(0.5, "rgba(180, 150, 60, 0.5)")  // Приглушённый жёлтый луч
            // }
            gradient.addColorStop(0.5, beamColor)
            // beamColor

            gradient.addColorStop(0.6, "rgba(0, 0, 0, 0)")
            gradient.addColorStop(1, "rgba(0, 0, 0, 0)")

            ctx.fillStyle = gradient
            ctx.fillRect(0, 0, width, height)
        }

        SequentialAnimation on beamPosition {
            running: true
            loops: Animation.Infinite

            NumberAnimation {
                to: 1.5
                duration: 8000
                easing.type: Easing.InOutCubic
            }
            NumberAnimation {
                to: -3.0
                duration: 0
            }
        }

        onBeamPositionChanged: {
            requestPaint()
        }

        onUseCoagColorsChanged: {
            requestPaint()
        }
    }

    // Слой 4: Мягкое пульсирующее сияние в центре
    Rectangle {
        id: centerGlow
        anchors.fill: parent
        opacity: 0.25

        property real glowIntensity: 0.0

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop {
                position: 0.5
                color: Qt.rgba(
                    !bright ? 0.1 : 0.7,
                    !bright ? 0.4 : 0.6,
                    !bright ? 1.0 : 0.1,
                    centerGlow.glowIntensity
                )
            }
            GradientStop { position: 1.0; color: "transparent" }
        }

        SequentialAnimation on glowIntensity {
            running: true
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.5
                duration: 3500
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                to: 0.1
                duration: 3500
                easing.type: Easing.InOutQuad
            }
        }
    }
}
