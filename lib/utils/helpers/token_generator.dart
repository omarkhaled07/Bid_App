// import 'package:livekit_server/livekit_server.dart';
//
// class TokenGenerator {
//   static const String apiKey = 'YOUR_API_KEY';
//   static const String apiSecret = 'YOUR_SECRET_KEY';
//
//   static String generateToken(String identity, String roomName) {
//     final grants = ClaimGrants()
//       ..video = VideoGrant(roomJoin: true, canPublish: true, room: roomName);
//
//     final at = AccessToken(
//       apiKey,
//       apiSecret,
//       identity: identity,
//       grants: grants,
//     );
//
//     return at.toJwt();
//   }
// }
