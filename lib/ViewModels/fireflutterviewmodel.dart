import 'dart:developer';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutterui/ViewModels/catalogviewmodel.dart';
import 'package:fireflutterui/shared/ff_constants.dart';
import 'package:fireflutterui/shared/ff_textfields.dart';
import 'package:fireflutterui/shared/ff_validators.dart';
import 'package:flutter/material.dart';

import '../AuthService/auth_service.dart';
import '../confirmation_code.dart';

class ResultTextField {
  final String infoToSend;
  final TextFieldCase textFieldCase;
  ResultTextField({required this.infoToSend, required this.textFieldCase});
}

class FireFlutterViewModelNotifier extends FireFlutterTextFieldNotifier {
  String verificationCode = "";
  bool isLoggedIn = false;
  ResultTextField? checkIfValidPhoneNumberOrEmail() {
    switch (textFieldCase) {
      case TextFieldCase.phoneNumber:
        if (prefixCountry.elementAt(1).length == 2) {
          return ResultTextField(
              infoToSend: textController.value.text,
              textFieldCase: TextFieldCase.phoneNumber);
        }
        break;
      case TextFieldCase.empty:
        // TODO: Handle this case.
        break;
      case TextFieldCase.email:
        if (prefixCountry.elementAt(1).length == 2) {
          return ResultTextField(
              infoToSend: textController.value.text,
              textFieldCase: TextFieldCase.email);
        }
        break;
      case TextFieldCase.incorrect:
        // TODO: Handle this case.
        break;
      case TextFieldCase.almostPhoneNumber:
        // TODO: Handle this case.
        break;
      case TextFieldCase.almostEmail:
        // TODO: Handle this case.
        break;
    }
    return null;
  }

  sendMessageOrEmail(BuildContext context) async {
    final ableToSend = checkIfValidPhoneNumberOrEmail();
    if (ableToSend != null) {
      switch (ableToSend.textFieldCase) {
        case TextFieldCase.phoneNumber:
          navigateToConfirmationPage(context);
          break;
        case TextFieldCase.email:
          // TODO: Handle this case.
          break;
        default:
          break;
      }
    }
  }

  verificationCodeSubmitted(String value) async {
    await FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.credential(
            verificationId: verificationCode, smsCode: value))
        .then((value) async {
      if (value.user != null) {
        log("pass to home");
      }
    });
  }

  void sendToEmail() async {
    await FirebaseAuth.instance
        .sendSignInLinkToEmail(
            email: "arnoldmitrica@gmail.com",
            actionCodeSettings: ActionCodeSettings(
              url:
                  "https://fireflutterdemo.page.link/?link=https://example.com/?signIn%3D1&apn=com.example.fireflutter",
              dynamicLinkDomain: "fireflutterdemo.page.link",
              handleCodeInApp: true,
              iOSBundleId: "com.example.fireflutter",
              androidPackageName: "com.example.flutterfiredemo",
              androidInstallApp: true,
            ))
        .then((value) {
      log("email sent");
    });
  }

  void sendCodeToPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+40746490839",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              log("user logged in");
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          log(e.message.toString());
        },
        codeSent: (String verificationID, int? resendToken) {
          verificationCode = verificationID;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          verificationCode = verificationID;
          notifyListeners();
        });
  }

  void navigateToConfirmationPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const ConfirmationCodePage()));
    sendCodeToPhoneNumber();
  }

  Future<UserCredential> signInWithEmailAndLink(String _email, Uri link) async {
    return await FirebaseAuth.instance
        .signInWithEmailLink(emailLink: link.toString(), email: _email);
  }

  Future<String> handleLink(Authentication _auth, Uri link) async {
    try {
      await _auth.signInWithEmailAndLink("arnoldmitrica@gmail.com", link);
    } catch (e) {
      return "An error occured";
    }
    return "You are logged successfully, you can change password now";
  }
}

class FireFlutterTextFieldNotifier extends ChangeNotifier
    with defaultUnknown
    implements FireFlutterTextFieldModel {
  TextFieldCase validateCase(String value) {
    if (value.isEmpty) return TextFieldCase.empty;
    if (FFValidators.emailValidator.isValid(value)) return TextFieldCase.email;
    if (FFValidators.phoneNumberValidator.isValid(value)) {
      return TextFieldCase.phoneNumber;
    }
    if (FFValidators.almostPhoneNumberValidator.isValid(value)) {
      return TextFieldCase.almostPhoneNumber;
    }
    if (FFValidators.stringValidator.isValid(value)) {
      return TextFieldCase.almostEmail;
    }
    return TextFieldCase.incorrect;
  }

  @override
  void newValueInTextField(String value) {
    // TODO: implement newValueInTextField
    final newCaseState = validateCase(value);
    if (newCaseState == TextFieldCase.almostPhoneNumber ||
        textFieldCase == TextFieldCase.phoneNumber && value.length >= 2) {
      final valueToBeSearched = value.substring(0, math.min(value.length, 5));
      if (valueToBeSearched.characters.elementAt(0) == '+' &&
          valueToBeSearched.length >= 2) {
        var copiedValue = valueToBeSearched;
        while (copiedValue.length >= 2) {
          final countryCodeSearched = FFUtils.countryCodes[copiedValue];
          if (countryCodeSearched != null) {
            prefixCountry = [copiedValue, countryCodeSearched];
            notifyListeners();
          }
          copiedValue = copiedValue.substring(0, copiedValue.length - 1);
        }
      }
    }
    if (newCaseState != textFieldCase) {
      textFieldCase = newCaseState;
      notifyListeners();
    }
  }
}
