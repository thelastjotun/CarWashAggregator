import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "qrc:/Elements/Buttons"
import "qrc:/Elements/TextFields"
import "qrc:/Elements/Texts"

Page {
    id: root

    readonly property color statusBarColor: themeSettings.backgroundColor
    readonly property color navigationBarColor: themeSettings.backgroundColor

    background: Rectangle {
        color: themeSettings.backgroundColor
    }

    readonly property int interactiveElementsHeight: 55
    readonly property int standardMargin: 30
    readonly property int betweenElementsGroupsMargin: 50
    readonly property int betweenElementsMargin: 20
    readonly property int loginButtonTopMargin: 50

    function validateEmail(email) {
        var reg = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

        if (reg.test(email) == false) {
            loginTextField.errorChanged(themeSettings.errorColor)

            return false
        }

        return true
    }

    function sendCodeProcess() {
        if (loginTextField.text == "") {
            loginTextField.errorChanged(themeSettings.errorColor)
        }

        if (loginTextField.text != "") {
            loginTextField.focus = false

            if (validateEmail(loginTextField.text)) {
                userData.login = loginTextField.text
                client.makePasswordRestoreRequest("ForgotPassword", userData.login)
            }
        }
    }

    Flickable {
        property int minimumContentHeight: root.height / 4 + heading.implicitHeight + betweenElementsMargin + subHeading.implicitHeight
                                           + betweenElementsGroupsMargin + interactiveElementsHeight * 2 + loginButtonTopMargin + standardMargin

        contentHeight: (root.height <= minimumContentHeight) ? minimumContentHeight : root.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        anchors {
            fill: parent
        }

        Heading {
            id: heading

            text: qsTr("Восстановить пароль")

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter

                topMargin: root.height / 4
            }
        }

        SubHeading {
            id: subHeading

            font.bold: false

            opacity: 0.5
            text: qsTr("Укажите email, который вы использовали при регистрации. На него будет выслан код восстановления пароля.")

            anchors {
                top: heading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsMargin
            }
        }

        LoginField {
            id: loginTextField

            height: interactiveElementsHeight
            bottomPadding: 8

            placeholderText: qsTr("Email")

            anchors {
                top: subHeading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsGroupsMargin
            }

            Keys.onReturnPressed: {
                focus = false
                sendCodeProcess()
            }
        }

        LoginPageButton {
            id: sendCodeButton

            height: interactiveElementsHeight

            buttonText: qsTr("Отправить код")

            anchors {
                top: loginTextField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: loginButtonTopMargin
            }

            onClicked: {
                sendCodeProcess()

                mainStackView.replace(codePage)
            }
        }
    }
}
