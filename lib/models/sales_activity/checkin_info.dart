import 'dart:convert';

class CheckinInfo {
  final String stat;
  final String status;
  final String message;
  CheckinInfo({
    required this.stat,
    required this.status,
    required this.message,
  });

  CheckinInfo copyWith({String? stat, String? status, String? message}) {
    return CheckinInfo(
      stat: stat ?? this.stat,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {'stat': stat, 'status': status, 'message': message};
  }

  factory CheckinInfo.fromMap(Map<String, dynamic> map) {
    return CheckinInfo(
      stat: map['stat'] ?? '',
      status: map['status'] ?? '',
      message: map['message'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CheckinInfo.fromJson(String source) =>
      CheckinInfo.fromMap(json.decode(source));

  @override
  String toString() =>
      'CheckinInfo(stat: $stat, status: $status, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckinInfo &&
        other.stat == stat &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => stat.hashCode ^ status.hashCode ^ message.hashCode;
}
