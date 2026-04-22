/// 日历日比较（忽略时分秒）：用于生日、到家日「不晚于今天」。
bool isCalendarOnOrBefore(DateTime candidate, DateTime today) {
  final c = DateTime(candidate.year, candidate.month, candidate.day);
  final t = DateTime(today.year, today.month, today.day);
  return !c.isAfter(t);
}
