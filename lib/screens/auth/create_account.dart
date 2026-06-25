import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/profile_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';


// CREATE ACCOUNT SCREEN 


class CreateAccount extends StatelessWidget {
  CreateAccount({super.key});

  // Controllers  
  final _storeController   = TextEditingController();
  final _ownerController   = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();

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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10),

                      // LOGO
                      Center(
                        child: Column(children: [
                          Image.asset('assets/images/logo.png', width: 50),
                          const SizedBox(height: 10),
                          const Text('StockSense',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ]),
                      ),

                      const SizedBox(height: 24),

                      // TITLE 
                      const Center(
                        child: Column(children: [
                          Text('Set Up Your Store',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Enter your shop details to get started',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.grey)),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // FIELDS 
                      _field(context, 'STORE NAME', 'e.g. Daily Fresh Market',
                          _storeController, isNameField: true),

                      _field(context, 'OWNER NAME', 'Full name',
                          _ownerController, isNameField: true),

                      _fieldLabel(context, 'PHONE NUMBER'),
                      const SizedBox(height: 6),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone number is required';
                          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Only numbers are allowed';
                          final expected = ProfileProvider.getPhoneLength(profile.selectedCode);
                          if (v.length != expected) return 'Enter a valid $expected-digit number';
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
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: AppColors.lightGrey, width: 1)),
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

                      const SizedBox(height: 15),

                      _field(context, 'SHOP ADDRESS', 'Street address, City, State',
                          _addressController, maxLines: 3),

                      const SizedBox(height: 10),

                      // CREATE ACCOUNT BUTTON 
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
                          ),
                          onPressed: () => _onCreateAccount(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Create Account',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward_rounded,
                                  color: AppColors.white, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      //  LOGIN LINK 
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: AppColors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // FOOTER 
                      const Center(
                        child: Text('© 2025 StockSense · Offline Inventory System',
                            style: TextStyle(fontSize: 10, color: AppColors.grey)),
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

  Future<void> _onCreateAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await context.read<ProfileProvider>().createAccount(
      storeName: _storeController.text.trim(),
      ownerName: _ownerController.text.trim(),
      phone:     _phoneController.text.trim(),
      address:   _addressController.text.trim(),
    );

    if (!context.mounted) return;

    if (result == 'duplicate') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Account Already Exists'),
          content: const Text('An account with this phone number already exists.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Login', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Widget _fieldLabel(BuildContext context, String label) => Text(label,
      style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface));

  Widget _field(BuildContext context, String label, String hint,
      TextEditingController ctrl, {int maxLines = 1, bool isNameField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'This field is required';
            if (isNameField && !RegExp(r'^[a-zA-Z ]+$').hasMatch(v.trim())) {
              return 'Only letters are allowed';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}