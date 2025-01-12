import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:searchfield/searchfield.dart';
import 'package:urban_culture/presentation/graph_data.dart';
import 'package:urban_culture/presentation/routines_page.dart';
import 'package:urban_culture/utils/enum.dart';
import 'package:urban_culture/utils/helper_functions.dart';

import '../data/model/skincare_model.dart';
import 'Info.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({super.key});

  @override
  State<StreaksPage> createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  int todayStreakDays = 0;
  int streakDays = 0;

  double overallPercent = 0;

  @override
  void initState() {
    fetchTodayList();
    super.initState();
  }

  List<RoutineStep> dailyRoutineList = [];

  double calculateOverallStreakPercentage() {
    int totalExpectedSteps = 5;
    int totalCompletedSteps = 0;
    int totalDays = streakData.length;

    for (var completedSteps in streakData) {
      totalCompletedSteps += completedSteps;
    }

    double overallPercentage =
        (totalCompletedSteps / (totalDays * totalExpectedSteps)) * 100;
    return overallPercentage;
  }

  Future<void> fetchTodayList() async {
    fetchStreakData();
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

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(MyHomePage.userId)
          .get();

      int userStreakCount = 0;

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        userStreakCount =
            userData['streakCount'] ?? 0; // Default to 0 if not found
      }

      if (routineSnapshot.docs.isNotEmpty) {
        List<RoutineStep> routineSteps = [];
        for (var doc in routineSnapshot.docs) {
          RoutinePage.routineId = doc.id;
          var routineData = doc.data() as Map<String, dynamic>;

          print("Routine Data: $routineData");
          var routine = Routine.fromMap(routineData);
          routineSteps = routine.steps;
        }

        setState(() {
          dailyRoutineList = routineSteps;

          todayStreakDays = userStreakCount;
        });

        updateDropdownList();
      } else {
        print('No routine found for today');
      }
    } catch (e) {
      print('Error fetching routines: $e');
    }
  }

  List<String> specificProductNameList = [];

  updateDropdownList() {
    for (var item in dailyRoutineList) {
      products.removeWhere((element) =>
          element.toString().toLowerCase().trim() ==
          item.step.toString().toLowerCase().trim());
    }
  }

  List<String> products = [
    'Cleanser',
    'Toner',
    'Lip Balm',
    'Moisturizer',
    'Sunscreen'
  ];

  Future<void> updateStreakCount() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot routineSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(MyHomePage.userId)
          .collection('routines')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (routineSnapshot.docs.isEmpty) {
        print('No routine found for today.');
        return;
      }

      DocumentSnapshot routineDoc = routineSnapshot.docs.first;
      Map<String, dynamic> routineData =
          routineDoc.data() as Map<String, dynamic>;

      List<String> requiredRoutines = [
        'Cleanser',
        'Toner',
        'Lip Balm',
        'Moisturizer',
        'Sunscreen'
      ];

      List<String> completedRoutines = [];
      for (var step in routineData['steps']) {
        completedRoutines.add(step['step']);
      }

      bool allRoutinesCompleted = requiredRoutines.every((routine) {
        return completedRoutines.contains(routine);
      });

      if (allRoutinesCompleted) {
        print('All routines completed for today.');

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(MyHomePage.userId)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          int currentStreakCount = userData['streakCount'] ?? 0;
          int newStreakCount = currentStreakCount + 1;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(MyHomePage.userId)
              .update({
            'streakCount': newStreakCount,
            'lastLogin': Timestamp.now(),
          });

          print('Streak count updated successfully to $newStreakCount.');
        } else {
          print('User data not found.');
        }
      } else {
        print('Not all routines completed for today.');
      }
    } catch (e) {
      print('Error updating streak count: $e');
    }
  }

  void showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Congratulations!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/great_job.json', width: 250),
              const Text(
                "You've completed your daily goal. Great job!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void checkAndShowCompletionDialog(BuildContext context) {
    int completedSteps = dailyRoutineList.length;
    int expectedSteps = 5;

    if (completedSteps == expectedSteps) {
      showCompletionDialog(context);
    } else {
      print("Not all tasks are completed yet.");
    }
  }

  openDialog() {
    fetchTodayList();
    List<String> productsNamesList = [];
    TextEditingController productNameController = TextEditingController();
    String selectedProduct = 'Select a Product';

    Future<void> checkAndInsertBrandName(String brandName) async {
      try {
        DocumentSnapshot userProductsDoc = await FirebaseFirestore.instance
            .collection('Products')
            .doc(MyHomePage.userId)
            .get();

        if (userProductsDoc.exists) {
          Map<String, dynamic> userProductsData =
              userProductsDoc.data() as Map<String, dynamic>;

          if (userProductsData.containsKey(selectedProduct)) {
            List<dynamic> productList = userProductsData[selectedProduct];

            bool brandExists = productList.any((product) {
              return product['BrandName'] == brandName;
            });

            if (!brandExists) {
              print('Brand not found. Adding new brand to the list.');

              Map<String, dynamic> newBrand = {
                'BrandName': brandName,
                'Date': Timestamp.now(),
              };

              productList.add(newBrand);

              await FirebaseFirestore.instance
                  .collection('Products')
                  .doc(MyHomePage.userId)
                  .update({
                selectedProduct: productList,
              });

              print('Brand name added successfully!');
            } else {
              print('Brand already exists in the list.');
            }
          } else {
            print(
                'Selected product category does not exist. Creating new category.');

            Map<String, dynamic> newProductCategory = {
              selectedProduct: [
                {
                  'BrandName': brandName,
                  'Date': Timestamp.now(),
                }
              ],
            };

            await FirebaseFirestore.instance
                .collection('Products')
                .doc(MyHomePage.userId)
                .set(newProductCategory, SetOptions(merge: true));

            print('New product category created and brand added.');
          }
        } else {
          print('User document not found. Creating new document.');

          Map<String, dynamic> newUserData = {
            selectedProduct: [
              {
                'BrandName': brandName,
                'Date': Timestamp.now(),
              }
            ],
          };

          await FirebaseFirestore.instance
              .collection('Products')
              .doc(MyHomePage.userId)
              .set(newUserData);

          print('User document created and brand added.');
        }
        await updateStreakCount();
        HelperFunctions.hideLoading(context);
      } catch (e) {
        HelperFunctions.hideLoading(context);
        print('Error checking and inserting brand name: $e');
      }
    }

    Future<void> addRoutineStep() async {
      try {
        DateTime today = DateTime.now();
        DateTime startOfDay = DateTime(today.year, today.month, today.day);
        DateTime endOfDay = startOfDay.add(Duration(days: 1));

        QuerySnapshot routineSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(MyHomePage.userId)
            .collection('routines')
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

        if (routineSnapshot.docs.isEmpty) {
          print('No routine found for today. Creating a new routine.');

          RoutineStep newStep = RoutineStep(
            step: selectedProduct,
            time: Timestamp.now(),
            product: productNameController.text,
            imageUrl: "",
          );

          Routine newRoutine = Routine(
            date: Timestamp.now(),
            steps: [newStep],
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(MyHomePage.userId)
              .collection('routines')
              .add(newRoutine.toMap());

          print('New routine created and step added successfully.');
          await checkAndInsertBrandName(productNameController.text);
          return;
        }

        DocumentSnapshot routineDoc = routineSnapshot.docs.first;
        Map<String, dynamic> routineData =
            routineDoc.data() as Map<String, dynamic>;
        Routine routine = Routine.fromMap(routineData);

        RoutineStep newStep = RoutineStep(
          step: selectedProduct,
          time: Timestamp.now(),
          product: productNameController.text,
          imageUrl: "",
        );

        routine.steps.add(newStep);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(MyHomePage.userId)
            .collection('routines')
            .doc(routineDoc.id)
            .update({
          'steps': routine.steps.map((step) => step.toMap()).toList(),
        });
        await checkAndInsertBrandName(productNameController.text);
        print('Routine step added successfully.');
      } catch (e) {
        HelperFunctions.hideLoading(context);
        print('Error adding routine step: $e');
      }
    }

    Future<void> fetchProductList() async {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Products')
            .doc(MyHomePage.userId) // Replace with actual userId
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          if (data.containsKey(selectedProduct)) {
            List<dynamic> productList = data[selectedProduct];

            if (productList.isNotEmpty) {
              print(
                  'Found ${productList.length} products for $selectedProduct.');
              for (var product in productList) {
                productsNamesList.add(product['BrandName']);
                print('Product data: $product');
              }
              productsNamesList = productsNamesList.toSet().toList();
            } else {
              productsNamesList.clear();
              print('No products found for $selectedProduct.');
            }
          } else {
            productsNamesList.clear();
            print('Selected product $selectedProduct not found in document.');
          }
        } else {
          productsNamesList.clear();
          print('No document found for userId ${MyHomePage.userId}');
        }
      } catch (e) {
        productsNamesList.clear();
        print('Error fetching product list: $e');
      }
    }

    if (products.isEmpty) {
      showCompletionDialog(context);
    } else {
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(builder: (context, setState) {
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select a Product',
                            border: OutlineInputBorder(),
                          ),
                          items: products.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            selectedProduct = value ?? 'Select a Product';
                            await fetchProductList();
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a product';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        SearchField<String>(
                          enabled: selectedProduct != 'Select a Product',
                          controller: productNameController,
                          searchInputDecoration: SearchInputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(5)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(5)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(5)),
                            hintText: "Enter Product Name",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                          ),
                          onSuggestionTap: (item) {
                            if (kDebugMode) {
                              print("On Suggestion Tap: ${item.item}");
                            }
                            productNameController.text = item.item ?? "";
                          },
                          suggestions: productsNamesList
                              .map(
                                (e) => SearchFieldListItem<String>(
                                  e,
                                  item: e,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      e,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (selectedProduct != 'Select a Product' &&
                                    productNameController.text.isNotEmpty) {
                                  HelperFunctions.showLoading(context);
                                  await addRoutineStep().then((value) {
                                    Navigator.pop(context);
                                    fetchTodayList();
                                  });
                                } else if (selectedProduct ==
                                    'Select a Product') {
                                  HelperFunctions.showToast(context,
                                      title: "Please Select a Product",
                                      type: toastType.error);
                                } else if (productNameController.text.isEmpty) {
                                  HelperFunctions.showToast(context,
                                      title: "Please Enter Product Name",
                                      type: toastType.error);
                                }
                              },
                              child: Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }));
    }
  }

  List<int> streakData = [];
  int productsLength = 5;

  Future<void> fetchStreakData() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfMonth = DateTime(today.year, today.month, 1);
      DateTime endOfMonth =
          DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1));

      QuerySnapshot routineSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(MyHomePage.userId)
          .collection('routines')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      List<int> streakData = [];
      int todayStreakCount = 0;

      for (var routineDoc in routineSnapshot.docs) {
        var routineData = routineDoc.data() as Map<String, dynamic>;
        Routine routine = Routine.fromMap(routineData);
        List<RoutineStep> routineSteps = routine.steps;

        int completedStepsCount = routineSteps.length;

        if (routine.date.toDate().isAtSameMomentAs(today)) {
          todayStreakCount = completedStepsCount;
        }

        streakData.add(completedStepsCount);
      }

      setState(() {
        this.streakData = streakData;
        // todayStreakDays = todayStreakCount; // Update streak count for today
      });
      overallPercent = calculateOverallStreakPercentage();
    } catch (e) {
      print("Error fetching streak data: $e");
    }
  }

  List<FlSpot> generateFlSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < streakData.length; i++) {
      spots.add(FlSpot(i.toDouble() + 1, streakData[i].toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              "Today's Goal: ${todayStreakDays + 1} streak days",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 130,
              decoration: BoxDecoration(
                  color: const Color(0xffF2E8EB),
                  borderRadius: BorderRadius.circular(11)),
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 10),
                      child: Text(
                        "Streak Days",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      "$todayStreakDays",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 10),
                    child: Text(
                      "Daily Streak",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    "${5 - products.length}",
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Text.rich(TextSpan(children: [
              const TextSpan(
                  text: "Last 30 Days ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              TextSpan(
                  text: "${overallPercent.toStringAsFixed(2)} %",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff088759)))
            ])),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: 6,
                  titlesData: LineTitles.getTitleData(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: const Color(0xff964F66),
                      barWidth: 3.5,
                      dotData: const FlDotData(show: false),
                      spots: generateFlSpots(),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 40,),
            const Text(
              "Keep it up! You're on a roll.",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                onPressed: openDialog,
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xffF2E8EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
