class Event {
  final String? id;
  final String? title;
  final String? leadText;
  final String? description;
  final String? coverUrl;
  final String? dateStart;
  final String? dateEnd;
  final String? addressName;
  final String? priceDetail;
  final String? tags;

  Event({
    this.id,
    this.title,
    this.leadText,
    this.description,
    this.coverUrl,
    this.dateStart,
    this.dateEnd,
    this.addressName,
    this.priceDetail,
    this.tags


});
static Event fromJson(Map<String, dynamic> json) {
  return Event(
    id: json['id'],
    title: json['title'],
    leadText: json['lead_text'],
    description: json['description'],
    coverUrl: json['cover_url'],
    dateStart: json['date_start'],
    dateEnd: json['date_end'],
    addressName: json['address_name'],
    priceDetail: json['price_detail'],
    tags: json['qfap_tags'],
  );

}
}