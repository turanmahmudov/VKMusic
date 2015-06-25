import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import Ubuntu.Components.Popups 1.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../js/scripts.js" as Scripts

Item {
    id: mytracks

    property var offset : 0

    function get_tracks() {
        Scripts.my_tracks(offset);
    }

    ListModel {
        id: myTracksModel
    }

    ListView {
        id:myTracksList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : 0

        model:myTracksModel

        delegate: ListItem.Empty {
            id: itemsDelegate

            removable: true
            confirmRemoval: true
            onItemRemoved: Scripts.delete_song(id, owner_id)

            width: parent.width
            height: itemtitle.height + units.gu(4)

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
                        mytrackspage.offset = mytrackspage.offset + 100;
                        get_tracks();
                    }
                }
            }
            onClicked: {
                if (off != 1) {
                    queueModel.clear();
                    for (var i = 0; i < myTracksModel.count; i++) {
                        queueModel.append(myTracksModel.get(i));
                    }
                    current_song_index = index;
                    Scripts.play_song(id, title, artist, songImage, songURL);
                }
            }
        }
        PullToRefresh {
            refreshing: myTracksModel.count == 0 && myTracksList.status == 0
            onRefresh: get_tracks()
        }
    }

    Item {
        id: indicat
        anchors.centerIn: parent
        opacity: myTracksModel.count == 0 && myTracksList.status == 0 ? 1 : 0

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
