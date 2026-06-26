import 'package:intl/intl.dart';
import 'package:opei/core/utils/error_helper.dart';

class RetryInfo {
  final int? retryAfterSeconds;
  final DateTime? retryAt;

  const RetryInfo({
    this.retryAfterSeconds,
    this.retryAt,
  });

  bool get hasData => retryAfterSeconds != null || retryAt != null;
}

RetryInfo parseRetryInfo(Map<String, dynamic>? payload) {
  int? seconds;
  DateTime? retryAt;

  if (payload != null) {
    final rawSeconds = payload['retryAfterSeconds'];
    if (rawSeconds is int) {
      seconds = rawSeconds;
    } else if (rawSeconds is String) {
      seconds = int.tryParse(rawSeconds);
    }

    final rawRetryAt = payload['retryAt'];
    if (rawRetryAt is String) {
      retryAt = DateTime.tryParse(rawRetryAt);
    }
  }

  return RetryInfo(
    retryAfterSeconds: seconds,
    retryAt: retryAt,
  );
}

int deriveRetrySeconds(RetryInfo info, {int fallbackSeconds = 120}) {
  if (info.retryAfterSeconds != null) {
    return info.retryAfterSeconds!.clamp(0, 3600);
  }

  if (info.retryAt != null) {
    final diff = info.retryAt!.toLocal().difference(DateTime.now());
    if (diff.isNegative) {
      return 0;
    }
    final seconds = diff.inSeconds;
    return seconds > 3600 ? 3600 : seconds;
  }

  return fallbackSeconds;
}

String buildRetryMessage(String baseMessage, RetryInfo info) {
  final cleaned = baseMessage.trim().isEmpty
      ? ErrorHelper.l10n.retryPleaseTryAgainLater
      : baseMessage.trim();

  if (!info.hasData) {
    return cleaned;
  }

  final buffer = StringBuffer(cleaned);

  if (info.retryAt != null) {
    final local = info.retryAt!.toLocal();
    final formatted = DateFormat('h:mm a').format(local);
    buffer.write(' ${ErrorHelper.l10n.retryYouCanRetryAt(formatted)}');
  } else if (info.retryAfterSeconds != null) {
    final seconds = info.retryAfterSeconds!.clamp(0, 3600);
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    if (minutes > 0) {
      buffer.write(
        ' ${ErrorHelper.l10n.retryTryAgainInMinutesSeconds(minutes, remainingSeconds.toString().padLeft(2, '0'))}',
      );
    } else {
      buffer.write(' ${ErrorHelper.l10n.retryTryAgainInSeconds(remainingSeconds)}');
    }
  }

  return buffer.toString();
}

