import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approval_pr_department/approval_pr_department_bloc.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approval_pr_list/approval_pr_list_bloc.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approve_pr/approve_pr_bloc.dart';
import 'package:vivakencanaapp/data/repository/approval_pr_repository.dart';
import 'package:vivakencanaapp/utils/string_extension.dart';

class ApprovalSrMenuScreen extends StatelessWidget {
  const ApprovalSrMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log('Access to presentation/approval/approval_sr_menu_screen.dart');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ApprovalPrDepartmentBloc(
                approvalPRRepository: context.read<ApprovalPRRepository>(),
              )..add(GetApprovalPrDepartmentEvent()),
        ),
        BlocProvider(
          create:
              (context) => ApprovalPrListBloc(
                approvalPRRepository: context.read<ApprovalPRRepository>(),
              ),
        ),
        BlocProvider(
          create:
              (context) => ApprovePrBloc(
                approvalPRRepository: context.read<ApprovalPRRepository>(),
              ),
        ),
      ],
      child: ApprovalSrMenuView(),
    );
  }
}

class ApprovalItem {
  final String id;
  final String title;
  final String description;
  final String status;
  final String department;

  ApprovalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.department,
  });
}

class ApprovalSrMenuView extends StatefulWidget {
  const ApprovalSrMenuView({super.key});

  @override
  State<ApprovalSrMenuView> createState() => _ApprovalSrMenuScreenState();
}

class _ApprovalSrMenuScreenState extends State<ApprovalSrMenuView> {
  final PageController _pageController = PageController();
  final List<ScrollController> _scrollControllers = [];
  int _currentPage = 0;
  bool _isAnimated = false;
  final List<String> statuses = ['all', 'pending', 'approved', 'rejected'];
  String? selectedStatus;

  // final dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? startDate;
  DateTime? endDate;
  String? startDateFormatted; // ← disimpan dalam format
  String? endDateFormatted;
  final displayFormat = DateFormat('dd-MM-yyyy'); // untuk UI
  final valueFormat = DateFormat('yyyy-MM-dd');

  String? selectedDepartment;

  @override
  void initState() {
    super.initState();

    startDate = DateTime.now();
    endDate = DateTime.now();

    // ⬇⬇ SAVE FORMAT SAAT PERTAMA KALI
    startDateFormatted = valueFormat.format(startDate!);
    endDateFormatted = valueFormat.format(endDate!);

    selectedStatus = statuses[0];

    _initializeControllers();
    // context.read<ApprovalPrDepartmentBloc>().add(
    //   GetApprovalPrDepartmentEvent(),
    // );
  }

  void _initializeControllers() {
    for (int i = 0; i < 3; i++) {
      _scrollControllers.add(ScrollController());
    }
  }

  List<ApprovalItem> getDummyApprovals() {
    return [
      ApprovalItem(
        id: '1',
        title: 'Approval SR #1',
        description: 'Pengajuan Sales Request 1',
        status: 'pending',
        department: 'Sales',
      ),
      ApprovalItem(
        id: '2',
        title: 'Approval SR #2',
        description: 'Pengajuan Sales Request 2',
        status: 'approved',
        department: 'Finance',
      ),
      ApprovalItem(
        id: '3',
        title: 'approval SR #3',
        description: 'Pengajuan Sales Request 3',
        status: 'rejected',
        department: 'HR',
      ),
      ApprovalItem(
        id: '4',
        title: 'Approval SR #4',
        description: 'Pengajuan Sales Request 4',
        status: 'pending',
        department: 'IT',
      ),
    ];
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  List<ApprovalItem> getFilteredApprovals() {
    final approvals = getDummyApprovals();
    return approvals.where((item) {
      final matchesDepartment =
          selectedDepartment == null || item.department == selectedDepartment;
      final matchesStatus =
          selectedStatus == null || item.status == selectedStatus;
      // Dummy date filter, since ApprovalItem doesn't have date. Adjust if you add date field.
      return matchesDepartment && matchesStatus;
    }).toList();
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final initialDate =
        isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          startDateFormatted = valueFormat.format(picked);
        } else {
          endDate = picked;
          endDateFormatted = valueFormat.format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvals = getFilteredApprovals();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Approval PR',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BlocConsumer<
                          ApprovalPrDepartmentBloc,
                          ApprovalPrDepartmentState
                        >(
                          listener: (context, state) {},
                          builder: (BuildContext context, state) {
                            if (state is ApprovalPrDepartmentInitial ||
                                state is ApprovalPrDepartmentLoadingState) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (state is ApprovalPrDepartmentFailureState) {
                              return Center(child: Text(state.message));
                            }
                            if (state is ApprovalPrDepartmentSuccessState) {
                              selectedDepartment = state.data.first.deptId;
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue:
                                        selectedDepartment ??
                                        state.data.first.deptId,
                                    decoration: const InputDecoration(
                                      labelText: 'Department',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      labelStyle: TextStyle(fontSize: 12),
                                    ),
                                    // 👇 Mengatasi overflow di selected value
                                    selectedItemBuilder: (context) {
                                      return state.data.map((dept) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            dept.descr,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        );
                                      }).toList();
                                    },

                                    // 👇 Mengatasi overflow di dropdown item
                                    items:
                                        state.data
                                            .map(
                                              (dept) => DropdownMenuItem(
                                                value: dept.deptId,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        dept.descr,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDepartment = value;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: statuses[0],
                          decoration: const InputDecoration(
                            labelText: 'Approve Status',
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelStyle: TextStyle(fontSize: 12),
                          ),
                          items: [
                            ...statuses.map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status.capitalize(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelStyle: TextStyle(fontSize: 12),
                            ),
                            child: Text(
                              startDate != null
                                  ? displayFormat.format(
                                    startDate!,
                                  ) // ⬅ tampil dd-MM-yyyy
                                  : 'Pilih tanggal',
                              style: TextStyle(
                                color:
                                    startDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelStyle: TextStyle(fontSize: 12),
                            ),
                            child: Text(
                              endDate != null
                                  ? displayFormat.format(
                                    endDate!,
                                  ) // ⬅ tampil dd-MM-yyyy
                                  : 'Pilih tanggal',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    endDate != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Cari'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        print(selectedDepartment);
                        print(selectedStatus);
                        print(startDateFormatted);
                        print(endDateFormatted);
                        setState(() {
                          // Trigger filter, jika nanti pakai API, panggil di sini
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: approvals.length,
                itemBuilder: (context, index) {
                  final approval = approvals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getStatusColor(approval.status),
                        child: Text(approval.title.substring(0, 2)),
                      ),
                      title: Text(approval.title),
                      subtitle: Text(
                        '${approval.description}\nDept: ${approval.department}',
                      ),
                      trailing: Text(
                        approval.status,
                        style: TextStyle(
                          color: getStatusColor(approval.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // TODO: Navigasi ke detail approval jika diperlukan
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
