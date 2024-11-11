import 'dart:typed_data';

import 'package:aura_techwizard/components/colors.dart';
import 'package:aura_techwizard/components/text_field_input.dart';
import 'package:aura_techwizard/components/utils.dart';
import 'package:aura_techwizard/resources/auth_methods.dart';
import 'package:aura_techwizard/views/HomeScreen/HomeScreen.dart';
import 'package:aura_techwizard/views/MainLayoutScreen.dart';
import 'package:aura_techwizard/views/auth_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  // RxBool isLoading = false.obs;
  // AuthController authController = Get.put(AuthController());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _userNameController.text,
      fullname: _fullNameController.text,
      contactnumber: _phoneNumberController.text,
      file: _image!,
    );
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainLayoutScreen()),
      );
    }
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  void navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50,),
              Text(
              'Sign In',
              style: TextStyle(color: Colors.black, fontSize: 35),
            ),// Added spacing at the top
              const SizedBox(
                height: 20,
              ),

              //circular widget
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              'https://i.pinimg.com/originals/65/25/a0/6525a08f1df98a2e3a545fe2ace4be47.jpg'),
                        ),
                  Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(Icons.add_a_photo),
                        color: Colors.blue,
                      ))
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.darkGreen)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15,),
                        const Text(
                      "Username",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                        TextFieldInput(
                  hintText: 'Enter your Username',
                  textEditingController: _userNameController,
                  textInputType: TextInputType.text),
              const SizedBox(
                height: 24,
              ),
              const Text(
                      "Full Name",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              TextFieldInput(
                  hintText: 'Enter your Full Name',
                  textEditingController: _fullNameController,
                  textInputType: TextInputType.text),
              const SizedBox(
                height: 24,
              ),
              const Text(
                      "Contact Number",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                        TextFieldInput(
                  hintText: 'Enter your Contact Number',
                  textEditingController: _phoneNumberController,
                  textInputType: TextInputType.text),
              const SizedBox(
                height: 24,
              ),
              //email input
              const Text(
                      "Email",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              TextFieldInput(
                  hintText: 'Enter your email',
                  textEditingController: _emailController,
                  textInputType: TextInputType.emailAddress),
              const SizedBox(
                height: 24,
              ),
              //password input
              const Text(
                      "Password",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              TextFieldInput(
                hintText: 'Enter your password',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
              ),
                      ],
                    ),
                  ),
              ),
              
              const SizedBox(
                height: 24,
              ),
              //button
              InkWell(
                onTap: () {
                  signUpUser();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                            AppColors.darkGreen,
                            AppColors.lightGreen,
                            AppColors.mediumGreen,
                            AppColors.mediumGreen,
                            AppColors.mediumGreen,
                            AppColors.mediumGreen,
                            AppColors.paleGreen,
                            AppColors.paleGreen
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight
                          )
                          ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.black,
                        ))
                      : Text('Sign Up'),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
            //   Obx(
            //   () => isLoading.value
            //       ? CircularProgressIndicator()
            //       : PrimaryButtonWithIcon(
            //           buttonText: "Sign in with Google",
            //           onTap: () {
            //             isLoading.value = true;
            //             authController.login();
            //           },
            //           //iconPath: IconsPath.google,
            //         ),
            // ),
              const SizedBox(
                height: 12,
              ),
              //signup page link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Already have a account?"),
                  ),
                  GestureDetector(
                    onTap: () {
                      navigateToLogin();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Added spacing at the bottom
            ],
          ),
        ),
      ),
    ));
  }
}