class CheckPhoneModel {
  bool? status;
  int? code;
  CheckPhoneModelData? data;
  String? msg;

  CheckPhoneModel({this.status, this.code, this.data, this.msg});

  CheckPhoneModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    data = json['data'] != null
        ? CheckPhoneModelData.fromJson(json['data'])
        : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'data': data?.toJson(),
      'msg': msg,
    };
  }
}

class CheckPhoneModelData {
  bool? isVerified;
  bool? requiresOtp;
  bool? isFirstLogin;
  bool? canUseBiometric;
  int? inactivityMonths;
  String? lastAppActivityAt;

  CheckPhoneModelData({
    this.isVerified,
    this.requiresOtp,
    this.isFirstLogin,
    this.canUseBiometric,
    this.inactivityMonths,
    this.lastAppActivityAt,
  });

  CheckPhoneModelData.fromJson(Map<String, dynamic> json) {
    isVerified = json['is_verified'] == true;
    requiresOtp = json['requires_otp'] == true;
    isFirstLogin = json['is_first_login'] == true;
    canUseBiometric = json['can_use_biometric'] == true;
    inactivityMonths = json['inactivity_months'] is int
        ? json['inactivity_months']
        : int.tryParse('${json['inactivity_months'] ?? ''}');
    lastAppActivityAt = json['last_app_activity_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'is_verified': isVerified,
      'requires_otp': requiresOtp,
      'is_first_login': isFirstLogin,
      'can_use_biometric': canUseBiometric,
      'inactivity_months': inactivityMonths,
      'last_app_activity_at': lastAppActivityAt,
    };
  }
}
