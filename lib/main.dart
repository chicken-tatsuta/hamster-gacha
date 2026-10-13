import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const HamsterApp());

class HamsterApp extends StatelessWidget {
  const HamsterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hamster Gacha',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFFAFC),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB18ADB)),
      fontFamily: null,
    ),
    home: const HamsterGacha(),
  );
}

// Keep these URLs unchanged. Each image has a stable index used for collection.
const _base = 'https://kmc2400.github.io/hamster-images/';
const imageNames = <String>[
  'acidfern-_ASImGUewVM-unsplash.jpg',
  'adela-monczkova-IvJa_c8THWg-unsplash.jpg',
  'adela-monczkova-qmiID5T8_uA-unsplash.jpg',
  'alex-konokh-6MKJbkZ0qNY-unsplash.jpg',
  'andy-holmes-fyc0u7SoBOQ-unsplash.jpg',
  'bjorn-antonissen-YkRRIEkVajk-unsplash.jpg',
  'bonnie-kittle-MUcxe_wDurE-unsplash.jpg',
  'denis-bayer-4KC4hUWCtJI-unsplash.jpg',
  'doina-gavrilov-BpAnE1DVWEs-unsplash.jpg',
  'finney-kFh7PHBKWd0-unsplash.jpg',
  'frances-goldberg-mnOVgsxg-8E-unsplash.jpg',
  'frenjamin-benklin-2Px6-jGGH_w-unsplash.jpg',
  'frenjamin-benklin-6yKTcxJhbQ8-unsplash.jpg',
  'frenjamin-benklin-8gOu6m_tj-0-unsplash.jpg',
  'frenjamin-benklin-i0OwUyZ4QW0-unsplash.jpg',
  'frenjamin-benklin-KIXHGKPswE0-unsplash.jpg',
  'frenjamin-benklin-waKf09YkDcw-unsplash.jpg',
  'guillermo-velarde-JlI9qNsD-Uw-unsplash.jpg',
  'gustavo-zambelli-mwwRDU_ekjw-unsplash.jpg',
  'henry-lai-2uTVeLDQQkk-unsplash.jpg',
  'henry-lai-ZKLsj6xruAk-unsplash.jpg',
  'jaroslaw-slodkiewicz-SDIIfq6nhFU-unsplash.jpg',
  'jay-nlper-Tpff0kOfhYw-unsplash.jpg',
  'juliya-sidorova-FOxMZK1VQS8-unsplash.jpg',
  'katherine-mcadoo-vSS2_KfzbLY-unsplash.jpg',
  'kim-green-1VY30CTcsqE-unsplash.jpg',
  'kim-green-D_pXn7cueOs-unsplash.jpg',
  'leslie-soto-Py1iPnpzLoo-unsplash.jpg',
  'matt-bero-wMXetxdXeZM-unsplash.jpg',
  'melissa-keizer-2Qs3kvXGwjg-unsplash.jpg',
  'melissa-keizer-UTv7cPiNsug-unsplash.jpg',
  'nick-fewings--dtKoaHpi9M-unsplash.jpg',
  'nikolett-emmert-4WDzXJrPNLE-unsplash.jpg',
  'nikolett-emmert-FsBKr0AOirM-unsplash.jpg',
  'nikolett-emmert-WiBYpESTwb8-unsplash.jpg',
  'nikolett-emmert-ZSc4X_rqjL8-unsplash.jpg',
  'nils-schirmer-cKYM8KMwaUQ-unsplash.jpg',
  'peter-steiner-1973-fcXMGrmk64o-unsplash.jpg',
  'raychan-8IW8f37QAYA-unsplash.jpg',
  'ricky-kharawala-adK3Vu70DEQ-unsplash.jpg',
  'silje-roseneng-cMp84C0fPSg-unsplash.jpg',
  'sunira-moses-aXK_a0xxmW0-unsplash.jpg',
  'sunira-moses-r149yvhlJ4Q-unsplash.jpg',
  'yosei-g-OVgE3m4MHKM-unsplash.jpg',
  'zdenek-machacek-WZC1_6ChfMs-unsplash.jpg',
  'zhaoli-jin-57ePgTDfwWM-unsplash.jpg',
  'zhaoli-jin-83lFoPXYbkA-unsplash.jpg',
  'zhaoli-jin-cgnDJkzWkTg-unsplash.jpg',
  'zhaoli-jin-g6q1ko1ghos-unsplash.jpg',
  'zhaoli-jin-MwJ-VkhxOBs-unsplash.jpg',
  'zhaoli-jin-ntpFNTy_XzY-unsplash.jpg',
  'zhaoli-jin-u33lLlcLoys-unsplash.jpg',
  'zhaoli-jin-Xtb_lO_9r6Q-unsplash.jpg',
];

