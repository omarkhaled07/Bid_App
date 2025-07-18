import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';

class LiveDetailsScreen extends StatefulWidget {
  final bool isHost;

  const LiveDetailsScreen({Key? key, required this.isHost}) : super(key: key);

  @override
  _LiveDetailsScreenState createState() => _LiveDetailsScreenState();
}

class _LiveDetailsScreenState extends State<LiveDetailsScreen> {
  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  List<RemoteParticipant> _remoteParticipants = [];
  final String _liveKitURL = "wss://bid-app-okpujtjt.livekit.cloud";
  final String _apiKey = "APIaimJHx8JEEc5";
  final String _secretKey = "IaHs2hMRd8NewS2u1PX6pgQplUYdNLrGLDFzSVUEidR";
  final String _roomName = "test-room";
  int _viewerCount = 0;

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      final String token = await fetchToken("user_${DateTime.now().millisecondsSinceEpoch}");
      _room = Room();

      // إضافة مستمعين لأحداث الغرفة
      _room?.addListener(_onRoomDidUpdate);

      await _room!.connect(_liveKitURL, token);

      if (widget.isHost) {
        // تفعيل الكاميرا والميكروفون للمضيف
        await _room!.localParticipant?.setMicrophoneEnabled(true);
        await _room!.localParticipant?.setCameraEnabled(true);

        _localVideoTrack = await LocalVideoTrack.createCameraTrack();
        await _room!.localParticipant?.publishVideoTrack(_localVideoTrack!);
      }

      // تحديث قائمة المشاركين
      _remoteParticipants = _room?.remoteParticipants.values.toList() ?? [];
      _updateViewerCount();

      setState(() {});
    } catch (e) {
      print("Error connecting to room: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: ${e.toString()}")),
      );
    }
  }

  void _onRoomDidUpdate() {
    setState(() {
      _remoteParticipants = _room?.remoteParticipants.values.toList() ?? [];
      _updateViewerCount();
    });
  }

  void _updateViewerCount() {
    if (_room != null) {
      _viewerCount = _room!.remoteParticipants.length;
      if (!widget.isHost) _viewerCount += 1; // إضافة المضيف إذا كان المستخدم مشاهد
    }
  }

  Future<String> fetchToken(String identity) async {
    try {
      final response = await http.post(
        Uri.parse("https://liveserver-wxl8.onrender.com/get-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identity": identity,
          "room": _roomName,
          "api_key": _apiKey,
          "secret_key": _secretKey
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      } else {
        throw Exception("Failed to get token: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Token fetch error: $e");
    }
  }

  Widget _renderParticipantVideo(RemoteParticipant participant) {
    // البحث عن أول فيديو تراك نشط
    for (final trackPublication in participant.videoTracks) {
      if (trackPublication.track != null && trackPublication.isSubscribed) {
        return VideoTrackRenderer(trackPublication.track!);
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // عرض فيديو المضيف
          if (widget.isHost && _localVideoTrack != null)
            Positioned.fill(
              child: VideoTrackRenderer(_localVideoTrack!),
            ),

          // عرض فيديو المشاركين الآخرين
          if (!widget.isHost)
            ..._remoteParticipants.map((participant) =>
                Positioned.fill(
                  child: _renderParticipantVideo(participant),
                ),
            ),

          // مؤشر تحميل إذا لم يتم الاتصال بعد
          if ((widget.isHost && _localVideoTrack == null) ||
              (!widget.isHost && _remoteParticipants.isEmpty))
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // عدد المشاهدين
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Text("$_viewerCount",
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ),

          // زر الخروج
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomDidUpdate);
    _room?.disconnect();
    _room?.dispose();
    _localVideoTrack?.dispose();
    super.dispose();
  }
}

extension on RemoteParticipant {
  get videoTracks => null;
}
