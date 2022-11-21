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

    readonly property int standardMargin: 30
    readonly property int betweenElementsMargin: 20
    readonly property int interactiveElementsHeight: 55
    readonly property int betweenElementsGroupsMargin: 50
    readonly property int loginButtonTopMargin: 70

    function changePasswordProcess() {
        if (passwordNewTextField.text === "") {
            passwordNewTextField.errorChanged(themeSettings.errorColor)
        }

        if (passwordAcceptTextField.text === "") {
            passwordAcceptTextField.errorChanged(themeSettings.errorColor)
        }

        if (passwordNewTextField.text !== "" && passwordAcceptTextField.text !== "") {
            passwordAcceptTextField.focus = false

            if (passwordNewTextField.text === passwordAcceptTextField.text && validatePassword(passwordAcceptTextField.text)) {
                userData.passwordHash = client.hashPassword(passwordNewTextField.text)
                client.makePasswordRestoreRequest("RestorePassword", userData.login, userData.passwordHash, userData.passwordHash)
            }
        }
    }

    function validatePassword(password) {
        if (password.length >= 6 && password.length <= 64) {
            return true
        }

        passwordTextField.errorChanged(themeSettings.errorColor)

        return false
    }

    Flickable {
        property int minimumContentHeight: root.height / 4 + heading.implicitHeight + betweenElementsMargin * 2 + subHeading.implicitHeight
                                           + betweenElementsGroupsMargin + interactiveElementsHeight * 3 + loginButtonTopMargin + standardMargin

        contentHeight: (root.height <= minimumContentHeight) ? minimumContentHeight : root.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        anchors {
            fill: parent
        }

        Heading {
            id: heading

            text: qsTr("Введите новый пароль")

            anchors {
                top: parent.top

                topMargin: root.height / 4
                horizontalCenter: parent.horizontalCenter
            }
        }

        SubHeading {
            id: subHeading

            font.bold: false

            opacity: 0.5

            text: qsTr("Пароль должен содержать не менее 8 символов")

            anchors {
                top: heading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin:  betweenElementsMargin
            }
        }

        PasswordField {
            id: passwordNewTextField

            height: interactiveElementsHeight

            bottomPadding: 8

            placeholderText: qsTr("Новый пароль")

            EnterKey.type: Qt.EnterKeyNext

            anchors {
                top: subHeading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsGroupsMargin
            }

            Keys.onReturnPressed: {
                passwordAcceptTextField.focus = true
            }
        }

        PasswordField {
            id: passwordAcceptTextField

            height: interactiveElementsHeight

            bottomPadding: 8

            placeholderText: qsTr("Подтвердите пароль")

            anchors {
                top: passwordNewTextField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsMargin
            }

            Keys.onReturnPressed: {
                focus = false
                changePasswordProcess()
            }
        }

        LoginPageButton {
            id: changePasswordButton

            height: interactiveElementsHeight

            buttonText: qsTr("Подтвердить")

            anchors {
                top: passwordAcceptTextField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: loginButtonTopMargin
            }

            onClicked: {
                changePasswordProcess()
            }
        }
    }
}
