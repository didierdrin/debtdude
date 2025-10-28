import 'package:debtdude/screens/home_screen.dart';
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title Section
                    Column(
                      children: [
                        Image.asset("assets/images/logo.png", height: 150, width: 150), 
                        Text(
                          'DebtDude',
                          style: TextStyle(fontSize: 32, color: const Color(0xFF5573F6)),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    
                    // Form Section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSignUp) ...[
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                            SizedBox(height: 16),
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
                            SizedBox(height: 16),
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
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                            SizedBox(height: 16),
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
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: Size(double.infinity, 50)),
                                onPressed: state is AuthLoading ? null : () {
                                  if (_isSignUp) {
                                    context.read<AuthCubit>().signUp(
                                      _usernameController.text,
                                      _passwordController.text,
                                      _confirmPasswordController.text,
                                    );
                                  } else {
                                    context.read<AuthCubit>().signIn(
                                      _usernameController.text,
                                      _passwordController.text,
                                    );
                                  }
                                },
                                child: state is AuthLoading 
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(_isSignUp ? 'Sign Up' : 'Sign In', style: TextStyle(color: Colors.white)),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _usernameController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            child: Text(_isSignUp ? 'Have an account? Sign In' : 'Don\'t have an account? Sign Up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:debtdude/screens/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:debtdude/cubits/auth_cubit.dart';

// class AuthScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AuthCubit(),
//       child: AuthScreenContent(),
//     );
//   }
// }

// class AuthScreenContent extends StatefulWidget {
//   @override
//   _AuthScreenContentState createState() => _AuthScreenContentState();
// }

// class _AuthScreenContentState extends State<AuthScreenContent> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isSignUp = true;
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state is AuthSuccess) {
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
//         } else if (state is AuthError) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset("assets/images/logo.png", height: 200, width: 200,), 
//                 Text(
//                   'DebtDude',
//                   style: TextStyle(fontSize: 32, color: const Color(0xFF5573F6)),
//                 ),
//                 SizedBox(height: 20),
//                 if (_isSignUp) ...[
//                   TextField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(labelText: 'Email'),
//                   ),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   TextField(
//                     controller: _confirmPasswordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Confirm Password',
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   TextField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(labelText: 'Email'),
//                   ),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//                 SizedBox(height: 20),
//                 BlocBuilder<AuthCubit, AuthState>(
//                   builder: (context, state) {
//                     return ElevatedButton(
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: Size(double.infinity, 50)),
//                       onPressed: state is AuthLoading ? null : () {
//                         if (_isSignUp) {
//                           context.read<AuthCubit>().signUp(
//                             _usernameController.text,
//                             _passwordController.text,
//                             _confirmPasswordController.text,
//                           );
//                         } else {
//                           context.read<AuthCubit>().signIn(
//                             _usernameController.text,
//                             _passwordController.text,
//                           );
//                         }
//                       },
//                       child: state is AuthLoading 
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(_isSignUp ? 'Sign Up' : 'Sign In', style: TextStyle(color: Colors.white)),
//                     );
//                   },
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _isSignUp = !_isSignUp;
//                       _usernameController.clear();
//                       _passwordController.clear();
//                       _confirmPasswordController.clear();
//                     });
//                   },
//                   child: Text(_isSignUp ? 'Have an account? Sign In' : 'Don\'t have an account? Sign Up'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }