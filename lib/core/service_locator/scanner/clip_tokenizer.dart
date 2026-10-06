import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Dart port of the HuggingFace `tokenizers` BPE pipeline as configured by
/// `assets/models/tokenizer.json`.
///
/// Pipeline (verified against the Rust `tokenizers` implementation and a
/// reference dump of the real encode() output):
///
///  1. Normalizer: Sequence[NFC, Replace(`\s+` -> ` `), Lowercase]
///  2. Pre-tokenizer: Sequence[
///       Split(regex, behavior=Removed, invert=true),
///       ByteLevel(add_prefix_space=false, trim_offsets=true, use_regex=true)
///     ]
///  3. BPE model with `end_of_word_suffix=</w>`, empty
///     `continuing_subword_prefix`, `byte_fallback=false`.
///  4. Post-processor: RobertaProcessing (cls=49406, sep=49407).
///
/// The ByteLevel `use_regex` second pass is a no-op here because step 2 already
/// emits whitespace-free chunks: every chunk produced by the Split regex is a
/// maximal letters run, a single number, a contraction token, or a non-alnum
/// run, and the ByteLevel regex matches each of those verbatim. Byte-encoding
/// (space -> U+0120 "Ġ", non-ASCII -append -utf8 bytes) is applied per chunk.
///
/// NFC is applied as an identity for non-decomposed inputs; all reference
/// vectors used to validate this class are already NFC, so this is exact for
/// them. A future change should add a real NFC pass if decomposed input is
/// expected.
class ClipTokenizer {
  ClipTokenizer._(this._vocab, this._merges);

  /// `class`/`sep` ids the model's RobertaProcessing post-processor uses.
  static const int bosToken = 49406;
  static const int eosToken = 49407;

  static const String _endOfWordSuffix = '</w>';
  static const int _unkToken = 49407;

  final Map<String, int> _vocab;

  /// Pair (idA, idB) -> (rank, newId) mirror of Rust `Word::merge_all`.
  final Map<(int, int), ({int rank, int newId})> _merges;

  /// Byte (0..255) -> code point, built like GPT-2 `bytes_to_unicode`.
  static final List<int> _byteToCodePoint = _buildByteToCodePoint();

