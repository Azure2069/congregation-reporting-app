import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/reports.dart';
import '../../../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitReportscreen extends ConsumerStatefulWidget {
  final Report? updateReport;

  const SubmitReportscreen({super.key, this.updateReport});

  @override
  ConsumerState<SubmitReportscreen> createState() => _SubmitReportscreen();
}

class _SubmitReportscreen extends ConsumerState<SubmitReportscreen> {
  bool _participated = false;
  late final TextEditingController _bibleStudyTextController;
  late final TextEditingController _hoursTextController;
  String? _publisherType;
  DateTime? _reportingMonth;
  final _formKey = GlobalKey<FormState>();

  static const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _bibleStudyTextController = TextEditingController();
    _hoursTextController = TextEditingController();
    if (widget.updateReport != null) {
      _publisherType = widget.updateReport!.publisherType;
      _reportingMonth = widget.updateReport!.reportingMonth;
      _bibleStudyTextController.text =
          widget.updateReport?.bibleStudies.toString() ?? '';
      _hoursTextController.text = widget.updateReport?.hours.toString() ?? '';
      _participated = widget.updateReport?.participated ?? false;
    }
  }

  @override
  void dispose() {
    _bibleStudyTextController.dispose();
    _hoursTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.updateReport != null
              ? 'Update Monthly Report'
              : 'Submit Monthly Report',
        ),
      ),
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
                            color: const Color(0xFF222121),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${months[DateTime.now().month - 1]} ${DateTime.now().year.toString()}",
                      style: const TextStyle(color: Color(0xFF555555)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.badge_outlined, color: Color(0xFF529FCB)),
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
                          final String publisherType = _publisherType!;
                          final int? hours = int.tryParse(
                            _hoursTextController.text,
                          );
                          final int? bibleStudies = int.tryParse(
                            _bibleStudyTextController.text,
                          );
                          final bool participated = _participated;
                          Report? report;

                          if (publisherType == "Publisher" && !participated) {
                            report = Report(

                              userId: "user123", // Replace with actual
                              participated: false,
                              bibleStudies: null,
                              hours: null,
                              publisherType: publisherType,
                              reportingMonth: DateTime(2026, 9),
                              submittedAt: DateTime.now(),
                              status: ReportStatus.submitted,
                              originalSubmissionTime: DateTime.now(),
                            );
                          } else if (publisherType == "Publisher" &&
                              participated) {
                            report = Report(
                              userId: user[1].userId,
                              participated: participated,
                              publisherType: publisherType,
                              hours: null,
                              bibleStudies: bibleStudies,
                              submittedAt: DateTime.now(),
                              reportingMonth: DateTime(2026, 9),
                              status: ReportStatus.submitted,
                              originalSubmissionTime: DateTime.now(),
                            );
                          } else if (publisherType == "Regular Pioneer" ||
                              publisherType == 'Auxiliary Pioneer') {
                            report = Report(
                              userId: user[1].userId,
                              participated: null,
                              publisherType: publisherType,
                              hours: hours,
                              bibleStudies: bibleStudies,
                              submittedAt: DateTime.now(),
                              reportingMonth: DateTime(2026, 9),
                              status: ReportStatus.submitted,
                              originalSubmissionTime: DateTime.now(),
                            );
                          }
                          if (widget.updateReport != null) {
                            final updateSuccess = ref
                                .read(reportProvider.notifier)
                                .updateReport(widget.updateReport!, report!);
                            if (!updateSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Cannot update report for ${months[report.reportingMonth.month - 1]} ${report.reportingMonth.year}. You can only update within 24 hours of submission.",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Report Updated")),
                              );
                              context.push('/reportHistory');
                            }
                          } else {
                            final success = ref
                                .read(reportProvider.notifier)
                                .addReport(report!);

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Report for ${months[report.reportingMonth.month - 1]} ${report.reportingMonth.year} already submitted",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Submitted")),
                              );
                              context.push(
                                '/reportHistory',
                              ); // Navigate to ReportHistoryScreen
                            }
                          }
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
