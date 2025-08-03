// playlist_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'playlist_model.dart';
import '../models/audio_model.dart';

class PlaylistManager with ChangeNotifier {
  List<Playlist> _playlists = [];
  Playlist? _currentPlaylist;

  List<Playlist> get playlists => _playlists;
  Playlist? get currentPlaylist => _currentPlaylist;

  PlaylistManager() {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString('playlists');

    if (playlistsJson != null) {
      final List<dynamic> playlistsData = json.decode(playlistsJson);
      _playlists = playlistsData.map((data) {
        return Playlist(
          id: data['id'],
          name: data['name'],
          songs: (data['songs'] as List<dynamic>).map((songData) {
            return AudioFile(
              name: songData['name'],
              path: songData['path'],
              duration: songData['duration'],
              artist: songData['artist'],
              album: songData['album'],
            );
          }).toList(),
          createdAt: DateTime.parse(data['createdAt']),
        );
      }).toList();
    }

    notifyListeners();
  }

  Future<void> savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(
      _playlists.map((playlist) {
        return {
          'id': playlist.id,
          'name': playlist.name,
          'songs': playlist.songs.map((song) {
            return {
              'name': song.name,
              'path': song.path,
              'duration': song.duration,
              'artist': song.artist,
              'album': song.album,
            };
          }).toList(),
          'createdAt': playlist.createdAt.toIso8601String(),
        };
      }).toList(),
    );
    await prefs.setString('playlists', playlistsJson);
  }

  void createPlaylist(String name, List<AudioFile> songs) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: songs,
      createdAt: DateTime.now(),
    );

    _playlists.add(newPlaylist);
    savePlaylists();
    notifyListeners();
  }

  void updatePlaylist(String id, String name, List<AudioFile> songs) {
    final index = _playlists.indexWhere((playlist) => playlist.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: name,
        songs: songs,
      );
      savePlaylists();
      notifyListeners();
    }
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((playlist) => playlist.id == id);
    if (_currentPlaylist?.id == id) {
      _currentPlaylist = null;
    }
    savePlaylists();
    notifyListeners();
  }

  void setCurrentPlaylist(Playlist? playlist) {
    _currentPlaylist = playlist;
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, AudioFile song) {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index != -1) {
      final updatedSongs = List<AudioFile>.from(_playlists[index].songs);
      if (!updatedSongs.any((s) => s.path == song.path)) {
        updatedSongs.add(song);
        _playlists[index] = _playlists[index].copyWith(songs: updatedSongs);
        savePlaylists();
        notifyListeners();
      }
    }
  }

  void removeSongFromPlaylist(String playlistId, String songPath) {
    final index = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (index != -1) {
      final updatedSongs = _playlists[index]
          .songs
          .where((song) => song.path != songPath)
          .toList();
      _playlists[index] = _playlists[index].copyWith(songs: updatedSongs);
      savePlaylists();
      notifyListeners();
    }
  }
}