import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/features/authentication/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SvgPicture.asset('assets/logo.svg', height: 80.65, width: 81.05),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "New Password",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                    color: kPrimaryColor,
                  ),
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Create your new password to recover account",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: obscurePassword,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: obscureConfirmPassword,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  child: Text(
                    "Recover Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                      color: Colors.white,
                    ),
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
