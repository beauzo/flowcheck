import 'package:json_annotation/json_annotation.dart';

enum SectionType {
  @JsonValue('normal')
  NORMAL,
  @JsonValue('abnormal')
  ABNORMAL,
  @JsonValue('emergency')
  EMERGENCY
}
