/***************************************************************************
 *   Copyright (C) 2014 by Aleix Pol Gonzalez <aleixpol@blue-systems.com>  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.2
import QtQuick.Window 2.2
import "../components"

Item {
    id: root
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    LogoutScreen {
        width: root.width
        height: 201
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: 26 + (root.height * 0.2)

        mode: switch (sdtype) {
            case ShutdownType.ShutdownTypeNone:
                return "logout";
            case ShutdownType.ShutdownTypeHalt:
                return maysd ? "shutdown" : "logout";
            case ShutdownType.ShutdownTypeReboot:
                return maysd ? "reboot" : "logout";
            default:
                return "logout";
        }

        onShutdownRequested: {
            root.haltRequested()
        }

        onRebootRequested: {
            root.rebootRequested()
        }
        canShutdown: maysd && choose
        canReboot: maysd && choose
        canLogout: true

        onCancel: root.cancelRequested()
    }
}
