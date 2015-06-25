// DB
function _getDB() {
    return LocalStorage.openDatabaseSync("VKMusic", "1.0", "VK Music Database", 2048)
}

function initializeUser() {
    var user = _getDB();
    user.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS user(key TEXT UNIQUE, value TEXT)');
                });
}
// This function is used to write a key into the database
function setKey(key, value) {
    var db = _getDB();
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO user VALUES (?,?);', [key,""+value]);
        if (rs.rowsAffected == 0) {
            throw "Error updating key";
        } else {
            //console.log("User record updated:"+key+" = "+value);
        }
    });
}
// This function is used to retrieve a key from the database
function getKey(key) {
    var db = _getDB();
    var returnValue = undefined;

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM user WHERE key=?;', [key]);
        if (rs.rows.length > 0)
          returnValue = rs.rows.item(0).value;
    })

    return returnValue;
}
// This function is used to delete a key from the database
function deleteKey(key) {
    var db = _getDB();

    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM user WHERE key=?;', [key]);
    })
}

function popular_songs(offset) {
    if (offset == 0) { popularSongsModel.clear(); }
    popularSongsList.status = 0;

    if (offset > 0) { popularSongsModel.remove(popularSongsModel.count-1); }

    var url = 'https://api.vk.com/method/audio.getPopular';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]); i++) {
                        var id = results[j][i]['id'];
                        var artistName = results[j][i]['artist'];
                        var songName = results[j][i]['title'];
                        var songURL = results[j][i]['url'];
                        var lyrics_id = results[j][i]['lyrics_id'];
                        var genre = results[j][i]['genre_id'];
                        var owner_id = results[j][i]['owner_id'];
                        var songImage = "";
                        popularSongsModel.append({"title":songName, "artist":artistName, "id":id, "ii":ii, "songImage":songImage, "songURL":songURL, "lyrics_id":lyrics_id, "genre":genre, "owner_id":owner_id});
                        ii++;
                    }

                    if (popularSongsModel.count > offset) { popularSongsModel.append({"off":"1"}); }
                }
            }

            popularSongsList.status = 1;
        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('only_eng=1&offset='+offset+'&count=100&v=5.33&access_token='+getKey('access_token'));
}

function my_tracks(offset) {
    if (offset == 0) { myTracksModel.clear(); }
    myTracksList.status = 0;

    if (offset > 0) { myTracksModel.remove(myTracksModel.count-1); }

    var url = 'https://api.vk.com/method/audio.get';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]['items']); i++) {
                        var id = results[j]['items'][i]['id'];
                        var artistName = results[j]['items'][i]['artist'];
                        var songName = results[j]['items'][i]['title'];
                        var songURL = results[j]['items'][i]['url'];
                        var lyrics_id = results[j]['items'][i]['lyrics_id'];
                        var genre = results[j]['items'][i]['genre_id'];
                        var owner_id = results[j]['items'][i]['owner_id'];
                        var songImage = "";
                        myTracksModel.append({"title":songName, "artist":artistName, "id":id, "ii":ii, "songImage":songImage, "songURL":songURL, "lyrics_id":lyrics_id, "genre":genre, "owner_id":owner_id});
                        ii++;
                    }
                }
            }

            if (myTracksModel.count > offset) { myTracksModel.append({"off":"1"}); }

            myTracksList.status = 1;
        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('need_user=0&offset='+offset+'&count=100&v=5.33&access_token='+getKey('access_token'));
}

function searchTracks(query) {
    searchSongsModel.clear();
    searchSongsList.status = 0;

    var url = 'https://api.vk.com/method/audio.search';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]['items']); i++) {
                        var id = results[j]['items'][i]['id'];
                        var artistName = results[j]['items'][i]['artist'];
                        var songName = results[j]['items'][i]['title'];
                        var songURL = results[j]['items'][i]['url'];
                        var lyrics_id = results[j]['items'][i]['lyrics_id'];
                        var genre = results[j]['items'][i]['genre_id'];
                        var owner_id = results[j]['items'][i]['owner_id'];
                        var songImage = "";
                        searchSongsModel.append({"title":songName, "artist":artistName, "id":id, "ii":ii, "songImage":songImage, "songURL":songURL, "lyrics_id":lyrics_id, "genre":genre, "owner_id":owner_id});
                        ii++;
                    }
                }
            }

            searchSongsList.status = 1;
        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('q='+query+'&offset=0&auto_complete=1&count=100&v=5.33&access_token='+getKey('access_token'));
}

function play_song(id, title, artist, simage, surl) {
    activityItem.opacity = 1;

    nowPlayingSong = {"id":id, "SongName":title, "ArtistName":artist, "SongURL":surl, "SongImage":simage};

    if (pausing_song == 0 && playing_song == 0) {
        playeropen.start();
        common_bmrgn = units.gu(7);
    }

    player.source = surl;
    player.play();
    pausing_song = 0;
    playing_song = id;

    track_title.text = title;
    track_artist.text = artist;
    getArtistArt(artist);

    activityItem.opacity = 0;
}

function play(url, title, id, songtitle, artist_album, songimage) {


    track_title.text = songtitle;
    track_artist.text = artist_album;
    if (songimage && songimage != "") {
        track_image.source = "http://images.gs-cdn.net/static/albums/70_"+songimage;
    } else {
        track_image.source = "../graphics/70_album.png"
    }

    activityItem.opacity = 0;
}

function pause_song(id) {
    player.pause();
    pausing_song = id;
}

