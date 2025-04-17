import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/models/schedule_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleModal extends StatefulWidget {
  final String transaction;
  final String product;
  final Function onComplete;

  const ScheduleModal({
    super.key,
    required this.transaction,
    required this.product,
    required this.onComplete,
  });

  @override
  ScheduleModalState createState() => ScheduleModalState();
}

class ScheduleModalState extends State<ScheduleModal> {
  List<Schedule> _schedules = [];
  List<Place> _places = [];

  String _selectedSchedule = "";
  String _selectedPlace = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  /// Fetch the initial data from the server.
  void _fetchData() async {
    // Skip if data is already loaded.
    if (_schedules.isNotEmpty && _places.isNotEmpty) return;

    // Fetch schedules.
    List<Schedule> schedules = await context
        .read<ProductProvider>()
        .getAllSchedules(widget.product, DateTime.now());

    // Fetch places.
    if (!mounted) return;
    List<Place> places = await context
        .read<ProductProvider>()
        .getAllPlaces(filters: {"product": widget.product});

    // Set the data.
    setState(() {
      _schedules = schedules;
      _selectedSchedule = schedules.first.id;

      _places = places;
      _selectedPlace = places.first.id;
    });
  }

  /// Format the time in a HH:mm format.
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
        title: "Confirm Schedule",
        icon: FontAwesomeIcons.solidMap,
        body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            /// [Description]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Color(SariTheme.neutralPalette.get(40))),
                    children: const <TextSpan>[
                      TextSpan(text: 'Select your '),
                      TextSpan(
                          text: 'preferred meetup schedule',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' and '),
                      TextSpan(
                          text: 'meetup place.',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                )),

            /// [Schedule]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: _schedules.isNotEmpty
                    ? DropdownButtonFormField(
                        value: _selectedSchedule,
                        onChanged: (value) {
                          setState(() {
                            _selectedSchedule = value.toString();
                          });
                        },
                        decoration: OutlinedFieldBorder("Meetup Schedule"),
                        items: _schedules.map((p) {
                          // Convert the date into a local timezone.
                          DateTime startLocal =
                              convertToLocalTimezone(p.start_date);
                          DateTime endLocal =
                              convertToLocalTimezone(p.end_date);

                          // Formatting the date part.
                          String date = DateFormat('MM/d').format(startLocal);

                          // Formatting the time part.
                          String startTime = _formatTime(startLocal);
                          String endTime = _formatTime(endLocal);

                          // Combine the date and time.
                          String result = "$date ($startTime - $endTime)";
                          return DropdownMenuItem(
                              value: p.id, child: Text(result));
                        }).toList(),
                      )
                    : Skeletonizer(
                        child: DropdownButtonFormField(
                        value: "",
                        onChanged: (value) {},
                        decoration: OutlinedFieldBorder("Meetup Schedule"),
                        items: const [],
                      ))),

            /// [Place]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: _places.isNotEmpty
                    ? DropdownButtonFormField(
                        value: _selectedPlace,
                        onChanged: (value) {
                          setState(() {
                            _selectedPlace = value.toString();
                          });
                        },
                        decoration: OutlinedFieldBorder("Meetup Place"),
                        items: _places.map((p) {
                          return DropdownMenuItem(
                              value: p.id, child: Text(p.name));
                        }).toList(),
                      )
                    : Skeletonizer(
                        child: DropdownButtonFormField(
                        value: "",
                        onChanged: (value) {},
                        decoration: OutlinedFieldBorder("Meetup Place"),
                        items: const [],
                      ))),
          ]);
        }),
        activeButtonLabel: "Confirm",
        onPressed: () async {
          // Process the transaction.
          context.loaderOverlay.show();

          int status = await context.read<TransactionProvider>().manageMeetup(
              widget.transaction,
              widget.product,
              context.read<DealerAuthProvider>().currentUser!.uid,
              data: {
                "schedule": _selectedSchedule,
                "place": _selectedPlace,
              });

          // End the loading state.
          if (!context.mounted) return;
          context.loaderOverlay.hide();

          // Display the success message.
          if (status == StatusCode.NO_CONTENT) {
            Navigator.of(context).pop();
            ToastAlert.success(
                context, "Your meetup has been scheduled successfully.");
            widget.onComplete();
          }
        });
  }
}
