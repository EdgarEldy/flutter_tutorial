import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_reset_request_model.freezed.dart';
part 'confirm_reset_request_model.g.dart';

@freezed
abstract class ConfirmResetRequestModel with _$ConfirmResetRequestModel {
  const factory ConfirmResetRequestModel({
    @JsonKey(name: 'new_password') required String newPassword,
    @JsonKey(name: 'confirm_password') required String confirmPassword,
  }) = _ConfirmResetRequestModel;

  factory ConfirmResetRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmResetRequestModelFromJson(json);
}
