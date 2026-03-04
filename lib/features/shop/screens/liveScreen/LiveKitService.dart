import 'dart:async';
import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  final List<RemoteParticipant> _remoteParticipants = [];
  final StreamController<int> _viewerCountController =
      StreamController<int>.broadcast();

  Stream<int> get viewerCountStream => _viewerCountController.stream;
  List<RemoteParticipant> get remoteParticipants => _remoteParticipants;
  LocalVideoTrack? get localVideoTrack => _localVideoTrack;
  Room? get room => _room;

  Future<void> connect(
    String liveKitUrl,
    String token, {
    bool isHost = false,
  }) async {
    try {
      _room = Room();
      _setupListeners();
      await _room!.connect(liveKitUrl, token);

      if (isHost) {
        await _enableMediaTracks();
      }

      _updateViewerCount();
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<void> _enableMediaTracks() async {
    try {
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          params: VideoParametersPresets.h720_169,
        ),
      );
      await _room!.localParticipant?.publishVideoTrack(_localVideoTrack!);
    } catch (e) {
      throw Exception('Failed to enable media tracks: $e');
    }
  }

  void _setupListeners() {
    _room?.addListener(_onRoomUpdate);

    // استخدام Listenable بدلاً من on<Event>
    _room?.events.listen((event) {
      if (event is ParticipantConnectedEvent) {
        _onParticipantConnected(event);
      } else if (event is ParticipantDisconnectedEvent) {
        _onParticipantDisconnected(event);
      } else if (event is TrackPublishedEvent) {
        _onTrackPublished(event);
      }
    });
  }

  void _onRoomUpdate() {
    _remoteParticipants.clear();
    _remoteParticipants.addAll(_room?.remoteParticipants.values.toList() ?? []);
    _updateViewerCount();
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    _remoteParticipants.add(event.participant);
    _updateViewerCount();
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    _remoteParticipants.remove(event.participant);
    _updateViewerCount();
  }

  void _onTrackPublished(TrackPublishedEvent event) {
    _updateViewerCount();
  }

  void _updateViewerCount() {
    if (_room != null) {
      final count = _room!.remoteParticipants.length;
      _viewerCountController.add(count);
    }
  }

  Future<void> disconnect() async {
    try {
      await _room?.disconnect();
      await _localVideoTrack?.dispose();
      _room?.removeListener(_onRoomUpdate);
      await _room?.dispose();
      _room = null;
      _localVideoTrack = null;
      _remoteParticipants.clear();
      await _viewerCountController.close();
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }
}
