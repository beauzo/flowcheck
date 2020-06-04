import 'package:json_annotation/json_annotation.dart';
import 'item_type.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  Item(this.type, this.action, this.expectedResult);

  @JsonKey(defaultValue: ItemType.ACTION)
  final ItemType type;

  @JsonKey(required: true)
  final String action;

  @JsonKey(required: false)
  final String expectedResult;

  @JsonKey(defaultValue: false)
  bool isChecked = false;

  void check() => isChecked = true;
  void unCheck() => isChecked = false;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
