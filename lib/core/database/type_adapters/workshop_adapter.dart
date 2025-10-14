import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';

class WorkshopAdapter extends TypeAdapter<Workshop> {
  @override
  final int typeId = 7;

  @override
  Workshop read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();

    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }

    return Workshop.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Workshop obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);

    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
