/// Deterministic dominant-color analysis (T-SCAN-04).
///
/// Pure Dart, no TFLite: downscales a packed ARGB image by uniform sampling,
/// runs Lloyd's k-means (k≈5) over RGB samples, and maps each cluster centroid
/// to the nearest named palette entry via CIE76 (Lab) distance. Output is a
/// ranked list of [DominantColor] with bilingual (en/ar) names.
///
/// Determinism: the k-means++ seeding uses a fixed-seed LCG that is reset on
/// every [ColorAnalyzer.analyze] call, and every tie-break resolves to the
/// lowest index. Same image in always yields exactly the same result out.
library;

import 'dart:math' as math;

/// An 8-bit sRGB color.
class RgbColor {
  const RgbColor(this.r, this.g, this.b);

  /// Unpacks a packed 0xAARRGGBB int (alpha ignored).
  const RgbColor.fromArgb(int argb)
      : r = (argb >> 16) & 0xff,
        g = (argb >> 8) & 0xff,
        b = argb & 0xff;

  final int r;
  final int g;
  final int b;

  @override
  bool operator ==(Object other) =>
      other is RgbColor && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => '#${_hex(r)}${_hex(g)}${_hex(b)}';
}

String _hex(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

/// A palette entry: one billboard color row (en name + ar name).
class NamedColor {
  const NamedColor(this.color, this.name, this.nameAr);

  final RgbColor color;
  final String name;
  final String nameAr;

  @override
  bool operator ==(Object other) =>
      other is NamedColor &&
      other.color == color &&
      other.name == name &&
      other.nameAr == nameAr;

  @override
  int get hashCode => Object.hash(color, name, nameAr);

  @override
  String toString() => '$name (ar: $nameAr)';
}

/// One dominant color: a palette name plus the cluster's pixel share.
class DominantColor {
  const DominantColor(this.namedColor, this.proportion);

  final NamedColor namedColor;

  /// Cluster size / total sampled pixels, in [0, 1].
  final double proportion;

  @override
  bool operator ==(Object other) =>
      other is DominantColor &&
      other.namedColor == namedColor &&
      other.proportion == proportion;

  @override
  int get hashCode => Object.hash(namedColor, proportion);

  @override
  String toString() => '${namedColor.name} (ar: ${namedColor.nameAr}) '
      '${(proportion * 100).toStringAsFixed(1)}%';
}

/// The [NamedColor]s whose hue family is [family], aggregated across clusters
/// so that a single garment hue is not split by the per-cluster quantizer.
///
/// [namedColor] is the largest member cluster's name (the family's
/// representative), [members] its palette constituents, and [proportion] is
/// the *summed* pixel share of every member, in [0, 1].
class DominantFamily {
  const DominantFamily(this.family, this.namedColor, this.proportion, this.members);

  /// Hue family key (see [ColorPalette.families]).
  final String family;

  /// Largest member cluster's palette name (family representative).
  final NamedColor namedColor;

  /// Sum of all member cluster proportions, in [0, 1].
  final double proportion;

  /// Every palette entry contributing to this family, largest share first.
  final List<NamedColor> members;

  @override
  String toString() => '$family: ${namedColor.name} '
      '${(proportion * 100).toStringAsFixed(1)}% '
      '[${members.map((m) => m.name).join(', ')}]';
}

/// Mutable accumulator used by [ColorAnalyzer.aggregateFamilies] while
/// merging per-cluster quantizer output into hue-family buckets. Sums member
/// proportions and remembers every constituent so the largest member can be
/// promoted to the family's [DominantFamily.namedColor] representative.
class _FamilyAcc {
  final members = <DominantColor>[];
  double proportion = 0;

  DominantFamily toDominantFamily() {
    members.sort((a, b) => b.proportion.compareTo(a.proportion));
    return DominantFamily(
      ColorPalette.familyOf(members.first.namedColor),
      members.first.namedColor,
      proportion,
      [for (final m in members) m.namedColor],
    );
  }
}

/// The fixed bilingual wardrobe color palette.
class ColorPalette {
  ColorPalette._();

  /// Anchor colors, spaced so that the CIE76 nearest-neighbor regions are
  /// stable. Both names are shown to the user; no translated storage needed.
  static const List<NamedColor> anchors = [
    NamedColor(RgbColor(10, 10, 10), 'black', 'أسود'),
    NamedColor(RgbColor(245, 245, 245), 'white', 'أبيض'),
    NamedColor(RgbColor(128, 128, 128), 'grey', 'رمادي'),
    NamedColor(RgbColor(205, 180, 140), 'beige', 'بيج'),
    NamedColor(RgbColor(115, 70, 35), 'brown', 'بني'),
    NamedColor(RgbColor(105, 15, 35), 'burgundy', 'عنابي'),
    NamedColor(RgbColor(225, 25, 30), 'red', 'أحمر'),
    NamedColor(RgbColor(185, 10, 70), 'crimson', 'قرمزي'),
    NamedColor(RgbColor(250, 130, 20), 'orange', 'برتقالي'),
    NamedColor(RgbColor(240, 215, 40), 'yellow', 'أصفر'),
    NamedColor(RgbColor(205, 160, 35), 'gold', 'ذهبي'),
    NamedColor(RgbColor(115, 110, 45), 'olive', 'زيتوني'),
    NamedColor(RgbColor(35, 150, 70), 'green', 'أخضر'),
    NamedColor(RgbColor(0, 145, 100), 'emerald', 'زمردي'),
    NamedColor(RgbColor(5, 120, 120), 'teal', 'أزرق مخضر'),
    NamedColor(RgbColor(25, 185, 190), 'turquoise', 'فيروزي'),
    NamedColor(RgbColor(140, 195, 235), 'sky', 'أزرق سماوي'),
    NamedColor(RgbColor(25, 60, 215), 'blue', 'أزرق'),
    NamedColor(RgbColor(20, 30, 95), 'navy', 'كحلي'),
    NamedColor(RgbColor(135, 40, 200), 'purple', 'بنفسجي'),
    NamedColor(RgbColor(190, 165, 225), 'lavender', 'لافندر'),
    NamedColor(RgbColor(255, 150, 170), 'pink', 'وردي'),
    NamedColor(RgbColor(205, 20, 145), 'magenta', 'أرجواني'),
  ];

  /// Finds the 32-bit ARGB hex integer for a named color, or null if unknown.
  static int? hexForName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final lower = name.toLowerCase().trim();
    for (final a in anchors) {
      if (a.name.toLowerCase() == lower || a.nameAr == lower) {
        return (0xFF << 24) | (a.color.r << 16) | (a.color.g << 8) | a.color.b;
      }
    }
    return null;
  }

  /// Hue families: every [anchors] name grouped by perceptual hue family.
  ///
  /// Each [anchors] name appears in exactly one bucket. Aggregating the
  /// per-cluster quantizer's output by family prevents a single garment hue
  /// (e.g. a coat that k-means splits into `sky` + `navy` clusters) from being
  /// reported as several low-share also-rans that each lose to an unrelated
  /// background cluster.
  static const Map<String, List<String>> families = {
    'neutral': ['black', 'white', 'grey'],
    'brown': ['brown'],
    'beige': ['beige'],
    'red': ['red', 'crimson', 'burgundy'],
    'orange': ['orange'],
    'yellow': ['yellow', 'gold', 'olive'],
    'green': ['green', 'emerald'],
    'teal': ['teal', 'turquoise'],
    'blue': ['sky', 'blue', 'navy'],
    'purple': ['purple', 'lavender'],
    'pink': ['pink', 'magenta'],
  };

  /// The hue family of [named]'s palette name, or `''` when the palette and
  /// [families] fall out of sync (the analyzer then falls back to [nearest]).
  static String familyOf(NamedColor named) {
    for (final entry in families.entries) {
      if (entry.value.contains(named.name)) return entry.key;
    }
    return '';
  }

  static final List<(double, double, double)> _anchorLab = [
    for (final a in anchors) _toLab(a.color),
  ];

  /// Nearest palette entry to [color] under CIE76 (Lab) distance, tie-broken
  /// by palette order. Deterministic.
  static NamedColor nearest(RgbColor color) {
    final (l, a, b) = _toLab(color);
    var best = anchors.first;
    var bestD = double.infinity;
    for (var i = 0; i < anchors.length; i++) {
      final (al, aa, ab) = _anchorLab[i];
      final dl = l - al;
      final da = a - aa;
      final db = b - ab;
      final d = dl * dl + da * da + db * db;
      if (d < bestD) {
        bestD = d;
        best = anchors[i];
      }
    }
    return best;
  }

  static (double, double, double) _toLab(RgbColor c) {
    double lin(double v) => v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    final r = lin(c.r / 255.0);
    final g = lin(c.g / 255.0);
    final b = lin(c.b / 255.0);
    final x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
    final y = 0.2126729 * r + 0.7151522 * g + 0.072175 * b;
    final z = (0.0193339 * r + 0.119192 * g + 0.9503041 * b) / 1.08883;
    double f(double t) =>
        t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
    final fx = f(x);
    final fy = f(y);
    final fz = f(z);
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }
}

