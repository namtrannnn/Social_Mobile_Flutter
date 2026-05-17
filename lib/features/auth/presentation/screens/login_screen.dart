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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRememberData();
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
                      Color(0xFFE7DFD9),
                      Color(0xFFD9D0CB),
                      Color(0xFFEDE6E0),
                    ],
                  ),
                ),
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
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(child: _buildFormCard(authController)),
                              const SizedBox(width: 28),
                              Expanded(child: _buildRightPanel()),
                            ],
                          )
                        : _buildFormCard(authController),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(AuthController authController) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE7),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 28),

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

              const SizedBox(height: 18),

              _buildLabel('Mật khẩu'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: passwordController,
                hint: 'Nhập mật khẩu...',
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

              const SizedBox(height: 14),

              Row(
                children: [
                  Transform.scale(
                    scale: 0.95,
                    child: Checkbox(
                      value: rememberMe,
                      activeColor: const Color(0xFFF25019),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
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
                    style: TextStyle(fontSize: 14, color: Color(0xFF444444)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: màn quên mật khẩu
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

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
                    ).withOpacity(0.7),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Hoặc đăng nhập với',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),

              const SizedBox(height: 14),

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
                    'Nếu bạn chưa có tài khoản? ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.register);
                    },
                    child: const Text(
                      'Đăng ký miễn phí',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
      height: 560,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE2D7), Color(0xFFF5CBB7), Color(0xFFEFB08F)],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.32),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 42,
                color: Color(0xFF8A3D1D),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5B2A17),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đăng nhập để tiếp tục trải nghiệm ứng dụng của bạn với giao diện hiện đại, đồng bộ và thân thiện hơn trên mobile.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF6B3A26),
              ),
            ),
            const SizedBox(height: 28),
            _buildFeatureItem(Icons.flash_on_rounded, 'Tốc độ mượt và dễ dùng'),
            const SizedBox(height: 14),
            _buildFeatureItem(Icons.security_rounded, 'Đăng nhập an toàn'),
            const SizedBox(height: 14),
            _buildFeatureItem(Icons.phone_iphone_rounded, 'Tối ưu cho mobile'),
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
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF7A3A21)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B2A17),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(AuthController authController) {
    final user = authController.currentUser!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: user.avatar.isNotEmpty
                ? NetworkImage(user.avatar)
                : null,
            child: user.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  'Role: ${user.role}',
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
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
      style: const TextStyle(fontSize: 15.5),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
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
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF444444)),
        ),
      ),
    );
  }
}
