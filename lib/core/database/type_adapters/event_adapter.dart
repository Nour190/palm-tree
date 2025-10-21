import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 9; // Unique ID for Event adapter

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return Event(
      id: fields[0] as String,
      name: fields[1] as String,
      nameAr: fields[2] as String?,
      overview: fields[3] as String?,
      overviewAr: fields[4] as String?,
      circleAvatar: fields[5] as String?,
      coverImage: fields[6] as String?,
      overviewImages:fields[6] as String?,
      //(fields[7] as List?)?.cast<String>() ?? const [],
      latitude: fields[8] as double?,
      longitude: fields[9] as double?,
      eventDate: fields[10] as DateTime?,
      artistIds: (fields[11] as List?)?.cast<String>() ?? const [],
      artworkIds: (fields[16] as List?)?.cast<String>() ?? const [],
      status: fields[12] as String? ?? 'published',
      metadata: fields[13] as Map<String, dynamic>?,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeByte(17);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.nameAr);
    writer.writeByte(3);
    writer.write(obj.overview);
    writer.writeByte(4);
    writer.write(obj.overviewAr);
    writer.writeByte(5);
    writer.write(obj.circleAvatar);
    writer.writeByte(6);
    writer.write(obj.coverImage);
    writer.writeByte(7);
    writer.write(obj.overviewImages);
    writer.writeByte(8);
    writer.write(obj.latitude);
    writer.writeByte(9);
    writer.write(obj.longitude);
    writer.writeByte(10);
    writer.write(obj.eventDate);
    writer.writeByte(11);
    writer.write(obj.artistIds);
    writer.writeByte(12);
    writer.write(obj.status);
    writer.writeByte(13);
    writer.write(obj.metadata);
    writer.writeByte(14);
    writer.write(obj.createdAt);
    writer.writeByte(15);
    writer.write(obj.updatedAt);
    writer.writeByte(16);
    writer.write(obj.artworkIds);
  }
}
