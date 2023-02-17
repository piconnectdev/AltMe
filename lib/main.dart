// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:altme/app/app.dart';
import 'package:altme/bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  bootstrap(
    () => const App(flavorMode: FlavorMode.production),
  );
}
