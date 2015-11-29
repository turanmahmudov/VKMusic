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
    id: playls

    function get_playlists() {
        Scripts.get_playlists();
    }

    Item {
        id: playlistTools
        height: createplbutton.height
        width: parent.width

        ListItem.Standard {
            id: createplbutton
            text: i18n.tr("Create playlist")
            iconName: "add"
            iconFrame: false
            onClicked: {
                PopupUtils.open(createPlaylistDialog, pagestack);
            }
        }
    }

    ListModel {
        id: playlistsModel
    }

    ListView {
        id:playlists
        anchors.top: playlistTools.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : false

        model:playlistsModel
        delegate: ListItem.Empty {
            width: parent.width
            height: pltitle.height + units.gu(5)

            removable: true
            confirmRemoval: true
            onItemRemoved: Scripts.delete_playlist(id);

            Item {
                id: delegateitem
                anchors.fill: parent
                width: parent.width
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2.5)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2.5)
                    anchors.rightMargin: units.gu(2.5)
                    width: parent.width
                    id: pltitle
                    text: pl_name
                    color: UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: units.gu(1.5)
                }
            }
            onClicked: {
                playlistPage.title = pl_name;
                pagestack.push(playlistPage);
                playlistpage.playlist_id = id;
                playlistpage.playlist_name = pl_name;
                playlistpage.playlist(id);
            }
        }
    }

    Item {
        id: indicat
        anchors.centerIn: parent
        opacity: playlistsModel.count == 0 && playlists.status == false ? 1 : 0

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
