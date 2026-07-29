class VersionModel {
  bool? status;
  int? code;
  List<VersionData>? data;
  String? msg;

  VersionModel({this.status, this.code, this.data, this.msg});

  VersionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    if (json['data'] != null) {
      data = <VersionData>[];
      json['data'].forEach((v) {
        data!.add(new VersionData.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class VersionData {
  String? app;
  List<Platforms>? platforms;

  VersionData({this.app, this.platforms});

  VersionData.fromJson(Map<String, dynamic> json) {
    app = json['app'];
    if (json['platforms'] != null) {
      platforms = <Platforms>[];
      json['platforms'].forEach((v) {
        platforms!.add(new Platforms.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['app'] = this.app;
    if (this.platforms != null) {
      data['platforms'] = this.platforms!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Platforms {
  String? platform;
  String? currentVersion;
  String? updatedAt;

  Platforms({this.platform, this.currentVersion, this.updatedAt});

  Platforms.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    currentVersion = json['current_version'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['platform'] = this.platform;
    data['current_version'] = this.currentVersion;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}