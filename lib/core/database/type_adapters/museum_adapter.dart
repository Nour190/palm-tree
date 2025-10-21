import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';

class MuseumAdapter extends TypeAdapter<Museum> {
  @override
  final int typeId = 15; // Use a unique typeId

  @override
  Museum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return Museum(
      id: fields[0] as String,
      museumName: fields[1] as String,
      museumNameAr: fields[2] as String?,
      description: fields[3] as String?,
      descriptionAr: fields[4] as String?,
      coverImage: fields[5] as String?,
      location: fields[6] as String,
      latitude: fields[7] as double?,
      longitude: fields[8] as double?,
      artworkTypes: (fields[9] as List?)?.cast<String>() ?? [],
      artistIds: (fields[10] as List?)?.cast<String>() ?? [],
      status: fields[11] as String? ?? 'published',
      metadata: fields[12] as Map<String, dynamic>?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Museum obj) {
    writer.writeByte(15);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.museumName);
    writer.writeByte(2);
    writer.write(obj.museumNameAr);
    writer.writeByte(3);
    writer.write(obj.description);
    writer.writeByte(4);
    writer.write(obj.descriptionAr);
    writer.writeByte(5);
    writer.write(obj.coverImage);
    writer.writeByte(6);
    writer.write(obj.location);
    writer.writeByte(7);
    writer.write(obj.latitude);
    writer.writeByte(8);
    writer.write(obj.longitude);
    writer.writeByte(9);
    writer.write(obj.artworkTypes);
    writer.writeByte(10);
    writer.write(obj.artistIds);
    writer.writeByte(11);
    writer.write(obj.status);
    writer.writeByte(12);
    writer.write(obj.metadata);
    writer.writeByte(13);
    writer.write(obj.createdAt);
    writer.writeByte(14);
    writer.write(obj.updatedAt);
  }
}
