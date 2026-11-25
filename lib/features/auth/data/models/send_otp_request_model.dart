import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_otp_request_model.freezed.dart';
part 'send_otp_request_model.g.dart';

/// Freezed request body for POST api/v1/password-reset/mobile.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class SendOtpRequestModel with _$SendOtpRequestModel {
  const factory SendOtpRequestModel({
    required String email,
  }) = _SendOtpRequestModel;

  factory SendOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestModelFromJson(json);
}
