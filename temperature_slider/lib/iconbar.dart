import 'package:flutter/material.dart';

class TemperatureIconBar extends StatelessWidget {
  final double value;
  final ValueChanged<double> onTemperatureChanged;

  const TemperatureIconBar({
    super.key,
    required this.value,
    required this.onTemperatureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 42),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ThermoIcon(
            icon: Icons.ac_unit,
            color: Colors.cyan,
            selected: value < 1 / 3,
            onTap: () => onTemperatureChanged(10),
          ),
          ThermoIcon(
            icon: Icons.water_drop,
            color: Colors.amber,
            selected: value >= 1 / 3 && value < 2 / 3,
            onTap: () => onTemperatureChanged(20),
          ),
          ThermoIcon(
            icon: Icons.local_fire_department,
            color: Colors.deepOrange,
            selected: value >= 2 / 3,
            onTap: () => onTemperatureChanged(35),
          ),
        ],
      ),
    );
  }
}

class ThermoIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ThermoIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final selectedButtonSize = size.height < 600 ? 42.0 : 64.0;
    final buttonSize = size.height < 600 ? 32.0 : 48.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: selectedButtonSize,
        height: selectedButtonSize,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: selected ? selectedButtonSize : buttonSize,
            height: selected ? selectedButtonSize : buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? color.withOpacity(.3) : Colors.grey.shade200,
            ),
            child: Center(
              child: Icon(
                icon,
                size: selected ? selectedButtonSize-12 : buttonSize-12,
                color: selected ? color : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}