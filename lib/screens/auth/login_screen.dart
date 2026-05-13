import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/storage_service.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_main.dart';


// LOGIN SCREEN
// Handles existing user login using saved phone number

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Controller for phone number text field
  final _phoneCtrl = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Local storage service
  final _storage = StorageService();

  // Default selected country code
  String _selectedCode = '+91';

  // Loading state
  bool _loading = false;

  // Error message
  String? _errorMsg;

  // Country code dropdown list
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+60', 'flag': '🇲🇾', 'name': 'Malaysia'},
    {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
    {'code': '+92', 'flag': '🇵🇰', 'name': 'Pakistan'},
    {'code': '+880', 'flag': '🇧🇩', 'name': 'Bangladesh'},
    {'code': '+94', 'flag': '🇱🇰', 'name': 'Sri Lanka'},
    {'code': '+977', 'flag': '🇳🇵', 'name': 'Nepal'},
  ];

  @override
  void dispose() {

    // Dispose controller to avoid memory leaks
    _phoneCtrl.dispose();

    super.dispose();
  }

  // -------------------------------------------------------
  // LOGIN FUNCTION
  // Validates phone number and checks saved number
  // -------------------------------------------------------
  void _login() {

    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    // Combine country code + phone number
    final entered =
        '$_selectedCode ${_phoneCtrl.text.trim()}';

    // Get saved phone number
    final saved = _storage.getPhone();

    // Fake delay for smooth UI
    Future.delayed(const Duration(milliseconds: 600), () {

      if (!mounted) return;

      // Check phone number match
      if (entered == saved) {

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      } else {

        // Show error message
        setState(() {
          _loading = false;
          _errorMsg =
              'Phone number does not match. Try again.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Screen background color
      backgroundColor: AppColors.backgroundTop,

      body: SafeArea(
        child: SingleChildScrollView(

          // Page padding
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 20),

              // -------------------------------------------------
              // MAIN LOGIN CARD
              // --------------------------------------------
              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: AppColors.white,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // -----------------------------------------
                      // APP LOGO
                      //---------------------------------------
                      Center(
                        child: Column(
                          children: [

                            // App logo
                            Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                            ),

                            const SizedBox(height: 10),

                            // App name
                            Text(
                              'StockSense',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ----------------------------------------
                      // WELCOME TEXT
                      // ---------------------------------------
                      Center(
                        child: Column(
                          children: [

                            Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Enter your phone number to continue',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ------------------------------------
                      // PHONE LABEL
                      // -----------------------------------
                      Text(
                        'PHONE NUMBER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---------------------------------------
                      // PHONE INPUT FIELD
                      // --------------------------------------
                      TextFormField(

                        controller: _phoneCtrl,

                        keyboardType: TextInputType.number,

                        // Remove error message while typing
                        onChanged: (_) =>
                            setState(() => _errorMsg = null),

                        // Validation
                        validator: (v) {

                          if (v == null ||
                              v.trim().isEmpty) {
                            return 'Phone number required';
                          }

                          if (!RegExp(r'^[0-9]+$')
                              .hasMatch(v)) {
                            return 'Numbers only';
                          }

                          if (v.length != 10) {
                            return 'Must be 10 digits';
                          }

                          return null;
                        },

                        decoration: InputDecoration(

                          hintText: '00000 00000',

                          filled: true,

                          fillColor:
                              AppColors.lightGrey
                                  .withOpacity(0.3),

                          // Default border
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),

                          // Focus border
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),

                            borderSide: BorderSide(
                              color: AppColors.goldDark,
                              width: 1.5,
                            ),
                          ),

                          // Error border
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),

                            borderSide: const BorderSide(
                              color: AppColors.darkRed,
                              width: 1,
                            ),
                          ),

                          // Country code dropdown
                          prefixIcon: Container(

                            margin:
                                const EdgeInsets.only(
                                    right: 8),

                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color:
                                      AppColors.lightGrey,
                                  width: 1,
                                ),
                              ),
                            ),

                            child:
                                DropdownButtonHideUnderline(
                              child:
                                  DropdownButton<String>(

                                value: _selectedCode,

                                isDense: true,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                ),

                                // Dropdown items
                                items: _countryCodes
                                    .map((c) {

                                  return DropdownMenuItem<
                                      String>(
                                    value: c['code'],

                                    child: Text(
                                      '${c['flag']} ${c['code']}',

                                      style:
                                          const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                // Change selected country code
                                onChanged: (val) {

                                  if (val != null) {

                                    setState(() =>
                                        _selectedCode =
                                            val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // -------------------------------------
                      // ERROR MESSAGE
                      //----------------------------------
                      if (_errorMsg != null) ...[

                        const SizedBox(height: 10),

                        Container(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color:
                                AppColors.darkRed.withOpacity(0.08),

                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          child: Row(
                            children: [

                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.darkRed,
                                size: 16,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  _errorMsg!,

                                  style:
                                      const TextStyle(
                                    color: AppColors.darkRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // -------------------------------------
                      // LOGIN BUTTON
                      // -----------------------------------------
                      Container(

                        width: double.infinity,
                        height: 50,

                        decoration: BoxDecoration(

                          borderRadius:
                              BorderRadius.circular(12),

                          // Gradient background
                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldDark,
                              AppColors.goldLight,
                            ],
                          ),
                        ),

                        child: ElevatedButton(

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.transparent,

                            shadowColor:
                                AppColors.transparent,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),

                          // Disable while loading
                          onPressed:
                              _loading ? null : _login,

                          child: _loading

                              // Loading indicator
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,

                                  child:
                                      CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )

                              // Button content
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                  children: const [

                                    Text(
                                      'Login',

                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    SizedBox(width: 6),

                                    Icon(
                                      Icons
                                          .arrow_forward_rounded,

                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------
                      // CREATE NEW ACCOUNT
                      // --------------------------------------
                      Center(
                        child: GestureDetector(

                          onTap: () {

                            // Logout old user
                            StorageService().logout();

                            // Open onboarding screen
                            Navigator.pushReplacement(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    OnboardingMain(),
                              ),
                            );
                          },

                          child: RichText(
                            text: TextSpan(

                              text: 'Not you? ',

                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),

                              children: [

                                TextSpan(
                                  text:
                                      'Create new account',

                                  style: TextStyle(
                                    color:
                                        AppColors.goldDark,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      //-------------------------------------------
                      // FOOTER TEXT
                      //-------------------------------------
                      Center(
                        child: Text(
                          '© 2025 StockSense · Offline Inventory System',

                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
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
}