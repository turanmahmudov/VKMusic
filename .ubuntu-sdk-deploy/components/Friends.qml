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
    id: friends

    function get_friends() {
        Scripts.get_friends();
    }

    ListModel {
        id: friendsModel
    }

    ListView {
        id:friendsList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : false

        model:friendsModel
        delegate: ListItem.Empty {
            width: parent.width
            height: pltitle.height + units.gu(5)

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
                    text: name
                    color: UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pointSize: units.gu(1.5)
                }
            }
            onClicked: {
                friendsongspage.offset = 0;
                friendsongspage.userid = id;
                friendsongspage.get_friend_tracks(id);
                friendSongsPage.title = name;
                pagestack.push(friendSongsPage);
            }
        }
    }

    Item {
        id: indicat
        anchors.centerIn: parent
        opacity: friendsModel.count == 0 && friendsList.status == false ? 1 : 0

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
