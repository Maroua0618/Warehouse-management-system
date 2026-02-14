import 'package:flutter/material.dart';

class SupervisorScreen extends StatelessWidget {
  const SupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supervisor')),
      body: const Center(child: Text('Supervisor Screen')),
    );
  }
}