  static Future<ClipTokenizer> fromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return fromJsonString(jsonString);
  }

  static ClipTokenizer fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final model = json['model'] as Map<String, dynamic>;

    final rawVocab = model['vocab'] as Map<String, dynamic>;
    final vocab = <String, int>{
      for (final e in rawVocab.entries) e.key: e.value as int,
    };

    final rawMerges = (model['merges'] as List<dynamic>)
        .map((e) => e as String)
        .toList(growable: false);
    final merges = <(int, int), ({int rank, int newId})>{};
    for (var rank = 0; rank < rawMerges.length; rank++) {
      final parts = rawMerges[rank].split(' ');
      final first = vocab[parts[0]]!;
      final second = vocab[parts[1]]!;
      // The merge produces the concatenation of the two vocab tokens; with an
      // empty `continuing_subword_prefix` that is simply first + second.
      final newId = vocab[parts[0] + parts[1]]!;
      merges[(first, second)] = (rank: rank, newId: newId);
    }

    return ClipTokenizer._(vocab, merges);
  }

  /// Returns the full token id sequence for [text], including BOS/EOS.
  List<int> encode(String text) {
    final normalized = _normalize(text);
    final ids = <int>[bosToken];
    for (final chunk in _preTokenize(normalized)) {
      ids.addAll(_mergeWord(_byteEncode(chunk)));
    }
    ids.add(eosToken);
    return ids;
  }

  String _normalize(String text) {
    // 1. NFC (identity here, see class doc).
    // 2. Collapse all whitespace to a single space.
    // 3. Lowercase.
    return text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  /// Split(regex, behavior=Removed, invert=true): keep every span matched by
  /// the alternation, drop everything between (whitespace delimiters, and any
  /// other unmatched characters).
  static const List<String> _contractions = [
    "'s",
    "'t",
    "'re",
    "'ve",
    "'m",
    "'ll",
    "'d",
  ];

  List<String> _preTokenize(String s) {
    final chunks = <String>[];
    final n = s.length;
    var i = 0;
    while (i < n) {
      String? alt;
      for (final c in _contractions) {
        if (s.startsWith(c, i)) {
          alt = c;
          break;
        }
      }
      if (alt != null) {
        chunks.add(alt);
        i += alt.length;
        continue;
      }

      final unit = s.codeUnitAt(i);
      if (_isLetter(unit)) {
        var j = i + 1;
        while (j < n && _isLetter(s.codeUnitAt(j))) {
          j++;
        }
        chunks.add(s.substring(i, j));
        i = j;
        continue;
      }

      if (_isDigit(unit)) {
        chunks.add(s.substring(i, i + 1)); // [\p{N}] matches a single digit.
        i += 1;
        continue;
      }

      if (!_isSpace(s[i])) {
        var j = i + 1;
        while (j < n &&
            !_isSpace(s[j]) &&
            !_isLetter(s.codeUnitAt(j)) &&
            !_isDigit(s.codeUnitAt(j))) {
          j++;
        }
        chunks.add(s.substring(i, j));
        i = j;
        continue;
      }

      i += 1; // Delimiter: removed by the Split pre-tokenizer.
    }
    return chunks;
  }

  String _byteEncode(String chunk) {
    final bytes = utf8.encode(chunk);
    return String.fromCharCodes([for (final b in bytes) _byteToCodePoint[b]]);
  }

  /// Port of `BPE::merge_word` + `Word::merge_all` from the Rust `tokenizers`
  /// crate, using a (rank, pos) min-heap with stale-entry validation.
  List<int> _mergeWord(String word) {
    final symbols = <_Symbol>[];
    final runes = word.runes.toList(growable: false);
    for (var i = 0; i < runes.length; i++) {
      final isLast = i == runes.length - 1;
      final key = String.fromCharCode(runes[i]) +
          (isLast ? _endOfWordSuffix : '');
      final id = _vocab[key] ?? _unkToken;
      symbols.add(_Symbol(id, i - 1, -1, 1));
      if (i > 0) {
        symbols[i - 1].next = i;
      }
    }

    final heap = _MergeHeap();
    for (var i = 0; i + 1 < symbols.length; i++) {
      final merge = _merges[(symbols[i].id, symbols[i + 1].id)];
      if (merge != null) {
        heap.push(_Merge(i, merge.rank, merge.newId));
      }
    }

    while (heap.isNotEmpty) {
      final top = heap.pop();
      final pos = top.pos;
      if (pos < 0 || pos >= symbols.length) continue;
      if (symbols[pos].len == 0) continue; // Already merged away.
      if (symbols[pos].next == -1) continue; // Last symbol: nothing to merge.
      final nextPos = symbols[pos].next;
      final right = symbols[nextPos];

      // Expired heap entry: the live pair no longer maps to this merge.
      final target = _merges[(symbols[pos].id, right.id)];
      if (target == null || target.newId != top.newId) continue;

      symbols[pos]
        ..id = top.newId
        ..len += right.len
        ..next = right.next;
      symbols[nextPos].len = 0;
      if (right.next > -1 && right.next < symbols.length) {
        symbols[right.next].prev = pos;
      }

      final current = symbols[pos];
      if (current.prev >= 0) {
        final prev = current.prev;
        final up = _merges[(symbols[prev].id, current.id)];
        if (up != null) {
          heap.push(_Merge(prev, up.rank, up.newId));
        }
      }
      final nxt = current.next;
      if (nxt >= 0 && nxt < symbols.length) {
        final down = _merges[(current.id, symbols[nxt].id)];
        if (down != null) {
          heap.push(_Merge(pos, down.rank, down.newId));
        }
      }
    }

    return [
      for (final s in symbols)
        if (s.len != 0) s.id,
    ];
  }

  static List<int> _buildByteToCodePoint() {
    final printable = <int>{
      for (var b = 0x21; b <= 0x7E; b++) b,
      for (var b = 0xA1; b <= 0xAC; b++) b,
      for (var b = 0xAE; b <= 0xFF; b++) b,
    };
    final map = List<int>.filled(256, 0);
    var n = 0;
    for (var b = 0; b < 256; b++) {
      map[b] = printable.contains(b) ? b : 256 + n++;
    }
    return map;
  }

  static bool _isSpace(String s) => _spaceRe.hasMatch(s);
  static final RegExp _spaceRe = RegExp(r'\s');

  static bool _isLetter(int c) => !_isDigit(c) && _inRanges(c, _letterRanges);

  static bool _isDigit(int c) => _inRanges(c, _digitRanges);

  static bool _inRanges(int c, List<(int, int)> ranges) {
    for (final r in ranges) {
      if (c >= r.$1 && c <= r.$2) {
        return true;
      }
    }
    return false;
  }

  /// Coarse General-Category-L approximation. Digit ranges are carved out
  /// globally by `_isLetter`, so these ranges may overlap number ranges.
  /// Covers everything the wardrobe catalog realistically needs (Latin incl.
  /// French diacritics, Arabic, Devanagari-family, SE-Asian, CJK, Hangul,
  /// Kana) plus common supplementary scripts.
  static const List<(int, int)> _letterRanges = [
    // Latin
    (0x0041, 0x005A),
    (0x0061, 0x007A),
    (0x00C0, 0x00D6),
    (0x00D8, 0x00F6),
    (0x00F8, 0x02AF),
    (0x1D00, 0x1DBF),
    (0x1E00, 0x1EFF),
    (0x2C60, 0x2C7F),
    (0xA720, 0xA7FF),
    (0xAB30, 0xAB6F),
    (0xFB00, 0xFB06),
    (0xFF21, 0xFF3A),
    (0xFF41, 0xFF5A),
    // Greek
    (0x0370, 0x03FF),
    (0x1F00, 0x1FFF),
    // Cyrillic
    (0x0400, 0x052F),
    (0x2DE0, 0x2DFF),
    (0xA640, 0xA69F),
    // Armenian / Hebrew
    (0x0531, 0x0587),
    (0x05D0, 0x05F2),
    // Arabic + presentation forms
    (0x0621, 0x063F),
    (0x0641, 0x064A),
    (0x066E, 0x06D3),
    (0x06D5, 0x06D5),
    (0x06E5, 0x06E6),
    (0x06EE, 0x06EF),
    (0x06FA, 0x06FF),
    (0x0750, 0x077F),
    (0x08A0, 0x08FF),
    (0xFB50, 0xFDCF),
    (0xFDF0, 0xFDFF),
    (0xFE70, 0xFEFC),
    // Syriac / Thaana / Samaritan / Mandaic
    (0x0710, 0x074F),
    (0x0780, 0x07BF),
    (0x0800, 0x083F),
    (0x0840, 0x085F),
    // Indic
    (0x0900, 0x0963),
    (0x0971, 0x097F),
    (0x0981, 0x09B9),
    (0x09DC, 0x09E3),
    (0x09F0, 0x09F7),
    (0x0A01, 0x0A30),
    (0x0A3C, 0x0A4D),
    (0x0A59, 0x0A71),
    (0x0A81, 0x0AAD),
    (0x0AF0, 0x0AF1),
    (0x0B01, 0x0B2F),
    (0x0B5C, 0x0B61),
    (0x0B71, 0x0B71),
    (0x0B82, 0x0BA3),
    (0x0BAE, 0x0BB9),
    (0x0C01, 0x0C33),
    (0x0C60, 0x0C6F),
    (0x0C81, 0x0CB3),
    (0x0CBC, 0x0CC5),
    (0x0CE0, 0x0CEF),
    (0x0D01, 0x0D3A),
    (0x0D60, 0x0D6F),
    (0x0D7A, 0x0D7F),
    (0x0D81, 0x0DC7),
    (0x0DCF, 0x0DDF),
    // Thai / Lao / Tibetan / Myanmar (digits carved by _isLetter)
    (0x0E01, 0x0E4E),
    (0x0E81, 0x0EDE),
    (0x0F00, 0x0F47),
    (0x0F49, 0x0F6C),
    (0x0F88, 0x0F97),
    (0x1000, 0x103F),
    // Georgian / Ethiopic / Canadian / Ogham / Runic
    (0x10A0, 0x10FF),
    (0x1200, 0x137F),
    (0x1400, 0x167F),
    (0x1680, 0x169F),
    (0x16A0, 0x16EA),
    // Khmer / Mongolian
    (0x1780, 0x17DC),
    (0x1820, 0x18AA),
    // Tifinagh / Ethiopic extensions
    (0x2D30, 0x2D67),
    (0x2D80, 0x2DDE),
    (0xAB00, 0xAB2F),
    // Hangul
    (0x1100, 0x11FF),
    (0xA960, 0xA97F),
    (0xAC00, 0xD7A3),
    (0xD7A4, 0xD7FF),
    // Kana / Bopomofo
    (0x3040, 0x309F),
    (0x30A0, 0x30FF),
    (0x31F0, 0x31FF),
    (0x3100, 0x312F),
    (0x31A0, 0x31BF),
    // CJK
    (0x3400, 0x4DBF),
    (0x4E00, 0x9FFF),
    (0xF900, 0xFAFF),
  ];

  static const List<(int, int)> _digitRanges = [
    (0x0030, 0x0039),
    (0x0660, 0x0669),
    (0x06F0, 0x06F9),
    (0x0966, 0x096F),
    (0x09E6, 0x09EF),
    (0x0A66, 0x0A6F),
    (0x0AE6, 0x0AEF),
    (0x0B66, 0x0B6F),
    (0x0BE6, 0x0BEF),
    (0x0C66, 0x0C6F),
    (0x0CE6, 0x0CEF),
    (0x0D66, 0x0D6F),
    (0x0DE6, 0x0DEF),
    (0x0E50, 0x0E59),
    (0x0ED0, 0x0ED9),
    (0x0F20, 0x0F29),
    (0x1040, 0x1049),
    (0x1090, 0x1099),
    (0x17E0, 0x17E9),
    (0x1810, 0x1819),
    (0x1946, 0x194F),
    (0x1B50, 0x1B59),
    (0xFF10, 0xFF19),
  ];
}

