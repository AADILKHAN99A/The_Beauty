import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_culture/data/model/skincare_model.dart';
import 'package:urban_culture/utils/helper_functions.dart';

import '../utils/device_info.dart';
import 'Info.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  static String routineId = "";

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(RoutineStep routineStep) async {
    if (await getStoragePermission()) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 30);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await uploadImageToStorage(XFile(_image!.path), routineStep);
      }
    }
  }

  Future<void> uploadImageToStorage(XFile pickedFile, RoutineStep step) async {
    try {
      HelperFunctions.showLoading(context);
      print("Picked Path : ${pickedFile.path}");

      String filePath =
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(filePath);

      UploadTask uploadTask = ref.putFile(File(pickedFile.path));

      await uploadTask.whenComplete(() async {
        String downloadUrl = await ref.getDownloadURL();

        print("Image url : ${downloadUrl}");
        updateImageUrlInFirestore(downloadUrl, step);
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> updateImageUrlInFirestore(
      String imageUrl, RoutineStep step) async {
    try {
      String userId = MyHomePage.userId;
      CollectionReference routinesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('routines');

      var routineDoc = await routinesRef.doc(RoutinePage.routineId).get();

      if (routineDoc.exists) {
        List<dynamic> steps =
            (routineDoc.data() as Map<String, dynamic>)['steps'] ?? [];

        for (int i = 0; i < steps.length; i++) {
          if (steps[i]['step'] == step.step) {
            steps[i]['imageUrl'] = imageUrl;
            break;
          }
        }

        await routineDoc.reference.update({
          'steps': steps,
        });

        print("Image URL updated successfully.");
        fetchTodayList();
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  static Future<bool> getStoragePermission() async {
    print("SDK Version: ${DeviceInformation.sdkVersion}");
    int sdk = int.parse(DeviceInformation.sdkVersion);
    if (sdk < 33) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {
        return false;
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        return true;
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
        return false;
      }
    }
    return false;
  }

  List<RoutineStep> dailyRoutineList = [];

  Future<void> fetchTodayList() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot routineSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(MyHomePage.userId)
          .collection('routines')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      if (routineSnapshot.docs.isNotEmpty) {
        List<RoutineStep> routineSteps = [];
        for (var doc in routineSnapshot.docs) {
          RoutinePage.routineId = doc.id;
          var routineData = doc.data() as Map<String, dynamic>;
          var routine = Routine.fromMap(routineData);
          routineSteps = routine.steps;
        }

        setState(() {
          dailyRoutineList = routineSteps;
        });
      } else {
        print('No routine found for today');
      }
    } catch (e) {
      print('Error fetching routines: $e');
    }
  }

  @override
  void initState() {
    fetchTodayList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return dailyRoutineList.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/no_data_animation.json', width: 200)
            ],
          )
        : ListView.separated(
            itemBuilder: (context, index) {
              String formattedTime = DateFormat('h:mm a')
                  .format(dailyRoutineList[index].time.toDate());
              return Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xffF2E8EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.check),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              dailyRoutineList[index].step,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              dailyRoutineList[index].product,
                              style: TextStyle(
                                  color: Color(0xff964F66),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _pickImage(dailyRoutineList[index]);
                        },
                        child: SizedBox(
                            width: 35,
                            height: 35,
                            child: dailyRoutineList[index].imageUrl != ""
                                ? Image.network(
                                    dailyRoutineList[index].imageUrl)
                                : Image.asset("assets/img_2.png")),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                          color: Color(0xff964F66),
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 10,
              );
            },
            itemCount: dailyRoutineList.length);
  }
}