/// Deterministic dominant-color extractor.
///
/// Defaults match the validated reference recipe: downscale → k-means with k=5.
class ColorAnalyzer {
  const ColorAnalyzer({
    this.k = 5,
    this.maxSamples = 4096,
    this.maxIterations = 24,
  });

  /// Number of k-means clusters. Only clusters that end up non-empty are
  /// reported, so solids yield one dominant color.
  final int k;

  /// Cap on sampled pixels after uniform downscaling.
  final int maxSamples;

  /// Lloyd iteration cap (typically converges in well under 24).
  final int maxIterations;

  /// Finds the dominant colors of an image given as packed `0xAARRGGBB`
  /// pixels in row-major order. Returns at most [top] entries ranked by
  /// proportion, each mapped to the nearest palette name.
  ///
  /// Throws [ArgumentError] if [argb]'s length does not match
  /// `width * height`.
  List<DominantColor> analyze({
    required List<int> argb,
    required int width,
    required int height,
    int top = 5,
  }) {
    if (argb.length != width * height) {
      throw ArgumentError(
        'argb length ${argb.length} does not match ${width}x$height',
      );
    }
    final samples = _sample(argb);
    if (samples.isEmpty) return const [];
    final clusters = _kMeans(samples, k);
    clusters.sort((a, b) => b.count.compareTo(a.count));
    final n = samples.length;
    final limit = top.clamp(1, clusters.length);
    return [
      for (var i = 0; i < limit; i++)
        DominantColor(
          ColorPalette.nearest(clusters[i].centroid),
          clusters[i].count / n,
        ),
    ];
  }

