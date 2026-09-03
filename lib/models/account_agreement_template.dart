class AccountAgreementTemplateModel {
  final int version;
  final String locale;
  final String title;
  final String introTemplate;
  final String partyOne;
  final String partyTwoTemplate;
  final List<AccountAgreementClauseModel> clauses;

  const AccountAgreementTemplateModel({
    required this.version,
    required this.locale,
    required this.title,
    required this.introTemplate,
    required this.partyOne,
    required this.partyTwoTemplate,
    required this.clauses,
  });

  factory AccountAgreementTemplateModel.fromJson(Map<String, dynamic> json) {
    final rawClauses = json['clauses'];
    final clauses = <AccountAgreementClauseModel>[];
    if (rawClauses is List) {
      for (final item in rawClauses) {
        if (item is Map) {
          clauses.add(AccountAgreementClauseModel.fromJson(
            Map<String, dynamic>.from(item),
          ));
        }
      }
    }

    return AccountAgreementTemplateModel(
      version: int.tryParse('${json['version'] ?? 1}') ?? 1,
      locale: '${json['locale'] ?? 'ar'}',
      title: '${json['title'] ?? 'اتفاقية فتح حساب'}',
      introTemplate: '${json['intro_template'] ?? ''}',
      partyOne: '${json['party_one'] ?? ''}',
      partyTwoTemplate: '${json['party_two_template'] ?? ''}',
      clauses: clauses,
    );
  }
}

class AccountAgreementClauseModel {
  final String title;
  final String body;

  const AccountAgreementClauseModel({
    required this.title,
    required this.body,
  });

  factory AccountAgreementClauseModel.fromJson(Map<String, dynamic> json) {
    return AccountAgreementClauseModel(
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
    );
  }
}
