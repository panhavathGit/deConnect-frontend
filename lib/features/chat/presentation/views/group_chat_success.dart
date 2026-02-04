// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../core/app_export.dart';
// import '../../../core/widgets/custom_button.dart';

// class GroupChatSuccess extends StatelessWidget {
//   final String? groupCode;
//   final String? groupName;

//   const GroupChatSuccess({
//     super.key,
//     this.groupCode,
//     this.groupName,
//   });

//   void _copyToClipboard(BuildContext context) {
//     if (groupCode != null && groupCode!.isNotEmpty) {
//       Clipboard.setData(ClipboardData(text: groupCode!));
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Code copied to clipboard!'),
//           backgroundColor: appTheme.greenCustom,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appTheme.white_A700,
//       appBar: AppBar(
//         backgroundColor: appTheme.white_A700,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: appTheme.black_900),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Group created successfully',
//           style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//             color: appTheme.blue_900,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
              
//               // Group code display
//               GestureDetector(
//                 onTap: () => _copyToClipboard(context),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 18,
//                   ),
//                   decoration: BoxDecoration(
//                     color: appTheme.white_A700,
//                     borderRadius: BorderRadius.circular(28),
//                     border: Border.all(
//                       color: appTheme.blue_gray_100.withOpacity(0.5),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Text(
//                         groupCode ?? 'your code :',
//                         style: TextStyleHelper.instance.body15MediumInter.copyWith(
//                           color: groupCode != null 
//                               ? appTheme.black_900 
//                               : appTheme.greyCustom.withOpacity(0.4),
//                           fontSize: 16,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (groupCode != null && groupCode!.isNotEmpty)
//                         Icon(
//                           Icons.copy,
//                           size: 18,
//                           color: appTheme.greyCustom,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const Spacer(),
              
//               // Success icon
//               Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: appTheme.greenCustom ?? Colors.green,
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.check,
//                     size: 120,
//                     color: appTheme.white_A700,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
              
//               // Success message
//               Text(
//                 'your group is ready!',
//                 style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//                   color: appTheme.blue_900,
//                   fontSize: 20,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               const Spacer(),
              
//               // Back to chat button
//               CustomButton(
//                 text: 'back to chat',
//                 width: 200,
//                 backgroundColor: appTheme.blue_900,
//                 textColor: appTheme.white_A700,
//                 borderRadius: 28,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 onPressed: () {
//                   // Navigate back to chat list
//                   Navigator.popUntil(context, (route) => route.isFirst);
//                 },
//               ),
              
//               const SizedBox(height: 100),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_button.dart';

class GroupChatSuccess extends StatelessWidget {
  final String? groupCode;
  final String? groupName;

  const GroupChatSuccess({
    super.key,
    this.groupCode,
    this.groupName,
  });

  void _copyToClipboard(BuildContext context) {
    if (groupCode != null && groupCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: groupCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code copied to clipboard!'),
          backgroundColor: appTheme.greenCustom,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        backgroundColor: appTheme.white_A700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black_900),
          onPressed: () {
            // Navigate back to chat list (same as bottom button)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        centerTitle: true,
        title: Text(
          'Group created successfully',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            color: appTheme.blue_900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // Group code display
              GestureDetector(
                onTap: () => _copyToClipboard(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: appTheme.white_A700,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: appTheme.blue_gray_100.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        groupCode ?? 'your code :',
                        style: TextStyleHelper.instance.body15MediumInter.copyWith(
                          color: groupCode != null 
                              ? appTheme.black_900 
                              : appTheme.greyCustom.withOpacity(0.4),
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (groupCode != null && groupCode!.isNotEmpty)
                        Icon(
                          Icons.copy,
                          size: 18,
                          color: appTheme.greyCustom,
                        ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Success icon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.greenCustom ?? Colors.green,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 120,
                    color: appTheme.white_A700,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Success message
              Text(
                'your group is ready!',
                style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                  color: appTheme.blue_900,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Back to chat button
              CustomButton(
                text: 'back to chat',
                width: 200,
                backgroundColor: appTheme.blue_900,
                textColor: appTheme.white_A700,
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(vertical: 14),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                onPressed: () {
                  // Navigate back to chat list
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}