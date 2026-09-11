import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/reports.dart';

class SubmitReportscreen extends StatefulWidget {
  const SubmitReportscreen({super.key});

  @override
  State<SubmitReportscreen> createState() => _SubmitReportscreen();
}

class _SubmitReportscreen extends State<SubmitReportscreen> {
  bool _participated = false;
  late final TextEditingController _bibleStudyTextController;
  late final TextEditingController _hoursTextController;
  String? _publisherType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _bibleStudyTextController = TextEditingController();
    _hoursTextController = TextEditingController();
  }

  @override
  void dispose() {
    _bibleStudyTextController.dispose();
    _hoursTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submit monthly report",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF173B38),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "January 2025",
                      style: TextStyle(color: Color(0xFF647773)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.badge_outlined, color: Color(0xFF176B62)),
                          SizedBox(width: 12),
                          Text(
                            "Baptized Publisher",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _publisherType,
                      hint: const Text("Select an Option"),
                      items: [
                        DropdownMenuItem(
                          value: 'Publisher',
                          child: Text("Publisher"),
                        ),
                        DropdownMenuItem(
                          value: "Auxiliary Pioneer",
                          child: Text("Auxiliary Pioneer"),
                        ),
                        DropdownMenuItem(
                          value: "Regular Pioneer",
                          child: Text("Regular Pioneer"),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a publisher type";
                        }
                        return null;
                      },
                      onChanged: (String? new_Val) {
                        setState(() {
                          _hoursTextController.clear();
                          _bibleStudyTextController.clear();
                          _participated = false;
                          _publisherType = new_Val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_publisherType == "Publisher") ...[
                      CheckboxListTile(
                        title: Text(
                          "Participated in the ministry?",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _participated,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? newVal) {
                          setState(() {
                            _participated = newVal ?? false;
                            if (!_participated) {
                              _bibleStudyTextController.clear();
                            }
                          });
                        },
                      ),
                      if (_participated) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bibleStudyTextController,
                          decoration: InputDecoration(
                            labelText: "Enter Number of Bible Studies",
                            prefixIcon: Icon(Icons.schedule_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Number of Bible Studies";
                            }
                            final number = int.tryParse(value);
                            if (number == null || number < 0) {
                              return "Please enter a valid number of Bible Studies";
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                    if (_publisherType == 'Auxiliary Pioneer' ||
                        _publisherType == 'Regular Pioneer') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _hoursTextController,
                        decoration: InputDecoration(
                          labelText: "Enter Number of Hours",
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Number of Hours";
                          }
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return "Please enter a valid number of Hours";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _bibleStudyTextController,
                        decoration: InputDecoration(
                          labelText: "Enter Number of Bible Studies",
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Number of Bible Studies";
                          }
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return "Please enter a valid number of Bible Studies";
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final Report report = Report(participated: false, publisherType: null, hours: null, bibleStudies: null);

                          String? publisherType = _publisherType!;
                          int? hours = int.tryParse(_hoursTextController.text);
                          int? bibleStudies = int.tryParse(
                            _bibleStudyTextController.text,
                          );
                          bool participated = _participated;
                          if (publisherType == "Publisher" && !participated) {
                            final report = Report(
                              participated: false,
                              bibleStudies: null,
                              hours: null,
                              publisherType: publisherType,
                            );
                          } else if (publisherType == "Publisher" &&
                              participated) {
                            final report = Report(
                              participated: participated,
                              publisherType: publisherType,
                              hours: null,
                              bibleStudies: bibleStudies,
                            );
                          } else if (publisherType == "Regular Pioneer" ||
                              publisherType == 'Auxiliary Pioneer') {
                            final report = Report(
                              participated: true,
                              publisherType: publisherType,
                              hours: hours,
                              bibleStudies: bibleStudies,
                            );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Submitted")),
                          );
                          context.go('/reportHistory');
                        }
                      },
                      child: Text("Submit Report"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
