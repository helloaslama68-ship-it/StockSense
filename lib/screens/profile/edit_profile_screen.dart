import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_snack_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _storeNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _ownerNameCtrl = TextEditingController(text: profile.ownerName ?? '');
    _storeNameCtrl = TextEditingController(text: profile.storeName ?? '');
    _phoneCtrl     = TextEditingController(text: profile.phone ?? '');
    _addressCtrl   = TextEditingController(text: profile.address ?? '');
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _storeNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {                                    
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileProvider>().saveUserData( 
      ownerName: _ownerNameCtrl.text.trim(),
      storeName: _storeNameCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      address:   _addressCtrl.text.trim(),
    );

    if (mounted) {
      AppSnackBar.success(context, 'Profile updated!');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileProvider>().saving; 

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.goldDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : _save,       
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // SECTION: Personal
              _sectionHeader('PERSONAL DETAILS'),
              SizedBox(height: 12),

              _buildCard(children: [
                _field(
                  controller: _ownerNameCtrl,
                  label: 'Owner Name',
                  icon: Icons.person_rounded,
                  hint: 'e.g. Ravi Kumar',
                  iconColor: AppColors.goldDark,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name required' : null,
                ),
                _divider(),
                _field(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_rounded,
                  hint: 'e.g. +91 98765 43210',
                  iconColor: AppColors.darkGreen,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Phone required' : null,
                ),
              ]),

              SizedBox(height: 16),

              // SECTION: Store 
              _sectionHeader('STORE DETAILS'),
              SizedBox(height: 12),

              _buildCard(children: [
                _field(
                  controller: _storeNameCtrl,
                  label: 'Store Name',
                  icon: Icons.storefront_rounded,
                  hint: 'e.g. Ravi General Store',
                  iconColor: AppColors.goldDark,
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Store name required'
                          : null,
                ),
                _divider(),
                _field(
                  controller: _addressCtrl,
                  label: 'Shop Address',
                  icon: Icons.location_on_rounded,
                  hint: 'e.g. 12 Market Street, Chennai',
                  iconColor: AppColors.darkRed,
                  maxLines: 2,
                ),
              ]),

              SizedBox(height: 32),

              // SAVE BUTTON
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldDark.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: saving                        
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.save_rounded,
                          color: Colors.white, size: 18),
                  label: Text(
                    saving ? 'Saving...' : 'Save Changes',   
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: saving ? null : _save,  
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.goldDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: AppColors.grey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.lightGrey,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.goldDark, width: 1.5),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.darkRed, width: 1),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.darkRed, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 70,
        endIndent: 16,
        color: AppColors.lightGrey.withOpacity(0.5),
      );
}