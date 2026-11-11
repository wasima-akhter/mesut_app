import 'app/app.dart';
import 'core/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(app: const App());
}
