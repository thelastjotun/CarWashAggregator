import QtQuick 2.0
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Material.impl 2.15
import QtLocation 5.15
import QtPositioning 5.15

import "qrc:/Elements/Maps"
import "qrc:/Elements/Texts"
import "qrc:/Elements/Images"
import "qrc:/Elements/Buttons"
import "qrc:/Elements/TextFields"

Page {
    id: root

    readonly property color statusBarColor: themeSettings.backgroundColor
    readonly property color navigationBarColor: themeSettings.backgroundColor

    property alias mainMap: mainMap
    property alias searchPage: searchPage
    property alias historyPage: historyPage
    property alias tagsListModel: tagsListModel
    property alias infoPanel: infoPanel

    property int animationDuration: 300

    property int buttonsTopMargin: 10
    property int standardMargin: 10
    property int betweenElementsMargin: 10

    property int tagsHeight: 30
    property int tagItemsSpacing: 8
    property int betweenTagsSpacing: 10

    property int mapItemAxisXOffset: mapItem.width - standardMargin * 2 - menuButton.width

    property int infoPanelRadius: 20

    property int infoPanelMaximumHeight: mapItem.height
    property int infoPanelMediumHeight: 180
    property int infoPanelMinimumHeight: 24

    property int infoPanelHandleTopMargin: 5

    property int infoPanelContentMargin: 20

    background: Rectangle {
        id: backgroundRectangle

        color: themeSettings.backgroundColor

        anchors {
            fill: parent

            topMargin: -mainStackView.anchors.topMargin
        }
    }

    onVisibleChanged: {
        if (visible === true && themeSettings.materialTheme === Material.Dark || (themeSettings.materialTheme === Material.Light && mainMap.opacity === 0.0)) {
            mainMap.opacity = 1.0
            makeMapVisibleTimer.running = true
        }
    }

    Component.onCompleted: {
        client.makeTagsRequest(userData.login, userData.passwordHash)
        client.makeCarWashesRequest(userData.login, userData.passwordHash)
    }

    function pushIntoStackView(item) {
        if (themeSettings.materialTheme === Material.Dark) {
            mainMap.opacity = 0.0
            mainMap.visible = false
        }

        mainStackView.push(item)
    }

    Timer {
        id: makeMapVisibleTimer

        interval: 220

        onTriggered: {
            mainMap.visible = true
        }
    }

    SearchPage {
        id: searchPage

        visible: mainStackView.currentItem == searchPage ? true : false
    }

    HistoryPage {
        id: historyPage

        visible: mainStackView.currentItem == historyPage ? true : false
    }

    Column {
        id: menuColumn

        visible: mapItem.state == "menu"

        height: accountButton.height * 5

        anchors {
            left: parent.left
            right: parent.right

            verticalCenter: shadowItem.verticalCenter
        }

        MenuButton {
            id: accountButton

            iconSource: "qrc:/icons/account.svg"
            contentText: qsTr("Аккаунт")

            onClicked: {
                informationToast.show("В разработке")
            }
        }

        MenuButton {
            id: favouriteButton

            iconSource: "qrc:/icons/favourite.svg"
            contentText: qsTr("Избранное")

            onClicked: {
                informationToast.show("В разработке")
            }
        }

        MenuButton {
            id: historyButton

            iconSource: "qrc:/icons/history.svg"
            contentText: qsTr("История")

            onClicked: {
                pushIntoStackView(historyPage)
                client.makeGetTicketRequest(userData.login, userData.passwordHash, "last")
                client.makeGetTicketRequest(userData.login, userData.passwordHash)
            }
        }

        MenuButton {
            id: settingsButton

            iconSource: "qrc:/icons/settings.svg"
            contentText: qsTr("Настройки")

            onClicked: {
                pushIntoStackView(settingsPage)
            }
        }

        MenuButton {
            id: aboutButton

            iconSource: "qrc:/icons/information.svg"
            contentText: qsTr("О приложении")

            onClicked: {
                pushIntoStackView(aboutPage)
            }
        }

        UpgradeToProButton {
            id: upgradeButton

//            buttonWidth: 225
//            buttonHeight: 150
//            sourceImage: "qrc:/icons/pro.svg"

//            anchors {
//                left: aboutButton.left
//                leftMargin: 30
//            }
        }
    }

    Rectangle {
        id: shadowItem

        color: themeSettings.backgroundColor

        layer.enabled: (themeSettings.materialTheme === Material.Light) ? true : false
        layer.effect: ElevationEffect {
            elevation: 8
        }

        anchors {
            fill: mapItem

            topMargin: -mainStackView.anchors.topMargin
        }
    }

    Item {
        id: mapItem

        height: parent.height - 120 * (x / mapItemAxisXOffset)
        width: parent.width

        state: "map"

        states: [
            State {
                name: "menu"
                PropertyChanges { target: mapItem; x: mapItemAxisXOffset }
            },
            State {
                name: "map"
                PropertyChanges { target: mapItem; x: 0 }
            },
            State {
                name: "undefined"
            }
        ]

        transitions: [
            Transition {
                PropertyAnimation {
                    target: mapItem
                    properties: "x"
                    duration: animationDuration
                    easing.type: Easing.OutQuad
                }
            }
        ]

        anchors {
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: dragMapItem

            z: 5

            hoverEnabled: true

            enabled: (parent.state == "menu") ? true : false

            drag.target: parent
            drag.axis: "XAxis"

            drag.smoothed: true

            drag.minimumX: 0
            drag.maximumX: mapItem.width - 60

            anchors {
                fill: parent
            }

            drag.onActiveChanged: {
                if (!drag.active) {
                    var previousState = parent.state
                    parent.state = "undefined"

                    if (mapItem.width - standardMargin * 2 - menuButton.width - dragMapItem.x > 40) {
                        parent.state = "map"
                        mainMap.item.showAllMapItems()
                    } else {
                        parent.state = previousState
                    }
                }
            }

            onClicked: {
                parent.state = "map"
                mainMap.item.showAllMapItems()
            }
        }

        Loader {
            id: mainMap

            z: 0

            active: true

            asynchronous: false

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutExpo
                }
            }

            anchors {
                fill: parent

                topMargin: -mainStackView.anchors.topMargin
            }

            sourceComponent: MainMap {
                gesture.acceptedGestures: (infoPanel.state == "maximum") ? MapGestureArea.NoGesture : MapGestureArea.PanGesture | MapGestureArea.PinchGesture | MapGestureArea.FlickGesture | MapGestureArea.RotationGesture
            }
        }

        MapRoundButton {
            id: menuButton

            iconSource: "qrc:/icons/menu.svg"

            anchors {
                top: parent.top
                left: parent.left

                topMargin: buttonsTopMargin
                leftMargin: standardMargin
            }

            onClicked: {
                if (parent.state == "map") {
                    parent.state = "menu"
                }
            }
        }

        SearchField {
            id: searchField

            anchors {
                top: parent.top
                left: menuButton.right
                right: parent.right

                topMargin: buttonsTopMargin
                leftMargin: betweenElementsMargin
                rightMargin: standardMargin
            }

            MouseArea {
                z: searchField.z + 1

                anchors {
                    fill: parent
                }

                onClicked: {
                    pushIntoStackView(searchPage)
                }
            }
        }

        ListModel {
            id: tagsListModel

            onCountChanged: {
                mainMap.item.updateCarWashesByTags()
            }

            /* Function removes the image from the sheet based on the 'criteria function' */
            function removeOne(criteria) {
                for (let i = 0; i < tagsListModel.count; ++i) {
                    if (criteria(tagsListModel.get(i))) {
                        tagsListModel.remove(i)
                    }
                }

                return false
            }
        }

        ListView {
            id: tagsListView

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
                        for (let k = 0; k < searchPage.typeTagPicker.categoryListModel.count; ++k) {
                            if (tagsListView.model.get(index).id === searchPage.typeTagPicker.categoryListModel.get(k).id) {
                                searchPage.typeTagPicker.categoryCheckBoxRepeater.itemAt(k).checked = false
                            }
                        }

                        for (let j = 0; j < searchPage.featuresTagPicker.categoryListModel.count; ++j) {
                            if (tagsListView.model.get(index).id === searchPage.featuresTagPicker.categoryListModel.get(j).id) {
                                searchPage.featuresTagPicker.categoryCheckBoxRepeater.itemAt(j).checked = false
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

        MapLocationButton {
            id: currentLocationButton

            y: (infoPanel.y - height > buttonsTopMargin + searchField.height + standardMargin * 3 + tagsHeight) ?
                   infoPanel.y - height - standardMargin : buttonsTopMargin + searchField.height + standardMargin * 2 + tagsHeight

            anchors {
                right: parent.right

                margins: 13
            }

            onClicked: {
                mainMap.item.centerUserPosition()
            }
        }

        Rectangle {
            id: infoPanel

            y: parent.height - infoPanelMinimumHeight
            z: 2

            height: parent.height - y

            radius: infoPanelRadius
            color: themeSettings.backgroundColor

            property string lastState: ""

            property int currentCarWashId: 0
            property real currentLongitude: 0.0
            property real currentLatitude: 0.0

            layer.enabled: (themeSettings.materialTheme === Material.Light) ? true : false
            layer.effect: ElevationEffect {
                elevation: 1
            }

            state: "minimum"
            states: [
                State {
                    name: "hidden"

                    PropertyChanges { target: infoPanel; y: parent.height }
                },
                State {
                    name: "minimum"

                    PropertyChanges { target: infoPanel; y: parent.height - infoPanelMinimumHeight }
                },
                State {
                    name: "medium"

                    PropertyChanges { target: infoPanel; y: parent.height - infoPanelMediumHeight }
                },
                State {
                    name: "maximum"

                    PropertyChanges { target: infoPanel; y: parent.height - infoPanelMaximumHeight }
                },
                State {
                    name: "undefined"
                }
            ]

            transitions: [
                Transition {
                    PropertyAnimation {
                        target: infoPanel
                        properties: "y, opacity"
                        duration: animationDuration
                        easing.type: Easing.OutQuad
                    }
                }
            ]

            Rectangle {
                height: parent.radius

                color: parent.color

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }

            anchors {
                left: parent.left
                right: parent.right
            }

            function hide() {
                lastState = state
                state = "hidden"
            }

            function show() {
                state = lastState
            }

            function setData(id, longitude, latitude, name, categories, address,
                             workTime, contacts, url, minPrice, images, town, rate, distance, rateCount, comments) {
                additionalDataView.model.clear()
                imagesView.model.clear()
                categoriesView.model.clear()
                organizationCategories.text = ""

                currentCarWashId = id
                currentLongitude = longitude
                currentLatitude = latitude

                organizationName.text = name
                starsRepeater.model = parseInt(rate)
                ratingText.text = rate
                routeLengthText.text = distance + " км"

                if (rateCount % 10 === 1) {
                    reviewsText.text = rateCount + " оценка"
                } else if (rateCount % 10 === 2 || rateCount % 10 === 3 || rateCount % 10 === 4) {
                    reviewsText.text = rateCount + " оценки"
                } else {
                    reviewsText.text = rateCount + " оценок"
                }


                var jsonCategories = JSON.parse(categories);
                for (let i = 0; i < jsonCategories.length; ++i) {
                    for (let k = 0; k < tagsListModel.count; ++k) {
                        if (tagsListModel.get(k).name === jsonCategories[i]) {
                            categoriesView.model.append({
                                                            "color": tagsListModel.get(k).color,
                                                            "name": tagsListModel.get(k).name
                                                        })
                        }
                    }

                    if (i + 1 >= jsonCategories.length) {
                        organizationCategories.text += jsonCategories[i]
                    } else {
                        organizationCategories.text += jsonCategories[i] + ", "
                    }
                }

                var jsonImages = JSON.parse(images);
                for (let j = 0; j < jsonImages.length; ++j) {
                    imagesView.model.append({
                                                "imageSource": jsonImages[j]
                                            })
                }

                if (address.length > 0) {
                    additionalDataView.model.append({
                                                        "type": "text",
                                                        "iconSource": "qrc:/icons/marker.svg",
                                                        "dataText": address
                                                    })
                }


                if (workTime.length > 0) {
                    additionalDataView.model.append({
                                                        "type": "text",
                                                        "iconSource": "qrc:/icons/clock.svg",
                                                        "dataText": workTime
                                                    })
                }

                if (minPrice.length > 0) {
                    additionalDataView.model.append({
                                                        "type": "text",
                                                        "iconSource": "qrc:/icons/dollar.svg",
                                                        "dataText": "от " + minPrice + "₽"
                                                    })
                }

                if (url.length > 0) {
                    additionalDataView.model.append({
                                                        "type": "link",
                                                        "iconSource": "qrc:/icons/earth.svg",
                                                        "dataText": url

                                                    })
                }

                var contactsJson = JSON.parse(contacts);
                var contactsEnd = ""
                for (let x = 0; x < contactsJson.length; ++x) {
                    if (x + 1 >= contactsJson.length) {
                        contactsEnd += contactsJson[x]
                    } else {
                        contactsEnd += contactsJson[x] + ", "
                    }
                }

                if (contactsEnd !== "") {
                    additionalDataView.model.append({
                                                        "type": "text",
                                                        "iconSource": "qrc:/icons/phone.svg",
                                                        "dataText": contactsEnd
                                                    })
                }

                var commentsJson = JSON.parse(comments);
                for (let z = 0; z < commentsJson.length; ++z) {
                    commentsColumnRepeater.model.append({
                                                            "commentTextData": commentsJson[z]
                                                        })
                }
            }

            // TODO: Заменить на элемент с анимацией
            Rectangle {
                id: infoPanelHandle

                height: 4
                width: 32

                radius: 2

                color: themeSettings.headingColorGreyShade

                opacity: 0.3

                anchors {
                    top: parent.top

                    topMargin: infoPanelHandleTopMargin
                    horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: infoPanelMouseArea

                property int previousY: root.height - infoPanelMinimumHeight

                height: infoPanelMediumHeight

                hoverEnabled: true

                drag.target: parent
                drag.axis: "YAxis"

                drag.smoothed: true

                drag.minimumY: (organizationName.text === "-") ? (root.height - infoPanelMediumHeight) : (root.height - infoPanelMaximumHeight)
                drag.maximumY: root.height - infoPanelMinimumHeight

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                drag.onActiveChanged: {
                    if (!drag.active) {
                        var previousState = parent.state
                        parent.state = "undefined"

                        if (previousY - infoPanel.y > 40) {
                            if (root.height - infoPanelMediumHeight <= infoPanel.y && root.height - infoPanelMinimumHeight >= infoPanel.y) {
                                parent.state = "medium"

                                previousY = root.height - infoPanelMediumHeight
                            }
                            else if (root.height - infoPanelMaximumHeight <= infoPanel.y && root.height - infoPanelMediumHeight >= infoPanel.y) {
                                parent.state = "maximum"

                                previousY = root.height - infoPanelMaximumHeight
                            }
                            else {
                                parent.state = "minimum"
                            }
                        }
                        else if (previousY - infoPanel.y < -40) {
                            if (root.height - infoPanelMediumHeight >= infoPanel.y && root.height - infoPanelMaximumHeight <= infoPanel.y) {
                                parent.state = "medium"

                                previousY = root.height - infoPanelMediumHeight
                            }
                            else if (root.height - infoPanelMinimumHeight >= infoPanel.y && root.height - infoPanelMediumHeight <= infoPanel.y) {
                                parent.state = "minimum"

                                previousY = root.height - infoPanelMinimumHeight
                            }
                            else {
                                yAnimation.to = previousY
                                parent.state = "maximum"
                            }
                        } else {
                            parent.state = previousState
                        }
                    }
                }
            }

            Item {
                id: panelHeader

                width: infoPanelMediumHeight - infoPanelHandleTopMargin - infoPanelHandle.height - 15

                height: infoPanelMediumHeight

                anchors {
                    top: infoPanelHandle.bottom
                    left: parent.left
                    right: parent.right

                    leftMargin: infoPanelContentMargin
                    rightMargin: infoPanelContentMargin
                }

                SubHeading {
                    visible: (organizationName.text == "-")

                    color: themeSettings.headingColorGreyShade

                    font.bold: false
                    font.pixelSize: 16

                    text: qsTr("Выберите мойку через поиск")

                    anchors {
                        centerIn: parent
                    }
                }

                Heading {
                    id: organizationName

                    visible: !(text == "-")

                    font.pointSize: 18
                    font.bold: false

                    font.weight: Font.Medium

                    text: "-"

                    anchors {
                        top: parent.top
                        left: parent.left

                        topMargin: 15
                    }
                }

                SubHeading {
                    id: organizationCategories

                    visible: !(organizationName.text == "-")

                    font.pointSize: 14
                    font.bold: false

                    text: "-"

                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1

                    anchors {
                        top: organizationName.bottom
                        left: organizationName.left
                        right: closeButton.left

                        rightMargin: 10
                    }
                }

                Row {
                    id: ratingStars

                    visible: !(organizationName.text == "-")

                    spacing: 2

                    height: 14
                    width: height * 5 + spacing * 4

                    anchors {
                        top: organizationCategories.bottom
                        left: organizationName.left

                        topMargin: standardMargin
                    }

                    Repeater {
                        id: starsRepeater

                        visible: !(organizationName.text == "-")

                        model: 5

                        delegate: SvgImage {
                            height: parent.height
                            width: height

                            imageColor: "gold"
                            imageSource: "qrc:/icons/star.svg"
                        }
                    }
                }

                SubHeading {
                    id: ratingText

                    visible: !(organizationName.text == "-")

                    color: themeSettings.headingColorGreyShade

                    font.pointSize: 15
                    font.bold: false

                    text: "0.0"

                    anchors {
                        left: ratingStars.right

                        leftMargin: 15
                        verticalCenter: ratingStars.verticalCenter
                    }
                }

                SubHeading {
                    id: reviewsText

                    visible: !(organizationName.text == "-")

                    font.pointSize: 15
                    font.bold: false

                    text: "0 оценок"

                    anchors {
                        left: ratingText.right

                        leftMargin: 10
                        verticalCenter: ratingText.verticalCenter
                    }
                }

                SubHeading {
                    id: routeLengthText

                    visible: !(organizationName.text == "-")

                    font.pointSize: 15
                    font.bold: false

                    text: "0,0 км"

                    anchors {
                        right: parent.right

                        verticalCenter: ratingText.verticalCenter
                    }
                }

                CloseButton {
                    id: closeButton

                    z: 20

                    preventStealing: true

                    anchors {
                        right: parent.right

                        verticalCenter: organizationName.verticalCenter
                    }

                    onClicked: {
                        organizationName.text = "-"

                        infoPanel.state = "minimal"
                        mainMap.item.forShowCarWashes()
                    }
                }

                Button {
                    id: routeButton

                    visible: !(organizationName.text == "-")

                    opacity: pressed ? 0.5 : 1

                    height: 55
                    width: routeButtonText.implicitWidth + 40

                    background: Rectangle {
                        height: parent.height
                        width: parent.width

                        radius: parent.height / 2
                        color: themeSettings.accentColor
                    }

                    anchors {
                        top: ratingText.bottom
                        left: organizationName.left

                        topMargin: 5
                    }

                    SubHeading {
                        id: routeButtonText

                        color: themeSettings.backgroundColor

                        font.pointSize: 14
                        font.bold: false

                        text: qsTr("Маршрут")

                        anchors {
                            centerIn: parent
                        }
                    }

                    onClicked: {
                        if (organizationName.text != "-") {
                            infoPanel.state = "medium"
                            mainMap.item.drawRouteFromSearch(infoPanel.currentLatitude, infoPanel.currentLongitude)
                        }
                    }
                }

                Button {
                    id: tickerButton

                    visible: !(organizationName.text == "-")

                    opacity: pressed ? 0.5 : 1

                    height: 55
                    width: saveButtonText.implicitWidth + 40

                    background: Rectangle {
                        height: parent.height
                        width: parent.width

                        radius: parent.height / 2
                        color: themeSettings.backgroundColor

                        border.color: "#CFD0D2"
                        border.width: 1
                    }

                    anchors {
                        left: routeButton.right

                        leftMargin: betweenElementsMargin
                        verticalCenter: routeButton.verticalCenter
                    }

                    SubHeading {
                        id: saveButtonText

                        color: themeSettings.accentColor

                        font.pointSize: 14
                        font.bold: false

                        text: qsTr("Забронировать")

                        anchors {
                            centerIn: parent
                        }
                    }

                    onClicked: {
                        if (infoPanel.currentCarWashId !== 0) {
                            client.makeSetTicketRequest(userData.login, userData.passwordHash, infoPanel.currentCarWashId)
                        }
                    }
                }
            }

            Flickable {
                clip: true

                contentHeight: commentsColumn.y + commentsColumn.implicitHeight

                boundsBehavior: Flickable.StopAtBounds

                enabled: (infoPanel.state === "maximum"/* || infoPanel.state === "medium"*/) ? true : false

                anchors {
                    top: panelHeader.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom

                    topMargin: 0
                    leftMargin: infoPanelContentMargin
                    rightMargin: infoPanelContentMargin
                }

                ListView {
                    id: imagesView

                    z: 1

                    clip: true

                    spacing: 8
                    height: width / 1.8

                    orientation: ListView.Horizontal
                    boundsBehavior: Flickable.StopAtBounds

                    model: ListModel { }

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right

                        topMargin: 0
                    }

                    delegate: Image {
                        id: image

                        height: imagesView.height
                        width: imagesView.width

                        source: imageSource
                        sourceSize.height: 250
                        sourceSize.width: 300

                        /* Make image round */
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: image.width
                                height: image.height

                                Rectangle {
                                    anchors.centerIn: parent
                                    anchors.fill: parent
                                    radius: 8
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: categoriesView

                    clip: true
                    height: tagsHeight
                    spacing: betweenTagsSpacing

                    orientation: ListView.Horizontal
                    boundsBehavior: Flickable.StopAtBounds

                    model: ListModel { }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: animationDuration

                            easing.type: Easing.OutQuad
                        }
                    }

                    anchors {
                        top: (imagesView.model.count <= 0) ? parent.bottom : imagesView.bottom
                        left: parent.left
                        right: parent.right

                        topMargin: 15
                    }

                    delegate: Rectangle {
                        opacity: 0.9

                        color: model.color

                        height: tagsHeight
                        width: categoryText.implicitWidth + tagItemsSpacing * 2

                        radius: height / 2

                        SubHeading {
                            id: categoryText

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
                    }
                }

                ListView {
                    id: additionalDataView

                    height: 65 * model.count

                    boundsBehavior: Flickable.StopAtBounds

                    clip: true

                    model: ListModel { }

                    anchors {
                        top: categoriesView.bottom /// TODO: если нет изображений и categoriesView
                        left: parent.left
                        right: parent.right

                        topMargin: 15
                    }

                    delegate: ItemDelegate {
                        height: 65
                        width: additionalDataView.width

                        onClicked:  {
                            if (type === "text") {
                                informationToast.show("Скопировано")
                                clipboard.copyToClipboard(dataText)
                            } else if (type === "link") {
                                Qt.openUrlExternally(dataText);
                            }
                        }

                        SvgImage {
                            id: iconData

                            width: height

                            imageSource: iconSource
                            imageColor: themeSettings.accentColor

                            anchors {
                                top: parent.top
                                left: parent.left
                                bottom: parent.bottom

                                margins: 20
                                leftMargin: 0
                            }
                        }

                        Heading {
                            id: textData

                            text: dataText

                            horizontalAlignment: Text.AlignLeft

                            font.pointSize: 14
                            font.bold: false

                            maximumLineCount: 2

                            anchors {
                                top: parent.top
                                left: iconData.right
                                right: parent.right
                                bottom: parent.bottom

                                margins: 5
                                leftMargin: 20
                                rightMargin: 0
                            }
                        }
                    }
                }

                Column {
                    id: commentsColumn

                    spacing: 10

                    anchors {
                        top: additionalDataView.bottom
                        left: parent.left
                        right: parent.right

                        topMargin: 15
                    }

                    Repeater {
                        id: commentsColumnRepeater

                        model: ListModel { }

                        delegate: Item {
                            height: commentData.implicitHeight + 20
                            width: commentsColumn.width

                            SubHeading {
                                id: commentData

                                text: commentTextData

                                horizontalAlignment: Text.AlignLeft

                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                            }

                            ToolSeparator {
                                height: 12

                                leftPadding: 0
                                rightPadding: 0

                                anchors {
                                    top: commentData.bottom
                                    left: parent.left
                                    right: parent.right
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
