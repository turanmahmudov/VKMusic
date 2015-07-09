import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.DownloadManager 0.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import "components"
import "js/scripts.js" as Scripts

MainView {
    id: mainView
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "vkmusic.turan-mahmudov-l"

    // Rotation
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    anchorToKeyboard: true

    width: units.gu(50)
    height: units.gu(75)

    // Account
    property bool is_logged : false

    // Content Transfer
    property var contentTransfer;
    property list<ContentItem> transferItemList

    // Now playing
    property var nowPlayingSong : {"id":"", "SongName":"", "ArtistName":"", "SongURL":"", "SongImage":""}
    property bool repeatSong : false
    property bool shuffleSongs : false

    property var playing_song : 0
    property var pausing_song : 0
    property var current_song_index

    // First run
    //property var firstRun : Scripts.getKey("firstRun")

    property var common_bmrgn : 0
    property var artistArt

    // Lyrics
    property var lyric_title
    property var lyric_text

    // Actions
    actions: [
        Action {
            id: searchAction
            text: i18n.tr("Search")
            iconName: "search"
            onTriggered: {
                pagestack.push(searchPage);
            }
        },
        Action {
            id: logoutAction
            text: i18n.tr("Sign out")
            iconName: "lock"
            onTriggered: {
                Scripts.logout();
            }
        }
    ]

    function home() {
        Scripts.initializeUser();

        // Check user
        if (Scripts.getKey('access_token') && Scripts.getKey('user_id')) {
            is_logged = true;
            pagestack.clear();
            pagestack.push(tabs);

            popularpage.get_popular();
            mytrackspage.get_tracks();
            playlistspage.get_playlists();
            friendspage.get_friends();

        } else {
            pagestack.push(Qt.resolvedUrl("ui/LoginPage.qml"));
        }

        /*if (firstRun != "1") {
            var comp = Qt.createComponent("components/Walkthrough/FirstRunWalkthrough.qml")
            var walkthrough = comp.createObject(pagestack, {});
            pagestack.push(walkthrough)
        }*/
    }

    // Queue
    ListModel {
        id: queueModel
    }
    function playNextSong() {
        if (shuffleSongs) {
            current_song_index = getShuffleIndex();
        }

        var id = queueModel.get(current_song_index+1).id;
        var title = queueModel.get(current_song_index+1).title;
        var artist = queueModel.get(current_song_index+1).artist;
        var song_image = queueModel.get(current_song_index+1).songImage;
        var song_url = queueModel.get(current_song_index+1).songURL;

        current_song_index = current_song_index+1;
        Scripts.play_song(id, title, artist, song_image, song_url);
    }
    function playPrevSong() {
        if (shuffleSongs) {
            current_song_index = getShuffleIndex();
        }

        var id = queueModel.get(current_song_index-1).id;
        var title = queueModel.get(current_song_index-1).title;
        var artist = queueModel.get(current_song_index-1).artist;
        var song_image = queueModel.get(current_song_index-1).songImage;
        var song_url = queueModel.get(current_song_index-1).songURL;

        current_song_index = current_song_index-1;
        Scripts.play_song(id, title, artist, song_image, song_url);
    }
    function getShuffleIndex() {
        var newIndex;

        var now = new Date();
        var seed = now.getSeconds();

        do {
            newIndex = (Math.floor((queueModel.count)
                                   * Math.random(seed)));
        } while (newIndex === current_song_index && queueModel.count > 1)

        return newIndex;
    }
    function doRepeatSong() {
        var id = queueModel.get(current_song_index).id;
        var title = queueModel.get(current_song_index).title;
        var artist = queueModel.get(current_song_index).artist;
        var song_image = queueModel.get(current_song_index).songImage;
        var song_url = queueModel.get(current_song_index).songURL;

        current_song_index = current_song_index;
        Scripts.play_song(id, title, artist, song_image, song_url);
    }

    // Player
    Rectangle {
        id: playerr
        z: 100000
        visible: pagestack.currentPage.title !== i18n.tr("Now playing")
        width: parent.width
        height: units.gu(7)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(-7)
        color: "#2B587A"
        Image {
            anchors.left: parent.left
            anchors.leftMargin: units.gu(1)
            anchors.top: parent.top
            anchors.topMargin: units.gu(1)
            height: source ? units.gu(5) : 0
            width: source ? height : 0
            id: track_image
            source: artistArt ? artistArt : "graphics/70_album.png"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (pagestack.currentPage.title !== i18n.tr("Queue")) {
                        pagestack.push(nowPlayingPage);
                    }
                }
            }
        }
        Text {
            id: track_title
            color: "white"
            font.bold: true
            font.pointSize: units.gu(1.3)
            anchors.top: parent.top
            anchors.topMargin: units.gu(1)
            anchors.left: track_image.source != "" ? track_image.right : parent.left
            anchors.leftMargin: units.gu(1)
            width: parent.width-controlsrow.width-units.gu(7)
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (pagestack.currentPage.title !== i18n.tr("Queue")) {
                        pagestack.push(nowPlayingPage);
                    }
                }
            }
        }
        Text {
            id: track_artist
            color: "white"
            font.pointSize: units.gu(1)
            anchors.top: track_title.bottom
            anchors.topMargin: units.gu(0.5)
            anchors.left: track_image.source != "" ? track_image.right : parent.left
            anchors.leftMargin: units.gu(1)
            width: parent.width-controlsrow.width-units.gu(7)
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (pagestack.currentPage.title !== i18n.tr("Queue")) {
                        pagestack.push(nowPlayingPage);
                    }
                }
            }
        }

        Rectangle {
            id: playingstate
            height: units.gu(0.3)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            color: "#F86F05"
            z: 100003
        }

        Rectangle {
            id: playingstatebuffer
            visible: false
            height: units.gu(0.3)
            width: mainView.width*player.bufferProgress
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            color: "#ffffff"
            z: 100002
        }

        Row {
            id: controlsrow
            z: 100000
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            Rectangle {
                z: 100000
                visible: true
                width: units.gu(3.5)
                height: playerr.height
                color: "transparent"
                Icon {
                    name: "media-skip-backward"
                    color: "#fff"
                    width: units.gu(2.5)
                    height: width
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                         Scripts.playPrevSong();
                    }
                }
            }
            Rectangle {
                z: 100000
                width: units.gu(3.5)
                height: playerr.height
                color: "transparent"
                Icon {
                    id: play_button
                    name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                    color: "#fff"
                    width: units.gu(2.5)
                    height: width
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (player.playbackState === MediaPlayer.PlayingState) {
                            Scripts.pause_song(playing_song);
                        } else {
                            Scripts.unpause_song(playing_song);
                        }
                    }
                }
            }
            Rectangle {
                z: 100000
                visible: true
                width: units.gu(3.5)
                height: playerr.height
                color: "transparent"
                Icon {
                    name: "media-skip-forward"
                    color: "#fff"
                    width: units.gu(2.5)
                    height: width
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Scripts.playNextSong();
                    }
                }
            }
        }
    }
    NumberAnimation { id: playeropen; target: playerr; property: "anchors.bottomMargin"; duration: 200; from: units.gu(-7); to: 0; }

    // Rename downloaded song
    Component {
        id: transferComponent
        ContentItem { }
    }
    // Transfer downloaded song to Music app
    Component {
        id: downloadDialog
        ContentDownloadDialog { }
    }

    // Add to playlists
    ListModel {
        id: aplayModel
    }
    Component {
        id: addtoplaylistDialog

        Popover {
            id: addtoplaylistDialogue
            Item {
                id: addtoplaylistLayout
                width: parent.width
                height: aplay.contentHeight > width ? width : aplay.contentHeight + units.gu(6)
                anchors {
                    left: parent.left
                    top: parent.top
                }

                Item {
                    id: playlistTools
                    height: createplbutton.height
                    width: parent.width

                    ListItem.Standard {
                        id: createplbutton
                        text: i18n.tr("Create playlist")
                        onClicked: {
                            PopupUtils.open(createPlaylistDialog, pagestack);
                            PopupUtils.close(addtoplaylistDialogue);
                        }
                    }
                }

                ListView {
                    id:aplay
                    anchors.top: playlistTools.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    clip: true

                    model:aplayModel
                    delegate: ListItem.Empty {
                        width: parent.width
                        height: pltitle.height + units.gu(3)
                        Item {
                            id: delegateitem
                            anchors.fill: parent
                            width: parent.width
                            Text {
                                anchors.top: parent.top
                                anchors.topMargin: units.gu(1)
                                anchors.left: parent.left
                                anchors.leftMargin: units.gu(2)
                                anchors.rightMargin: units.gu(2)
                                width: parent.width
                                id: pltitle
                                text: title
                                color: UbuntuColors.darkGrey
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.pointSize: units.gu(1.4)
                            }
                        }
                        onClicked: {
                            Scripts.addToPlaylist(id, song_id);
                            PopupUtils.close(addtoplaylistDialogue);
                        }
                    }
                }
                Scrollbar {
                    flickableItem: aplay
                }
            }
        }
    }

    // Create playlist dialog
    Component {
        id: createPlaylistDialog

        Dialog {
            id: createPlaylistDialogue
            title: i18n.tr("Create playlist")

            Flickable {
                id: flickable
                width: parent.width
                height: units.gu(15)
                clip: true
                contentHeight: crtplylst.height

                Column {
                    id: crtplylst
                    width: parent.width

                    Label {
                        id: nameLabel
                        anchors.left: parent.left
                        anchors.top: parent.top
                        text: i18n.tr("Name:")
                    }
                    TextField {
                        id: sname
                        width: parent.width
                        anchors.left: parent.left
                        anchors.top: nameLabel.bottom
                        anchors.topMargin: units.gu(1)
                    }
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    PopupUtils.close(createPlaylistDialogue)
                }
            }

            Button {
                text: i18n.tr("Create")
                color: "#F86F05"
                onClicked: {
                    Scripts.createPlaylist(sname.text);
                    PopupUtils.close(createPlaylistDialogue);
                }
            }
        }
    }

    // Error
    Component {
        id: errorDialog

        Dialog {
            id: errorDialogue
            text: i18n.tr("An error occured")

            Button {
                text: i18n.tr("Close")
                color: "#F86F05"
                onClicked: {
                    PopupUtils.close(errorDialogue)
                }
            }
        }
    }

    // Lyrics Dialog
    Component {
        id: lyricDialog

        Dialog {
            id: lyricDialogue
            title: lyric_title

            Flickable {
                id: flickable
                width: parent.width
                height: units.gu(35)
                clip: true
                contentHeight: lyricColumn.height

                Column {
                    id: lyricColumn
                    width: parent.width

                    Text {
                        width: parent.width
                        text: mainView.lyric_text
                        wrapMode: Text.WordWrap
                        font.pointSize: units.gu(1.32)
                    }
                }
            }

            Button {
                text: i18n.tr("Close")
                color: "#F86F05"
                onClicked: {
                    PopupUtils.close(lyricDialogue)
                }
            }
        }
    }

    Audio {
        id: player
        onVolumeChanged: {  }
        onSourceChanged: {  }
        onStopped: {
            if(status == Audio.EndOfMedia) {
                playingstate.width = 0;
                if (repeatSong) {
                    doRepeatSong();
                } else {
                    Scripts.playNextSong();
                }
            }
        }
        onPositionChanged: {
            playingstate.width=mainView.width*(position/duration);
        }
        onBufferProgressChanged: { }
        onPlaybackStateChanged: { }
    }

    SingleDownload {
        id: dmanager

        property var title

        onFinished: {
            // Path to move file
            var pathArray = path.split("/");
            var newpath = "";
            for (var i = 1; i < pathArray.length-1; i++) {
                newpath = newpath + "/" + pathArray[i];
            }

            // File
            var filename = dmanager.title + ".mp3";
            filename = filename.replace("/", "_");
            filename = filename.replace("?", "_");

            contentTransfer = [];
            transferItemList = [transferComponent.createObject(mainView, {"url": path}) ]
            contentTransfer.items = transferItemList;
            contentTransfer.state = ContentTransfer.Charged;

            var importItems = contentTransfer.items;

            importItems[0].move(newpath, filename);

            //active_download = 0

            PopupUtils.open(downloadDialog, pagestack, {"contentType" : ContentType.Music, "downloadId" : dmanager.downloadId, "path" : newpath+"/"+filename})

        }
    }

    Item {
        id: activityItem
        z: 100000
        anchors.centerIn: parent
        opacity: 0

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

    PageStack {
        id: pagestack

        Component.onCompleted: {
            home();
        }
    }

    Tabs {
        id: tabs
        visible: false

        Tab {
            title: i18n.tr("My tracks")
            page: Page {
                id: myTracksPage
                head.actions: [searchAction, logoutAction]

                MyTracks {
                    id: mytrackspage
                    anchors.fill:parent
                    anchors.bottomMargin: common_bmrgn
                }
            }
        }

        Tab {
            title: i18n.tr("Popular")
            page: Page {
                id: popularPage
                head.actions: [searchAction, logoutAction]

                PopularSongs {
                    id: popularpage
                    anchors.fill:parent
                    anchors.bottomMargin: common_bmrgn
                }
            }
        }

        Tab {
            title: i18n.tr("Playlists")
            page: Page {
                id: playlistsPage
                head.actions: [searchAction, logoutAction]

                Playlists {
                    id: playlistspage
                    anchors.fill:parent
                    anchors.bottomMargin: common_bmrgn
                }
            }
        }

        Tab {
            title: i18n.tr("Friends")
            page: Page {
                id: friendsPage
                head.actions: [searchAction, logoutAction]

                Friends {
                    id: friendspage
                    anchors.fill:parent
                    anchors.bottomMargin: common_bmrgn
                }
            }
        }

        Tab {
            title: i18n.tr("Downloads")
            page: Page {
                id: downloadsPage
                head.actions: [searchAction, logoutAction]

                Item {
                    anchors.fill: parent
                    anchors.bottomMargin: common_bmrgn

                    ProgressBar {
                        minimumValue: 0
                        maximumValue: 100
                        value: dmanager.progress
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            leftMargin: units.gu(1)
                            rightMargin: units.gu(1)
                            topMargin: units.gu(1)
                        }
                    }
                }
            }
        }

        Tab {
            title: i18n.tr("About")
            page: Page {
                id: aboutPage
                head.actions: [searchAction, logoutAction]

                About {
                    id:aboutpage
                    anchors.fill:parent
                    anchors.bottomMargin: common_bmrgn
                }
            }
        }
    }

    Page {
        id: nowPlayingPage
        title: i18n.tr("Now playing")
        visible: false
        head.actions: [
            Action {
                id: gotoQueueAction
                iconName: "view-list-symbolic"
                onTriggered: {
                    pagestack.push(queuePage);
                }
            }
        ]

        NowPlaying {
            id: nowplayingpage
            anchors.fill: parent
        }
    }

    Page {
        id: queuePage
        title: i18n.tr("Queue")
        visible: false
        head.actions: [
            Action {
                id: clearQueueAction
                iconName: "delete"
                onTriggered: {
                    queueModel.clear();

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
                }
            }
        ]

        QueuePage {
            id: queuepage
            anchors.fill: parent
            anchors.bottomMargin: common_bmrgn
        }
    }

    Page {
        id: searchPage
        title: i18n.tr("Search")
        visible: false

        Search {
            id: searchpage
            anchors.fill: parent
            anchors.bottomMargin: common_bmrgn
        }
    }

    Page {
        id: playlistPage
        head.actions: [searchAction, logoutAction]
        visible: false

        Playlist {
            id:playlistpage
            anchors.fill:parent
            anchors.bottomMargin: common_bmrgn
        }
    }

    Page {
        id: friendSongsPage
        title: i18n.tr("Friend")
        head.actions: [searchAction, logoutAction]
        visible: false

        FriendSongs {
            id:friendsongspage
            anchors.fill:parent
            anchors.bottomMargin: common_bmrgn
        }
    }
}