  /// Ranks dominant colors by *hue family* instead of by raw cluster share.
  ///
  /// Runs the same deterministic pipeline as [analyze], then merges every
  /// cluster whose palette name shares a [ColorPalette.families] entry —
  /// summing their proportions — so a single garment hue that k-means split
  /// into several named clusters (e.g. `sky` + `navy` + `blue`) is reported as
  /// one family instead of several low-share also-rans. This is what makes a
  /// mostly-blue garment win against a black/white backdrop that would
  /// otherwise rank higher by cluster size.
  ///
  /// Returns at most [top] [DominantFamily]s ranked by summed proportion, each
  /// carrying [DominantFamily.namedColor] = the largest member cluster's name,
  /// [DominantFamily.proportion] = the summed share in [0, 1], and
  /// [DominantFamily.members] = every constituent. Empty images yield `const
  /// []`.
  ///
  /// When [preferChromatic] is true, an image shot on a light neutral
  /// background (a `neutral` family whose representative the palette names
  /// `white`) is re-ranked so the *item* wins instead of the backdrop: either
  /// the largest chromatic family (provided it holds at least
  /// [minChromaticShare] of all pixels) or, when the item is itself a
  /// dark/monochrome garment, the sum of the `black`-named clusters (e.g. a
  /// black tee photographed on white). A genuinely white item still reports
  /// white because there is no chromatic or dark component to promote. The
  /// budget [minChromaticShare] prevents a stray logo, label, or shadow
  /// swatch from hijacking the dominant color.
  ///
  /// Throws [ArgumentError] if [argb] does not match `width * height` (same
  /// contract as [analyze]).
  List<DominantFamily> aggregateFamilies({
    required List<int> argb,
    required int width,
    required int height,
    int top = 3,
    bool preferChromatic = false,
    double minChromaticShare = 0.15,
  }) {
    final clusters = analyze(argb: argb, width: width, height: height);
    if (clusters.isEmpty) return const [];

    final byFamily = <String, _FamilyAcc>{};
    for (final c in clusters) {
      final family = ColorPalette.familyOf(c.namedColor);
      final acc = byFamily.putIfAbsent(
            family.isEmpty ? c.namedColor.name : family,
            () => _FamilyAcc(),
          );
      acc.members.add(c);
      acc.proportion += c.proportion;
    }

    var families = <DominantFamily>[
      for (final acc in byFamily.values) acc.toDominantFamily(),
    ];
    families.sort((a, b) => b.proportion.compareTo(a.proportion));
    if (preferChromatic) {
      families = _preferItemOverBackground(families, clusters, minChromaticShare);
    }
    final limit = top.clamp(1, families.length);
    return families.take(limit).toList();
  }

