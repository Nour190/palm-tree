/// Bytes-based upload payload (works on mobile/web/desktop).
class UploadBlob {
  final String fileName;
  final List<int> bytes; // Use Uint8List if you prefer: final Uint8List bytes;
  final String? contentType;

  const UploadBlob({
    required this.fileName,
    required this.bytes,
    this.contentType,
  });
}

class ChatAttachment {
  final String name; // original filename (sanitized)
  final String path; // storage path in bucket
  final String url; // public or signed URL
  final String? contentType; // e.g. "image/png"
  final int? size; // in bytes

  const ChatAttachment({
    required this.name,
    required this.path,
    required this.url,
    this.contentType,
    this.size,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'path': path,
    'url': url,
    'content_type': contentType,
    'size': size,
  };

  factory ChatAttachment.fromMap(Map<String, dynamic> m) => ChatAttachment(
    name: (m['name'] ?? '') as String,
    path: (m['path'] ?? '') as String,
    url: (m['url'] ?? '') as String,
    contentType: m['content_type'] as String?,
    size: m['size'] is int ? m['size'] as int : (m['size'] as num?)?.toInt(),
  );
}

class ChatMessage {
  final String id;
  final String artworkId;
  final String userId;
  final String? text; // nullable for attachment-only messages
  final List<ChatAttachment> attachments; // JSONB array in DB
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.artworkId,
    required this.userId,
    required this.attachments,
    required this.createdAt,
    this.text,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
    id: (m['id'] ?? '') as String,
    artworkId: (m['artwork_id'] ?? '') as String,
    userId: (m['user_id'] ?? '') as String,
    text: m['text'] as String?,
    attachments: (m['attachments'] as List<dynamic>? ?? [])
        .map((e) => ChatAttachment.fromMap(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(
      (m['created_at'] ?? DateTime.now().toIso8601String()) as String,
    ),
  );
}
