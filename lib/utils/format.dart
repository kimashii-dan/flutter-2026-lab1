const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

String formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${formatTime(date.hour, date.minute)}';

String formatDuration(Duration duration) => duration.inDays > 0
    ? '${duration.inDays}d ${duration.inHours % 24}h'
    : '${duration.inHours}h ${duration.inMinutes % 60}m';
