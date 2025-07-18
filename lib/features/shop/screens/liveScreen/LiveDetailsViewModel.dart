import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import 'LiveKitService.dart';

class LiveDetailsViewModel extends ChangeNotifier {
  final LiveKitService _liveKitService;
  final bool isHost;

  LiveDetailsViewModel({required this.isHost}) : _liveKitService = LiveKitService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LocalVideoTrack? get localVideoTrack => _liveKitService.localVideoTrack;
  List<RemoteParticipant> get remoteParticipants => _liveKitService.remoteParticipants;
  Stream<int> get viewerCountStream => _liveKitService.viewerCountStream;

  Future<void> connectToRoom({
    required String liveKitUrl,
    required String token,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _liveKitService.connect(
        liveKitUrl,
        token,
        isHost: isHost,
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _liveKitService.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }
}