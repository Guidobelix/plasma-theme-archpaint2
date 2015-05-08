/*
 *   Copyright 2014 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import SddmComponents 2.0

import "../components"

Image {
    id: root
    width: 1000
    height: 1000

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            property real ratio: geometry.width / geometry.height
            source: {
                if (ratio == 16.0 / 9.0) {
                    source = "../components/artwork/background_169.png"
                }
                else if (ratio == 16.0 / 10.0) {
                    source = "../components/artwork/background_1610.png"
                }
                else if (ratio == 4.0 / 3.0) {
                    source = "../components/artwork/background_43.png"
                }
                else {
                    source = "../components/artwork/background.png"
                }
            }
            fillMode: Image.PreserveAspectFit
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = "../components/artwork/background.png"
                }
            }
        }
    }

    property bool debug: false

    Rectangle {
        id: debug3
        color: "green"
        visible: debug
        width: 3
        height: parent.height
        anchors.horizontalCenter: root.horizontalCenter
    }

    Controls.StackView {
        id: stackView
        property variant geometry: screenModel.geometry(screenModel.primary)
        width: geometry.width
        height: units.largeSpacing * 11
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: geometry.height * 0.22

        initialItem: BreezeBlock {
            id: loginPrompt
            width: parent.width
            main: UserSelect {
                id: usersSelection
                model: userModel
                selectedIndex: userModel.lastIndex
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Connections {
                    target: sddm
                    onLoginFailed: {
                        usersSelection.notification = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
                    }
                }
                BreezeLabel {
                    id: capsLockWarning
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                    visible: keystateSource.data["Caps Lock"]["Locked"]

                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 0
                    anchors.verticalCenterOffset: units.largeSpacing * 3
                    font.weight: Font.Bold

                    PlasmaCore.DataSource {
                        id: keystateSource
                        engine: "keystate"
                        connectedSources: "Caps Lock"
                    }
                }

            }

            controls: Item {
                height: childrenRect.height

                property alias password: passwordInput.text
                property alias sessionIndex: sessionCombo.currentIndex

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0
                    RowLayout {
                        //NOTE password is deliberately the first child so it gets focus
                        //be careful when re-ordering

                        anchors.horizontalCenter: parent.horizontalCenter
                        PlasmaComponents.TextField {
                            id: passwordInput
                            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Password")
                            echoMode: TextInput.Password
                            onAccepted: {
                                enabled = false
                                loginPrompt.startLogin()
                            }
                            focus: true

                            //focus works in qmlscene
                            //but this seems to be needed when loaded from SDDM
                            //I don't understand why, but we have seen this before in the old lock screen
                            Timer {
                                interval: 200
                                running: true
                                repeat: false
                                onTriggered: passwordInput.forceActiveFocus()
                            }
                            //end hack

                            Keys.onEscapePressed: {
                                //nextItemInFocusChain(false) is previous Item
                                nextItemInFocusChain(false).forceActiveFocus();
                            }

                            //if empty and left or right is pressed change selection in user switch
                            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
                            Keys.onPressed: {
                                if (event.key == Qt.Key_Left && !text) {
                                    loginPrompt.mainItem.decrementCurrentIndex();
                                    event.accepted = true
                                }
                                if (event.key == Qt.Key_Right && !text) {
                                    loginPrompt.mainItem.incrementCurrentIndex();
                                    event.accepted = true
                                }
                            }

                        }

                        PlasmaComponents.Button {
                            //this keeps the buttons the same width and thus line up evenly around the centre
                            Layout.minimumWidth: passwordInput.width
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Login")
                            onClicked: loginPrompt.startLogin();
                        }
                    }

                }

                PlasmaComponents.ComboBox {
                    id: sessionCombo
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex

                    width: 200
                    textRole: "name"

                    anchors.left: parent.left
                }

                LogoutOptions {
                    mode: ""
                    canShutdown: true
                    canReboot: true
                    canLogout: false
                    exclusive: false

                    anchors {
                        right: parent.right
                    }

                    onModeChanged: {
                        if (mode) {
                            stackView.push(logoutScreenComponent, {"mode": mode})
                        }
                    }
                    onVisibleChanged: if(visible) {
                        mode = ""
                    }
                }

                Connections {
                    target: sddm
                    onLoginFailed: {
                        passwordInput.enabled = true
                        passwordInput.selectAll()
                        passwordInput.forceActiveFocus()
                    }
                }

            }

            function startLogin () {
                sddm.login(mainItem.selectedUser, controlsItem.password, controlsItem.sessionIndex)
            }

            Component {
                id: logoutScreenComponent
                LogoutScreen {
                    onCancel: {
                        stackView.pop()
                    }

                    onShutdownRequested: {
                        sddm.powerOff()
                    }

                    onRebootRequested: {
                        sddm.reboot()
                    }
                }
            }
        }

    }
}
