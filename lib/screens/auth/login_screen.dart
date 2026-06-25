import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/profile_provider.dart';
import '../home/home_screen.dart';
import 'create_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Column(children: [
                          Image.asset('assets/images/logo.png', width: 50),
                          const SizedBox(height: 10),
                          const Text('StockSense',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ]),
                      ),

                      const SizedBox(height: 28),

                      const Center(
                        child: Column(children: [
                          Text('Welcome Back! 👋',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Enter your phone number to continue',
                              style: TextStyle(fontSize: 13, color: AppColors.grey)),
                        ]),
                      ),

                      const SizedBox(height: 28),

                      Text('PHONE NUMBER',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface)),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => context.read<ProfileProvider>().clearError(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Phone number required';
                          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Numbers only';
                          final expected = ProfileProvider.getPhoneLength(profile.selectedCode);
                          if (v.length != expected) return 'Must be $expected digits';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '00000 00000',
                          filled: true,
                          fillColor: AppColors.lightGrey.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.goldDark, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.darkRed, width: 1),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: AppColors.lightGrey, width: 1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: profile.selectedCode,
                                isDense: true,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                items: ProfileProvider.countryCodes.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c['code'],
                                    child: Text('${c['flag']} ${c['code']}',
                                        style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    context.read<ProfileProvider>().selectCountryCode(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (profile.errorMsg != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.darkRed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(profile.errorMsg!,
                                  style: const TextStyle(color: AppColors.darkRed, fontSize: 12)),
                            ),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.goldDark, AppColors.goldLight],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            shadowColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: profile.loading ? null : _onLogin,
                          child: profile.loading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: AppColors.white, strokeWidth: 2))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Login',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded,
                                        color: AppColors.white, size: 18),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ProfileProvider>().logout();
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => CreateAccount()));
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: 'Not you? ',
                              style: TextStyle(color: AppColors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Create new account',
                                  style: TextStyle(
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          '© 2025 StockSense · Offline Inventory System',
                          style: TextStyle(fontSize: 10, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context
        .read<ProfileProvider>()
        .login(_phoneCtrl.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }
}