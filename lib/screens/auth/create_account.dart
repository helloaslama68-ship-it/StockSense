import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../home/home_screen.dart';
import '../../services/storage_service.dart';
import 'login_screen.dart';

// -----------------------------------------------------------
// CREATE ACCOUNT SCREEN
// This screen is used to register a new store account.
// User enters:
// Store name
// Owner name
// Phone number
// Shop address
// ---------------------------------------------------------------------
class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  // ── TEXT CONTROLLERS ---------------------
  // Used to read values from input fields
  final storeController = TextEditingController();
  final ownerController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Selected country code
  String _selectedCode = '+91';

  // ── COUNTRY CODE LIST ---------------------------
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

  // ── DISPOSE CONTROLLERS ──────────────────────────
  // Prevents memory leaks
  @override
  void dispose() {
    storeController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),

          child: Column(
            children: [

              SizedBox(height: 10),

              // ----------------------------------------
              // MAIN FORM CARD
              // --------------------------------------
              Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      SizedBox(height: 10),

                      // ------------------------------------------------
                      // APP LOGO + APP NAME
                      // ---------------------------------------------
                      Center(
                        child: Column(
                          children: [

                            Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                            ),

                            SizedBox(height: 10),

                            Text(
                              "StockSense",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // -------------------------------------
                      // SCREEN TITLE
                      // ---------------------------------------
                      Center(
                        child: Column(
                          children: [

                            Text(
                              "Set Up Your Store",
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Enter your shop details to get started",
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      
                      // STORE NAME FIELD
                      
                      _field(
                        "STORE NAME",
                        "e.g. Daily Fresh Market",
                        storeController,
                        isNameField: true,
                      ),

                      // ------------------------------------------
                      // OWNER NAME FIELD
                      // --------------------------------------
                      _field(
                        "OWNER NAME",
                        "Full name",
                        ownerController,
                        isNameField: true,
                      ),

                      // ---------------------------------------------
                      // PHONE NUMBER LABEL
                      // ---------------------------------------
                      _fieldLabel("PHONE NUMBER"),

                      SizedBox(height: 6),

                      // -----------------------------------
                      // PHONE NUMBER INPUT FIELD
                      // Includes country code dropdown
                      // -----------------------------------------
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,

                        // ── VALIDATION ──────────────────
                        validator: (value) {

                          // Empty check
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }

                          // Numbers only check
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Only numbers are allowed';
                          }

                          // Length check
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }

                          return null;
                        },

                        decoration: InputDecoration(

                          hintText: "00000 00000",

                          filled: true,

                          fillColor:
                              AppColors.lightGrey.withOpacity(0.3),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),

                          // --------------------------------------------
                          // COUNTRY CODE DROPDOWN
                          // -------------------------------------
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 8),

                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.lightGrey,
                                  width: 1,
                                ),
                              ),
                            ),

                            child: DropdownButtonHideUnderline(

                              child: DropdownButton<String>(
                                value: _selectedCode,
                                isDense: true,

                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),

                                // Dropdown items
                                items: _countryCodes.map((c) {

                                  return DropdownMenuItem<String>(
                                    value: c['code'],

                                    child: Text(
                                      "${c['flag']} ${c['code']}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),

                                // Change selected country code
                                onChanged: (val) {

                                  if (val != null) {

                                    setState(() {
                                      _selectedCode = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // -------------------------------------------
                      // SHOP ADDRESS FIELD
                      // ----------------------------------------
                      _field(
                        "SHOP ADDRESS",
                        "Street address, City, State",
                        addressController,
                        maxLines: 3,
                      ),

                      SizedBox(height: 10),

                      // -----------------------------------------
                      // CREATE ACCOUNT BUTTON
                      // ---------------------------------------
                      Container(
                        width: double.infinity,
                        height: 50,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldDark,
                              AppColors.goldLight,
                            ],
                          ),
                        ),

                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            shadowColor: AppColors.transparent,
                          ),

                          // ── CREATE ACCOUNT LOGIC ───────
                          onPressed: () async {

                            // Validate form
                            if (_formKey.currentState!.validate()) {

                              final storage = StorageService();

                              // Final phone number
                              final newPhone =
                                  '$_selectedCode ${phoneController.text.trim()}';

                              // ------------------------------------
                              // CHECK DUPLICATE ACCOUNT
                              // ---------------------------------
                              if (
                                  storage.hasAccount() &&
                                  storage.getPhone() == newPhone
                              ) {

                                // Show duplicate account dialog
                                showDialog(
                                  context: context,

                                  builder: (_) => AlertDialog(

                                    title: Text('Account Already Exists'),

                                    content: Text(
                                      'An account with this phone number already exists.',
                                    ),

                                    actions: [

                                      // Cancel button
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),

                                        child: Text('Cancel'),
                                      ),

                                      // Login button
                                      ElevatedButton(

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.goldDark,
                                        ),

                                        onPressed: () {

                                          Navigator.pop(context);

                                          Navigator.pushReplacement(
                                            context,

                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },

                                        child: Text(
                                          'Login',

                                          style: TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                return;
                              }

                              // ----------------------------------
                              // CLEAR OLD ACCOUNT IF EXISTS
                              // ---------------------------------
                              if (storage.hasAccount()) {
                                await storage.clearAllUserData();
                              }

                              // ----------------------------
                              // SAVE USER DATA
                              // -------------------------------
                              storage.saveUserData(

                                storeName:
                                    storeController.text.trim(),

                                ownerName:
                                    ownerController.text.trim(),

                                phone: newPhone,

                                address:
                                    addressController.text.trim(),
                              );

                              // ----------------------------------
                              // NAVIGATE TO HOME SCREEN
                              // ------------------------------
                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => HomeScreen(),
                                ),
                              );
                            }
                          },

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Text(
                                "Create Account",

                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(width: 5),

                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 18),

                      // -------------------------------------------
                      // LOGIN NAVIGATION
                      // -------------------------------------------
                      Center(
                        child: GestureDetector(

                          onTap: () => Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),

                          child: RichText(
                            text: TextSpan(

                              text: 'Already have an account? ',

                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),

                              children: [

                                TextSpan(
                                  text: 'Login',

                                  style: TextStyle(
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // ------------------------------------------
                      // FOOTER
                      //-----------------------------------------------
                      Center(
                        child: Text(
                          "© 2025 StockSense · Offline Inventory System",

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

  //--------------------------------------------------------
  // FIELD LABEL WIDGET
  // Reusable label for text fields
  // -----------------------------------------------------
  Widget _fieldLabel(String label) {

    return Text(
      label,

      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
    );
  }

  // ---------------------------------------------------
  // REUSABLE TEXT FIELD
  // Used for:
  // • Store Name
  // • Owner Name
  // • Address
  // ----------------------------------------
  Widget _field(
    String label,
    String hint,
    TextEditingController ctrl, {

    int maxLines = 1,
    bool isNameField = false,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // Label
        _fieldLabel(label),

        SizedBox(height: 6),

        // Text input
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,

          // ── VALIDATION ---------------------
          validator: (value) {

            // Empty check
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }

            // Name field validation
            if (isNameField) {

              // Only letters and spaces allowed
              if (
                  !RegExp(r'^[a-zA-Z ]+$')
                      .hasMatch(value.trim())
              ) {

                return 'Only letters are allowed';
              }
            }

            return null;
          },

          decoration: InputDecoration(

            hintText: hint,

            filled: true,

            fillColor:
                AppColors.lightGrey.withOpacity(0.3),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: 15),
      ],
    );
  }
}