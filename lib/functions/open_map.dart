import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(String link) async {
  await launch(link);
}

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}