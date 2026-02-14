// Test file to verify structure
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestLoginPage extends StatelessWidget {
  const TestLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => null,
      child: const TestLoginPageContent(),
    );
  }
}

class TestLoginPageContent extends StatefulWidget {
  const TestLoginPageContent();

  @override
  State<TestLoginPageContent> createState() => _TestLoginPageContentState();
}

class _TestLoginPageContentState extends State<TestLoginPageContent> {
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (context, state) {
        // listener body
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Form(child: Column(children: [Text('Test')])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
