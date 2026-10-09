import 'package:flutter/material.dart';

/// Represents a student support ticket and administrative resolution.
class SupportTicket {
  final String id;
  final String ticketNumber;
  final String category;
  final String subject;
  final String message;
  final String status;
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
}