  /// Re-ranks [families] (already sorted by proportion) so that, when the
  /// current winner looks like a light neutral photo background, the item in
  /// front of it is promoted to first place: the largest chromatic family, or
  /// the summed `black` clusters when the item is a dark monochrome garment.
  /// [clusters] is the raw quantizer output (has per-member proportions) —
  /// [DominantFamily.members] only keeps palette names.
  List<DominantFamily> _preferItemOverBackground(
    List<DominantFamily> families,
    List<DominantColor> clusters,
    double minChromaticShare,
  ) {
    if (families.isEmpty) return families;
    final winner = families.first;
    final lightNeutralBackground =
        winner.family == 'neutral' && winner.namedColor.name == 'white';
    if (!lightNeutralBackground) return families;

    // Best chromatic candidate (colored garment on the backdrop).
    DominantFamily? bestChromatic;
    for (final f in families) {
      if (f.family == 'neutral') continue;
      if (f.proportion < minChromaticShare) continue;
      if (bestChromatic == null || f.proportion > bestChromatic.proportion) {
        bestChromatic = f;
      }
    }

    // Dark monochrome candidate: the sum of every `black` member cluster. A
    // charcoal garment quantizes to `black` (closer to the black anchor than
    // to mid-grey), so this catches near-black items without promoting
    // genuine mid-grey.
    final blackClusters = [
      for (final c in clusters)
        if (c.namedColor.name == 'black') c,
    ];
    double blackShare =
        blackClusters.fold(0.0, (sum, c) => sum + c.proportion);

    if (bestChromatic == null &&
        (blackClusters.isEmpty || blackShare < minChromaticShare)) {
      return families;
    }

    if (bestChromatic != null &&
        (blackClusters.isEmpty || bestChromatic.proportion >= blackShare)) {
      return [
        bestChromatic,
        for (final f in families)
          if (!identical(f, bestChromatic)) f,
      ];
    }

    final dark = _FamilyAcc()
      ..members.addAll(blackClusters)
      ..proportion = blackShare;
    return [
      dark.toDominantFamily(),
      for (final f in families)
        if (!identical(f, winner)) f,
    ];
  }

  List<RgbColor> _sample(List<int> argb) {
    final n = argb.length;
    if (n <= maxSamples) return [for (final v in argb) RgbColor.fromArgb(v)];
    final step = (n / maxSamples).ceil();
    final out = <RgbColor>[];
    for (var i = 0; i < n; i += step) {
      out.add(RgbColor.fromArgb(argb[i]));
    }
    return out;
  }

