import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../Screens/ProfilePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Documentation extends StatefulWidget {
  // FOR TOKEN -----------------------------
  final token;
  Documentation({Key? key, this.token}) : super(key: key);
  // -----------------------------------------

  @override
  _DocumentationState createState() => _DocumentationState();
}

class _DocumentationState extends State<Documentation>
    with SingleTickerProviderStateMixin {
  late String userId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? suffix;

  late String selectedTypeOfDocuments;
  List<String> TypeOfDocumentsOptions = [
    'CertificateOfIndigency',
    'BusinessClearance',
    'BarangayID',
    'InstallationPermit',
    'ConstructionPermit',
    'BarangayCertificate',
  ];
  String? selectedDate;
  final dateController = TextEditingController();

  final reasonOfRequestController = TextEditingController();

  String? _selectedPaymentMethod;
  bool isGcashPayment = false;
  bool iscashPayment = false;
  bool showBusinessNameField = false;
  bool showBusinessAddressField = false;
  final referenceController = TextEditingController();
  final fileUploadController = TextEditingController();
  String? selectedFilePath;
  final addressController = TextEditingController();
  final businessNameController = TextEditingController();
  final businessAddressController = TextEditingController();
  final residentNameController = TextEditingController();

  @override
  // Function to handle dropdowns selection
  void initState() {
    super.initState();
    selectedTypeOfDocuments = TypeOfDocumentsOptions[0];

    if (widget.token != null) {
      // Decode the JWT token and extract the user ID
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      userId = jwtDecodedToken['_id'];
      firstName = jwtDecodedToken['firstName'];
      middleName = jwtDecodedToken['middleName'];
      lastName = jwtDecodedToken['lastName'];
      suffix = jwtDecodedToken['suffix'];
      selectedTypeOfDocuments = TypeOfDocumentsOptions[0];
      residentNameController.text = "$lastName, $firstName, $middleName";
    }
  }

  // -------------- DATABASE --------------------
  void requestDocument() async {
    var defaultStatus = "NEW";

    var regBody = {
      "residentName": residentNameController.text,
      "userId": userId,
      "typeOfDocument": selectedTypeOfDocuments,
      "businessName": businessNameController.text,
      "address": addressController.text,
      "pickUpDate": dateController.text,
      "reasonOfRequest": reasonOfRequestController.text,
      "modeOfPayment": _selectedPaymentMethod,
      "reference": referenceController.text,
      "status": defaultStatus,
    };
    print('Request Body: $regBody'); // Debug log to check the request payload

    var url = Uri.parse(
        'https://dbarangay-mobile-e5o1.onrender.com/requestDocument'); //HOME IP ADDRESS

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print(
          'Response: $jsonResponse'); // Debug log to check the response from the server
      if (jsonResponse['status'] == 'success') {
        showSuccessDialog();
      } else {
        print('Request failed with an error.');
        // Handle any specific error responses here
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      // Handle any HTTP error responses here
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Success',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Request submitted successfully.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 95, 170),
      appBar: AppBar(
        title: const Text('Request Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // ------------------------------------------- RESIDENT NAME  ---------------------------
            const SizedBox(height: 16.0),
            TextFormField(
              controller: residentNameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Resident Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the resident name';
                }
                return null;
              },
            ),

            // -------------------------------------------TYPE OF DOCUMENTS ---------------------------
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'TYPE OF DOCUMENTS',
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              value: selectedTypeOfDocuments,
              icon: const Icon(Icons.arrow_drop_down),
              items: TypeOfDocumentsOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTypeOfDocuments = value!;
                  if (selectedTypeOfDocuments == 'BusinessClearance') {
                    addressController.text = '';
                  } else {
                    addressController.text = '';
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Type of Documents is Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

// BUSINESS NAME
            Visibility(
              visible: selectedTypeOfDocuments == 'BusinessClearance',
              child: SizedBox(
                width: 500,
                child: TextFormField(
                  controller: businessNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Business Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the business name';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),

// USER ADDRESS
            SizedBox(
              width: 500,
              child: TextFormField(
                controller: addressController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: selectedTypeOfDocuments == 'BusinessClearance'
                      ? 'Business Address'
                      : 'Complete Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return selectedTypeOfDocuments == 'BusinessClearance'
                        ? 'Please enter the business address'
                        : 'Please enter the complete address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),

// DATE OF PICKUP
            SizedBox(
              width: 550,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color.fromARGB(255, 245, 245, 245),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final currentDate = DateTime.now();
                      final lastSelectableDate =
                          currentDate.add(const Duration(days: 60));
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: currentDate,
                        lastDate: lastSelectableDate,
                      );

                      if (pickedDate != null) {
                        setState(() {
                          dateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                    child: ListTile(
                      title: const Text(
                        'Date of Pick-up',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      trailing: Text(
                        dateController.text.isNotEmpty
                            ? dateController.text
                            : 'Select date',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),

// REASON FOR REQUESTING
            const SizedBox(height: 16.0),
            SizedBox(
              width: 500,
              child: TextFormField(
                controller: reasonOfRequestController,
                maxLines: 5,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Reason for Requesting',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
            ),

// PAYMENT METHOD CHECKBOX
            const SizedBox(height: 16.0),
            SizedBox(
              width: 500,
              child: RadioListTile<String>(
                title: const Text(
                  'Pay with Cash',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 'Cash',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),

            Container(
              child: RadioListTile<String>(
                title: const Text(
                  'Pay with GCash',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                value: 'GCash',
                groupValue: _selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),

// ------------------------------------------- PAYMENT REFERENCE NUMBER ---------------------------
            Visibility(
              visible: _selectedPaymentMethod == 'GCash',
              child: SizedBox(
                width: 500,
                child: TextFormField(
                  controller: referenceController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Payment Reference Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the payment reference number';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // -------------------------------------------  SUBMIT BUTTON ---------------------------
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: ElevatedButton(
                onPressed: () {
                  requestDocument();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 9, 33, 152)),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
