import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../utils/internet/internet_cubit.dart';

class InternetConnectionCheck extends StatelessWidget {
  const InternetConnectionCheck({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetState>(
      builder: (context, state) {
        if (state is InternetConnectedState) {
          return child;
        } else if (state is InternetDisconnectedState) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/no_internet.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                      animate: true,
                      repeat: true,
                      reverse: false,
                      frameRate: const FrameRate(20),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No Internet Connection.. ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No Internet connection found. Check your \nconnection or try again.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          child: Scaffold(
            body: Lottie.asset('assets/loading.json'),
          ),
        );
      },
    );
  }
}
