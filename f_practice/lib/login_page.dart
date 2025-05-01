import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage2());
  }
}
class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login'),
              SizedBox(height: 20,),
              Padding(padding: EdgeInsets.all(20)),
             Form(child: Column(
               children: [
                 Image.network(''),
                 Image.asset(''),
                 Padding(padding: EdgeInsets.all(20)),
                 TextFormField(
                   decoration: InputDecoration(
                     labelText: 'Email',
                     hintText: 'Enter your email',
                     labelStyle: TextStyle(
                       color: Colors.black,
                       fontWeight: FontWeight.bold,
                     ),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),

                     ),
                   ),
                   validator: (value){
                     if(value!.isEmpty){
                       return 'Please enter your email';
                     }
                     return null;

                   }
                 ),
                 SizedBox(height: 10,),
                 TextFormField(
                     decoration: InputDecoration(
                       labelText: 'Password',
                       hintText: 'Enter your password',
                       labelStyle: TextStyle(
                         color: Colors.black,
                         fontWeight: FontWeight.bold,
                       ),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10),

                       ),
                     ),
                     validator: (value){
                       if(value!.isEmpty){
                         return 'Please enter your password';
                       } else if(value.length <= 6){
                         return 'Password must be at least 6 characters';
                       }
                       return null;

                     }
                 ),
                 SizedBox(height: 10,),
                 SizedBox(
                   width: double.infinity,
                     child: ElevatedButton(onPressed: (){}, child: Text('Submit')),
                 )
               ],
             ))
            ],
          ),
        ),
      ),
    );
  }
}

