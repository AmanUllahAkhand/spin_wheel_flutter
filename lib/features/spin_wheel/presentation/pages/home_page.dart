import 'package:flutter/material.dart';
import 'package:spin_wheel_ui/features/spin_wheel/presentation/widgets/spin_wheel_widget.dart';
import '../../../../core/widgets/design_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeUI();
  }
}

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final SpinWheelController controller = SpinWheelController();
  String? _result; // Result label text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spin Wheel From Scratch",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinWheelWidget(
              controller: controller,
              wheelSize: MediaQuery.sizeOf(context).width * 0.8,
              values: ["A", "B", "C", "D", "E", "F","G","H","I"],
              textStyle: Theme.of(context).textTheme.titleSmall,
              onSpinEnd: (value) {
                setState(() {
                  _result = "Result: $value"; // Show selected value
                });
              },
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Text(
                _result!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 32),
            DesignButton(
              text: "Spin",
              onPressed: () {
                controller.spin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
