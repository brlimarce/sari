import 'package:flutter/material.dart';
import 'dart:async';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/utils/sari_theme.dart';

class ServerTimer extends StatefulWidget {
  final int milliseconds;

  const ServerTimer({super.key, required this.milliseconds});

  @override
  ServerTimerState createState() => ServerTimerState();
}

class ServerTimerState extends State<ServerTimer> {
  late int milliseconds;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    milliseconds = widget.milliseconds;
    start();
  }

  /// Start the timer.
  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (milliseconds > 0) {
          milliseconds -= 1000;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  /// Format the time in milliseconds to a readable format.
  ///
  /// The format is `HH:MM:SS`.
  String formatTime(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FaIcon(FontAwesomeIcons.clock,
                  color: Color(SariTheme.neutralPalette.get(60)), size: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
                child: Text(
                    milliseconds > 0 ? formatTime(milliseconds) : "00:00:00",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        )),
              )
            ]));
  }
}
