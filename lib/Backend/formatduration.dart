String formatDuration(Duration duration, {
  bool useSmartFormat = false,
  bool showMilliseconds = false,
}) {
  if (useSmartFormat) {
    if (duration.inDays >= 1) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else if (duration.inSeconds >= 1) {
      return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
    } else {
      return '${duration.inMilliseconds} ms';
    }
  } else {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');

    return showMilliseconds
      ? '$hours:$minutes:$seconds:$ms'
      : '$hours:$minutes:$seconds';
  }
}