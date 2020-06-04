// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Checklist _$ChecklistFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['title']);
  return Checklist(
    json['title'] as String,
    (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChecklistToJson(Checklist instance) => <String, dynamic>{
      'title': instance.title,
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
    };
