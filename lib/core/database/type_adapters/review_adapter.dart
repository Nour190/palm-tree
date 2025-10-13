import 'package:hive/hive.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';

class ReviewModelAdapter extends TypeAdapter<ReviewModel> {
  @override
  final int typeId = 3;

  @override
  ReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <String, dynamic>{};
    
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      fields[key] = value;
    }
    
    return ReviewModel(
      name: fields['reviewer_name'] as String,
      textEn: fields['text_en'] as String,
      textAr: fields['text_ar'] as String,
      rating: (fields['rating'] as num).toDouble(),
      gender: fields['gender'] as String,
      avatarUrl: fields['avatar_url'] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewModel obj) {
    final map = {
      'reviewer_name': obj.name,
      'text_en': obj.textEn,
      'text_ar': obj.textAr,
      'rating': obj.rating,
      'gender': obj.gender,
      'avatar_url': obj.avatarUrl,
    };
    
    writer.writeByte(map.length);
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
