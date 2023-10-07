class NoScriptTagException implements Exception {
  @override
  String toString() =>
      'Did you add   <script src="https://cdn.jsdelivr.net/npm/shaka-player@4.5.0/dist/shaka-player.compiled.min.js"  type="application/javascript"></script> in index.html? ';
}
