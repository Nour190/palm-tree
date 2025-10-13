import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';

class InfoModelAdapter extends TypeAdapter<InfoModel> {
  @override
  final int typeId = 2;

  @override
  InfoModel read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();
    
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    
    return InfoModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, InfoModel obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);
    
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
