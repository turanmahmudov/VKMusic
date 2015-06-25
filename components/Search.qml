import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import Ubuntu.Components.Popups 1.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../js/scripts.js" as Scripts

Item {
    id: search

    function get_search(query) {
        Scripts.searchTracks(query);
    }

    TextField {
        id: searchField
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }
        hasClearButton: true
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search")
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus()
            }
        }
        onAccepted: {
            searchpage.get_search(searchField.text);
        }
    }

    ListModel {
        id: searchSongsModel
    }

    ListView {
        id:searchSongsList
        anchors.top: searchField.bottom
        anchors.topMargin: units.gu(1)
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : 0

        model:searchSongsModel
        delegate: ListItem.Empty {
            id: itemsDelegate

            width: parent.width
            height: itemtitle.height + units.gu(4)

            Item {
                id: delegateitem
                anchors.fill: parent
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    width: parent.width
                    id: itemtitle
                    text: title
                    color: playing_song == id ? '#2B587A' : UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: playing_song == id ? units.gu(1.8) : units.gu(1.6)
                }
                Text {
                    anchors.top: itemtitle.bottom
                    anchors.topMargin: units.gu(0)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    width: parent.width
                    id: itemartist
                    text: artist
                    color: UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: units.gu(1.2)
                }
            }
            onClicked: {
                queueModel.clear();
                for (var i = 0; i < searchSongsModel.count; i++) {
                    queueModel.append(searchSongsModel.get(i));
                }
                current_song_index = index;
                Scripts.play_song(id, title, artist, songImage, songURL);
            }
        }
    }
}