class _Symbol {
  int id;
  int prev;
  int next;
  int len;

  _Symbol(this.id, this.prev, this.next, this.len);
}

class _Merge {
  final int pos;
  final int rank;
  final int newId;

  _Merge(this.pos, this.rank, this.newId);
}

/// Min-heap over (_Merge.rank, _Merge.pos).
class _MergeHeap {
  final List<_Merge> _items = [];

  bool get isNotEmpty => _items.isNotEmpty;

  void push(_Merge m) {
    _items.add(m);
    _siftUp(_items.length - 1);
  }

  _Merge pop() {
    final top = _items[0];
    final last = _items.removeLast();
    if (_items.isNotEmpty) {
      _items[0] = last;
      _siftDown(0);
    }
    return top;
  }

  void _siftUp(int i) {
    while (i > 0) {
      final p = (i - 1) ~/ 2;
      if (_less(_items[i], _items[p])) {
        _swap(i, p);
        i = p;
      } else {
        break;
      }
    }
  }

  void _siftDown(int i) {
    final n = _items.length;
    while (true) {
      final l = 2 * i + 1;
      final r = l + 1;
      var s = i;
      if (l < n && _less(_items[l], _items[s])) {
        s = l;
      }
      if (r < n && _less(_items[r], _items[s])) {
        s = r;
      }
      if (s == i) {
        break;
      }
      _swap(i, s);
      i = s;
    }
  }

  bool _less(_Merge a, _Merge b) =>
      a.rank < b.rank || (a.rank == b.rank && a.pos < b.pos);

  void _swap(int i, int j) {
    final t = _items[i];
    _items[i] = _items[j];
    _items[j] = t;
  }
}