import 'package:task_manager/controller/auth_controller.dart';
import 'package:task_manager/data/model/api_response.dart';
import 'package:task_manager/data/model/user_model.dart';
import 'package:task_manager/data/service/api_caller.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/screens/main_nav_screen.dart';
import 'package:task_manager/utils/app_colors.dart';
import 'package:task_manager/widget/screen_bg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:task_manager/crud/utils/urls.dart';
import '../utils/urls.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {


  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void>updateProfile() async {

    Map<String,dynamic> requestBody = {
        "email":emailController.text,
        "firstName":firstNameController.text,
        "lastName":lastNameController.text,
        "mobile":mobileController.text,
      };

    if(passwordController.text.isNotEmpty){
      requestBody['password'] = passwordController.text;
    }





    final ApiResponse response = await ApiCaller.PostRequest(url: TMUrls.updateProfileURL,
        body: requestBody

    );


    if(response.isSuccess){
      UserModel user = UserModel(
        sId: AuthController.userData?.sId,
        email: emailController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        mobile: mobileController.text,
      );

      AuthController.updateUserData(user);
      AuthController.getUserData();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainNavScreen()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up success....!')));


    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.responseData['data'])));

    }
  }


  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    AuthController.userData = null;
    AuthController.accessToken = null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    UserModel user = AuthController.userData!;

    emailController.text = user.email!;
    firstNameController.text = user.firstName!;
    lastNameController.text = user.lastName!;
    mobileController.text = user.mobile!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.PColor,
        title: Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ScreenBG(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24,),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/14306684?v=4'),
                  ),
                ),
                SizedBox(height: 32,),
                Text('Update Profile', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 24,),
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
                    hintText: 'New Password (optional)',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: Icon(Icons.visibility_off_outlined)
                  ),
                ),
                SizedBox(height: 32,),
                FilledButton(
                  onPressed: (){
                    if(formkey.currentState!.validate()){
                      updateProfile();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update, size: 28),
                        SizedBox(width: 8),
                        Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ),
                SizedBox(height: 24,),
                OutlinedButton(
                  onPressed: logout,
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size.fromWidth(double.maxFinite),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red, width: 2)
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red
                    ),
                  )
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
