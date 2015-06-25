import QtQuick 2.0
import Ubuntu.Components 1.1
import QtMultimedia 5.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../js/scripts.js" as Scripts

Item {
    id: queue

    ListView {
        id:queuelist
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var finished : false

        model:queueModel
        delegate: ListItem.Empty {
            width: parent.width
            height: songtitle.height + artistalbum.height + units.gu(3)
            removable: true
            confirmRemoval: true
            onItemRemoved: {
                if (index < current_song_index) {
                    current_song_index = current_song_index - 1;
                } else if (index == current_song_index) {
                    if (queueModel.count == 1 || queueModel.count == 0) {
                        current_song_index = 0;

                        common_bmrgn = units.gu(0);
                        playerr.anchors.bottomMargin = units.gu(-7);

                        player.stop();
                        pausing_song = 0;
                        playing_song = 0;

                        track_title.text = '';
                        track_artist.text = '';
                        track_image.source = '';

                        pagestack.clear();
                        pagestack.push(tabs);
                    } else {
                        if (index == queueModel.count - 1) {
                            Scripts.playPrevSong();
                        } else {
                            Scripts.playNextSong();
                            current_song_index = current_song_index - 1;
                        }
                    }
                }

                queueModel.remove(index);
            }

            Item {
                id: delegateitem
                anchors.fill: parent
                width: parent.width
                Rectangle {
                    id: image
                    height: units.gu(5)
                    width: units.gu(5)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    color: "transparent"
                    Image {
                        width: parent.width
                        height: parent.height
                        source: songImage ?
                                    "http://images.gs-cdn.net/static/albums/70_" + songImage :
                                    "../graphics/70_album.png"
                    }
                }
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    anchors.left: image.right
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(2)
                    width: parent.width - units.gu(6)
                    id: songtitle
                    text: title
                    color: playing_song == id ? '#2B587A' : UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: playing_song == id ? units.gu(1.8) : units.gu(1.6)
                }
                Text {
                    anchors.top: songtitle.bottom
                    anchors.topMargin: units.gu(1)
                    anchors.left: image.right
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(2)
                    width: parent.width
                    id: artistalbum
                    text: artist
                    color: UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: units.gu(1.2)
                }
            }
            onClicked: {
                current_song_index = index;
                Scripts.play_song(id, title, artist, songImage, songURL);
            }
        }
    }
    Scrollbar {
        flickableItem: queuelist
    }
}
