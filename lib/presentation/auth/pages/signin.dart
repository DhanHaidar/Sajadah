import 'package:flutter/material.dart';

import 'package:sajadah/common/widgets/appbar/app_bar.dart';
import 'package:sajadah/common/widgets/button/basic_app_button.dart';
import 'package:sajadah/core/configs/assets/app_images.dart';
import 'package:sajadah/data/models/auth/signin_user_req.dart';
import 'package:sajadah/domain/usecases/auth/signin.dart';
import 'package:sajadah/presentation/auth/pages/signup.dart';
import 'package:sajadah/presentation/dashboard/pages/dashboard.dart';
import 'package:sajadah/service_locator.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(0, 0, 0, 0.7),
              BlendMode.darken,
            ),
            image: AssetImage(AppImages.signupsigninBG),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BasicAppbar(
                //title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
              ),
              SizedBox(height: 20),
              _registerText(),
              SizedBox(height: 20),
              _emailField(context),
              SizedBox(height: 30),
              _passwordField(context),
              SizedBox(height: 40),
              BasicAppButton(
                onPressed: () async {
                  var result = await sl<SigninUseCase>().call(
                    params: SigninUserReq(
                      email: _email.text.toString(),
                      password: _password.text.toString(),
                    ),
                  );
                  result.fold(
                    (l) {
                      var snackbar = SnackBar(content: Text(l));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    },
                    (r) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Dashboard(),
                        ),
                        (route) => false,
                      );
                    },
                  );
                },
                title: "Sign In Now",
              ),
              Spacer(),
              _signinText(context),
            ],
          ),
        ),
      ),
      //bottomNavigationBar: _signinText(context),
    );
  }

  Widget _registerText() {
    return const Text(
      'Sign In',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: InputDecoration(
        hintText: 'Enter Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      decoration: InputDecoration(
        hintText: 'Enter Password',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Not A Member?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignupPage(),
                ),
              );
            },
            child: Text(
              "Register Now",
              style: TextStyle(color: const Color.fromARGB(255, 58, 184, 69)),
            ),
          ),
        ],
      ),
    );
  }
}
