import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/api/users/users_api.dart';
import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/service_assignments/service_assignments_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_labels.dart';

class SubmitReportscreen extends ConsumerStatefulWidget {
  final Map? report;
  const SubmitReportscreen({super.key, this.report});

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
    final report = widget.report;
    _bibleStudyTextController = TextEditingController(
      text: report?['bible_studies']?.toString() ?? '',
    );
    _hoursTextController = TextEditingController(
      text: report?['hours']?.toString() ?? '',
    );
    _participated = report == null ? false : report['participated'] as bool?;
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
    final isEditing = widget.report != null;
    final reportingMonth = isEditing
        ? DateTime.parse(widget.report!['reporting_month'].toString())
        : DateLabels.currentReportingMonth();
    final serviceType = widget.report?['publisher_type']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Update Monthly Report' : 'Submit Monthly Report',
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
                      isEditing
                          ? "Update monthly report"
                          : "Submit monthly report",
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
                        color: const Color(0xFFEDFCE9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFF003C33),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing
                                ? _formatServiceType(serviceType ?? '')
                                : 'Service assignment for this month',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        if (isEditing)
                          _buildFieldsForServiceType(serviceType ?? '')
                        else
                          userasync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stackTrace) =>
                                const Text("Unable to load user"),
                            data: (user) {
                              final assignmentsAsync = ref.watch(
                                checkServiceAssignmentProvider((
                                  user['id'] as int,
                                  reportingMonth,
                                )),
                              );
                              return assignmentsAsync.when(
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (error, stackTrace) =>
                                    const Text("Unable to load assignment"),
                                data: (assignments) {
                                  if (assignments is! List ||
                                      assignments.isEmpty) {
                                    return const Text(
                                      "No assignment found for this month.",
                                    );
                                  }
                                  final serviceTypes = assignments
                                      .whereType<Map>()
                                      .map(
                                        (assignment) =>
                                            assignment['service_type'],
                                      )
                                      .whereType<String>()
                                      .toList();
                                  final pioneerType = serviceTypes.firstWhere(
                                    (type) =>
                                        type == 'auxiliary_pioneer' ||
                                        type == 'regular_pioneer',
                                    orElse: () => 'publisher',
                                  );
                                  return _buildFieldsForServiceType(
                                    pioneerType,
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
                                    int? bibleStudies = int.tryParse(
                                      _bibleStudyTextController.text,
                                    );
                                    final int? hours = int.tryParse(
                                      _hoursTextController.text,
                                    );
                                    final api = ref.read(reportsApiProvider);
                                    if (isEditing) {
                                      final reportId = widget.report!['id'];
                                      if (reportId is! int) {
                                        throw StateError(
                                          'The selected report has no valid ID.',
                                        );
                                      }
                                      final isPublisher =
                                          serviceType?.toLowerCase() ==
                                          'publisher';
                                      if (isPublisher &&
                                          _participated != true) {
                                        bibleStudies = null;
                                      }
                                      await api.updateReport(
                                        reportId,
                                        hours,
                                        bibleStudies,
                                        // The backend report model stores
                                        // participation as a required bool,
                                        // including for pioneer reports. Keep
                                        // the existing value when that field
                                        // is not editable in this form.
                                        _participated ?? false,
                                      );
                                      ref.invalidate(getMyReportsProvider);
                                      final userId = widget.report!['user_id'];
                                      if (userId is int) {
                                        ref.invalidate(
                                          getReportsbyIdProvider(userId),
                                        );
                                      }
                                    } else {
                                      await api.addReport(
                                        hours,
                                        bibleStudies,
                                        _participated ?? false,
                                        reportingMonth,
                                      );
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? 'Report updated.'
                                                : 'Successfully submitted.',
                                          ),
                                        ),
                                      );
                                    }
                                    context.go(
                                      isEditing ? '/reportHistory' : '/home',
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      final detail = e is DioException
                                          ? e.response?.data is Map
                                                ? (e.response!.data
                                                          as Map)['detail']
                                                      ?.toString()
                                                : null
                                          : null;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            detail != null && detail.isNotEmpty
                                                ? detail
                                                : isEditing
                                                ? 'Unable to update report. Please try again.'
                                                : 'Unable to submit report. Contact your group overseer.',
                                          ),
                                        ),
                                      );
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
                          label: Text(
                            isLoading
                                ? (isEditing ? 'Updating...' : 'Submitting...')
                                : (isEditing ? 'Update report' : 'Submit'),
                          ),
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

  Widget _buildFieldsForServiceType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'auxiliary_pioneer':
      case 'regular_pioneer':
        return Column(
          children: [
            _buildNumberField(
              controller: _hoursTextController,
              label: 'Enter Number of Hours',
              fieldName: 'Hours',
              icon: Icons.timer,
            ),
            const SizedBox(height: 10),
            _buildNumberField(
              controller: _bibleStudyTextController,
              label: 'Enter Number of Bible Studies',
              fieldName: 'Bible studies',
              icon: Icons.schedule_outlined,
            ),
          ],
        );
      case 'publisher':
        return Column(
          children: [
            CheckboxListTile(
              title: const Text(
                'Participated in the ministry?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              value: _participated ?? false,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _participated = value ?? false;
                  if (_participated != true) {
                    _bibleStudyTextController.clear();
                  }
                });
              },
            ),
            if (_participated == true)
              _buildNumberField(
                controller: _bibleStudyTextController,
                label: 'Enter Number of Bible Studies',
                fieldName: 'Bible studies',
                icon: Icons.schedule_outlined,
              ),
          ],
        );
      default:
        return const Text('This report has an unsupported publisher type.');
    }
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String fieldName,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $fieldName.';
        }
        final number = int.tryParse(value);
        if (number == null || number < 0) {
          return 'Enter a valid non-negative number for $fieldName.';
        }
        return null;
      },
    );
  }
}

String _formatServiceType(String serviceType) {
  switch (serviceType.toLowerCase()) {
    case 'publisher':
      return 'Publisher';
    case 'auxiliary_pioneer':
      return 'Auxiliary Pioneer';
    case 'regular_pioneer':
      return 'Regular Pioneer';
    default:
      return serviceType;
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
