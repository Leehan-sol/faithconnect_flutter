/// iOS String+Extensions.swift의 toTimeAgoDisplay() 대응
/// 동일한 로직으로 시간 표기 통일
String timeAgo(String dateString) {
  try {
    // 서버 날짜 파싱 (yyyy-MM-ddTHH:mm:ss.SSS)
    final trimmed = dateString.length > 23 ? dateString.substring(0, 23) : dateString;
    final date = DateTime.parse(trimmed);
    final now = DateTime.now();
    final diff = now.difference(date);

    final days = diff.inDays;
    if (days == 0) {
      if (diff.inHours >= 1) return '${diff.inHours}시간 전';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}분 전';
      return '방금 전';
    }
    if (days == 1) return '어제';
    if (days <= 6) return '$days일 전';
    if (days == 7) return '일주일 전';

    // 7일 이상: 날짜 표시
    if (date.year == now.year) {
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
    return '${(date.year % 100).toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return dateString;
  }
}
