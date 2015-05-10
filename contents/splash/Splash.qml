/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Window 2.2

Image {
    id: root
    width: screen.width
    height: screen.height
    property real ratio: (screen.width / screen.height)
    source: {
        source = "../components/artwork/background.png"
        if ((ratio - (16.0 / 9.0)) <= 0.00001) {
            source = "../components/artwork/background_169.png"
        }
        else if ((ratio - (16.0 / 10.0)) <= 0.00001) {
            source = "../components/artwork/background_1610.png"
        }
        else if ((ratio - (4.0 / 3.0)) <= 0.00001) {
            source = "../components/artwork/background_43.png"
        }
    }
    fillMode: Image.PreserveAspectFit

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    
    Rectangle {
        id: topRect
        width: parent.width
        height: 150
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: parent.height * 0.20
        color: "#CCeff0f1"
        Image {
            source: "images/arch.svgz"
            anchors.centerIn: parent
            sourceSize.height: 128
            sourceSize.width: 128
        }
    }

    Rectangle {
        id: bottomRect
        width: parent.width
        height: 50
        anchors.centerIn: topRect
        anchors.horizontalCenterOffset: 0
        anchors.verticalCenterOffset: 101
        color: "#CCeff0f1"

        Rectangle {
            radius: 3
            color: "#31363b"
            anchors.centerIn: parent
            height: 8
            width: height*32
            Rectangle {
                radius: 3
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width / 6) * (stage - 1)
                color: "#1793d1"
                Behavior on width { 
                    PropertyAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    ParallelAnimation {
        id: introAnimation
        running: false

        YAnimator {
            target: topRect
            from: root.height
            to: root.height / 3
            duration: 1000
            easing.type: Easing.InOutBack
            easing.overshoot: 1.0
        }
        YAnimator {
            target: bottomRect
            from: -bottomRect.height
            to: 2 * (root.height / 3) - bottomRect.height
            duration: 1000
            easing.type: Easing.InOutBack
            easing.overshoot: 1.0
        }
    }
}
