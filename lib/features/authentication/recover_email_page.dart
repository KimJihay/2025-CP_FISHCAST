import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/features/authentication/reset_pass_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RecoverEmailPage extends StatelessWidget {
  const RecoverEmailPage({super.key});

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
                  "Recover Account",
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
                "Follow the steps to recover your account",
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
                  hintText: "Email",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPassPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  child: Text(
                    "Next",
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
