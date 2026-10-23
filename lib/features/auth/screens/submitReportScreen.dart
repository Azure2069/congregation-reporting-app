import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/reports.dart';
import '../../../core/api/users/users_api.dart';
import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/service_assignments/service_assignments_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_labels.dart';

class SubmitReportscreen extends ConsumerStatefulWidget {
  const SubmitReportscreen({super.key});

  @override
  ConsumerState<SubmitReportscreen> createState() => _SubmitReportscreen();
}

class _SubmitReportscreen extends ConsumerState<SubmitReportscreen> {
  bool? _participated = false;
  late final TextEditingController _bibleStudyTextController;
  late final TextEditingController _hoursTextController;
  bool isLoading = false;

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
  }

  @override
  void dispose() {
    _bibleStudyTextController.dispose();
    _hoursTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userasync = ref.watch(getcurrentUserProvider);
    final reportingMonth = DateLabels.currentReportingMonth();
    final _serviceType = [];

    return Scaffold(
      appBar: AppBar(title: Text('Submit Monthly Report')),
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
                      DateLabels.monthYear(reportingMonth),
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
                    Column(
                      children: [
                        userasync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) =>
                              const Text("Unable to load user"),
                          data: (user) {
                            final assignmentsAsync = ref.watch(
                              checkServiceAssignmentProvider((
                                user['id'],
                                reportingMonth,
                              )),
                            );
                            return assignmentsAsync.when(
                              loading: () => CircularProgressIndicator(),
                              error: (error, stackTrace) =>
                                  Text("unable to load assignment"),
                              data: (assignments) {
                                if (assignments.isEmpty) {
                                  return const Text(
                                    "No Assignment Found for this month",
                                  );
                                }
                                for (int i = 0; i < assignments.length; i++) {
                                  _serviceType.add(
                                    assignments[i]['service_type'],
                                  );
                                }

                                if (_serviceType.contains(
                                      'auxiliary_pioneer',
                                    ) ||
                                    _serviceType.contains("regular_pioneer")) {
                                  return Column(
                                    children: [
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
                                          labelText:
                                              "Enter Number of Bible Studies",
                                          prefixIcon: Icon(
                                            Icons.schedule_outlined,
                                          ),
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
                                  );
                                }

                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(
                                        "Participated in the ministry?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      value: _participated,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (bool? newVal) {
                                        setState(() {
                                          _participated = newVal ?? false;
                                          if (!_participated!) {
                                            _bibleStudyTextController.clear();
                                          }
                                        });
                                      },
                                    ),
                                    if (_participated!) ...[
                                      TextFormField(
                                        controller: _bibleStudyTextController,
                                        decoration: InputDecoration(
                                          labelText:
                                              "Enter Number of Bible Studies",
                                          prefixIcon: Icon(
                                            Icons.schedule_outlined,
                                          ),
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
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if ((!_formKey.currentState!.validate())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please correct the highlighted fields.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);

                                  try {
                                    final int? bibleStudies = int.tryParse(
                                      _bibleStudyTextController.text,
                                    );
                                    final int? hours = int.tryParse(
                                      _hoursTextController.text,
                                    );
                                    final reportSent = await ref
                                        .read(reportsApiProvider)
                                        .addReport(
                                          bibleStudies,
                                          hours,
                                          _participated!,
                                          reportingMonth,
                                        );

                                    final reportStatus = reportSent['status'];
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Successfully submitted.',
                                          ),
                                        ),
                                      );
                                    }
                                    context.go('/home');
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to submit Report\n Contact Your Group Overseer.',
                                          ),
                                        ),
                                      );


                                      //will be removed soon *************
                                      context.go('/allMembers');
                                       //will be removed soon *************just for testing
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(isLoading ? 'Submitting...' : 'Submit'),
                        ),
                      ],
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



















/*
                    
                    userasync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stackTrace) =>
                          const Text("unable to load user"),
                      data: (user) {
                        final serviceAssignment = ref.read(
                          getAssignmentsProvider,
                        );
                        

                        final service_type = ref.watch(
                          checkServiceAssignmentProvider(
                            user['id'],
                            reportingMonth,
                          ),
                        );

                        for(int i=0; i<service_type.length; i++){
                          if (service_type[i]['service_type']=='auxiliary_pioneer'){
                            _publisherType=
                          }
                        }
                        return service_type.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stackTrace) =>
                              const Text("unable to load service Type"),
                          data: (_publisherType) {
                            
                          },
                        );
                      },
                    ),
                    */
                    
  


/*

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
                      onChanged: (String? newVal) {
                        setState(() {
                          _hoursTextController.clear();
                          _bibleStudyTextController.clear();
                          _participated = false;
                          _publisherType = newVal;
                        });
                      },
                    ),
 



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
 
 
 */