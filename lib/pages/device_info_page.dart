// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:intl/intl.dart';

// class DeviceInfoPage extends StatefulWidget {
//   const DeviceInfoPage({super.key});

//   @override
//   State<DeviceInfoPage> createState() => _DeviceInfoPageState();
// }

// class _DeviceInfoPageState extends State<DeviceInfoPage> {
//   final _plugin = DeviceInfoPlugin();
//   Map<String, String> _info = {};
//   String _now = '';

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     final now = DateTime.now();
//     // contoh format internasional
//     _now = DateFormat('EEEE, dd MMMM yyyy – HH:mm', 'id_ID').format(now);

//     try {
//       if (Platform.isAndroid) {
//         final a = await _plugin.androidInfo;
//         _info = {
//           'Brand': a.brand ?? '',
//           'Model': a.model ?? '',
//           'Device': a.device ?? '',
//           'SDK': '${a.version.sdkInt}',
//           'Release': a.version.release ?? '',
//           'SupportedABIs': a.supportedAbis.join(', '),
//         };
//       } else if (Platform.isIOS) {
//         final i = await _plugin.iosInfo;
//         _info = {
//           'Name': i.name ?? '',
//           'System': '${i.systemName} ${i.systemVersion}',
//           'Model': i.model ?? '',
//           'Localized': i.localizedModel ?? '',
//           'Identifier': i.identifierForVendor ?? '',
//         };
//       } else {
//         _info = {'Platform': 'Unsupported on this platform'};
//       }
//     } catch (e) {
//       _info = {'Error': e.toString()};
//     }

//     if (mounted) setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Device Info')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Text('Sekarang: $_now', style: const TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 12),
//           ..._info.entries.map((e) => ListTile(
//                 title: Text(e.key),
//                 subtitle: Text(e.value),
//                 dense: true,
//               )),
//         ],
//       ),
//     );
//   }
// }
