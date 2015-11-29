/*
 * Copyright (C) 2014-2015
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Nekhelesh Ramananthan <nik90@ubuntu.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Upstream location:
 * https://github.com/krnekhelesh/flashback
 */

import QtQuick 2.3
import Ubuntu.Components 1.3

// Walkthrough - Slide 7
Component {
    id: slide7
    Item {
        id: slide7Container

        Icon {
            id: centerIcon
            anchors {
                bottom: introductionText.top
                bottomMargin: units.gu(10)
                horizontalCenter: parent.horizontalCenter
            }
            width: units.gu(13)
            height: width
            name: "save"
            color: "#fff"
        }

        Label {
            id: introductionText
            anchors {
                bottom: finalMessage.top
                bottomMargin: units.gu(4)
            }
            color: "#fff"
            elide: Text.ElideRight
            fontSize: "x-large"
            horizontalAlignment: Text.AlignHLeft
            maximumLineCount: 2
            text: i18n.tr("Download")
            width: units.gu(36)
            wrapMode: Text.WordWrap
        }

        Label {
            id: finalMessage
            anchors {
                bottom: continueButton.top
                bottomMargin: units.gu(7)
            }
            color: "#fff"
            fontSize: "large"
            horizontalAlignment: Text.AlignHLeft
            text: i18n.tr("Download VK songs to your phone and play on your favorite music player any time you want.")
            width: units.gu(36)
            wrapMode: Text.WordWrap
        }

        Button {
            id: continueButton
            anchors {
                bottom: parent.bottom
                bottomMargin: units.gu(3)
                horizontalCenter: parent.horizontalCenter
            }
            color: "#F86F05"
            height: units.gu(5)
            text: i18n.tr("Start")
            width: units.gu(18)

            onClicked: finished()
        }
    }
}
