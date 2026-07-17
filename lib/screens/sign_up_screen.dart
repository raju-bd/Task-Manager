import 'package:task_manager/data/model/api_response.dart';
import 'package:task_manager/data/service/api_caller.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/utils/app_colors.dart';
import 'package:task_manager/widget/screen_bg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../crud/utils/urls.dart';
import '../utils/urls.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  void onTapSignIn(){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
  }
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void>signUp() async {




    final ApiResponse response = await ApiCaller.PostRequest(url: TMUrls.SignUpURL,
    body: {
      "email":emailController.text,
      "firstName":firstNameController.text,
      "lastName":lastNameController.text,
      "mobile":mobileController.text,
      "password":passwordController.text,
    }

    );


    if(response.isSuccess){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up success....!')));


    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.responseData['data'])));

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBG(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60,),
                Text('Join With Us', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 30,),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined)
                  ),
                  validator: (value){
                    if(value ==null || value.isEmpty){
                      return 'Please enter email';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'First name',
                    prefixIcon: Icon(Icons.person_outline)
                  ),
                  validator: (value){
                    if(value ==null || value.isEmpty){
                      return 'Please enter first name';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Last name',
                    prefixIcon: Icon(Icons.person_outline)
                  ),
                  validator: (value){
                    if(value ==null || value.isEmpty){
                      return 'Please enter last name';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Mobile',
                    prefixIcon: Icon(Icons.phone_outlined)
                  ),
                  validator: (value){
                    if(value ==null || value.isEmpty){
                      return 'Please enter mobile';
                    }else if(value.length != 11){
                      return 'Please enter correct mobile number';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: Icon(Icons.visibility_off_outlined)
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter password';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 24,),
                FilledButton(
                  onPressed: (){
                    if(formkey.currentState!.validate()){
                      signUp();
                    }
                  }, 
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_circle_right_outlined, size: 28),
                      ],
                    ),
                  )
                ),
                SizedBox(height: 48,),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: AppColors.PColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                          recognizer: TapGestureRecognizer()..onTap = onTapSignIn
                        )
                      ]
                    )
                  ),
                ),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
