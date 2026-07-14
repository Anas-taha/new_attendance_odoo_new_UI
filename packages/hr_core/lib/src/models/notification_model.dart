class NotificationModel {
  String? status;
  num? unreadCount;
  List<Notifications>? notifications;

  NotificationModel({this.status, this.unreadCount, this.notifications});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    unreadCount = json['unread_count'];
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(new Notifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['unread_count'] = this.unreadCount;
    if (this.notifications != null) {
      data['notifications'] = this.notifications!
          .map((v) => v.toJson())
          .toList();
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

  Notifications({
    this.id,
    this.title,
    this.description,
    this.type,
    this.state,
    this.date,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    state = json['state'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['type'] = this.type;
    data['state'] = this.state;
    data['date'] = this.date;
    return data;
  }
}
