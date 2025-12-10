import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'download_urls_model.g.dart';

@JsonSerializable()
class DownloadUrlsModel extends Equatable {
  final String? pdf;
  final String? qr;

  const DownloadUrlsModel({
    this.pdf,
    this.qr,
  });

  factory DownloadUrlsModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadUrlsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadUrlsModelToJson(this);

  @override
  List<Object?> get props => [pdf, qr];
}

