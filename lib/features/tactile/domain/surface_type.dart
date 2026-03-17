enum SurfaceType {
  water,
}

extension SurfaceTypeExtension on SurfaceType {
  String get title {
    switch (this) {
      case SurfaceType.water:
        return 'Water';
    }
  }

  String get subtitle {
    switch (this) {
      case SurfaceType.water:
        return 'Create gentle ripples';
    }
  }

  /// Describes the helper hint inside the active experience screen
  String get helperText {
    switch (this) {
      case SurfaceType.water:
        return 'Tap or drag slowly';
    }
  }
}
