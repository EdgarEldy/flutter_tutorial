import 'package:freezed_annotation/freezed_annotation.dart';

part 'activate_account_request_model.freezed.dart';
part 'activate_account_request_model.g.dart';

/// Freezed request body for POST api/v1/auth/activate-account.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class ActivateAccountRequestModel with _$ActivateAccountRequestModel {
  const factory ActivateAccountRequestModel({
    required String email,
    @JsonKey(name: 'activation_code') required String activationCode,
  }) = _ActivateAccountRequestModel;

  factory ActivateAccountRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ActivateAccountRequestModelFromJson(json);
}
