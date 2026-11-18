import 'package:flutter/material.dart';

/// Represents a student support ticket and administrative resolution.
class SupportTicket {
  final String id;
  final String ticketNumber;
  final String category;
  final String subject;
  final String message;
  final String status;
  final String priority;
  final String? adminReply;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.subject,
    required this.message,
    required this.status,
    this.priority = 'MEDIUM',
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['pk'] ?? json['uuid'] ?? '';
    final rawStatus = (json['status'] ?? json['ticket_status'] ?? 'OPEN')
        .toString()
        .toUpperCase()
        .replaceAll(' ', '_');

    final rawPriority = (json['priority'] ?? json['priority_level'] ?? 'MEDIUM')
        .toString()
        .toUpperCase()
        .replaceAll(' ', '_');

    // Handle all potential variations of admin reply from backend
    final rawReply = json['admin_reply'] ??
        json['admin_response'] ??
        json['reply'] ??
        json['response'] ??
        json['resolution'] ??
        json['admin_comment'] ??
        json['admin_notes'];

    final cat = json['category'] ??
        json['query_type'] ??
        json['category_name'] ??
        json['type'] ??
        'General Query';

    final ticketNum = json['ticket_number'] ??
        json['ticket_id'] ??
        json['number'] ??
        (rawId.toString().isNotEmpty ? rawId.toString() : 'TICK');

    return SupportTicket(
      id: rawId.toString(),
      ticketNumber: ticketNum.toString(),
      category: cat.toString(),
      subject: (json['subject'] ?? json['title'] ?? 'No Subject').toString(),
      message: (json['message'] ?? json['description'] ?? json['query'] ?? '').toString(),
      status: rawStatus,
      priority: rawPriority,
      adminReply: rawReply != null && rawReply.toString().trim().isNotEmpty
          ? rawReply.toString().trim()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'category': category,
      'subject': subject,
      'message': message,
      'status': status,
      'priority': priority,
      if (adminReply != null) 'admin_reply': adminReply,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  SupportTicket copyWith({
    String? id,
    String? ticketNumber,
    String? category,
    String? subject,
    String? message,
    String? status,
    String? priority,
    String? adminReply,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the ticket has been resolved or closed.
  bool get isResolved => status == 'RESOLVED' || status == 'CLOSED';

  /// Whether the ticket is in progress.
  bool get isInProgress => status == 'IN_PROGRESS' || status == 'INPROGRESS';

  /// Human-readable status label.
  String get statusDisplay {
    switch (status) {
      case 'RESOLVED':
        return 'Resolved';
      case 'CLOSED':
        return 'Closed';
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return 'In Progress';
      case 'PENDING':
        return 'Pending';
      case 'OPEN':
      default:
        return 'Open';
    }
  }

  /// Color palette for status badge.
  Color get statusTextColor {
    if (isResolved) return const Color(0xFF15803D); // Emerald Green
    if (isInProgress) return const Color(0xFF1D4ED8); // Royal Blue
    return const Color(0xFFD97706); // Amber
  }

  Color get statusBgColor {
    if (isResolved) return const Color(0xFFDCFCE7); // Light Green
    if (isInProgress) return const Color(0xFFDBEAFE); // Light Blue
    return const Color(0xFFFEF3C7); // Light Amber
  }

  Color get statusBorderColor {
    if (isResolved) return const Color(0xFFBBF7D0);
    if (isInProgress) return const Color(0xFFBFDBFE);
    return const Color(0xFFFDE68A);
  }

  IconData get statusIcon {
    if (isResolved) return Icons.check_circle_rounded;
    if (isInProgress) return Icons.sync_rounded;
    return Icons.access_time_filled_rounded;
  }

  /// Normalized priority key (LOW, MEDIUM, HIGH, URGENT).
  String get normalizedPriority {
    final upper = priority.toUpperCase();
    if (upper.contains('URGENT')) return 'URGENT';
    if (upper.contains('HIGH')) return 'HIGH';
    if (upper.contains('LOW')) return 'LOW';
    return 'MEDIUM';
  }

  /// Human-readable priority label.
  String get priorityDisplay {
    switch (normalizedPriority) {
      case 'URGENT':
        return 'Urgent';
      case 'HIGH':
        return 'High';
      case 'LOW':
        return 'Low';
      case 'MEDIUM':
      default:
        return 'Medium';
    }
  }

  /// Color palette for priority badge.
  Color get priorityTextColor {
    switch (normalizedPriority) {
      case 'URGENT':
        return const Color(0xFFDC2626); // Crimson Red
      case 'HIGH':
        return const Color(0xFFEA580C); // Deep Orange
      case 'LOW':
        return const Color(0xFF0284C7); // Sky Blue
      case 'MEDIUM':
      default:
        return const Color(0xFFD97706); // Warm Amber
    }
  }

  Color get priorityBgColor {
    switch (normalizedPriority) {
      case 'URGENT':
        return const Color(0xFFFEE2E2);
      case 'HIGH':
        return const Color(0xFFFFEDD5);
      case 'LOW':
        return const Color(0xFFE0F2FE);
      case 'MEDIUM':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color get priorityBorderColor {
    switch (normalizedPriority) {
      case 'URGENT':
        return const Color(0xFFFECACA);
      case 'HIGH':
        return const Color(0xFFFED7AA);
      case 'LOW':
        return const Color(0xFFBAE6FD);
      case 'MEDIUM':
      default:
        return const Color(0xFFFDE68A);
    }
  }

  IconData get priorityIcon {
    switch (normalizedPriority) {
      case 'URGENT':
        return Icons.priority_high_rounded;
      case 'HIGH':
        return Icons.arrow_upward_rounded;
      case 'LOW':
        return Icons.arrow_downward_rounded;
      case 'MEDIUM':
      default:
        return Icons.remove_rounded;
    }
  }
}
