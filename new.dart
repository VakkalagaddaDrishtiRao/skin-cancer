import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController captchaController = TextEditingController();

  String randomString = "";
  bool isVerified = false;

  void buildCaptcha() {
    const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    const length = 6;
    final random = Random();
    randomString = String.fromCharCodes(
      List.generate(length, (index) => letters.codeUnitAt(random.nextInt(letters.length))),
    );
    setState(() {});
    print("The random string is $randomString");
  }

  @override
  void initState() {
    super.initState();
    buildCaptcha();
  }

  void handleLogin() {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email')),
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter password')),
      );
      return;
    }
    if (captchaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter captcha value')),
      );
      return;
    }
    if (captchaController.text == randomString) {
      // Handle the login logic here
      print(emailController.text);
      print(passwordController.text);
      setState(() {
        isVerified = true;
      });
      // Perform the login action
      // For example, navigate to the next screen or show a success message
    } else {
      setState(() {
        isVerified = false;
      });
      // Show an error message if the CAPTCHA is not verified
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect CAPTCHA value')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 237, 220, 1),
        appBar: AppBar(
          title: const Text(
            'Ex Servicemen Management Portal',
            style: TextStyle(color: Color.fromRGBO(245, 237, 220, 1)),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color.fromRGBO(14, 84, 45, 1),
                  Color.fromRGBO(17, 93, 51, 1),
                  Color.fromRGBO(31, 110, 66, 1),
                  Color.fromRGBO(32, 118, 30, 1),
                  Color.fromRGBO(32, 118, 30, 1),
                  Color.fromRGBO(31, 110, 66, 1),
                  Color.fromRGBO(17, 93, 51, 1),
                  Color.fromRGBO(14, 84, 45, 1),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.green),
                            hintText: 'Enter Email',
                            prefixIcon: Icon(Icons.email),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter email' : null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.green),
                            hintText: 'Enter Password',
                            prefixIcon: Icon(Icons.password),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter Password' : null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              randomString,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: buildCaptcha,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: TextFormField(
                          controller: captchaController,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            hintText: 'Enter Captcha Value',
                            labelText: 'Enter Captcha Value',
                            labelStyle: TextStyle(color: Colors.green),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isVerified = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          onPressed: handleLogin,
                          color: const Color.fromRGBO(31, 110, 66, 1),
                          textColor: const Color.fromRGBO(245, 237, 220, 1),
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isVerified)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified),
                            Text('Verified'),
                          ],
                        )
                      else
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel),
                            Text('Not Verified'),
                          ],
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
}
