import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final num valueA;
  final num valueB;

  const StatRow({
    super.key,
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  @override
  Widget build(BuildContext context) {
    final bool aWins = valueA > valueB;
    final bool bWins = valueB > valueA;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildValueContainer(
                  'You: ${valueA.toInt()}',
                  aWins ? Colors.green : (bWins ? Colors.red : Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              const Text('vs'),
              const SizedBox(width: 8),
              Expanded(
                child: _buildValueContainer(
                  'Opponent: ${valueB.toInt()}',
                  bWins ? Colors.green : (aWins ? Colors.red : Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueContainer(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
