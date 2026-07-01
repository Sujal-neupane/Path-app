class PermitInfoModel {
  final String region;
  final String regionKey;
  final List<PermitDetailModel> permits;
  final List<String> notes;
  final List<String> whereToObtain;
  final List<String> officialLinks;

  PermitInfoModel({
    required this.region,
    required this.regionKey,
    required this.permits,
    required this.notes,
    required this.whereToObtain,
    required this.officialLinks,
  });

  factory PermitInfoModel.fromJson(Map<String, dynamic> json) {
    return PermitInfoModel(
      region: json['region'] ?? '',
      regionKey: json['regionKey'] ?? '',
      permits: (json['permits'] as List<dynamic>?)
              ?.map((e) => PermitDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: List<String>.from(json['notes'] ?? []),
      whereToObtain: List<String>.from(json['where_to_obtain'] ?? []),
      officialLinks: List<String>.from(json['official_links'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'regionKey': regionKey,
      'permits': permits.map((e) => e.toJson()).toList(),
      'notes': notes,
      'where_to_obtain': whereToObtain,
      'official_links': officialLinks,
    };
  }
}

class PermitDetailModel {
  final String name;
  final double feeNpr;
  final double feeUsd;
  final String validity;
  final bool required;
  final String description;

  PermitDetailModel({
    required this.name,
    required this.feeNpr,
    required this.feeUsd,
    required this.validity,
    required this.required,
    required this.description,
  });

  factory PermitDetailModel.fromJson(Map<String, dynamic> json) {
    return PermitDetailModel(
      name: json['name'] ?? '',
      feeNpr: (json['fee_npr'] as num?)?.toDouble() ?? 0.0,
      feeUsd: (json['fee_usd'] as num?)?.toDouble() ?? 0.0,
      validity: json['validity'] ?? '',
      required: json['required'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fee_npr': feeNpr,
      'fee_usd': feeUsd,
      'validity': validity,
      'required': required,
      'description': description,
    };
  }
}
