
List<CountryCode> countryCodesList = [
  CountryCode(
    name: "Saudi Arabia",
    nameAr: "المملكة العربية السعودية",
    code: "+966",
    flag: 'assets/svg/sa_flag.svg',
  ),
  CountryCode(
    name: "USA",
    nameAr: "الولايات المتحدة",
    code: "+1",
    flag: 'assets/svg/us_flag.svg',
  ),
  CountryCode(
    name: "The United Arab Emirates",
    nameAr: "الإمارات العربية المتحدة",
    code: "+971",
    flag: 'assets/svg/emarate_flag.svg',
  ),
  CountryCode(
    name: "Qatar",
    nameAr: "قطر",
    code: "+974",
    flag: 'assets/svg/qatar_flag.svg',
  ),
  CountryCode(
    name: "Oman",
    nameAr: "عُمان",
    code: "+968",
    flag: 'assets/svg/oman.svg',
  ),
  CountryCode(
    name: "Kuwait",
    nameAr: "الكويت",
    code: "+965",
    flag: 'assets/svg/kuwait.svg',
  ),
  CountryCode(
    name: "Bahrain",
    nameAr: "البحرين",
    code: "+973",
    flag: 'assets/svg/bahrain.svg',
  ),
];

class CountryCode {
  String name;
  String nameAr;
  String code;
  String flag;

  CountryCode({
    required this.name,
    this.nameAr = '',
    required this.code,
    required this.flag,
  });

  String localizedName(String locale) {
    if (locale.startsWith('ar') && nameAr.isNotEmpty) {
      return nameAr;
    }
    return name;
  }
}
