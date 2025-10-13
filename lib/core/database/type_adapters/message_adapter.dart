import 'package:hive/hive.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';

class MessageAdapter extends TypeAdapter<MessageRecord> {
  @override
  final int typeId = 5;

  @override
  MessageRecord read(BinaryReader reader) {
    return MessageRecord(
      id: reader.readString(),
      conversationId: reader.readString(),
      role: reader.readString(),
      content: reader.readString(),
      isVoice: reader.readBool(),
      voiceDurationS: reader.read() as int?,
      languageCode: reader.read() as String?,
      showTranslation: reader.readBool(),
      translationText: reader.read() as String?,
      translationLang: reader.read() as String?,
      ttsLang: reader.read() as String?,
      extras: (reader.read() as Map?)?.cast<String, dynamic>() ?? {},
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, MessageRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.conversationId);
    writer.writeString(obj.role);
    writer.writeString(obj.content);
    writer.writeBool(obj.isVoice);
    writer.write(obj.voiceDurationS);
    writer.write(obj.languageCode);
    writer.writeBool(obj.showTranslation);
    writer.write(obj.translationText);
    writer.write(obj.translationLang);
    writer.write(obj.ttsLang);
    writer.write(obj.extras);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
