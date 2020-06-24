import 'package:checklist/item_type.dart';

import 'item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checklist.g.dart';

@JsonSerializable(explicitToJson: true)
class Checklist {
  Checklist(this.title, this.items);

  @JsonKey(required: true)
  String title;

  List<Item> items;

  int getNumberOfCheckableItems() {
    int checkableItems = 0;
    items.forEach((item) {
      if (item.type == ItemType.ACTION) checkableItems++;
    });
    return checkableItems;
  }

  int getNumberOfCheckedItems() {
    int numChecked = 0;
    items
      .where((item) => (item.isChecked))
      .forEach((element) => numChecked++);
    return numChecked;
  }

  bool isAllChecked() {
    if (items == null)
      return true;

    int numChecked = 0;
    items
      .where((item) => (item.isChecked))
      .forEach((element) => numChecked++);
    return (getNumberOfCheckedItems() >= getNumberOfCheckableItems());
  }

  bool isAllUnchecked() => !isAllChecked();

  bool isAnyChecked() {
    if (items == null)
      return true;
    return getNumberOfCheckedItems() > 0;
  }

  double getPercentChecked() => getNumberOfCheckedItems() / getNumberOfCheckableItems();

  int getNextItemUncheckedIndex() => items.lastIndexWhere((item) => item.isChecked) + 1;

  Item getNextUncheckedItem() {
    int nextUncheckedItemIndex = getNextItemUncheckedIndex();
    if (nextUncheckedItemIndex >= items.length)
      return null;
    return items[getNextItemUncheckedIndex()];
  }

  void uncheckAll() {
    items.forEach((item) => item.unCheck());
    _currentItem = 0;
  }

  void checkAll() {
    items.forEach((item) => item.check());
    _currentItem = items.length;
  }

  @JsonKey(ignore: true)
  int _currentItem = 0; // the current, active item waiting to be checked
  void checkCurrentItem() {
    if (_currentItem >= items.length)
      return;
    items[_currentItem].check();
    _currentItem++;
  }

  void unCheckLastItem() {
    if (_currentItem == 0)
      return;
    _currentItem--;
    items[_currentItem].unCheck();
  }

  bool canUncheckLastItem() => _currentItem != 0;

  @JsonKey(ignore: true)
  Checklist prev;

  @JsonKey(ignore: true)
  Checklist next;

  factory Checklist.fromJson(Map<String, dynamic> json) => _$ChecklistFromJson(json);

  Map<String, dynamic> toJson() => _$ChecklistToJson(this);
}
