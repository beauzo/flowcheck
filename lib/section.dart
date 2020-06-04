import 'package:json_annotation/json_annotation.dart';
import 'section_type.dart';
import 'checklist.dart';

part 'section.g.dart';

@JsonSerializable(explicitToJson: true)
class Section {
  Section(this.title, this.description, this.sectionType, this.checklists);

  @JsonKey(required: true)
  final String title;

  final String description;

  @JsonKey(required: true)
  final SectionType sectionType;

  List<Checklist> checklists;

  bool completed() => checklists.every((checklist) => checklist.isAllChecked());

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}
