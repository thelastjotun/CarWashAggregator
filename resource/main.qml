import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "qrc:/Pages"

ApplicationWindow {
    id: root

    StackView {
        id: myStackView

        initialItem: homePage
    }

    Component {
        id: homePage

        HomePage { }
    }
}
