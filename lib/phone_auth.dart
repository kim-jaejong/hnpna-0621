// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class PhoneAuth extends StatelessWidget {
  const PhoneAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('잘못됨'));
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const SignInScreen();
        });
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController =
      MaskedTextController(mask: '000-0000-0000'); //TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _codeController = TextEditingController();
  String _verificationId = '';
//  bool _codeSent = false;

  // 전화번호 유효성 검사
  String? _validatePhoneNumber(String? value) {
    String pattern = r'^01[016789]-\d{3,4}-\d{4}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value ?? '')) {
      return '유효하지 않은 전화번호입니다. 다시 입력해주세요.';
    }
    return null;
  }

  Future<void> _verifyPhoneNumber() async {
    String inputNumber = _phoneController.text;
    String processedNumber;

    // 입력된 전화번호에서 '-' 제거
    String numberWithoutHyphen = inputNumber.replaceAll('-', '');

    // 전화번호가 11자리인 경우
    if (numberWithoutHyphen.length == 11) {
      processedNumber =
          '010-${numberWithoutHyphen.substring(3, 7)}-${numberWithoutHyphen.substring(7)}';
    } else {
      processedNumber = inputNumber;
    }

    // '+82'을 추가하여 최종 전화번호 생git branch성
    String finalNumber = '+82${processedNumber.substring(1)}';

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: finalNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('제공된 전화번호가 유효하지 않습니다.');
          } else {
            print('전화번호 인증에 실패했습니다: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
//            _codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        });
  }

  Future<void> _signInWithPhoneNumber() async {
    final code = _codeController.text.trim();
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      // 인증 후 사용자 정보를 Firestore에 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'address': _addressController.text,
      });
    } catch (e) {
      print('인증 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: const Text('Verify Phone Number'),
              ),
              TextField(
                controller: _codeController,
                decoration:
                    const InputDecoration(labelText: 'Verification code'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Home'), actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              })
        ]),
        body: const Center(
          child: Text('Welcome!'),
        ));
  }
}
