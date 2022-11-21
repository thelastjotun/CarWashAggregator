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

    property int timerInitialTime: 120                  // Начальное значение таймера

    function codeVerificationProcess(code) {
        mainStackView.replace(loadingPage)
        client.makeCodeVerificationRequest(client.codeVerificationType, userData.login, userData.passwordHash, code)
    }

    function resendCodeProcess() {
        client.makeCodeVerificationRequest(client.codeVerificationType, userData.login, userData.passwordHash, "", true)
    }

    Flickable {
        property int minimumContentHeight: root.height / 4 + heading.implicitHeight + betweenElementsMargin * 2 + standardMargin
                                           + subHeading.implicitHeight + betweenElementsGroupsMargin + codeField.height
                                           + loginButtonTopMargin + interactiveElementsHeight + resendCode.height

        contentHeight: (root.height <= minimumContentHeight) ? minimumContentHeight : root.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded

        anchors {
            fill: parent
        }

        Heading {
            id: heading

            text: qsTr("Введите код")

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
            text: qsTr("На вашу почту выслан проверочный код. Введите его, чтобы продолжить.")

            anchors {
                top: heading.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: betweenElementsMargin
            }
        }

        CodeField {
            id: codeField

            anchors {
                top: subHeading.bottom
                horizontalCenter: parent.horizontalCenter

                topMargin: betweenElementsGroupsMargin
            }

            onCodeIntered: {
                codeVerificationProcess(code)
            }
        }

        LoginPageButton {
            id: loginButton

            height: interactiveElementsHeight

            buttonText: qsTr("Подтвердить")

            anchors {
                top: codeField.bottom
                left: parent.left
                right: parent.right

                margins: standardMargin
                topMargin: loginButtonTopMargin
            }

            onClicked: {
                codeField.startCodeVerification()

                mainStackView.replace(loginPage)
            }
        }

        Item {
            id: resendCode

            height: firstText.implicitHeight + 2 + secondText.implicitHeight
            width: Math.max(firstText.implicitWidth, secondText.implicitWidth)

            anchors {
                top: loginButton.bottom

                topMargin: betweenElementsMargin
                horizontalCenter: parent.horizontalCenter
            }

            SubHeading {
                id: firstText

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                opacity: resendCodeMouseArea.pressed ? 0.3 : 0.5

                text: qsTr("Не пришел код?")

                anchors {
                    top: parent.top

                    horizontalCenter: parent.horizontalCenter
                }
            }

            SubHeading {
                id: secondText

                color: themeSettings.accentColor

                font.bold: false
                fontSizeMode: Text.HorizontalFit

                opacity: resendCodeMouseArea.pressed ? 0.5 : 1

                text: Math.floor(timerInitialTime / 60).toString() + ':' + ((timerInitialTime % 60 < 9) ? '0' + (timerInitialTime % 60).toString() : (timerInitialTime % 60).toString())

                anchors {
                    top: firstText.bottom
                    horizontalCenter: parent.horizontalCenter

                    topMargin: 1
                }

                Timer {
                    id: resendCodeTimer

                    property int timerTime: timerInitialTime

                    interval: 1000
                    repeat: true
                    running: true

                    onTriggered: {
                        if (timerTime > 0) {
                            timerTime -= 1
                            secondText.text = Math.floor(timerTime / 60).toString() + ':' + ((timerTime % 60 < 10) ? '0' + (timerTime % 60).toString() : (timerTime % 60).toString())
                        }
                        else {
                            stop()
                            secondText.text = qsTr("Отправить код повторно")
                            timerTime = timerInitialTime
                        }
                    }
                }
            }

            MouseArea {
                id: resendCodeMouseArea

                enabled: !resendCodeTimer.running

                anchors {
                    fill: parent
                }

                onClicked: {
                    resendCodeTimer.start()
                    resendCodeProcess()
                }
            }
        }
    }
}
