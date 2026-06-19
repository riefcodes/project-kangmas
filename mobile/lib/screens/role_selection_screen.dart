import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KANGMAS  –  Choosing‐Role Landing Screen
//
// Color palette extracted from the repo:
//   Primary Amber   : 0xFFFFB800  (splash, profile, buttons)
//   Slate 900       : 0xFF0F172A  (appBar, dark accents)
//   Background      : 0xFFF8F9FA  (scaffold bg across screens)
//   Card Surface    : 0xFFFFFFFF
//   Text Dark       : 0xFF333333 / 0xFF1E293B
//   Text Muted      : 0xFF64748B
// ─────────────────────────────────────────────────────────────────────────────

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // ── Design tokens (repo‐sourced) ──────────────────────────────────────────
  static const Color _amber      = Color(0xFFFFB800);
  static const Color _amberLight = Color(0xFFFFF3D0);
  static const Color _slate900   = Color(0xFF0F172A);
  static const Color _bgColor    = Color(0xFFF8F9FA);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textMuted  = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── App branding ──────────────────────────────────────────────
              Image.asset(
                'asset/images/logo loading dan tombol tenggah.webp',
                width: 72,
                height: 72,
              ),
              const SizedBox(height: 20),
              const Text(
                'KANGMAS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _slate900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Temukan Tukang Terpercaya\nDi Sekitar Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _textMuted,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Prompt ────────────────────────────────────────────────────
              const Text(
                'Kamu menggunakan\naplikasi ini sebagai:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // ── Role cards ────────────────────────────────────────────────
              _RoleCard(
                title: 'Tukang',
                subtitle: 'Terima order & kerjakan jasa',
                mascotPath: 'asset/images/Tukang maskot.webp',
                accentColor: _slate900,
                iconBgColor: _slate900.withOpacity(0.08),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/auth_choice',
                  arguments: 'tukang',
                ),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Pengguna',
                subtitle: 'Cari tukang & pesan jasa',
                mascotPath: 'asset/images/pengguna maskot.webp',
                accentColor: _amber,
                iconBgColor: _amberLight,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/auth_choice',
                  arguments: 'user',
                ),
              ),

              const Spacer(),

              // ── Footer tagline ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Text(
                  '© 2026 KANGMAS  •  Solusi Jasa Terpercaya',
                  style: TextStyle(
                    fontSize: 11,
                    color: _textMuted.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  _RoleCard  –  Animated, self‐contained role‐selection card widget
// ═══════════════════════════════════════════════════════════════════════════════

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String mascotPath;
  final Color accentColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.mascotPath,
    required this.accentColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Mascot avatar ─────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(widget.mascotPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),

              // ── Text column ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Chevron ───────────────────────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
