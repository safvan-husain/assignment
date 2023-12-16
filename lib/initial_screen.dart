import 'package:assignment/auth_provider.dart';
import 'package:assignment/home_screen.dart';
import 'package:assignment/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _termsChecked = false;
  String _lastError = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        //show any error.
        if (_lastError != authProvider.error) {
          _lastError = authProvider.error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackbar(authProvider.error, context);
          });
        }
        if (authProvider.user != null) {
          // If the user is not null, navigate to a Home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
        }
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: authProvider.isLoading,
              child: Container(
                color: authProvider.isLoading
                    ? Colors.black.withOpacity(0.5)
                    : Colors.transparent,
                child: Stack(
                  children: [
                    if (authProvider.isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 45,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisAlignment:
                                authProvider.verificationId == null
                                    ? MainAxisAlignment.spaceBetween
                                    : MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Lottie.asset(
                                  'assets/robo.json',
                                  height: 200,
                                ),
                              ),
                              //if user and verification id null, show input fieald and google button.
                              if (authProvider.user == null &&
                                  authProvider.verificationId == null)
                                ..._buildFormAndButtons(context),
                              //if verification id not null, which means sms sended, show otp fieald.
                              if (authProvider.verificationId != null)
                                ..._buildVerificationFieald(context),
                              const SizedBox(
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildVerificationFieald(BuildContext context) {
    return [
      const SizedBox(height: 50),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Enter verification code",
          style: GoogleFonts.poppins(
            fontSize: 18,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: PinCodeTextField(
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
          ),
          onCompleted: (code) {
            Provider.of<AuthProvider>(context, listen: false).verifyPhone(code);
          },
        ),
      )
    ];
  }

  List<Widget> _buildFormAndButtons(BuildContext context) {
    return [
      Text(
        "Log In",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      Column(
        children: [
          buildNameInputFieald(controller: _nameController),
          buildPhoneInputFieald(controller: _phoneController),
          Theme(
            data: ThemeData(
              unselectedWidgetColor: Colors
                  .deepOrangeAccent, // This is for the unchecked border color
            ),
            child: CheckboxListTile(
              checkColor: Colors.white,
              activeColor: Colors.deepOrangeAccent,
              hoverColor: Colors.deepOrangeAccent,
              title: Text(
                'I agree to the terms and conditions',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 10,
                ),
              ),
              value: _termsChecked,
              onChanged: (bool? value) {
                setState(() {
                  _termsChecked = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: InkWell(
          onTap: () {
            if (_termsChecked) {
              if (_validateInput()) {
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).phoneSignIn(
                  phoneNumber: '+91${_phoneController.text.trim()}',
                  name: _nameController.text,
                );
              }
            } else {
              showSnackbar("agree to the terms to continue", context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              "Log in",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: Colors.black54,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("OR"),
            ),
            Expanded(
              child: Divider(
                color: Colors.black54,
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      InkWell(
        onTap: () {
          if (_termsChecked) {
            Provider.of<AuthProvider>(context, listen: false)
                .signInWithGoogle();
          } else {
            showSnackbar("accept terms and conditions", context);
          }
        },
        child: Center(
          child: CircleAvatar(
            radius: 35,
            child: Image.asset('assets/google.png'),
          ),
        ),
      )
    ];
  }

  bool _validateInput() {
    if (_nameController.text.length < 3) {
      showSnackbar("Name must be at least 3 characters long", context);
      return false;
    }
    if (_phoneController.text.length != 10) {
      showSnackbar("Phone number must be exactly 10 characters long", context);
      return false;
    }
    return true;
  }

  Widget buildPhoneInputFieald({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Mobile number",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: const Color.fromARGB(158, 254, 252, 252),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepOrangeAccent, width: 0.7)),
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: TextField(
            keyboardType: TextInputType.phone,
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "phone",
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  top: 15,
                  bottom: 8.0,
                  right: 10,
                ),
                child: Text("🇮🇳  IN  +91"),
              ),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget buildNameInputFieald({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Full Name",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: const Color.fromARGB(158, 254, 252, 252),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepOrangeAccent, width: 0.7)),
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: TextField(
            keyboardType: TextInputType.name,
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "enter your name",
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }
}
