import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/data/models/support_ticket_model.dart';

void main() {
  group('SupportTicket Model Tests', () {
    test('parses support ticket with admin reply and status accurately', () {
      final json = {
        'id': 'tick-1001',
        'ticket_number': 'TICK-1001',
        'category': 'Technical Issue / App Crash',
        'subject': 'App stops when playing video',
        'message': 'Video screen crashes on module 3',
        'status': 'RESOLVED',
        'admin_reply': 'We have fixed the video streaming issue in the latest update.',
        'created_at': '2026-10-09T14:30:00Z',
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, 'tick-1001');
      expect(ticket.ticketNumber, 'TICK-1001');
      expect(ticket.category, 'Technical Issue / App Crash');
      expect(ticket.subject, 'App stops when playing video');
      expect(ticket.status, 'RESOLVED');
      expect(ticket.isResolved, isTrue);
      expect(ticket.isInProgress, isFalse);
      expect(ticket.statusDisplay, 'Resolved');
      expect(ticket.adminReply, 'We have fixed the video streaming issue in the latest update.');
      expect(ticket.createdAt, isNotNull);
    });

    test('handles fallback keys for admin reply and status', () {
      final json = {
        'id': 204,
        'query_type': 'Billing & Payments / Refund',
        'title': 'Payment deducted but course not unlocked',
        'description': 'Razorpay payment was successful.',
        'status': 'IN_PROGRESS',
        'response': 'Verifying payment with payment gateway.',
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.id, '204');
      expect(ticket.category, 'Billing & Payments / Refund');
      expect(ticket.subject, 'Payment deducted but course not unlocked');
      expect(ticket.message, 'Razorpay payment was successful.');
      expect(ticket.status, 'IN_PROGRESS');
      expect(ticket.isInProgress, isTrue);
      expect(ticket.isResolved, isFalse);
      expect(ticket.statusDisplay, 'In Progress');
      expect(ticket.adminReply, 'Verifying payment with payment gateway.');
    });

    test('handles open ticket without admin reply gracefully', () {
      final json = {
        'id': 305,
        'subject': 'General Query',
        'message': 'When does the winter batch start?',
      };

      final ticket = SupportTicket.fromJson(json);

      expect(ticket.status, 'OPEN');
      expect(ticket.isResolved, isFalse);
      expect(ticket.statusDisplay, 'Open');
      expect(ticket.adminReply, isNull);
    });
  });
}
