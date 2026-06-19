import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KANGMAS  –  Register Screen  (overhauled UI + front-end validation)
//
// Color palette (repo):
//   Amber    : 0xFFFFB800
//   Slate 900: 0xFF0F172A
//   Bg       : 0xFFF8F9FA
//   Muted    : 0xFF64748B
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameCtl     = TextEditingController();
  final _emailCtl    = TextEditingController();
  final _phoneCtl    = TextEditingController();
  final _passCtl     = TextEditingController();
  final _passConfCtl = TextEditingController();

  // ── Validation state ──────────────────────────────────────────────────────
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passError;
  String? _passConfError;
  String? _serverError;
  bool _obscurePass     = true;
  bool _obscurePassConf = true;
  bool _submitted       = false;

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const _amber    = Color(0xFFFFB800);
  static const _slate900 = Color(0xFF0F172A);
  static const _bgColor  = Color(0xFFF8F9FA);
  static const _muted    = Color(0xFF64748B);
  static const _errorRed = Color(0xFFEF4444);
  static const _fieldBg  = Color(0xFFF1F5F9);

  // ── Validators ────────────────────────────────────────────────────────────
  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$');
  static final _phoneRegex = RegExp(r'^08\d{8,12}$');

  String? _validateName(String v)  {
    if (v.isEmpty) return 'Nama tidak boleh kosong';
    if (v.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? _validateEmail(String v) {
    if (v.isEmpty) return 'Email tidak boleh kosong';
    if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePhone(String v) {
    if (v.isEmpty) return 'Nomor WhatsApp tidak boleh kosong';
    if (!_phoneRegex.hasMatch(v)) return 'Nomor harus diawali 08 dan 10‑14 digit';
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  String? _validatePassConf(String v) {
    if (v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (v != _passCtl.text) return 'Password tidak cocok';
    return null;
  }

  bool _validate() {
    final nameErr     = _validateName(_nameCtl.text.trim());
    final emailErr    = _validateEmail(_emailCtl.text.trim());
    final phoneErr    = _validatePhone(_phoneCtl.text.trim());
    final passErr     = _validatePassword(_passCtl.text);
    final passConfErr = _validatePassConf(_passConfCtl.text);
    setState(() {
      _submitted    = true;
      _nameError    = nameErr;
      _emailError   = emailErr;
      _phoneError   = phoneErr;
      _passError    = passErr;
      _passConfError = passConfErr;
    });
    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        passErr == null &&
        passConfErr == null;
  }

  void _onFieldChanged() {
    if (!_submitted) return;
    setState(() {
      _nameError     = _validateName(_nameCtl.text.trim());
      _emailError    = _validateEmail(_emailCtl.text.trim());
      _phoneError    = _validatePhone(_phoneCtl.text.trim());
      _passError     = _validatePassword(_passCtl.text);
      _passConfError = _validatePassConf(_passConfCtl.text);
    });
  }

  // ── Backend call (existing AuthProvider logic) ────────────────────────────
  Future<void> _register() async {
    if (!_validate()) return;

    // Clear any previous server error before a new attempt
    setState(() => _serverError = null);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    Map<String, dynamic> data = {
      'name': _nameCtl.text.trim(),
      'email': _emailCtl.text.trim(),
      'password': _passCtl.text,
      'password_confirmation': _passConfCtl.text,
      'role': 'user', // Register via app hanya untuk user
      'phone_number': _phoneCtl.text.trim(),
    };

    try {
      final success = await auth.register(data);
      if (!mounted) return;
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      // Surface the backend message as inline red disclaimer text
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _serverError = msg);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final ctl in [_nameCtl, _emailCtl, _phoneCtl, _passCtl, _passConfCtl]) {
      ctl.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passCtl.dispose();
    _passConfCtl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            _buildHeader(context),

            const SizedBox(height: 28),

            // ── Form body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _nameCtl,
                    hint: 'Masukkan nama lengkap kamu',
                    icon: Icons.person_outline,
                    error: _nameError,
                  ),
                  if (_nameError != null) _buildErrorText(_nameError!),
                  const SizedBox(height: 18),

                  // Email
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _emailCtl,
                    hint: 'Masukkan alamat email kamu',
                    icon: Icons.email_outlined,
                    error: _emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (_emailError != null) _buildErrorText(_emailError!),
                  const SizedBox(height: 18),

                  // Phone
                  _buildLabel('No. WhatsApp'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _phoneCtl,
                    hint: '08xxxxxxxxxx',
                    icon: Icons.phone_android_outlined,
                    error: _phoneError,
                    keyboardType: TextInputType.phone,
                  ),
                  if (_phoneError != null) _buildErrorText(_phoneError!),
                  const SizedBox(height: 18),

                  // Password
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _passCtl,
                    hint: 'Password (min 8 karakter)',
                    icon: Icons.lock_outline,
                    error: _passError,
                    obscureText: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _muted, size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  if (_passError != null) _buildErrorText(_passError!),
                  const SizedBox(height: 18),

                  // Confirm Password
                  _buildLabel('Konfirmasi Password'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _passConfCtl,
                    hint: 'Ketik ulang password kamu',
                    icon: Icons.lock_outline,
                    error: _passConfError,
                    obscureText: _obscurePassConf,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassConf ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _muted, size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassConf = !_obscurePassConf),
                    ),
                  ),
                  if (_passConfError != null) _buildErrorText(_passConfError!),
                  const SizedBox(height: 24),

                  // ── Server error banner ────────────────────────────────
                  if (_serverError != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: _errorRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _serverError!,
                              style: const TextStyle(fontSize: 13, color: _errorRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit
                  if (auth.isLoading)
                    const Center(child: CircularProgressIndicator(color: _amber))
                  else
                    _AnimatedButton(
                      label: 'Daftar Sekarang',
                      color: _amber,
                      onTap: _register,
                    ),
                  const SizedBox(height: 20),

                  // Footer link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(fontSize: 13, color: _muted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  Shared UI components
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 52, left: 24, right: 24, bottom: 28),
      decoration: const BoxDecoration(
        color: _amber,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _backButton(context),
              Image.asset(
                'asset/images/pengguna maskot.webp',
                height: 64,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Daftar Baru',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lengkapi data untuk membuat akun',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _slate900,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? error,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final bool hasError = error != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? _errorRed : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _slate900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: _muted.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: _amber, size: 20),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: _errorRed),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: _errorRed, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  _AnimatedButton  –  reusable scale‐press CTA button
// ═════════════════════════════════════════════════════════════════════════════

class _AnimatedButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
