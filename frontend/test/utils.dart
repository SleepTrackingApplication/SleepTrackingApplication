// Adapted from
// https://remelehane.dev/widget-testing-dealing-with-renderflex-overflow-errors
import 'package:flutter/material.dart';

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  bool ifIsOverflowError = false;

  // Detect overflow error.
  var exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
    );
  }

  // Ignore if overflow error.
  if (ifIsOverflowError) {
    debugPrint('Ignored Overflow Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}
