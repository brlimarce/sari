import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/home_view.dart';
import 'package:sari/widgets/form/checkbox_loader.dart';
import 'package:sari/widgets/form/form_button_group.dart';
import 'package:sari/widgets/form/form_indicator.dart';
import 'package:sari/widgets/form/form_section_header.dart';
import 'package:sari/widgets/form/schedule_field.dart';

class EditProductFormView extends StatefulWidget {
  static const String route = '/product/form/update/:id';
  final int steps = 2;
  final String id;

  const EditProductFormView({required this.id, super.key});

  @override
  EditProductFormViewState createState() => EditProductFormViewState();
}

class EditProductFormViewState extends State<EditProductFormView> {
  int step = 0;
  final _sellingKey = GlobalKey<FormState>();
  final _meetupKey = GlobalKey<FormState>();

  final _quantityKey = GlobalKey<FormFieldState>();
  final _sellEndDateKey = GlobalKey<FormFieldState>();
  final _sellEndTimeKey = GlobalKey<FormFieldState>();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sellEndDateController = TextEditingController();
  final TextEditingController _sellEndTimeController = TextEditingController();

  List<dynamic> scheduleList = [];
  List<dynamic> startTimeList = [""];
  List<dynamic> endTimeList = [""];

  List<Map<String, dynamic>> _placeMap = [];
  int _placeCount = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchItems();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sellEndDateController.dispose();
    _sellEndTimeController.dispose();
    super.dispose();
  }

  /// Fetch the [Place] from the server.
  void _fetchItems() async {
    // Check if the data is already loaded.
    // If it is, skip the fetch.
    if (_placeMap.isNotEmpty) return;

    // Load the data from the server.
    List<Place> places = await context.read<ProductProvider>().getAllPlaces();
    setState(() {
      _placeMap = Place.toMap(places);
    });
  }

  /// Get the initial date for the meetup schedule.
  ///
  /// It returns a [DateTime] object.
  String _getInitialDate() {
    final sellingEndDate = DateTime.parse(mergeDateTime(
        _sellEndDateController.text, _sellEndTimeController.text));

    final date = sellingEndDate.add(const Duration(days: 1)).toString();
    return date.split(' ')[0].trimRight();
  }

  /// Validate the schedule overlap.
  ///
  /// It takes in a [String] date, [String] time, and [int] index.
  bool _validateScheduleOverlap(String date, String time, int index) {
    // Convert the time to DateTime.
    DateTime dateTime = DateTime.parse(mergeDateTime(date, time));

    // Check if the time overlaps with the current schedule.
    for (int i = 0; i < scheduleList.length; i++) {
      // Skip the item's index.
      if (i == index) continue;

      // Check if both schedules (and start time) overlap.
      if (startTimeList[i].isNotEmpty) {
        DateTime start =
            DateTime.parse(mergeDateTime(scheduleList[i], startTimeList[i]));
        if (dateTime.isAtSameMomentAs(start)) {
          return true;
        }
      }

      // Check if both schedules (and end time) overlap.
      if (endTimeList[i].isNotEmpty) {
        DateTime end =
            DateTime.parse(mergeDateTime(scheduleList[i], endTimeList[i]));
        if (dateTime.isAtSameMomentAs(end)) {
          return true;
        }
      }

      // Check if the schedule overlaps the time range.
      if (startTimeList[i].isNotEmpty && endTimeList[i].isNotEmpty) {
        DateTime start =
            DateTime.parse(mergeDateTime(scheduleList[i], startTimeList[i]));
        DateTime end =
            DateTime.parse(mergeDateTime(scheduleList[i], endTimeList[i]));
        if (dateTime.isAfter(start) && dateTime.isBefore(end)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Render the [Button], depending on the index.
  /// If the index is the last item, render a plus icon.
  /// Otherwise, render a minus icon.
  ///
  /// It takes in an [int] index to determine the button function.
  Widget _buildItemButton(int index) {
    bool isLast = index == scheduleList.length - 1;
    return IconButton(
        icon: Icon(isLast ? FontAwesomeIcons.plus : FontAwesomeIcons.minus,
            size: 18),
        onPressed: () {
          // Add or remove the schedule.
          if (isLast) {
            scheduleList.add(_getInitialDate().toString());
            startTimeList.add("");
            endTimeList.add("");
          } else {
            scheduleList.removeAt(index);
            startTimeList.removeAt(index);
            endTimeList.removeAt(index);
          }

          if (mounted) setState(() {});
        },
        color: isLast ? SariTheme.green : Theme.of(context).colorScheme.error,
        style: IconButton.styleFrom(
          backgroundColor: isLast
              ? Color(SariTheme.greenPalette.get(94))
              : Theme.of(context).colorScheme.errorContainer,
        ));
  }

  // Submit the data to the server.
  void _submit() async {
    // Show a loader to process the data.
    context.loaderOverlay.show();

    // Get selected meetup places.
    List<String> selectedPlaces = [];
    for (int i = 0; i < _placeMap.length; i++) {
      if (_placeMap[i]["checked"]) {
        selectedPlaces.add(_placeMap[i]["id"]);
      }
    }

    // Get the schedule list.
    List<Map<String, String>> schedules = [];
    for (int i = 0; i < scheduleList.length; i++) {
      schedules.add({
        "start_date": mergeDateTime(scheduleList[i], startTimeList[i]),
        "end_date": mergeDateTime(scheduleList[i], endTimeList[i]),
      });
    }

    // Create the request body.
    Map<String, dynamic> data = {
      "stock_qty": _quantityController.text,
      "meetup_place": selectedPlaces,
      "meetup_schedule": schedules,
      "end_date": mergeDateTime(
        _sellEndDateController.text,
        _sellEndTimeController.text,
      ),
    };

    int status =
        await context.read<ProductProvider>().reopenSelling(widget.id, data);
    if (!mounted) return;

    // Hide the loader.
    context.loaderOverlay.hide();
    if (status == StatusCode.NO_CONTENT) {
      ToastAlert.success(
          context, "Your product is now available for sale again!");
      context.replace(HomeView.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialDate = DateTime.now();
    // final initialDate = DateTime.now().add(Duration(days: 1));
    final endDate = DateTime(initialDate.year + 1, 12, 31);

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(SariTheme.primaryPalette.get(96)),
            title: Image.asset("assets/logo/logo.png", width: 32, height: 32),
            iconTheme:
                IconThemeData(color: Color(SariTheme.neutralPalette.get(50))),
            centerTitle: true,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(12),
                child: FormIndicator(
                  step: step,
                  totalSteps: widget.steps,
                  color: SariTheme.green,
                ))),
        backgroundColor: Color(SariTheme.primaryPalette.get(98)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Form(
              key: step == 0 ? _sellingKey : _meetupKey,
              child: step == 0
                  ? Column(children: [
                      /// [Section Header]
                      FormSectionHeader(
                          title: "Reopen Selling",
                          emojiPath: "assets/svg_icons/emoji_coin.svg",
                          description:
                              "Update the selling information of your product before reopening it for sale.",
                          textColor: SariTheme.green),

                      /// [Stock Quantity]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
                          child: TextFormField(
                              key: _quantityKey,
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: OutlinedFieldBorder("Stock Quantity",
                                  hintText: "The stock should be more than 1."),
                              onChanged: (_) {
                                _quantityKey.currentState!.validate();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ProductError.REQUIRED_ERROR;
                                }

                                if (int.parse(value) < 1) {
                                  return ProductError.STOCK_QUANTITY_ERROR;
                                }

                                return null;
                              })),

                      /// [Selling End Date]
                      DateTimePicker(
                          key: _sellEndDateKey,
                          controller: _sellEndDateController,
                          type: DateTimePickerType.date,
                          initialDate: initialDate,
                          firstDate: initialDate,
                          lastDate: endDate,
                          decoration: OutlinedFieldBorder("Selling End Date",
                              hintText: "Select a date.",
                              suffixIcon: Icon(FontAwesomeIcons.calendar,
                                  color:
                                      Color(SariTheme.neutralPalette.get(70)),
                                  size: 20)),
                          onChanged: (_) {
                            _sellEndDateKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ProductError.REQUIRED_ERROR;
                            }

                            return null;
                          }),

                      /// [Selling End Time]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
                          child: DateTimePicker(
                              key: _sellEndTimeKey,
                              controller: _sellEndTimeController,
                              type: DateTimePickerType.time,
                              decoration: OutlinedFieldBorder(
                                  "Selling End Time",
                                  hintText: "Select a time.",
                                  suffixIcon: Icon(FontAwesomeIcons.clock,
                                      color: Color(
                                          SariTheme.neutralPalette.get(70)),
                                      size: 20)),
                              onChanged: (_) {
                                _sellEndTimeKey.currentState!.validate();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ProductError.REQUIRED_ERROR;
                                }

                                return null;
                              })),

                      /// [Button Group]
                      FormButtonGroup(
                          backgroundColor: SariTheme.secondary,
                          step: step,
                          totalSteps: widget.steps,
                          onBack: () {},
                          onNext: () {
                            if (_sellingKey.currentState!.validate()) {
                              setState(() {
                                step++;
                                scheduleList = [_getInitialDate()];
                              });
                            }
                          })
                    ])
                  : Column(children: [
                      /// [Section Header]
                      FormSectionHeader(
                        title: "One last step...",
                        emojiPath: "assets/svg_icons/emoji_sparkles.svg",
                        description:
                            "Update your meetup locations and schedule before reopening your product for sale.",
                        textColor: SariTheme.green,
                        bottomMargin: 20,
                      ),

                      /// [Meetup Places]
                      _placeMap.isEmpty
                          ? CheckboxLoader(isLoading: _placeMap.isEmpty)
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                              child: Column(
                                  children: _placeMap.map<Widget>((item) {
                                return Column(children: [
                                  CheckboxListTile(
                                      title: Text(item['name']),
                                      value: item['checked'],
                                      onChanged: (checked) {
                                        setState(() {
                                          item['checked'] = checked;
                                        });

                                        checked!
                                            ? _placeCount++
                                            : _placeCount--;
                                      }),
                                ]);
                              }).toList())),
                      const SizedBox(height: 8),

                      /// [Meetup Schedule]
                      FormSectionHeader(
                          title: "Meetup Schedule",
                          emojiPath: "assets/svg_icons/emoji_calendar.svg",
                          description:
                              "Create multiple schedules to find a common time slot.",
                          textColor: SariTheme.green),
                      ListView.separated(
                          shrinkWrap: true,
                          itemCount: scheduleList.length,
                          itemBuilder: (context, i) => ScheduleField(
                              key: UniqueKey(),
                              endDate: _sellEndDateController.text,
                              button: _buildItemButton(i),
                              initialDate: scheduleList[i].toString(),
                              initialStartTime: startTimeList[i].toString(),
                              initialEndTime: endTimeList[i].toString(),
                              onDateChanged: (value) {
                                scheduleList[i] = value;
                                _meetupKey.currentState!.validate();
                              },
                              onEndTimeChanged: (value) {
                                endTimeList[i] = value;
                                _meetupKey.currentState!.validate();
                              },
                              onStartTimeChanged: (value) {
                                startTimeList[i] = value;
                                _meetupKey.currentState!.validate();
                              },
                              onStartTimeValidate: (value) {
                                if (value == null || value.isEmpty) {
                                  return ProductError.REQUIRED_ERROR;
                                }
                                // The start time is later than the end time.
                                if (endTimeList[i].isNotEmpty &&
                                    DateTime.parse(mergeDateTime(
                                            scheduleList[i], value))
                                        .isAfter(DateTime.parse(mergeDateTime(
                                            scheduleList[i],
                                            endTimeList[i])))) {
                                  return ProductError.START_LATER_ERROR;
                                }

                                if (_validateScheduleOverlap(
                                    scheduleList[i], value, i)) {
                                  return ProductError.SCHEDULE_OVERLAP_ERROR;
                                }

                                return null;
                              },
                              onEndTimeValidate: (value) {
                                if (value == null || value.isEmpty) {
                                  return ProductError.REQUIRED_ERROR;
                                }

                                // The end time is earlier than the start time.
                                if (startTimeList[i].isNotEmpty &&
                                    DateTime.parse(mergeDateTime(
                                            scheduleList[i], value))
                                        .isBefore(DateTime.parse(mergeDateTime(
                                            scheduleList[i],
                                            startTimeList[i])))) {
                                  return ProductError.END_EARLIER_ERROR;
                                }

                                if (_validateScheduleOverlap(
                                    scheduleList[i], value, i)) {
                                  return ProductError.SCHEDULE_OVERLAP_ERROR;
                                }

                                return null;
                              }),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 4)),

                      /// [Button Group]
                      FormButtonGroup(
                          backgroundColor: SariTheme.secondary,
                          step: step,
                          totalSteps: widget.steps,
                          onBack: () {
                            setState(() {
                              step--;
                            });
                          },
                          onNext: () {
                            // Check if a place has been checked.
                            if (_placeCount <= 0) {
                              ToastAlert.error(
                                  context,
                                  ProductError.SELECT_ONE_ERROR(
                                      "meetup place"));
                            }

                            // Validate the meetup information.
                            if (_meetupKey.currentState!.validate()) {
                              _submit();
                            }
                          })
                    ]),
            )));
  }
}
