// String messageId = DateTime.now().millisecondsSinceEpoch.toString();

import 'package:intl/intl.dart';

String generateChattingId(String user1, String user2) {
  if (user1.compareTo(user2) < 0) {
    return "${user1}_$user2";
  } else {
    return "${user2}_$user1";
  }
}

String messageTime(DateTime messageTime) {
  DateTime now = DateTime.now();
  if (messageTime.year == now.year &&
      messageTime.month == now.month &&
      messageTime.day == now.day) {
    return "Today ${DateFormat('hh:mm a').format(messageTime)}";
  }
  DateTime yesterday = now.subtract(const Duration(days: 1));

  if (messageTime.year == yesterday.year &&
      messageTime.month == yesterday.month &&
      messageTime.day == yesterday.day) {
    return "Yesterday ${DateFormat('hh:mm a').format(messageTime)}";
  }
  return DateFormat('dd MMM hh:mm a').format(messageTime);
}