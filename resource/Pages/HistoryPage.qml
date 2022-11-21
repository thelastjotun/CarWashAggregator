import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "qrc:/Elements/Buttons"
import "qrc:/Elements/Dialogs"
import "qrc:/Elements/Images"
import "qrc:/Elements/Items"
import "qrc:/Elements/Texts"

Page {
    id: root

    background: Rectangle {
        color: themeSettings.backgroundColor
    }

    property alias currentTicketsColumnRepeater: currentTicketsColumnRepeater
    property alias allTicketsColumnRepeater: allTicketsColumnRepeater

    readonly property color statusBarColor: themeSettings.backgroundColor
    readonly property color navigationBarColor: themeSettings.backgroundColor

    property int standardMargin: 25     // Стандартное расстояние между элементами

    property int headingTextTopMargin: 15   // Расстояние между 'backButton' и 'headingText'

    Flickable {
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        contentHeight: (backButton.height + backButton.anchors.topMargin + headingText.height + headingText.anchors.topMargin +  historyUpcomingCategoryItem.height + historyUpcomingCategoryItem.anchors.margins
                        + currentTicketsColumn.implicitHeight  + currentTicketsColumn.anchors.topMargin + allTicketsColumn.implicitHeight + allTicketsColumn.anchors.topMargin + allUpcomingCategoryItem.height + allUpcomingCategoryItem.anchors.topMargin) + 15

        anchors {
            fill: parent
        }

        BackButton {
            id: backButton
        }

        Heading {
            id: headingText

            text: qsTr("История")

            font.pointSize: 28

            color: themeSettings.headingColorGreyShade

            maximumLineCount: 1

            elide: Text.ElideRight
            textFormat: Text.PlainText

            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft

            anchors {
                top: backButton.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: headingTextTopMargin
            }
        }

        Column {
            id: historyUpcomingCategoryItem

            height: historyUpcomingCategoryText.height + toolUpcomingSeparator.height

            anchors {
                top: headingText.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                leftMargin: 0
                rightMargin: 0
            }

            SettingsPageCategoryItem {
                id: historyUpcomingCategoryText

                contentImageSource: "qrc:/icons/HistoryPage/upcomin.svg"
                contentText: qsTr("Предстоящие")
            }

            ToolSeparator {
                id: toolUpcomingSeparator

                width: parent.width

                orientation: Qt.Horizontal

                bottomPadding: 0
                topPadding: 0
                leftPadding: standardMargin
                rightPadding: standardMargin
            }
        }

        Column {
            id: currentTicketsColumn

            anchors {
                top: historyUpcomingCategoryItem.bottom
                left: parent.left
                right: parent.right

                topMargin: 15
            }

            Repeater {
                id: currentTicketsColumnRepeater

                model: ListModel { }

                delegate: HistoryPageTicketItem {
                    autowashName: "-"
                    washTime: "-"

                    Component.onCompleted: {
                        for (let j = 0; j < mainMap.item.carWashesInTown.length; ++j) {
                            if (carWashId === mainMap.item.carWashesInTown[j][0]) {

                                console.log();
                                washTime = "с " + dateStart.getHours() + ":" + dateStart.getMinutes() + " по " + dateEnd.getHours() + ":" + dateEnd.getMinutes() + " " + dateStart.toLocaleDateString(Qt.locale("ru_RU"), "dd MMMM")

                                autowashName = mainMap.item.carWashesInTown[j][3]

                                var jsonCategories = JSON.parse(mainMap.item.carWashesInTown[j][4]);
                                for (let i = 0; i < jsonCategories.length; ++i) {
                                    for (let k = 0; k < tagsListModel.count; ++k) {
                                        if (tagsListModel.get(k).name === jsonCategories[i]) {
                                            model.append({
                                                             "color": tagsListModel.get(k).color,
                                                             "name": tagsListModel.get(k).name
                                                         })
                                        }
                                    }
                                }

                                if (isDiscard == true) {
                                    state = "cancel"
                                }

                                return
                            }
                        }
                    }

                    anchors {
                        left: parent.left
                        right: parent.right

                        margins: 30
                    }
                }
            }
        }

        Column {
            id: allUpcomingCategoryItem

            height: historyUpcomingCategoryText.height + toolUpcomingSeparator.height

            anchors {
                top: currentTicketsColumn.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                leftMargin: 0
                rightMargin: 0
            }

            SettingsPageCategoryItem {
                id: allUpcomingCategoryText

                contentImageSource: "qrc:/icons/history.svg"
                contentText: qsTr("Последние")
            }

            ToolSeparator {
                id: allToolUpcomingSeparator

                width: parent.width

                orientation: Qt.Horizontal

                bottomPadding: 0
                topPadding: 0
                leftPadding: standardMargin
                rightPadding: standardMargin
            }
        }

        Column {
            id: allTicketsColumn

            spacing: 10

            anchors {
                top: allUpcomingCategoryItem.bottom
                left: parent.left
                right: parent.right

                topMargin: 15
            }

            Repeater {
                id: allTicketsColumnRepeater

                model: ListModel { }

                delegate: HistoryPageTicketItem {
                    autowashName: "-"
                    washTime: "-"

                    Component.onCompleted: {
                        for (let j = 0; j < mainMap.item.carWashesInTown.length; ++j) {
                            if (carWashId === mainMap.item.carWashesInTown[j][0]) {

                                console.log();
                                washTime = "с " + dateStart.getHours() + ":" + dateStart.getMinutes() + " по " + dateEnd.getHours() + ":" + dateEnd.getMinutes() + " " + dateStart.toLocaleDateString(Qt.locale("ru_RU"), "dd MMMM")

                                autowashName = mainMap.item.carWashesInTown[j][3]

                                var jsonCategories = JSON.parse(mainMap.item.carWashesInTown[j][4]);
                                for (let i = 0; i < jsonCategories.length; ++i) {
                                    for (let k = 0; k < tagsListModel.count; ++k) {
                                        if (tagsListModel.get(k).name === jsonCategories[i]) {
                                            model.append({
                                                             "color": tagsListModel.get(k).color,
                                                             "name": tagsListModel.get(k).name
                                                         })
                                        }
                                    }
                                }

                                if (isDiscard === "ended") {
                                    state = "done"
                                }

                                return
                            }
                        }
                    }

                    anchors {
                        left: parent.left
                        right: parent.right

                        margins: 30
                    }
                }
            }
        }
    }
}
