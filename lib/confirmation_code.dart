import 'dart:async';

import 'package:fireflutter/Providers/fire_flutter_provider.dart';
import 'package:fireflutterui/fireflutterui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmationCodePage extends ConsumerStatefulWidget {
  const ConfirmationCodePage({Key? key}) : super(key: key);

  @override
  _ConsumerConfirmationCodePageState createState() =>
      _ConsumerConfirmationCodePageState();
}

class _ConsumerConfirmationCodePageState
    extends ConsumerState<ConfirmationCodePage> {
  @override
  Widget build(BuildContext context) {
    final _isLoggedIn =
        ref.watch(fireFlutterProvider.select((value) => value.isLoggedIn));
    return Scaffold(
      body: _isLoggedIn == false
          ? Padding(
              padding: const EdgeInsets.only(top: 75, bottom: 114, left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "We've sent you a code",
                        style:
                            FireFlutterTextStyles.poppinsSize28Weight700Black,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Enter the confirmation code below",
                        style: FireFlutterTextStyles
                            .poppinsSize16Weight400BlackOpacity60,
                      ),
                    ],
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pinput(
                          onCompleted: (value) {
                            ref
                                .read(fireFlutterProvider)
                                .verificationCodeSubmitted(value);
                          },
                          obscureText: true,
                          defaultPinTheme: FireFlutterTextFields.ffPinTheme,
                          length: 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 18),
                          child: ResendCode(),
                        ),
                      ]),
                ],
              ),
            )
          : const LoggedIn(),
    );
  }
}

class ResendCode extends ConsumerStatefulWidget {
  const ResendCode({Key? key}) : super(key: key);

  @override
  _ConsumerResendCodeState createState() => _ConsumerResendCodeState();
}

class _ConsumerResendCodeState extends ConsumerState<ResendCode> {
  late TapGestureRecognizer _tapGestureRecognizer;
  Duration duration = const Duration(seconds: 60);
  Timer? timer;

  bool countDown = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = sendAgain;
    startTimer();
  }

  void sendAgain() {
    ref.read(fireFlutterProvider.notifier).sendCodeToPhoneNumber();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
        TextSpan(text: "Didn't receive a code? ", children: [
          TextSpan(
            recognizer: _tapGestureRecognizer,
            text: duration == const Duration(seconds: 0)
                ? "Send code again"
                : "Wait for ${duration.inSeconds} sec",
            style: FireFlutterTextStyles.poppinsSize12Weight400BlackOpacity60(
                withOpacity: false),
          ),
        ]),
        style: FireFlutterTextStyles.poppinsSize12Weight400BlackOpacity60());
  }
}

class LoggedIn extends StatelessWidget {
  const LoggedIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Icon(
            Icons.done,
            size: 35,
          ),
          Text("Logged In")
        ],
      ),
    );
  }
}
