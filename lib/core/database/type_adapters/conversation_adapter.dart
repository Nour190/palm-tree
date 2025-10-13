import 'package:hive/hive.dart';
import 'package:baseqat/modules/artwork_details/data/models/conversation_models.dart';

class ConversationAdapter extends TypeAdapter<ConversationRecord> {
  @override
  final int typeId = 4;

  @override
  ConversationRecord read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();
    
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    
    return ConversationRecord.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, ConversationRecord obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);
    
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
