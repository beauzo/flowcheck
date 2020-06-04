// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['action']);
  return Item(
    _$enumDecodeNullable(_$ItemTypeEnumMap, json['type']) ?? ItemType.ACTION,
    json['action'] as String,
    json['expectedResult'] as String,
  )..isChecked = json['isChecked'] as bool ?? false;
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'type': _$ItemTypeEnumMap[instance.type],
      'action': instance.action,
      'expectedResult': instance.expectedResult,
      'isChecked': instance.isChecked,
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

const _$ItemTypeEnumMap = {
  ItemType.ACTION: 'action',
  ItemType.HEADER: 'header',
};
