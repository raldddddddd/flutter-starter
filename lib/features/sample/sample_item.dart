import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_item.freezed.dart';
part 'sample_item.g.dart';

/// The sample API payload and feature model have the same two fields.
@freezed
abstract class SampleItem with _$SampleItem {
  const factory SampleItem({required String id, required String title}) =
      _SampleItem;

  factory SampleItem.fromJson(Map<String, dynamic> json) =>
      _$SampleItemFromJson(json);
}