  /// Lloyd's k-means on RGB samples with deterministic k-means++ seeding and
  /// deterministic empty-cluster reseeding. Returns one `_Cluster` per
  /// non-empty center.
  List<_Cluster> _kMeans(List<RgbColor> samples, int k) {
    final pts = <_Point>[
      for (final s in samples) _Point(s.r.toDouble(), s.g.toDouble(), s.b.toDouble()),
    ];

    // Fixed-seed LCG, reset per call -> deterministic across calls.
    var seed = 0x9E3779B9;
    double nextRand() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    // k-means++ seeding.
    final centerIds = <int>[0];
    final d2 = List<double>.filled(pts.length, double.infinity);
    for (var c = 1; c < k; c++) {
      final last = centerIds.last;
      var sum = 0.0;
      for (var i = 0; i < pts.length; i++) {
        final d = _dist2(pts[i], pts[last]);
        if (d < d2[i]) d2[i] = d;
        sum += d2[i];
      }
      if (sum == 0.0) break; // all points identical -> cannot split further
      var target = nextRand() * sum;
      var pick = 0;
      for (var i = 0; i < pts.length; i++) {
        target -= d2[i];
        if (target <= 0) {
          pick = i;
          break;
        }
      }
      if (centerIds.contains(pick)) {
        // Zero-probability collision: fall back to farthest distinct point.
        var best = -1;
        var bestD = 0.0;
        for (var i = 0; i < pts.length; i++) {
          if (!centerIds.contains(i) && d2[i] > bestD) {
            bestD = d2[i];
            best = i;
          }
        }
        if (best < 0) break;
        pick = best;
      }
      centerIds.add(pick);
    }

    final centers = <_Point>[
      for (final id in centerIds)
        _Point(pts[id].x, pts[id].y, pts[id].z),
    ];
    final assignment = List<int>.filled(pts.length, 0);

    for (var iter = 0; iter < maxIterations; iter++) {
      // Assign to nearest center (tie-break: lowest center index).
      var changed = false;
      for (var i = 0; i < pts.length; i++) {
        var bestC = 0;
        var bestD = _dist2(pts[i], centers[0]);
        for (var c = 1; c < centers.length; c++) {
          final d = _dist2(pts[i], centers[c]);
          if (d < bestD) {
            bestD = d;
            bestC = c;
          }
        }
        if (assignment[i] != bestC) {
          assignment[i] = bestC;
          changed = true;
        }
      }
      if (!changed) break;

      final counts = List<int>.filled(centers.length, 0);
      final sums = [
        for (final _ in centers) _Point(0, 0, 0),
      ];
      for (var i = 0; i < pts.length; i++) {
        final c = assignment[i];
        counts[c]++;
        sums[c] = _Point(
          sums[c].x + pts[i].x,
          sums[c].y + pts[i].y,
          sums[c].z + pts[i].z,
        );
      }

      // Reseed empty centers to the farthest point from its own center.
      for (var c = 0; c < centers.length; c++) {
        if (counts[c] == 0) {
          var fi = -1;
          var fBest = 0.0;
          for (var i = 0; i < pts.length; i++) {
            final d = _dist2(pts[i], centers[assignment[i]]);
            if (d > fBest) {
              fBest = d;
              fi = i;
            }
          }
          if (fi >= 0) {
            centers[c] = _Point(pts[fi].x, pts[fi].y, pts[fi].z);
          }
        }
      }

      // Recompute means.
      for (var c = 0; c < centers.length; c++) {
        if (counts[c] > 0) {
          centers[c] = _Point(
            sums[c].x / counts[c],
            sums[c].y / counts[c],
            sums[c].z / counts[c],
          );
        }
      }
    }

    final groups = <int, List<int>>{};
    for (var i = 0; i < pts.length; i++) {
      groups.putIfAbsent(assignment[i], () => []).add(i);
    }
    final clusters = <_Cluster>[];
    groups.forEach((cid, indices) {
      if (indices.isEmpty) return;
      var sx = 0.0, sy = 0.0, sz = 0.0;
      for (final i in indices) {
        sx += pts[i].x;
        sy += pts[i].y;
        sz += pts[i].z;
      }
      final n = indices.length.toDouble();
      int quantize(double v) => math.min(255, math.max(0, v.round()));
      clusters.add(
        _Cluster(
          RgbColor(
            quantize(sx / n),
            quantize(sy / n),
            quantize(sz / n),
          ),
          indices.length,
        ),
      );
    });
    return clusters;
  }
}

class _Point {
  const _Point(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

class _Cluster {
  const _Cluster(this.centroid, this.count);
  final RgbColor centroid;
  final int count;
}

double _dist2(_Point a, _Point b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  final dz = a.z - b.z;
  return dx * dx + dy * dy + dz * dz;
}