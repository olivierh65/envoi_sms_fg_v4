import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DurationFormat {
  minutesSeconds,
  secondsCentiseconds,
}

class DurationInput extends StatefulWidget {
  final ValueChanged<Duration>? onChanged;
  final Duration? initialDuration;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final DurationFormat format;
  final TextInputType? keyboardType; // Ajout du paramètre keyboardType

  const DurationInput({
    Key? key,
    this.onChanged,
    this.initialDuration,
    this.decoration,
    this.inputFormatters,
    this.label,
    this.labelStyle,
    this.hintStyle,
    this.hintText,
    this.format = DurationFormat.minutesSeconds,
    this.keyboardType, // Ajout du paramètre keyboardType
  }) : super(key: key);

  @override
  _DurationInputState createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  late TextEditingController _firstController;
  late TextEditingController _secondController;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController();
    _secondController = TextEditingController();
    _updateControllersFromDuration(widget.initialDuration);
    _firstController.addListener(_onChanged);
    _secondController.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant DurationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDuration != widget.initialDuration) {
      _updateControllersFromDuration(widget.initialDuration);
    }
  }

  void _updateControllersFromDuration(Duration? duration) {
    if (duration != null) {
      if (widget.format == DurationFormat.minutesSeconds) {
        _firstController.text =
            duration.inMinutes.remainder(60).toString();
        _secondController.text = duration.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');
      } else {
        _firstController.text = duration.inSeconds.toString();
        _secondController.text = duration.inMilliseconds
            .remainder(1000)
            .toString()
            .padLeft(3, '0'); // Utilisation de 3 digits
      }
    } else {
      _firstController.text = '0';
      _secondController.text = '000'; // Utilisation de 3 digits
    }
  }


  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _onChanged() {
    int firstValue = int.tryParse(_firstController.text) ?? 0;
    int secondValue = int.tryParse(_secondController.text) ?? 0;

    Duration duration;
    if (widget.format == DurationFormat.minutesSeconds) {
      duration = Duration(minutes: firstValue, seconds: secondValue);
    } else {
      duration = Duration(seconds: firstValue, milliseconds: secondValue); // Pas de *10
    }
    widget.onChanged?.call(duration);
  }

  @override
  Widget build(BuildContext context) {
    final defaultFieldDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      hintText: '000',
      hintStyle: widget.hintStyle,
    );

    final firstLabel = widget.format == DurationFormat.minutesSeconds
        ? 'Min'
        : 'Sec';
    final secondLabel = widget.format == DurationFormat.minutesSeconds
        ? 'Sec'
        : 'Centi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: widget.labelStyle,
            ),
          ),
        if (widget.hintText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.hintText!,
              style: widget.hintStyle,
            ),
          ),
        Container(
          decoration: widget.decoration?.border != null
              ? BoxDecoration(
            border: (widget.decoration!.border is OutlineInputBorder)
                ? Border.all(
              color:
              (widget.decoration!.border as OutlineInputBorder)
                  .borderSide
                  .color,
              width:
              (widget.decoration!.border as OutlineInputBorder)
                  .borderSide
                  .width,
            )
                : null,
          )
              : null,
          padding: widget.decoration?.contentPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: _firstController,
                  keyboardType: widget.keyboardType ?? TextInputType.number, // Utilisation du paramètre keyboardType
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: defaultFieldDecoration.copyWith(
                    labelText: firstLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final firstValue = int.tryParse(value);
                    if (firstValue == null || firstValue < 0) {
                      return 'Invalid';
                    }
                    if (widget.format == DurationFormat.minutesSeconds &&
                        firstValue > 59) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(':'),
              ),
              SizedBox(
                width: widget.format == DurationFormat.minutesSeconds ? 60 : 80,
                child: TextFormField(
                  controller: _secondController,
                  keyboardType: widget.keyboardType ?? TextInputType.number, // Utilisation du paramètre keyboardType
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    widget.format == DurationFormat.minutesSeconds ? LengthLimitingTextInputFormatter(2) : LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: defaultFieldDecoration.copyWith(
                    labelText: secondLabel,
                    hintText: widget.format == DurationFormat.minutesSeconds ? '00' : '000',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final secondValue = int.tryParse(value);
                    if (secondValue == null || secondValue < 0) {
                      return 'Invalid';
                    }
                    if (widget.format == DurationFormat.minutesSeconds &&
                        secondValue > 59) {
                      return 'Invalid';
                    }
                    if (widget.format == DurationFormat.secondsCentiseconds &&
                        secondValue > 999) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}