import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

class ArtistAdapter extends TypeAdapter<Artist> {
  @override
  final int typeId = 0;

  @override
  Artist read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();

    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }

    return Artist.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Artist obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);

    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
