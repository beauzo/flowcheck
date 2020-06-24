import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'item_type.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  Item(this.type, this.action, this.expectedResult, this.sayAction, this.sayExpectedResult);

  @JsonKey(defaultValue: ItemType.ACTION)
  final ItemType type;

  @JsonKey(required: true)
  final String action;

  @JsonKey(required: false)
  final String expectedResult;

  @JsonKey(required: false)
  final String sayAction;

  @JsonKey(required: false)
  final String sayExpectedResult;

  @JsonKey(defaultValue: false)
  bool isChecked = false;

  void check() => isChecked = true;
  void unCheck() => isChecked = false;

  String speakAction() => (sayAction != null) ? sayAction : action;
  String speakExpectedResult() => (sayExpectedResult != null) ? sayExpectedResult : expectedResult;

  final Map<String, Function> _macroGenerators = {
    "{{time}}": () => DateFormat('kk:mm').format(DateTime.now()),
    "{{time_utc}}": () => DateFormat('kk:mm').format(DateTime.now().toUtc()),
  };

  String expandExpectedResult() => _macroGenerators.entries.fold(expectedResult, (prev, e) => prev.replaceAll(e.key, e.value()));
  String expandSpeakExpectedResult() => _macroGenerators.entries.fold(speakExpectedResult(), (prev, e) => prev.replaceAll(e.key, e.value()));

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
