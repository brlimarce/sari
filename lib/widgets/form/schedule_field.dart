import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';

class ScheduleField extends StatefulWidget {
  final String endDate;
  final String initialDate;
  final String initialStartTime;
  final String initialEndTime;
  final void Function(String) onDateChanged;
  final void Function(String) onStartTimeChanged;
  final void Function(String) onEndTimeChanged;
  final String? Function(String?) onStartTimeValidate;
  final String? Function(String?) onEndTimeValidate;
  final Widget button;

  const ScheduleField({
    super.key,
    required this.endDate,
    required this.initialDate,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onStartTimeValidate,
    required this.onEndTimeValidate,
    required this.button,
  });

  @override
  ScheduleFieldState createState() {
    return ScheduleFieldState();
  }
}

class ScheduleFieldState extends State<ScheduleField> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.parse(widget.endDate);
    _dateController.text = widget.initialDate;
    _startTimeController.text = widget.initialStartTime;
    _endTimeController.text = widget.initialEndTime;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      /// [Meetup Date]
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date Picker
              Expanded(
                  child: DateTimePicker(
                      controller: _dateController,
                      type: DateTimePickerType.date,
                      initialDate: DateTime.parse(widget.initialDate),
                      firstDate: _date.add(const Duration(days: 1)),
                      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
                      onChanged: widget.onDateChanged,
                      decoration: OutlinedFieldBorder("Meetup Date",
                          hintText: "Select a date.",
                          suffixIcon: Icon(FontAwesomeIcons.calendar,
                              color: Color(SariTheme.neutralPalette.get(70)),
                              size: 20)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ProductError.REQUIRED_ERROR;
                        }
                        return null;
                      })),

              /// [Add/Remove Date Button]
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: widget.button)
            ]),
      ),

      /// [Meetup Time]
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// [Start Time]
                Expanded(
                    child: DateTimePicker(
                        controller: _startTimeController,
                        type: DateTimePickerType.time,
                        onChanged: widget.onStartTimeChanged,
                        decoration: OutlinedFieldBorder("Start Time",
                            suffixIcon: Icon(FontAwesomeIcons.clock,
                                color: Color(SariTheme.neutralPalette.get(70)),
                                size: 20)),
                        validator: widget.onStartTimeValidate)),

                /// [Divider]
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(FontAwesomeIcons.minus,
                        color: Color(SariTheme.neutralPalette.get(70)),
                        size: 20)),

                /// [End Time]
                Expanded(
                    child: DateTimePicker(
                        controller: _endTimeController,
                        type: DateTimePickerType.time,
                        onChanged: widget.onEndTimeChanged,
                        decoration: OutlinedFieldBorder("End Time",
                            suffixIcon: Icon(FontAwesomeIcons.clock,
                                color: Color(SariTheme.neutralPalette.get(70)),
                                size: 20)),
                        validator: widget.onEndTimeValidate)),
              ]))
    ]);
  }
}