enum Rarity { n, r, sr, ssr }

extension RarityUI on Rarity {
  String get shortLabel => switch (this) {
    Rarity.n => 'N',
    Rarity.r => 'R',
    Rarity.sr => 'SR',
    Rarity.ssr => 'SSR',
  };

  String get label => switch (this) {
    Rarity.n => 'N · NORMAL',
    Rarity.r => 'R · RARE',
    Rarity.sr => 'SR · SUPER RARE',
    Rarity.ssr => 'SSR · LEGENDARY',
  };
  Color get color => switch (this) {
    Rarity.n => const Color(0xFF9A8B82),
    Rarity.r => const Color(0xFF559BCF),
    Rarity.sr => const Color(0xFFE3AC35),
    Rarity.ssr => const Color(0xFFCC6ACD),
  };
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.longestSide * .72;
    final inner = size.shortestSide * (.12 + phase * .025);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 20; i++) {
      final angle = i * pi / 10 + phase * .08;
      final halfWidth = i.isEven ? .075 : .035;
      paint.color = (i.isEven ? color : Colors.white).withValues(
        alpha: i.isEven ? .34 : .48,
      );
      final path = Path()
        ..moveTo(
          center.dx + cos(angle - halfWidth) * inner,
          center.dy + sin(angle - halfWidth) * inner,
        )
        ..lineTo(
          center.dx + cos(angle) * radius,
          center.dy + sin(angle) * radius,
        )
        ..lineTo(
          center.dx + cos(angle + halfWidth) * inner,
          center.dy + sin(angle + halfWidth) * inner,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

// The catalogue uses fixed rarities for consistency. The four draw-rate
// weights are applied first; an image is then selected within that tier.
Rarity rarityFor(int index) {
  if (index == 0) return Rarity.ssr;
  if (index < 6) return Rarity.sr;
  if (index < 19) return Rarity.r;
  return Rarity.n;
}

const hamsterNames = <String>[
  'ほしの',
  'きなこ',
  'もなか',
  'ぽてと',
  'しらたま',
  'くるみ',
  'ぷりん',
  'こはく',
  'まろん',
  'もちまる',
  'こむぎ',
  'つぶ',
  'むぎ',
  'おもち',
  'きなり',
  'ぽんず',
  'ふわり',
  'こてつ',
  'すあま',
  'ぽっけ',
  'ひまわり',
  'みるく',
  'ちゃい',
  'くり',
  'はな',
  'のん',
  'ちょこ',
  'こはる',
  'ぴの',
  'こむ',
  'ここあ',
  'ころん',
  'ごま',
  'ふく',
  'ちま',
  'りん',
  'ちび',
  'まる',
  'ぽよ',
  'ちゃちゃ',
  'てん',
  'もふ',
  'もぐ',
  'もも',
  'きゅう',
  'ぽむ',
  'ちょび',
  'ころ',
  'あずき',
  'ゆず',
  'らて',
  'ふに',
  'ぴぴ',
];

enum GachaPhase { idle, spinning, suspense, reveal }

class HamsterGacha extends StatefulWidget {
  const HamsterGacha({super.key});
  @override
  State<HamsterGacha> createState() => _HamsterGachaState();
}

class _HamsterGachaState extends State<HamsterGacha>
    with TickerProviderStateMixin {
  final _random = Random();
  final _audio = AudioPlayer();
  late final AnimationController _pulse;
  late final AnimationController _entrance;
  Timer? _reelTimer;
  int _generation = 0;
  int _selected = 0;
  int _pending = 0;
  int _spins = 0;
  int _tick = 0;
  int _pattern = 0;
  List<int> _reels = [0, 1, 2];
  final Set<int> _owned = <int>{};
  final List<int> _history = <int>[];
  GachaPhase _phase = GachaPhase.idle;
  bool _soundEnabled = true;
  bool _reduceMotion = false;
  bool _isNew = false;
  bool _ready = false;
  bool get _busy =>
      _phase == GachaPhase.spinning || _phase == GachaPhase.suspense;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..repeat(reverse: true);
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _spins = prefs.getInt('spins') ?? 0;
      _owned.addAll(
        (prefs.getStringList('owned') ?? <String>[])
            .map(int.tryParse)
            .whereType<int>()
            .where((e) => e >= 0 && e < imageNames.length),
      );
      _history.addAll(
        (prefs.getStringList('history') ?? <String>[])
            .map(int.tryParse)
            .whereType<int>()
            .where((e) => e >= 0 && e < imageNames.length),
      );
      _soundEnabled = prefs.getBool('sound') ?? true;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;
      _ready = true;
    });
    // Prefetch only a few images to avoid downloading all 53 photographs at once.
    for (var i = 0; i < min(5, imageNames.length); i++) {
      if (!mounted) break;
      precacheImage(
        NetworkImage('$_base${imageNames[i]}'),
        context,
      ).catchError((Object _) {});
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spins', _spins);
    await prefs.setStringList(
      'owned',
      _owned.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'history',
      _history.map((e) => e.toString()).toList(),
    );
    await prefs.setBool('sound', _soundEnabled);
    await prefs.setBool('reduceMotion', _reduceMotion);
  }

  Future<void> _play(String sound) async {
    if (!_soundEnabled) return;
    try {
      await _audio.stop();
      await _audio.play(AssetSource('sounds/$sound.wav'));
    } catch (_) {
      // Audio may be blocked by a browser or unavailable on a device.
    }
  }

  int _draw() {
    final roll = _random.nextInt(100);
    final tier = roll < 1
        ? Rarity.ssr
        : roll < 10
        ? Rarity.sr
        : roll < 35
        ? Rarity.r
        : Rarity.n;
    final candidates = <int>[
      for (int i = 0; i < imageNames.length; i++)
        if (rarityFor(i) == tier) i,
    ];
    return candidates[_random.nextInt(candidates.length)];
  }

  void _start() {
    if (_busy || !_ready) return;
    _generation++;
    final g = _generation;
    final target = _draw(); // Draw is fixed before any animation.
    _reelTimer?.cancel();
    _entrance.reset();
    setState(() {
      _pending = target;
      _phase = GachaPhase.spinning;
      _pattern = _random.nextInt(3);
      _tick = 0;
      _reels = List.generate(3, (_) => _random.nextInt(5));
    });
    HapticFeedback.lightImpact();
    _play('start');
    if (_reduceMotion) {
      _reveal(g);
      return;
    }
    _reelTimer = Timer.periodic(const Duration(milliseconds: 95), (timer) {
      if (!mounted || g != _generation) {
        timer.cancel();
        return;
      }
      setState(() {
        _tick++;
        for (int i = 0; i < 3; i++) {
          // First, second, third reels stop at staggered intervals.
          final stopAt = [
            15 + _pattern * 2,
            21 + _pattern * 2,
            28 + _pattern * 2,
          ][i];
          if (_tick < stopAt) _reels[i] = _random.nextInt(5);
          if (_tick == stopAt) _reels[i] = 0;
        }
      });
      if (_tick >= 28 + _pattern * 2) timer.cancel();
    });
    _sequence(g, 2900 + _pattern * 190);
  }

  Future<void> _sequence(int g, int millis) async {
    await Future.delayed(Duration(milliseconds: millis));
    if (!mounted || g != _generation) return;
    setState(() => _phase = GachaPhase.suspense);
    _reelTimer?.cancel();
    await _audio.stop(); // A brief contrast before the reveal.
    await Future.delayed(const Duration(milliseconds: 360));
    if (!mounted || g != _generation) return;
    _reveal(g);
  }

  void _reveal(int g) {
    if (!mounted || g != _generation) return;
    _reelTimer?.cancel();
    final target = _pending;
    setState(() {
      _selected = target;
      _isNew = !_owned.contains(target);
      _owned.add(target);
      _history.insert(0, target);
      _spins++;
      _phase = GachaPhase.reveal;
    });
    _entrance.forward(from: 0);
    HapticFeedback.mediumImpact();
    _play(
      rarityFor(target) == Rarity.ssr
          ? 'ssr'
          : rarityFor(target) == Rarity.sr
          ? 'sr'
          : rarityFor(target) == Rarity.r
          ? 'rare'
          : 'result',
    );
    _save();
    precacheImage(
      NetworkImage('$_base${imageNames[target]}'),
      context,
    ).catchError((Object _) {});
  }

  void _skip() {
    if (!_busy) return;
    _generation++; // Invalidates pending async steps and timers.
    _reveal(_generation);
  }

  @override
  void dispose() {
    _generation++;
    _reelTimer?.cancel();
    _pulse.dispose();
    _entrance.dispose();
    _audio.dispose();
    super.dispose();
  }

  Widget _photo(int index, {BoxFit fit = BoxFit.cover}) => Image.network(
    '$_base${imageNames[index]}',
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorBuilder: (_, _, _) => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 38),
          SizedBox(height: 8),
          Text('画像を読み込めませんでした', style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _slot() {
    if (_phase == GachaPhase.suspense) {
      return Container(
        color: const Color(0xFF32263D),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, _) => Transform.scale(
            scale: .9 + _pulse.value * .2,
            child: const Text(
              '・・・',
              style: TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
            ),
          ),
        ),
      );
    }
    const symbols = ['🐹', '🌻', '🥜', '⭐', '🍓'];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE0B0), Color(0xFFFFF4EA)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final reelWidth = min(116.0, (constraints.maxWidth - 30) / 3);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                Container(
                  width: reelWidth,
                  height: min(150.0, constraints.maxHeight * .62),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _tick > 17
                          ? const Color(0xFFFF9F43)
                          : const Color(0xFFE5B878),
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55A56A37),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 70),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -.65),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      symbols[_reels[i]],
                      key: ValueKey('${_reels[i]}-$i-$_tick'),
                      style: const TextStyle(fontSize: 68),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _result() {
    final rarity = rarityFor(_selected);
    final rare = rarity == Rarity.sr || rarity == Rarity.ssr;
    return AnimatedBuilder(
      animation: Listenable.merge([_entrance, _pulse]),
      builder: (context, child) {
        final entrance = Curves.elasticOut.transform(
          _entrance.value.clamp(0.0, 1.0),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    rarity.color.withValues(alpha: rare ? .95 : .58),
                    const Color(0xFF251B2B),
                  ],
                  stops: const [.04, .58, 1],
                ),
              ),
            ),
            if (rarity != Rarity.n)
              CustomPaint(
                painter: _BurstPainter(
                  color: rarity.color,
                  phase: _pulse.value,
                ),
              ),
            Transform.scale(
              scale: _reduceMotion ? 1 : .5 + .5 * entrance,
              child: Transform.rotate(
                angle: _reduceMotion ? 0 : (1 - entrance) * -.08,
                child: child,
              ),
            ),
            if (!_reduceMotion && _entrance.value < .32)
              ColoredBox(
                color: Colors.white.withValues(
                  alpha: (1 - _entrance.value / .32).clamp(0, 1),
                ),
              ),
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.all(rare ? 18 : 12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: rarity.color.withValues(alpha: rare ? .9 : .45),
                    blurRadius: rare ? 34 : 18,
                    spreadRadius: rare ? 8 : 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: _photo(_selected),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 28, 18, 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD160F19)],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        hamsterNames[_selected],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      rarity.shortLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rare ? 29 : 22,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: rarity.color, blurRadius: 14)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isNew)
              Positioned(
                top: 10,
                left: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8664),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    child: Text(
                      'NEW!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (rare)
              Positioned(
                right: 8,
                top: 4,
                child: Text(
                  rarity == Rarity.ssr ? '✨✨✨' : '✨✨',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openCollection() {
    if (_busy) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('🐹 ハムスター図鑑  ${_owned.length}/${imageNames.length}'),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .78,
            ),
            itemCount: imageNames.length,
            itemBuilder: (context, i) {
              final found = _owned.contains(i);
              final rarity = rarityFor(i);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: found ? rarity.color : const Color(0xFFE7E2E8),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: found
                            ? _photo(i)
                            : Container(
                                color: const Color(0xFFF1EEF2),
                                alignment: Alignment.center,
                                child: const Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 56,
                                    color: Color(0xFFCAC2CD),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        children: [
                          Text(
                            found ? hamsterNames[i] : '？？？',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            found ? rarity.label : '未発見',
                            style: TextStyle(
                              fontSize: 10,
                              color: found ? rarity.color : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openHistory() {
    if (_busy) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('獲得履歴  ${_history.length}件')),
          body: _history.isEmpty
              ? const Center(child: Text('まだ獲得履歴がありません'))
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: _history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final index = _history[i];
                    final rarity = rarityFor(index);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: _photo(index),
                        ),
                        title: Text(
                          hamsterNames[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          rarity.label,
                          style: TextStyle(color: rarity.color),
                        ),
                        trailing: Text(
                          '#${_history.length - i}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showResult = _phase == GachaPhase.reveal;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAFC),
        title: const Text('🐹', style: TextStyle(fontSize: 28)),
        actions: [
          IconButton(
            tooltip: _soundEnabled ? '音をオフ' : '音をオン',
            onPressed: () {
              setState(() => _soundEnabled = !_soundEnabled);
              _save();
            },
            icon: Icon(
              _soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          IconButton(
            tooltip: '図鑑',
            onPressed: _busy ? null : _openCollection,
            icon: const Icon(Icons.auto_stories_rounded),
          ),
          IconButton(
            tooltip: '獲得履歴',
            onPressed: _busy ? null : _openHistory,
            icon: const Icon(Icons.history_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: '設定',
            onSelected: (v) {
              if (v == 'reduce') {
                setState(() => _reduceMotion = !_reduceMotion);
                _save();
              }
            },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: 'reduce',
                checked: _reduceMotion,
                child: const Text('動きを抑える'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat(Icons.casino_rounded, '$_spins'),
                      const SizedBox(width: 10),
                      _stat(
                        Icons.auto_stories_rounded,
                        '${_owned.length}/${imageNames.length}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFD9BC),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16B46C3E),
                          blurRadius: 20,
                          offset: Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: AspectRatio(
                            aspectRatio: .95,
                            child: AnimatedSwitcher(
                              duration: _reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 220),
                              child: _busy
                                  ? KeyedSubtree(
                                      key: ValueKey(_phase),
                                      child: _slot(),
                                    )
                                  : _phase == GachaPhase.idle
                                  ? Container(
                                      key: const ValueKey('idle'),
                                      color: const Color(0xFFFFEAD9),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '🐹',
                                        style: TextStyle(fontSize: 136),
                                      ),
                                    )
                                  : KeyedSubtree(
                                      key: const ValueKey('result'),
                                      child: _result(),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 57,
                          child: FilledButton(
                            onPressed: _busy ? null : _start,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF1A769),
                              foregroundColor: const Color(0xFF603F2C),
                              disabledBackgroundColor: const Color(0xFFE8C9B7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              _busy
                                  ? '回転中'
                                  : showResult
                                  ? 'もう一度'
                                  : '回す',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                        if (_busy) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _skip,
                            child: const Text('SKIP'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF1ECF6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF76628C)),
        const SizedBox(width: 7),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF76628C),
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
