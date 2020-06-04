import 'section.dart';
import 'package:json_annotation/json_annotation.dart';
part 'root.g.dart';

@JsonSerializable(explicitToJson: true)
class Root {
  Root(this.sections);

  List<Section> sections;

  factory Root.fromJson(Map<String, dynamic> json) => _$RootFromJson(json);
  Map<String, dynamic> toJson() => _$RootToJson(this);
}
