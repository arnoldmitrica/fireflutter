import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fireflutter/Providers/fire_flutter_provider.dart';
import 'package:fireflutter/auth_provider.dart';
import 'package:fireflutterui/fireflutterui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MaterialApp(home: FireFlutter())));
}

class FireFlutter extends ConsumerStatefulWidget {
  const FireFlutter({Key? key}) : super(key: key);

  @override
  _ConsumerFireFlutterState createState() => _ConsumerFireFlutterState();
}

class _ConsumerFireFlutterState extends ConsumerState<FireFlutter>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      FirebaseDynamicLinks.instance.onLink.listen(
          (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink.link;
        try {
          final message = await ref
              .watch(fireFlutterProvider)
              .handleLink(ref.watch(authenticationProvider), deepLink);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
          ));
          log("isLogged in");
        } catch (e) {
          log(e.toString());
        }
      }, onError: (e) async {
        log('onLinkError');
        log(e.message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        ref.watch(fireFlutterProvider.select((value) => value.textController));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 47, bottom: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 28.25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 42,
                      child: Icon(
                        Icons.arrow_back,
                      )),
                  const SizedBox(
                    width: 7,
                  ),
                  Column(
                    children: [
                      Text(
                        "Connect your wallet",
                        style:
                            FireFlutterTextStyles.poppinsSize28Weight700Black,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "We'll send you a confirmation code",
                        style: FireFlutterTextStyles
                            .poppinsSize16Weight400BlackOpacity60,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FFPhoneNumberOrEmailTextField(
                        controller: controller,
                        myprovider: fireFlutterProvider,
                        hintText: "Phone number or Email"),
                    const SizedBox(
                      height: 24,
                    ),
                    FFTextButton(
                        onPressed: () {
                          ref
                              .read(fireFlutterProvider)
                              .sendMessageOrEmail(context);
                        },
                        buttonText: "Continue"),
                    const SizedBox(
                      height: 21,
                    ),
                    PlainTexts.registerPageTerms,
                  ]),
            )
          ],
        ),
      ),
    );
  }

}
