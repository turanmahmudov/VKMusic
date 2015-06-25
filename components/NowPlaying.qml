import QtQuick 2.0
import Ubuntu.Components 1.1
import QtMultimedia 5.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1
import QtQuick.LocalStorage 2.0
import "Themes"
import "../js/scripts.js" as Scripts

Item {
    id: nowPlaying

    property var np_id : queueModel.count > 0 ? queueModel.get(current_song_index).id : ''
    property var np_title : queueModel.count > 0 ? queueModel.get(current_song_index).title : ''
    property var np_artistName : queueModel.count > 0 ? queueModel.get(current_song_index).artist : ''
    property var np_lyrics_id : queueModel.count > 0 ? queueModel.get(current_song_index).lyrics_id : ''
    property var np_genre : queueModel.count > 0 ? queueModel.get(current_song_index).genre : ''
    property var np_owner_id : queueModel.count > 0 ? queueModel.get(current_song_index).owner_id : ''

    function durationToString(duration) {
        var minutes = Math.floor((duration/1000) / 60);
        var seconds = Math.floor((duration/1000)) % 60;
        // Make sure that we never see "NaN:NaN"
        if (minutes.toString() == 'NaN')
            minutes = 0;
        if (seconds.toString() == 'NaN')
            seconds = 0;
        return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
    }

    Item {
        id: covertArtBackground
        width: parent.width
        height: parent.width > parent.height ? parent.height - units.gu(18) : parent.width - units.gu(2)

        Rectangle {
            id: coverImage
            width: parent.width
            height: parent.height
            color: "transparent"

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                clip: true
                source: artistArt ? artistArt :
                                    "../graphics/500_album.png"
            }
        }

        Rectangle {
            id: labelsBackground
            anchors.bottom: parent.bottom
            color: "#2B587A"
            height: songTitle.lineCount === 1 ? units.gu(10) : units.gu(13)
            opacity: 0.8
            width: parent.width
        }

        Column {
            id: labels
            spacing: units.gu(1)
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
                top: labelsBackground.top
                topMargin: songTitle.lineCount === 1 ? units.gu(2) : units.gu(1.5)
            }

            Label {
                id: songTitle
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
                color: "#ffffff"
                elide: Text.ElideRight
                fontSize: "x-large"
                maximumLineCount: 2
                text: nowPlayingSong.SongName
                wrapMode: Text.WordWrap
            }

            Label {
                id: songArtistAlbum
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
                color: "#ffffff"
                elide: Text.ElideRight
                fontSize: "small"
                text: nowPlayingSong.ArtistName
            }
        }

        /* Detect cover art swipe */
        MouseArea {
            anchors.fill: parent
            property string direction: "None"
            property real lastX: -1

            onPressed: lastX = mouse.x

            onReleased: {
                var diff = mouse.x - lastX
                if (Math.abs(diff) < units.gu(4)) {
                    return;
                } else if (diff < 0) {
                    Scripts.playNextSong()
                } else if (diff > 0) {
                    Scripts.playPrevSong()
                }
            }
        }
    }

    Rectangle {
        id: toolbarBackground
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: covertArtBackground.bottom
        }
        color: "#2B587A"
    }

    Rectangle {
        id: detailed
        visible: true
        width: parent.width
        height: units.gu(7)
        anchors.top: covertArtBackground.bottom
        anchors.left: parent.left
        color: "#2B587A"
        Flickable {
            id: flickableh

            anchors.fill: parent
            contentWidth: buttons.width;
            contentHeight: flickableh.height
            Item {
                id: buttons
                width: downloadButton.width + lyricsButton.width + artistButton.width + collectionButton.width + pylButton.width + units.gu(16) + units.gu(6)
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                Rectangle {
                    width: units.gu(5)
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    id: downloadButton
                    color: "transparent"
                    Icon {
                        id: downloadIcon
                        width: units.gu(3)
                        height: units.gu(3)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "save"
                        color: "#fff"
                    }
                    Label {
                        id: downloadLabel
                        text: "Download"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "x-small"
                        color: "#fff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dmanager.title = nowPlayingSong.SongName;
                            dmanager.download(nowPlayingSong.SongURL);
                        }
                    }
                }
                Rectangle {
                    width: units.gu(5)
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: downloadButton.right
                    anchors.leftMargin: units.gu(4)
                    id: artistButton
                    color: "transparent"
                    Icon {
                        width: units.gu(3)
                        height: units.gu(3)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../graphics/microphone.png"
                        color: "#fff"
                    }
                    Label {
                        text: "Artist"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "x-small"
                        color: "#fff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pagestack.push(searchPage);
                            searchpage.get_search(nowPlayingSong.ArtistName);
                        }
                    }
                }
                Rectangle {
                    width: units.gu(5)
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: artistButton.right
                    anchors.leftMargin: units.gu(4)
                    id: collectionButton
                    color: "transparent"
                    Icon {
                        width: units.gu(3)
                        height: units.gu(3)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "tick"
                        color: "#fff"
                    }
                    Label {
                        text: i18n.tr("Library")
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "x-small"
                        color: "#fff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Scripts.addToLibrary(np_id, np_owner_id);
                        }
                    }
                }
                Rectangle {
                    width: units.gu(5)
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: collectionButton.right
                    anchors.leftMargin: units.gu(4)
                    id: pylButton
                    color: "transparent"
                    Icon {
                        width: units.gu(3)
                        height: units.gu(3)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "media-playlist"
                        color: "#fff"
                    }
                    Label {
                        text: "Playlist"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "x-small"
                        color: "#fff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Scripts.getPlaylists(np_id);
                            // TODO : popup must be stay in center
                            PopupUtils.open(addtoplaylistDialog, pagestack);
                        }
                    }
                }
                Rectangle {
                    width: units.gu(5)
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: pylButton.right
                    anchors.leftMargin: units.gu(4)
                    id: lyricsButton
                    color: "transparent"
                    Icon {
                        width: units.gu(3)
                        height: units.gu(3)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../graphics/edit-select-all.svg"
                        color: "#fff"
                    }
                    Label {
                        text: "Lyrics"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        fontSize: "x-small"
                        color: "#fff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Scripts.getLyrics(np_lyrics_id, nowPlayingSong.ArtistName, nowPlayingSong.SongName);
                        }
                    }
                }
            }
        }
    }

    Item {
        id: toolbarContainer
        anchors.left: parent.left
        anchors.leftMargin: units.gu(3)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(3)
        anchors.top: detailed.bottom
        height: units.gu(2)
        width: parent.width

        Label {
            id: toolbarPositionLabel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: units.gu(1.4)
            color: "#ffffff"
            fontSize: "small"
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            text: durationToString(player.position)
            verticalAlignment: Text.AlignVCenter
            width: units.gu(3)
        }

        Slider {
            id: progressSliderMusic
            anchors.left: toolbarPositionLabel.right
            anchors.leftMargin: units.gu(1)
            anchors.right: toolbarDurationLabel.left
            anchors.rightMargin: units.gu(1)
            maximumValue: player.duration  // load value at startup
            value: player.position  // load value at startup
            style: UbuntuBlueSliderStyle {}

            function formatValue(v) {
                if (seeking) {  // update position label while dragging
                    toolbarPositionLabel.text = durationToString(v)
                }

                return durationToString(v)
            }

            property bool seeking: false
            property bool seeked: false

            onSeekingChanged: {
                if (seeking === false) {
                    toolbarDurationLabel.text = durationToString(player.position)
                }
            }

            onPressedChanged: {
                seeking = pressed

                if (!pressed) {
                    seeked = true
                    player.seek(value)

                    toolbarPositionLabel.text = durationToString(value)
                }
            }

            Connections {
                target: player
                onPositionChanged: {
                    // seeked is a workaround for bug 1310706 as the first position after a seek is sometimes invalid (0)
                    if (progressSliderMusic.seeking === false && !progressSliderMusic.seeked) {
                        toolbarPositionLabel.text = durationToString(player.position)
                        toolbarDurationLabel.text = durationToString(player.duration)

                        progressSliderMusic.value = player.position
                        progressSliderMusic.maximumValue = player.duration
                    }

                    progressSliderMusic.seeked = false;
                }
                onStopped: {
                    toolbarPositionLabel.text = durationToString(0);
                    toolbarDurationLabel.text = durationToString(0);
                }
            }
        }

        /* Duration label */
        Label {
            id: toolbarDurationLabel
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: units.gu(1.4)
            color: "#ffffff"
            fontSize: "small"
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            text: durationToString(player.duration)
            verticalAlignment: Text.AlignVCenter
            width: units.gu(3)
        }
    }

    /* Full toolbar */
    Rectangle {
        id: musicToolbarFullContainer
        anchors.bottom: parent.bottom
        color: "#2B587A"
        height: units.gu(7)
        width: parent.width

        /* Repeat button */
        MouseArea {
            id: nowPlayingRepeatButton
            anchors.right: nowPlayingPreviousButton.left
            anchors.rightMargin: units.gu(1)
            anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
            height: units.gu(6)
            opacity: repeatSong ? 1 : .4
            width: height
            onClicked: repeatSong = !repeatSong

            Icon {
                id: repeatIcon
                height: units.gu(3)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                name: "media-playlist-repeat"
                opacity: repeatSong ? 1 : .4
            }
        }

        /* Previous button */
        MouseArea {
            id: nowPlayingPreviousButton
            anchors.right: nowPlayingPlayButton.left
            anchors.rightMargin: units.gu(1)
            anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
            height: units.gu(6)
            opacity: 1
            width: height
            onClicked: Scripts.playPrevSong()

            Icon {
                id: nowPlayingPreviousIndicator
                height: units.gu(3)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                name: "media-skip-backward"
                opacity: 1
            }
        }

        /* Play/Pause button */
        MouseArea {
            id: nowPlayingPlayButton
            anchors.centerIn: parent
            height: units.gu(6)
            width: height
            onClicked: {
                if (player.playbackState === MediaPlayer.PlayingState) {
                    Scripts.pause_song(playing_song);
                } else {
                    Scripts.unpause_song(playing_song);
                }
            }

            Icon {
                id: nowPlayingPlayIndicator
                height: units.gu(5)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 1
                color: "white"
                name: player.playbackState === MediaPlayer.PlayingState ?
                          "media-playback-pause" :
                          "media-playback-start"
            }
        }

        /* Next button */
        MouseArea {
            id: nowPlayingNextButton
            anchors.left: nowPlayingPlayButton.right
            anchors.leftMargin: units.gu(1)
            anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
            height: units.gu(6)
            opacity: 1
            width: height
            onClicked: Scripts.playNextSong()

            Icon {
                id: nowPlayingNextIndicator
                height: units.gu(3)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                name: "media-skip-forward"
                opacity: 1
            }
        }

        /* Shuffle button */
        MouseArea {
            id: nowPlayingShuffleButton
            anchors.left: nowPlayingNextButton.right
            anchors.leftMargin: units.gu(1)
            anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
            height: units.gu(6)
            opacity: shuffleSongs ? 1 : .4
            width: height
            onClicked: shuffleSongs = !shuffleSongs

            Icon {
                id: shuffleIcon
                height: units.gu(3)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                name: "media-playlist-shuffle"
                opacity: shuffleSongs ? 1 : .4
            }
        }
    }
}
