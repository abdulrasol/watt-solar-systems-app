import 'package:flutter/material.dart';

class CalcInputRow extends StatefulWidget {
  final String label;
  final String suffix;
  final String? hint;
  final Function(String) onChanged;
  final double? initialValue;

  const CalcInputRow({super.key, required this.label, required this.suffix, required this.onChanged, this.initialValue, this.hint});

  @override
  State<CalcInputRow> createState() => _CalcInputRowState();
}

class _CalcInputRowState extends State<CalcInputRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant CalcInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      // Only update text if the value is different and we're not currently editing it
      // (or rather, if the external value doesn't match our current text)
      // Actually, if we are typing "125", the external value becomes 125.
      // So widget.initialValue will be 125. _controller.text is "125".
      // So we don't need to do anything.
      // Standard pattern: Only update if significant difference (e.g. formatted differently or reset)

      final newValue = widget.initialValue?.toString() ?? '';
      if (_controller.text != newValue) {
        // Check if they are effectively the same number to avoid "1." vs "1" issues while typing decimal
        double? currentNum = double.tryParse(_controller.text);
        double? newNum = widget.initialValue;

        if (currentNum != newNum) {
          // Use selection to try and preserve cursor if we force update?
          // Ideally we shouldn't force update if it's just a loopback.
          _controller.text = newValue;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixText: widget.suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  const ResultCard({super.key, required this.title, required this.value, required this.icon, required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
