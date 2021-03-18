import 'package:flutter/material.dart';
import 'package:lilay/ui/launcher.dart';
import 'package:logging/logging.dart';

Logger logger = Logger('Lilay');

void main() {
  logger.onRecord.listen((record) {
    print('[${record.level.name}] [${record.time}]: ${record.message}');
  });

  logger.info("Setting up core config...");

  runApp(Launcher());
}
