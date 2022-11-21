import QtQuick 2.0
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15

import "qrc:/Elements/Buttons"
import "qrc:/Elements/Images"
import "qrc:/Elements/Texts"
import "qrc:/Elements/TextFields"
import "qrc:/Elements"

Page {
    id: root

    readonly property color statusBarColor: themeSettings.backgroundColor
    readonly property color navigationBarColor: themeSettings.backgroundColor

    property alias searchResultsView: searchResultsView
    property alias typeTagPicker: typeTagPicker
    property alias featuresTagPicker: featuresTagPicker
    property alias sortTypeButton: sortTypeButton

    property int buttonsTopMargin: 10
    property int standardMargin: 10
    property int betweenElementsMargin: 10
    property int betweenElementsGroupsMargin: 10

    property int tagsHeight: 30
    property int tagItemsSpacing: 8
    property int betweenTagsSpacing: 10

    background: Rectangle {
        id: backgroundRectangle

        color: themeSettings.backgroundColor

        anchors {
            fill: parent

            topMargin: -mainStackView.anchors.topMargin
        }
    }

    onVisibleChanged: {
        if (visible === true) {
            searchField.forceActiveFocus()
        }
    }

    MapRoundButton {
        id: backButton

        iconSource: "qrc:/icons/back.svg"
        iconMargin: 13

        anchors {
            top: parent.top
            left: parent.left

            topMargin: buttonsTopMargin
            leftMargin: standardMargin
        }

        onClicked: {
            mainStackView.pop()
        }
    }

    SearchField {
        id: searchField

        anchors {
            top: parent.top
            left: backButton.right
            right: parent.right

            topMargin: buttonsTopMargin
            leftMargin: betweenElementsMargin
            rightMargin: standardMargin
        }

        onDisplayTextChanged:  {
            if (searchField.displayText.length >= 2) {
                client.makeCarWashesRequest(userData.login, userData.passwordHash, "name", searchField.displayText)
            } else if (searchField.displayText.length <= 0) {
                var tagsToAsk = []
                for (let i = 0; i < tagsListModel.count; ++i) {
                    tagsToAsk.push(tagsListModel.get(i).name)
                }

                client.makeCarWashesRequest(userData.login, userData.passwordHash, "tags", "", tagsToAsk)
            }
        }

        MouseArea {
            id: parametersButton

            property bool checked: false

            height: parent.height
            width: parent.height

            anchors {
                right: parent.right

                rightMargin: 8
            }

            SvgImage {
                id: parametersIcon

                opacity: (parent.pressed) ? 0.5 : 1

                imageColor: themeSettings.headingColorGreyShade
                imageSource: "qrc:/icons/parameters.svg"

                anchors {
                    fill: parent

                    margins: 12
                }
            }

            onClicked: {
                searchField.focus = false

                tagPickerDrawer.open()
            }
        }
    }

    ListView {
        id: tagsListView

        visible: parametersButton.checked ? false : true

        clip: true
        height: tagsHeight
        spacing: betweenTagsSpacing

        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds

        model: tagsListModel

        displaced: Transition {
            NumberAnimation {
                properties: "x"
                duration: animationDuration

                easing.type: Easing.OutQuad
            }
        }

        anchors {
            top: searchField.bottom
            left: parent.left
            right: parent.right

            margins: standardMargin
            topMargin: betweenElementsMargin
        }

        delegate: Rectangle {
            id: tagRectangle

            opacity: 0.9

            color: model.color

            height: tagsHeight
            width: tagText.implicitWidth + closeIcon.width + tagItemsSpacing * 3

            radius: height / 2

            SubHeading {
                id: tagText

                color: themeSettings.backgroundColor

                font.pointSize: 13
                font.bold: false

                text: model.name

                anchors {
                    left: parent.left

                    leftMargin: tagItemsSpacing

                    verticalCenter: parent.verticalCenter
                }
            }

            SvgImage {
                id: closeIcon

                height: 8
                width: 8

                imageSource: "qrc:/icons/close.svg"
                imageColor: themeSettings.backgroundColor

                anchors {
                    left: tagText.right

                    leftMargin: tagItemsSpacing
                    verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                height: closeIcon.height + tagItemsSpacing * 2
                width: height

                anchors {
                    centerIn: closeIcon
                }

                onClicked: {
                    for (let k = 0; k < typeTagPicker.categoryListModel.count; ++k) {
                        if (tagsListView.model.get(index).id === typeTagPicker.categoryListModel.get(k).id) {
                            typeTagPicker.categoryCheckBoxRepeater.itemAt(k).checked = false
                        }
                    }

                    for (let j = 0; j < featuresTagPicker.categoryListModel.count; ++j) {
                        if (tagsListView.model.get(index).id === featuresTagPicker.categoryListModel.get(j).id) {
                            featuresTagPicker.categoryCheckBoxRepeater.itemAt(j).checked = false
                        }
                    }

                    tagsListView.model.remove(index)

                    var tagsToAsk = []
                    for (let i = 0; i < tagsListModel.count; ++i) {
                        tagsToAsk.push(tagsListModel.get(i).name)
                    }

                    client.makeCarWashesRequest(userData.login, userData.passwordHash, "tags", "", tagsToAsk)
                }
            }
        }
    }

    SubHeading {
        id: sortTypeButton

        visible: parametersButton.checked ? false : true

        opacity: (sortTypeMouseArea.pressed) ? 0.5 : 1

        color: "#0066FF"

        font.bold: false
        font.pointSize: 15

        state: "raiting"
        states: [
            State {
                name: "distance"
                PropertyChanges {
                    target: sortTypeButton
                    text: "Сортировка по рейтингу"
                }
            },
            State {
                name: "raiting"
                PropertyChanges {
                    target: sortTypeButton
                    text: "Сортировка по расстоянию"
                }
            }
        ]

        anchors {
            top: (tagsListView.model.count > 0) ? tagsListView.bottom : searchField.bottom
            right: searchField.right

            topMargin: betweenElementsMargin
            rightMargin: standardMargin
        }

        MouseArea {
            id: sortTypeMouseArea

            anchors {
                fill: parent
            }

            onClicked: {
                if (parent.state == "raiting") {
                    parent.state = "distance"
                    searchResultsView.listModelSort(searchResultsView.model, searchResultsView.compareByRate)
                } else if (parent.state == "distance") {
                    parent.state = "raiting"
                    searchResultsView.listModelSort(searchResultsView.model, searchResultsView.compareByDistance)
                }
            }
        }
    }

    ListView {
        id: searchResultsView

        spacing: 10

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        model: ListModel { }

        function compareByRate(first, second) {
            return second.rate - first.rate
        }

        function compareByDistance(first, second) {
            return first.distance - second.distance
        }

        function listModelSort(listModel, compareFunction) {
            let indexes = [...Array(listModel.count).keys()]
            indexes.sort((a, b) => compareFunction(listModel.get(a), listModel.get(b)))

            let sorted = 0
            while (sorted < indexes.length && sorted === indexes[sorted]) {
                sorted++
            }

            if (sorted === indexes.length) {
                return
            }

            for (let i = sorted; i < indexes.length; i++) {
                listModel.move(indexes[i], listModel.count - 1, 1)
                listModel.insert(indexes[i], { })
            }

            listModel.remove(sorted, indexes.length - sorted)
        }


        anchors {
            top: sortTypeButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            margins: betweenElementsMargin
            topMargin: buttonsTopMargin
        }

        delegate: CarWashSearchPageButton {
            height: 65
            width: searchResultsView.width

            nameText: name
            addressText: address
            rating: (isNaN(rate) === true) ? 0.0 : rate
            price: minPrice
            distanceTo: distance

            onClicked: {
                mainMap.item.drawRouteFromSearch(latitude, longitude)

                infoPanel.setData(id, longitude, latitude, name, categories, address,
                                  workTime, contacts, url, minPrice, images, town, rate, distance, rateCount, comments)

                mainStackView.pop()
                infoPanel.state = "medium"
            }
        }
    }

    Drawer {
        id: tagPickerDrawer

        edge: Qt.BottomEdge

        height: typeTagPicker.height + betweenElementsGroupsMargin + featuresTagPicker.height + 40
        width: parent.width

        closePolicy: Popup.CloseOnReleaseOutside

        dragMargin: 0

        Material.theme: Material.Light

        background: Rectangle {
            anchors.fill: parent

            radius: 20

            color: themeSettings.backgroundColor

            layer.enabled: (themeSettings.materialTheme === Material.Light) ? true : false
            layer.effect: ElevationEffect {
                elevation: 1
            }

            Rectangle {
                height: parent.radius

                color: parent.color

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        }

        TagPicker {
            id: typeTagPicker

            categoryName: qsTr("Тип автомойки:")

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right

                margins: 20
                topMargin: 20
            }
        }

        TagPicker {
            id: featuresTagPicker

            categoryName: qsTr("Дополнительно:")

            anchors {
                top: typeTagPicker.bottom
                left: parent.left
                right: parent.right

                margins: 20
                topMargin: betweenElementsGroupsMargin
            }
        }
    }
}

