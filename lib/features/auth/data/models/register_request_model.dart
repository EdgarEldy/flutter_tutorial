import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

/// Freezed request body for POST api/v1/auth/register.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String username,
    required String email,
    required String password,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);
}
