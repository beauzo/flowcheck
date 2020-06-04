// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Root _$RootFromJson(Map<String, dynamic> json) {
  return Root(
    (json['sections'] as List)
        ?.map((e) =>
            e == null ? null : Section.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$RootToJson(Root instance) => <String, dynamic>{
      'sections': instance.sections?.map((e) => e?.toJson())?.toList(),
    };
