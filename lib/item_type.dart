import 'package:json_annotation/json_annotation.dart';

enum ItemType {
  @JsonValue('action')
  ACTION,
  @JsonValue('header')
  HEADER,
}
