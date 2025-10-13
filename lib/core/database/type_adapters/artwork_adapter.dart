import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

class ArtworkAdapter extends TypeAdapter<Artwork> {
  @override
  final int typeId = 1;

  @override
  Artwork read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();
    
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    
    return Artwork.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, Artwork obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);
    
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
