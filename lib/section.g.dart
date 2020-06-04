// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['title', 'sectionType']);
  return Section(
    json['title'] as String,
    json['description'] as String,
    _$enumDecodeNullable(_$SectionTypeEnumMap, json['sectionType']),
    (json['checklists'] as List)
        ?.map((e) =>
            e == null ? null : Checklist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'sectionType': _$SectionTypeEnumMap[instance.sectionType],
      'checklists': instance.checklists?.map((e) => e?.toJson())?.toList(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$SectionTypeEnumMap = {
  SectionType.NORMAL: 'normal',
  SectionType.ABNORMAL: 'abnormal',
  SectionType.EMERGENCY: 'emergency',
};
