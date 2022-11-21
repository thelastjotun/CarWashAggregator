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

    property int interactiveElementsHeight: 55          // Стандартная высота для интерактивных элементов
    property int standardMargin: 30                     // Cтандартный отступ элементов от краев.
    property int betweenElementsMargin: 20              // Отступ между элементами.
    property int betweenElementsGroupsMargin: 50        // Отступ между группами элементомов.
    property int loginButtonTopMargin: 50               // Отступ для кнопки входа

    function loginProcess() {
        if (loginTextField.text === "") {
            loginTextField.errorChanged(themeSettings.errorColor)
        }

        if (passwordTextField.text === "") {
            passwordTextField.errorChanged(themeSettings.errorColor)
        }

        if (loginTextField.text !== "" && passwordTextField.text !== "") {
            passwordTextField.focus = false

            if (validateEmail(loginTextField.text) && validatePassword(passwordTextField.text)) {
                userData.login = loginTextField.text
                userData.passwordHash = client.hashPassword(passwordTextField.text);

                client.makeAuthorizationRequest("Authorization", userData.login, userData.passwordHash, "Таганрог");
            }
        }
    }

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

    Flickable {
        property int minimumContentHeight: root.height / 4 + heading.implicitHeight + betweenElementsGroupsMargin
                                           + interactiveElementsHeight * 4 + betweenElementsMargin + betweenElementsMargin
                                           + loginButtonTopMargin  + standardMargin * 2 + dontHaveButton.height

        contentHeight: (root.height <= minimumContentHeight) ? minimumContentHeight : root.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        anchors {
            fill: parent
        }

        Heading {
            id: heading

            text: qsTr("Авторизация")

            anchors {
                top: parent.top

                topMargin: root.height / 4
                horizontalCenter: parent.horizontalCenter
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
                loginProcess()
            }
        }

        SubHeading {
            id: forgotPasswordButton

            font.bold: false
            fontSizeMode: Text.HorizontalFit

            opacity: (forgotPasswordMouseArea.pressed) ? 0.3 : 0.5

            text: qsTr("Забыли пароль?")

            anchors {
                top: passwordTextField.bottom

                topMargin: 13
                horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                id: forgotPasswordMouseArea

                anchors {
                    fill: parent
                }

                onClicked: {
                    mainStackView.replace(forgotPasswordPage)
                }
            }
        }

        LoginPageButton {
            id: loginButton

            height: interactiveElementsHeight

            buttonText: qsTr("Войти")

            anchors {
                top: forgotPasswordButton.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: loginButtonTopMargin
            }

            onClicked: {
                loginProcess()
            }
        }

        Item {
            id: dontHaveButton

            height: firstDontHaveText.implicitHeight + 2 + secondDontHaveText.implicitHeight
            width: Math.max(firstDontHaveText.implicitWidth, secondDontHaveText.implicitWidth)

            anchors {
                bottom: parent.bottom

                bottomMargin: standardMargin
                horizontalCenter: parent.horizontalCenter
            }

            SubHeading {
                id: firstDontHaveText

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                opacity: dontHaveMouseArea.pressed ? 0.3 : 0.5

                text: qsTr("У вас еще нет аккаунта?")

                anchors {
                    top: parent.top

                    horizontalCenter: parent.horizontalCenter
                }
            }

            SubHeading {
                id: secondDontHaveText

                color: themeSettings.accentColor

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                opacity: dontHaveMouseArea.pressed ? 0.5 : 1

                text: qsTr("Зарегистрироваться")

                anchors {
                    top: firstDontHaveText.bottom

                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                id: dontHaveMouseArea

                anchors {
                    fill: parent
                }

                onClicked: {
                    mainStackView.replace(registrationPage)
                }
            }
        }
    }
}
