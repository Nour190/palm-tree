import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

class SpeakerAdapter extends TypeAdapter<Speaker> {
  @override
  final int typeId = 6;

  @override
  Speaker read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();

    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }

    return Speaker.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Speaker obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);

    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
