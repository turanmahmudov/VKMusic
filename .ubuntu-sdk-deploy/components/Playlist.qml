import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import Ubuntu.DownloadManager 0.1
import Ubuntu.Content 0.1
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import "../js/scripts.js" as Scripts

Item {
    id: playl

    property var playlist_id
    property var playlist_name

    property var offset : 0

    function playlist(id) {
        Scripts.get_playlist_by_id(id, offset);
    }

    ListModel {
        id: playlistsongsModel
    }

    ListView {
        id:playlistsongs
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : false

        model:playlistsongsModel
        delegate: ListItem.Empty {
            width: parent.width
            height: itemtitle.height + units.gu(4)
            onClicked: {
                if (off != 1) {
                    queueModel.clear();
                    for (var i = 0; i < playlistsongsModel.count; i++) {
                        queueModel.append(playlistsongsModel.get(i));
                    }
                    current_song_index = index;
                    Scripts.play_song(id, title, artist, songImage, songURL);
                }
            }
            Item {
                id: delegateitem
                anchors.fill: parent
                visible: off == 1 ? false : true
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
            Item {
                id: offitem
                anchors.fill: parent
                visible: off == 1 ? true : false
                Button {
                    anchors.centerIn: parent
                    text: i18n.tr("Load more")
                    onClicked: {
                        playlistpage.offset = playlistpage.offset + 100;
                        playlist(playlist_id)
                    }
                }
            }
        }
        PullToRefresh {
            refreshing: playlistsongsModel.count == 0 && playlistsongs.status == false
            onRefresh: {
                offset = 0;
                playlist(playlist_id)
            }
        }
    }

    Item {
        id: indicat
        anchors.centerIn: parent
        opacity: playlistsongsModel.count == 0 && playlistsongs.status == false ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SlowDuration
            }
        }

        ActivityIndicator {
            id: activity
            running: true
        }
    }
}