function unpause_song(id) {
    player.play();
    pausing_song = 0;
}

function playNextSong() {
    mainView.playNextSong();
}

function playPrevSong() {
    mainView.playPrevSong();
}

function getArtistArt(query) {
    var url = 'http://ws.audioscrobbler.com/2.0';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            var pr = results['results']['artistmatches']['artist']['image'][4];
            artistArt = pr['#text'];

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('method=artist.search&format=json&api_key=3d5c06ebfd58e0ab97a81ec3cc356e67&artist='+query+'&limit=1');
}

function getLyrics(id, artist, song) {
    activityItem.opacity = 1;

    var url = 'https://api.vk.com/method/audio.getLyrics';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            activityItem.opacity = 0;
                var results = JSON.parse(xhr.responseText);

                lyric_text = results['response']['text'];
                lyric_title = artist + " - " + song;
                PopupUtils.open(lyricDialog, mainView, {"lyric_text" : lyric_text, "lyric_title" : artist + " - " + song});
        }
    };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    xhr.send('lyrics_id='+id+'&v=5.33&access_token='+getKey('access_token'));
}

function addToLibrary(id, owner_id) {
    activityItem.opacity = 1;

    var url = 'https://api.vk.com/method/audio.add';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            activityItem.opacity = 0;
                var results = JSON.parse(xhr.responseText);

                mytrackspage.get_tracks();
        }
    };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    xhr.send('audio_id='+id+'&owner_id='+owner_id+'&v=5.33&access_token='+getKey('access_token'));
}

// Playlists
function getPlaylists(song_id) {
    aplayModel.clear();

    var url = 'https://api.vk.com/method/audio.getAlbums';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]['items']); i++) {
                        var id = results[j]['items'][i]['id'];
                        var title = results[j]['items'][i]['title'];
                        aplayModel.append({"title":title, "id":id, "ii":ii, "song_id":song_id});
                        ii++;
                    }
                }
            }

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('owner_id='+getKey('user_id')+'&offset=0&count=100&v=5.33&access_token='+getKey('access_token'));
}

function addToPlaylist(pl_id, song_id) {
    var url = 'https://api.vk.com/method/audio.moveToAlbum';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('album_id='+pl_id+'&audio_ids='+song_id+'&v=5.33&access_token='+getKey('access_token'));
}

function createPlaylist(title) {
    var url = 'https://api.vk.com/method/audio.addAlbum';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            console.log(xhr.responseText)

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('title='+title+'&v=5.33&access_token='+getKey('access_token'));
}

function get_playlists() {
    playlistsModel.clear();
    playlists.status = false;

    var url = 'https://api.vk.com/method/audio.getAlbums';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]['items']); i++) {
                        var id = results[j]['items'][i]['id'];
                        var title = results[j]['items'][i]['title'];
                        playlistsModel.append({"pl_name":title, "id":id, "ii":ii});
                        ii++;
                    }
                }
            }

            playlists.status = true;
        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('owner_id='+getKey('user_id')+'&offset=0&count=100&v=5.33&access_token='+getKey('access_token'));
}

function get_playlist_by_id(id, offset) {
    if (offset == 0) { playlistsongsModel.clear(); }
    playlistsongs.status = 0;

    if (offset > 0) { playlistsongsModel.remove(playlistsongsModel.count-1); }

    var url = 'https://api.vk.com/method/audio.get';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            var j;
            for (j in results) {
                if (j == 'response') {
                    var ii = 0;
                    for (var i = 0; i < objLength(results[j]['items']); i++) {
                        var id = results[j]['items'][i]['id'];
                        var artistName = results[j]['items'][i]['artist'];
                        var songName = results[j]['items'][i]['title'];
                        var songURL = results[j]['items'][i]['url'];
                        var lyrics_id = results[j]['items'][i]['lyrics_id'];
                        var genre = results[j]['items'][i]['genre_id'];
                        var owner_id = results[j]['items'][i]['owner_id'];
                        var songImage = "";
                        playlistsongsModel.append({"title":songName, "artist":artistName, "id":id, "ii":ii, "songImage":songImage, "songURL":songURL, "lyrics_id":lyrics_id, "genre":genre, "owner_id":owner_id});
                        ii++;
                    }
                }
            }

            if (playlistsongsModel.count > offset) { playlistsongsModel.append({"off":"1"}); }

            playlistsongs.status = 1;
        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('album_id='+id+'&need_user=0&offset='+offset+'&count=100&v=5.33&access_token='+getKey('access_token'));
}

function delete_playlist(id) {
    activityItem.opacity = 1;

    var url = 'https://api.vk.com/method/audio.deleteAlbum';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            activityItem.opacity = 0;

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('album_id='+id+'&v=5.33&access_token='+getKey('access_token'));
}

function delete_song(id, owner_id) {
    activityItem.opacity = 1;

    var url = 'https://api.vk.com/method/audio.delete';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4)
            // Must be edit
            var results = JSON.parse(xhr.responseText);
            //console.log(xhr.responseText)

            activityItem.opacity = 0;

        };
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    // send the collected data as JSON
    xhr.send('audio_id='+id+'&owner_id='+owner_id+'&v=5.33&access_token='+getKey('access_token'));
}

function logout() {
    deleteKey('access_token');
    deleteKey('user_id');
    home();
}

function objLength(obj){
  var i=0;
  for (var x in obj){
    if(obj.hasOwnProperty(x)){
      i++;
    }
  }
  return i;
}
