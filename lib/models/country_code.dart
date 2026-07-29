
List<CountryCode> countryCodesList=[
  CountryCode(name: "Saudi Arabia", code: "+966", flag: 'assets/svg/sa_flag.svg'),
  // CountryCode(name: "Egypt", code: "+2", flag: 'assets/svg/sa_flag.svg'),
  CountryCode(name: "USA", code: "+1", flag: 'assets/svg/us_flag.svg'),
  CountryCode(name: "The United Arab Emirates", code: "+971", flag: 'assets/svg/emarate_flag.svg'),
  CountryCode(name: "Qatar", code: "+974", flag: 'assets/svg/qatar_flag.svg'),
  CountryCode(name: "Oman", code: "+968", flag: 'assets/svg/oman.svg'),
  CountryCode(name: "Kuwait", code: "+965", flag: 'assets/svg/kuwait.svg'),
  CountryCode(name: "Bahrain", code: "+973", flag: 'assets/svg/bahrain.svg'),
];



class CountryCode{
  String name;
  String code;
  String flag;
  CountryCode({required this.name,required this.code,required this.flag});

}