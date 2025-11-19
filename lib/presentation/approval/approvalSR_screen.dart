import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class ApprovalSRScreen extends StatefulWidget {
  const ApprovalSRScreen({super.key});

  @override
  State<ApprovalSRScreen> createState() => _ApprovalSRScreenState();
}

class _ApprovalSRScreenState extends State<ApprovalSRScreen> {
  String? selectedDepartment;
  String? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> departments = ['Sales', 'Finance', 'HR', 'IT'];
  final List<String> statuses = ['Pending', 'Approved', 'Rejected'];

  List<ApprovalItem> getDummyApprovals() {
    return [
      ApprovalItem(
        id: '1',
        title: 'Approval SR #1',
        description: 'Pengajuan Sales Request 1',
        status: 'Pending',
        department: 'Sales',
      ),
      ApprovalItem(
        id: '2',
        title: 'Approval SR #2',
        description: 'Pengajuan Sales Request 2',
        status: 'Approved',
        department: 'Finance',
      ),
      ApprovalItem(
        id: '3',
        title: 'Approval SR #3',
        description: 'Pengajuan Sales Request 3',
        status: 'Rejected',
        department: 'HR',
      ),
      ApprovalItem(
        id: '4',
        title: 'Approval SR #4',
        description: 'Pengajuan Sales Request 4',
        status: 'Pending',
        department: 'IT',
      ),
    ];
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  List<ApprovalItem> getFilteredApprovals() {
    final approvals = getDummyApprovals();
    return approvals.where((item) {
      final matchesDepartment = selectedDepartment == null || item.department == selectedDepartment;
      final matchesStatus = selectedStatus == null || item.status == selectedStatus;
      // Dummy date filter, since ApprovalItem doesn't have date. Adjust if you add date field.
      return matchesDepartment && matchesStatus;
    }).toList();
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
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
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvals = getFilteredApprovals();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Approval List',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          ...departments.map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Approve Status',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          ...statuses.map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              )),
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
                          ),
                          child: Text(
                            startDate != null ? dateFormat.format(startDate!) : 'Pilih tanggal',
                            style: TextStyle(
                              color: startDate != null ? Colors.black : Colors.grey,
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
                          ),
                          child: Text(
                            endDate != null ? dateFormat.format(endDate!) : 'Pilih tanggal',
                            style: TextStyle(
                              color: endDate != null ? Colors.black : Colors.grey,
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(approval.status),
                      child: Text(approval.title.substring(0, 2)),
                    ),
                    title: Text(approval.title),
                    subtitle: Text('${approval.description}\nDept: ${approval.department}'),
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
    );
  }
}