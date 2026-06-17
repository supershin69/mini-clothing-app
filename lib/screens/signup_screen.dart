import 'dart:io';
import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  late final ApiService _apiService;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isOtpStage =
      false; // true ဖြစ်သွားရင် OTP ရိုက်တဲ့ Screen UI ပြောင်းမယ်

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(context);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitRegistrationInfo() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('ကျေးဇူးပြု၍ အချက်အလက်များ အပြည့်အစုံဖြည့်ပါ');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('စကားဝှက်များ ကိုက်ညီမှု မရှိပါ');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _showSnackBar('သင့်ရဲ့ Gmail ထဲကို OTP ဂဏန်း ပို့ပေးလိုက်ပါပြီ');

      setState(() {
        _isOtpStage = true;
      });
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception:', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyOtpAndRegister() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar('ကျေးဇူးပြု၍ OTP ဂဏန်း ရိုက်ထည့်ပေးပါ');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool isOtpValid = await _apiService.verifyOtp(email: email, otp: otp);

      if (isOtpValid) {
        _showSnackBar('အကောင့်ဖွင့်ခြင်း အောင်မြင်ပါသည်');
        widget.onRegisterSuccess();
      } else {
        _showSnackBar(
          'OTP ဂဏန်း မှားယွင်းနေပါသည် သို့မဟုတ် သက်တမ်းကုန်ဆုံးသွားပါပြီ',
        );
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception:', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: _isOtpStage ? _buildOtpUI() : _buildRegistrationFormUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationFormUI() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.createAccount,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          l10n.signUpText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: 24),

        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Theme.of(
                  context,
                ).inputDecorationTheme.fillColor,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? Icon(
                        Icons.person,
                        size: 55,
                        color: Theme.of(context).disabledColor.withOpacity(0.7),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.name,
            prefixIcon: Icon(
              Icons.person_outline,
              color: Theme.of(context).disabledColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.email,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Theme.of(context).disabledColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phoneNo,
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).disabledColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).disabledColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.confirmPassword,
            prefixIcon: Icon(
              Icons.lock_clock_outlined,
              color: Theme.of(context).disabledColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _submitRegistrationInfo,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  l10n.register,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: widget.onBackToLogin,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
          child: Text(l10n.alreadyHaveAcc),
        ),
      ],
    );
  }

  Widget _buildOtpUI() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_unread_outlined,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.emailVerification,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.verificationReqText(_emailController.text),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: 32),

        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtpAndRegister,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  l10n.verifyAndCreateAccount,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            setState(() {
              _isOtpStage = false;
            });
          },
          child: Text(
            'Back to Edit Info',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
      ],
    );
  }
}
