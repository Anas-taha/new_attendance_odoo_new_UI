//  AppBar _homeAppBar(BuildContext context) {
//     return AppBar(
//       title: Text(AppLocalizations.of(context)!.hrDashboard),
//       backgroundColor: Colors.red,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       actions: [
//         PopupMenuButton<String>(
//           onSelected: (value) async {
//             if (value == 'logout') {
//               homeController.requestLogout();
//             } else if (value == 'lang_en' || value == 'lang_ar') {
//               final code = value == 'lang_en' ? 'en' : 'ar';
//               await LocaleScope.of(context).setLocale(code);
//             }
//           },
//           itemBuilder: (BuildContext context) => [
//             PopupMenuItem<String>(
//               value: 'user',
//               enabled: false,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     homeController.currentEmployee.value?.name ??
//                         AppLocalizations.of(context)!.employee,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2D3748),
//                     ),
//                   ),
//                   Text(
//                     homeController.currentEmployee.value?.workEmail ??
//                         AppLocalizations.of(context)!.noEmail,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF718096),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             PopupMenuItem<String>(
//               value: 'lang_en',
//               child: Row(
//                 children: [
//                   const Icon(Icons.language),
//                   const SizedBox(width: 8),
//                   Text(AppLocalizations.of(context)!.english),
//                 ],
//               ),
//             ),
//             PopupMenuItem<String>(
//               value: 'lang_ar',
//               child: Row(
//                 children: [
//                   const Icon(Icons.language),
//                   const SizedBox(width: 8),
//                   Text(AppLocalizations.of(context)!.arabic),
//                 ],
//               ),
//             ),
//             const PopupMenuDivider(),
//             PopupMenuItem<String>(
//               value: 'logout',
//               child: Row(
//                 children: [
//                   const Icon(Icons.logout, color: Colors.red),
//                   const SizedBox(width: 8),
//                   Text(AppLocalizations.of(context)!.logout),
//                 ],
//               ),
//             ),
//           ],
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     (homeController.currentEmployee.value?.name ?? 'E')
//                         .substring(0, 1)
//                         .toUpperCase(),
//                     style: const TextStyle(
//                       color: Color(0xFF6B46C1),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.arrow_drop_down, color: Colors.white),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }