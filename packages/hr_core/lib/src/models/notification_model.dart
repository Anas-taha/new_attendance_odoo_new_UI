class NotificationModel {
  String? status;
  num? unreadCount;
  List<Notifications>? notifications;
  num? marked;

  NotificationModel({
    this.status,
    this.unreadCount,
    this.notifications,
    this.marked,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    unreadCount = json['unread_count'] as num?;
    marked = json['marked'] as num?;
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      for (final item in json['notifications'] as List) {
        notifications!.add(
          Notifications.fromJson(Map<String, dynamic>.from(item as Map)),
        );
      }
    } else if (json['notification'] != null) {
      notifications = [
        Notifications.fromJson(
          Map<String, dynamic>.from(json['notification'] as Map),
        ),
      ];
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['unread_count'] = unreadCount;
    data['marked'] = marked;
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notifications {
  num? id;
  String? title;
  String? description;
  String? type;
  String? state;
  String? date;
  String? readDate;
  num? leaveId;
  String? rejectedReason;

  Notifications({
    this.id,
    this.title,
    this.description,
    this.type,
    this.state,
    this.date,
    this.readDate,
    this.leaveId,
    this.rejectedReason,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'] as num?;
    title = json['title']?.toString();
    description = json['description']?.toString();
    type = json['type']?.toString();
    state = json['state']?.toString();
    date = json['date']?.toString();
    readDate = json['read_date']?.toString();
    leaveId = json['leave_id'] as num?;
    rejectedReason = json['rejected_reason']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['state'] = state;
    data['date'] = date;
    data['read_date'] = readDate;
    data['leave_id'] = leaveId;
    data['rejected_reason'] = rejectedReason;
    return data;
  }

  Notifications copyWith({
    num? id,
    String? title,
    String? description,
    String? type,
    String? state,
    String? date,
    String? readDate,
    num? leaveId,
    String? rejectedReason,
  }) {
    return Notifications(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      state: state ?? this.state,
      date: date ?? this.date,
      readDate: readDate ?? this.readDate,
      leaveId: leaveId ?? this.leaveId,
      rejectedReason: rejectedReason ?? this.rejectedReason,
    );
  }
}
