import 'package:app/models/account_agreement_template.dart';

class AccountAgreementData {
  final String companyName;
  final String crNumber;
  final String headquarters;
  final String signerName;
  final String signerTitle;
  final String dayName;
  final String dateD;
  final String dateM;
  final String dateY;
  final String title;
  final String intro;
  final String partyOne;
  final String partyTwo;
  final List<Map<String, String>> clauses;
  final int? templateVersion;

  const AccountAgreementData({
    required this.companyName,
    required this.crNumber,
    required this.headquarters,
    required this.signerName,
    required this.signerTitle,
    required this.dayName,
    required this.dateD,
    required this.dateM,
    required this.dateY,
    required this.title,
    required this.intro,
    required this.partyOne,
    required this.partyTwo,
    required this.clauses,
    this.templateVersion,
  });

  factory AccountAgreementData.fromForm({
    required String companyName,
    required String crNumber,
    required String buildingNumber,
    required String street,
    required String district,
    required String city,
    required String postalCode,
    required String signerName,
    required String signerTitle,
    AccountAgreementTemplateModel? template,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final hq = [
      buildingNumber,
      street,
      district,
      city,
      postalCode,
      'المملكة العربية السعودية',
    ].where((e) => e.trim().isNotEmpty).join('، ');

    final resolvedCompany =
        companyName.trim().isEmpty ? '______________________________' : companyName.trim();
    final resolvedCr =
        crNumber.trim().isEmpty ? '__________________' : crNumber.trim();
    final resolvedHq =
        hq.isEmpty ? '______________________________' : hq;
    final resolvedSigner =
        signerName.trim().isEmpty ? '______________________________' : signerName.trim();
    final resolvedTitle =
        signerTitle.trim().isEmpty ? '__________________' : signerTitle.trim();

    final placeholders = {
      '{{day_name}}': days[now.weekday - 1],
      '{{date_d}}': now.day.toString().padLeft(2, '0'),
      '{{date_m}}': now.month.toString().padLeft(2, '0'),
      '{{date_y}}': '${now.year}',
      '{{company_name}}': resolvedCompany,
      '{{cr_number}}': resolvedCr,
      '{{headquarters}}': resolvedHq,
      '{{signer_name}}': resolvedSigner,
      '{{signer_title}}': resolvedTitle,
    };

    String apply(String value) {
      var out = value;
      placeholders.forEach((key, replacement) {
        out = out.replaceAll(key, replacement);
      });
      return out;
    }

    if (template != null) {
      return AccountAgreementData(
        companyName: resolvedCompany,
        crNumber: resolvedCr,
        headquarters: resolvedHq,
        signerName: resolvedSigner,
        signerTitle: resolvedTitle,
        dayName: days[now.weekday - 1],
        dateD: now.day.toString().padLeft(2, '0'),
        dateM: now.month.toString().padLeft(2, '0'),
        dateY: '${now.year}',
        title: template.title,
        intro: apply(template.introTemplate),
        partyOne: template.partyOne,
        partyTwo: apply(template.partyTwoTemplate),
        clauses: template.clauses
            .map((clause) => {
                  'title': clause.title,
                  'body': clause.body,
                })
            .toList(),
        templateVersion: template.version,
      );
    }

    return AccountAgreementData(
      companyName: resolvedCompany,
      crNumber: resolvedCr,
      headquarters: resolvedHq,
      signerName: resolvedSigner,
      signerTitle: resolvedTitle,
      dayName: days[now.weekday - 1],
      dateD: now.day.toString().padLeft(2, '0'),
      dateM: now.month.toString().padLeft(2, '0'),
      dateY: '${now.year}',
      title: 'اتفاقية فتح حساب',
      intro:
          'إنه في يوم ${days[now.weekday - 1]} الموافق ${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year}م، تم الاتفاق بين كل من:',
      partyOne:
          'الطرف الأول: شركة دروع المحرك الماسية للتجارة، شركة ذات مسؤولية محدودة، سجل تجاري رقم 1010839238، ومقرها الرئيسي الرياض – المملكة العربية السعودية، ويمثلها في هذا العقد السيد/ أحمد محمد الغول بصفته المدير العام، ويشار إليها فيما بعد بـ "الطرف الأول" أو "المورد".',
      partyTwo:
          'الطرف الثاني: شركة/مؤسسة $resolvedCompany، سجل تجاري رقم $resolvedCr، ومقرها $resolvedHq، ويمثلها السيد/ $resolvedSigner بصفته $resolvedTitle، ويشار إليها فيما بعد بـ "الطرف الثاني" أو "العميل".',
      clauses: _defaultClauses(),
    );
  }

  static List<Map<String, String>> _defaultClauses() => const [
        {
          'title': 'تمهيد',
          'body':
              'حيث إن الطرف الأول يعمل في مجال توريد وبيع وتوزيع منتجات ومواد العناية بالسيارات وغيرها من المنتجات التي يقوم بتسويقها أو توزيعها، وحيث أبدى الطرف الثاني رغبته في فتح حساب تجاري لدى الطرف الأول وشراء المنتجات منه فقد اتفق الطرفان على تنظيم العلاقة التجارية بينهما وفقًا لأحكام هذا العقد.\nويعتبر هذا التمهيد جزءًا لا يتجزأ من العقد ومكملاً ومفسرًا لأحكامه.',
        },
      ];
}
