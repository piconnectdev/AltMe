// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:altme/app/app.dart';
import 'package:altme/bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://b1e6ffd0c1224d64bcaaadd46ea4f24e@o586691.ingest.sentry.io/4504605041688576';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions
      // for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      options.debug = true;
    },
    appRunner: () => bootstrap(
      () => const App(flavorMode: FlavorMode.production),
    ),
  );
}
