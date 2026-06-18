import 'dart:io';

/// Returns the current resident set size of the process in bytes.
int getMemoryBytes() => ProcessInfo.currentRss;

/// Returns the peak resident set size of the process in bytes.
int getPeakMemoryBytes() => ProcessInfo.maxRss;
