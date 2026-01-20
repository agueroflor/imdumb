import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  final String environment;

  const SplashPage({super.key, required this.environment});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger app initialization
    context.read<SplashBloc>().add(InitializeApp(widget.environment));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashLoaded) {
          // Navigate to home when initialization is complete
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state is SplashError) {
          // Show error dialog if initialization fails
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Initialization Error'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Retry initialization
                    context.read<SplashBloc>().add(InitializeApp(widget.environment));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
