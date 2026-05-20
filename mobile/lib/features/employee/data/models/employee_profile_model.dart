class EmployeeProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? zone;
  final String? shiftStart;
  final String? shiftEnd;
  final bool dutyStatus;

  EmployeeProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.zone,
    this.shiftStart,
    this.shiftEnd,
    this.dutyStatus = true,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      zone: json['zone'] as String?,
      shiftStart: json['shift_start'] as String?,
      shiftEnd: json['shift_end'] as String?,
      dutyStatus: json['duty_status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'zone': zone,
      'shift_start': shiftStart,
      'shift_end': shiftEnd,
      'duty_status': dutyStatus,
    };
  }
}
