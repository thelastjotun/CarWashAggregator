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
    readonly property int loginButtonTopMargin: 70

    function validateEmail(email) {
        var reg = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

        if (reg.test(email) == false) {
            loginTextField.errorChanged(themeSettings.errorColor)

            return false
        }

        return true
    }

    function validatePassword(password) {
        if (password.length >= 6 && password.length <= 64) {
            return true
        }

        passwordTextField.errorChanged(themeSettings.errorColor)

        return false
    }

    function registrationProcess() {
        if (loginTextField.text == "") {
            loginTextField.errorChanged(themeSettings.errorColor)
        }

        if (passwordTextField.text == "") {
            passwordTextField.errorChanged(themeSettings.errorColor)
        }

        if (loginTextField.text !== "" && passwordTextField.text !== "") {
            passwordTextField.focus = false

            if (validateEmail(loginTextField.text) && validatePassword(passwordTextField.text)) {
                userData.login = loginTextField.text
                userData.passwordHash = client.hashPassword(passwordTextField.text);

                client.makeAuthorizationRequest("Registration", userData.login, userData.passwordHash, "Таганрог");
            }
        }
    }

    Flickable {
        property int minimumContentHeight: root.height / 4 + heading.implicitHeight + interactiveElementsHeight * 3
                                           + betweenElementsGroupsMargin + betweenElementsMargin + loginButtonTopMargin
                                           + alreadyHaveButton.height + standardMargin * 2

        contentHeight: (root.height <= minimumContentHeight) ? minimumContentHeight : root.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        anchors {
            fill: parent
        }

        Heading {
            id: heading

            text: qsTr("Регистрация")

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter

                topMargin: root.height / 4
            }
        }

        LoginField {
            id: loginTextField

            height: interactiveElementsHeight
            bottomPadding: 8

            placeholderText: qsTr("Email")

            EnterKey.type: Qt.EnterKeyNext

            anchors {
                top: heading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsGroupsMargin
            }

            Keys.onReturnPressed: {
                passwordTextField.focus = true
            }
        }

        PasswordField {
            id: passwordTextField

            height: interactiveElementsHeight
            bottomPadding: 8

            maximumLength: 64

            placeholderText: qsTr("Пароль")

            anchors {
                top: loginTextField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsMargin
            }

            Keys.onReturnPressed: {
                focus = false
                registrationProcess()
            }
        }

        LoginPageButton {
            id: registrationButton

            height: interactiveElementsHeight

            buttonText: qsTr("Продолжить")

            anchors {
                top: passwordTextField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: loginButtonTopMargin
            }

            onClicked: {
                registrationProcess()
            }
        }

        Item {
            id: alreadyHaveButton

            height: firstAlreadyHaveText.implicitHeight + secondAlreadyHaveText.implicitHeight + 2
            width: Math.max(firstAlreadyHaveText.implicitWidth, secondAlreadyHaveText.implicitWidth)

            anchors {
                bottom: parent.bottom

                bottomMargin: standardMargin
                horizontalCenter: parent.horizontalCenter
            }

            SubHeading {
                id: firstAlreadyHaveText

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                opacity: alreadyHaveMouseArea.pressed ? 0.3 : 0.5

                text: qsTr("У вас уже есть аккаунт?")

                anchors {
                    top: parent.top

                    horizontalCenter: parent.horizontalCenter
                }
            }

            SubHeading {
                id: secondAlreadyHaveText

                color: themeSettings.accentColor
                opacity: alreadyHaveMouseArea.pressed ? 0.5 : 1

                text: qsTr("Войти")

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                anchors {
                    top: firstAlreadyHaveText.bottom

                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: alreadyHaveMouseArea

                anchors {
                    fill: parent
                }

                onClicked: {
                    mainStackView.replace(loginPage)
                }
            }
        }
    }
}
