import 'package:echo_world/app/app.dart';
import 'package:echo_world/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
