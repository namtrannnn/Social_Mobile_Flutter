import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/controllers/auth_controller.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/storage/local_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberData();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberData() async {
    final data = await LocalStorageService.getRememberLogin();

    if (!mounted) return;

    setState(() {
      rememberMe = data['rememberMe'] ?? false;
      emailController.text = data['email'] ?? '';
      passwordController.text = data['password'] ?? '';
    });
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();

    final success = await authController.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      await LocalStorageService.saveRememberLogin(
        rememberMe: rememberMe,
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công')));

      Navigator.pushReplacementNamed(context, RouteNames.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Đăng nhập thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFD9D0CB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEDE6E0),
                      Color(0xFFD9D0CB),
                      Color(0xFFFFE7DC),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -80,
              right: -70,
              child: _blurCircle(
                size: 220,
                color: const Color(0xFFFFB199).withOpacity(0.35),
              ),
            ),

            Positioned(
              bottom: -90,
              left: -70,
              child: _blurCircle(
                size: 240,
                color: const Color(0xFFF25019).withOpacity(0.18),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(child: _buildLoginCard(authController)),
                              const SizedBox(width: 28),
                              Expanded(child: _buildRightPanel()),
                            ],
                          )
                        : _buildLoginCard(authController),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(AuthController authController) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 470),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1EC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF25019).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  size: 34,
                  color: Color(0xFFF25019),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'ĐĂNG NHẬP',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Chào mừng bạn quay trở lại ứng dụng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 26),

              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: emailController,
                hint: 'User@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }

                  final email = value.trim();
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                  if (!emailRegex.hasMatch(email)) {
                    return 'Email không hợp lệ';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildLabel('Mật khẩu'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: passwordController,
                hint: 'Nhập mật khẩu',
                obscureText: obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }

                  if (value.trim().length < 6) {
                    return 'Mật khẩu tối thiểu 6 ký tự';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Transform.scale(
                    scale: 0.95,
                    child: Checkbox(
                      value: rememberMe,
                      activeColor: const Color(0xFFF25019),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),

                  const Text(
                    'Nhớ tài khoản',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      // TODO: chuyển qua màn quên mật khẩu nếu bạn đã làm
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF25019),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: authController.isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF25019),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFFF25019,
                    ).withOpacity(0.65),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: authController.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.black.withOpacity(0.12)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Hoặc đăng nhập với',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.black.withOpacity(0.12)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Google',
                  ),
                  SizedBox(width: 12),
                  _SocialButton(
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                  ),
                  SizedBox(width: 12),
                  _SocialButton(icon: Icons.code_rounded, label: 'Github'),
                ],
              ),

              const SizedBox(height: 22),

              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'Bạn chưa có tài khoản? ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.register);
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF25019),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      height: 620,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE2D7), Color(0xFFF7C7B3), Color(0xFFEFA17C)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),

            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.waving_hand_rounded,
                size: 44,
                color: Color(0xFF8A3D1D),
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5B2A17),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Đăng nhập để tiếp tục kết nối bạn bè, chia sẻ khoảnh khắc và cập nhật những hoạt động mới nhất trong ứng dụng.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF6B3A26),
              ),
            ),

            const SizedBox(height: 30),

            _buildFeatureItem(
              Icons.flash_on_rounded,
              'Trải nghiệm nhanh và mượt',
            ),
            const SizedBox(height: 14),
            _buildFeatureItem(Icons.security_rounded, 'Tài khoản được bảo vệ'),
            const SizedBox(height: 14),
            _buildFeatureItem(
              Icons.phone_iphone_rounded,
              'Tối ưu cho thiết bị di động',
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.36),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF7A3A21), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B2A17),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3C3C3C),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF25019), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _blurCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 30, color: const Color(0xFF444444)),
        ),
      ),
    );
  }
}
