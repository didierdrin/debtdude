import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debtdude/cubits/auth_cubit.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: AuthScreenContent(),
    );
  }
}

class AuthScreenContent extends StatefulWidget {
  @override
  _AuthScreenContentState createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<AuthScreenContent> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 200, width: 200,), 
              Text(
                'DebtDude',
                style: TextStyle(fontSize: 32, color: const Color(0xFF5573F6)),
              ),
              SizedBox(height: 20),
              if (_isSignUp) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username/Email'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username/Email'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(                
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: Size(double.infinity, 50),),
                onPressed: () {
                  if (_isSignUp) {
                    // Sign up logic with BLoC
                    context.read<AuthCubit>().signUp(
                          _usernameController.text,
                          _passwordController.text,
                          _confirmPasswordController.text,
                        );
                  } else {
                    // Sign in logic with BLoC
                    context.read<AuthCubit>().signIn(
                          _usernameController.text,
                          _passwordController.text,
                        );
                  }
                },
                child: Text(_isSignUp ? 'Sign Up' : 'Sign In', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _usernameController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  });
                },
                child: Text(_isSignUp ? 'Have no account? Sign In' : 'Have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}