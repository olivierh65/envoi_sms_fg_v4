import 'package:envoi_sms_fg_v4/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'duration_input.dart';

final _formKey = GlobalKey<FormState>();

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  // const Settings({super.key, this.args});

  //final MyappArgs? args;
  // final SharedPreferences? prefs;

  @override
  State<Settings> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  bool _passwordVisible = false;
  Duration? _selectedDuration;

  // Variables de configuration
  String? sendUrl = '';
  String? receiveUrl = '';
  String? statusUrl = '';
  Duration? queryInterval = Duration(minutes: 59);
  String? deviceId = '';
  Duration? sendInterval = Duration(seconds: 1, milliseconds: 500);
  String? webApiKey = '';

  @override
  initState() {
    _passwordVisible = false;
    super.initState();

    // final MyPrefs = widget.args?['MyPrefs'] as SharedPreferences;
    final myPrefs = AppPreferences();
    sendUrl = myPrefs.getString('sendUrl');
    receiveUrl = myPrefs.getString('receiveUrl');
    statusUrl = myPrefs.getString('statusUrl');
    queryInterval = myPrefs.getDuration('queryInterval');
    deviceId = myPrefs.getString('deviceId');
    sendInterval = myPrefs.getDuration('sendInterval');
    webApiKey = myPrefs.getString('webApiKey');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Settings"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: savePrefs,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(4),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter send URL',
                    hintText: 'Send URL to contact'),
                keyboardType: TextInputType.url,
                validator: validUrl,
                initialValue: sendUrl ?? '',
                onChanged: (name) => setState(() => sendUrl = name),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Receive URL',
                    hintText: 'Receive URL to contact'),
                keyboardType: TextInputType.url,
                validator: validUrl,
                initialValue: receiveUrl ?? '',
                onChanged: (name) => setState(() => receiveUrl = name),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Status URL',
                    hintText: 'Status URL to contact'),
                keyboardType: TextInputType.url,
                validator: validUrl,
                initialValue: statusUrl ?? '',
                onChanged: (name) => setState(() => statusUrl = name),
              ),
            ),
            /* Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Query Interval',
                    hintText: 'Query interval in minutes'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                initialValue: queryInterval.toString() ?? '1',
                onChanged: (name) => setState(() => queryInterval = name as int?),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) {
                    return null;
                  }
                  var v = int.tryParse(value);
                  if ((v! <= 0) || (v > 60)) {
                    return 'Interval must be > 0 et < 60 minutes';
                  } else {
                    return null;
                  }
                },
              ),
            ), */
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DurationInput(
                  format: DurationFormat.minutesSeconds,
                  label: 'Query interval',
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  hintText: 'Enter duration in minutes and seconds', // hintText global
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (duration) {
                    setState(() {
                      queryInterval = duration;
                    });
                  },
                  initialDuration: queryInterval ?? Duration(minutes: 1, seconds: 0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Device Id',
                    hintText: 'Device ID'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                initialValue: deviceId ?? '1',
                onChanged: (name) => setState(() => deviceId = name),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) {
                    return null;
                  }
                  var v = int.tryParse(value);
                  if (v! <= 0) {
                    return 'ID must be > 0';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            /* Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'SMS send interval (s)',
                    hintText:
                        'Delay between each SMS in seconde. To short interval can be seen as spam!!!'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                initialValue: sendInterval.toString() ?? '5',
                onChanged: (name) =>
                    setState(() => sendInterval = name as double?),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) {
                    return null;
                  }
                  var v = double.tryParse(value);
                  if (v! <= 0.1) {
                    return 'Delay must be > 0.1';
                  } else {
                    return null;
                  }
                },
              ),
            ), */
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DurationInput(
                  format: DurationFormat.secondsCentiseconds,
                  label: 'SMS send interval',
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  hintText: 'Delay between each SMS in seconde. To short interval can be seen as spam!!!', // hintText global
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (duration) {
                    setState(() {
                      sendInterval = duration;
                    });
                  },
                  initialDuration: sendInterval ?? Duration(seconds: 1, milliseconds: 200),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'WebApiKey',
                  hintText: 'Enter Web Api key',
                  suffixIcon: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _passwordVisible = true;
                      });
                    },
                    onLongPressUp: () {
                      setState(() {
                        _passwordVisible = false;
                      });
                    },
                    child: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                initialValue: webApiKey ?? '',
                onChanged: (name) => setState(() => webApiKey = name),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validUrl(String? value) {
    if (value != null && value.contains('@')) {
      return ('Do not use the @ char.');
    } else {
      return null;
    }
  }

  savePrefs() async {
    // final MyPrefs = widget.args?['MyPrefs'] as SharedPreferences;
    final myPrefs = AppPreferences();
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      if (sendUrl != null) {
        myPrefs.setString('sendUrl', sendUrl!);
      }
      if (receiveUrl != null) {
        myPrefs.setString('receiveUrl', receiveUrl!);
      }
      if (statusUrl != null) {
        myPrefs.setString('statusUrl', statusUrl!);
      }
      if (queryInterval != null) {
        myPrefs.setDuration('queryInterval', queryInterval!);
      }
      if (deviceId != null) {
        myPrefs.setString('deviceId', deviceId!);
      }
      if (sendInterval != null) {
        myPrefs.setDuration('sendInterval', sendInterval!);
      }
      if (webApiKey != null) {
        myPrefs.setString('webApiKey', webApiKey!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.pop(context);
    }
  }
}
