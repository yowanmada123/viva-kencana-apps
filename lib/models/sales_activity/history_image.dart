import 'dart:convert';

class HistoryImage {
  final String trId;
  final String seqId;
  final String seqIdImg;
  final String str1SacategChar;
  final String price;
  final String imgUrl;
  final String createdDate;
  final String modifiedDate;
  final String createdBy;
  final String modifiedBy;
  final String millId;
  final String remark;
  HistoryImage({
    required this.trId,
    required this.seqId,
    required this.seqIdImg,
    required this.str1SacategChar,
    required this.price,
    required this.imgUrl,
    required this.createdDate,
    required this.modifiedDate,
    required this.createdBy,
    required this.modifiedBy,
    required this.millId,
    required this.remark,
  });

  HistoryImage copyWith({
    String? trId,
    String? seqId,
    String? seqIdImg,
    String? str1SacategChar,
    String? price,
    String? imgUrl,
    String? createdDate,
    String? modifiedDate,
    String? createdBy,
    String? modifiedBy,
    String? millId,
    String? remark,
  }) {
    return HistoryImage(
      trId: trId ?? this.trId,
      seqId: seqId ?? this.seqId,
      seqIdImg: seqIdImg ?? this.seqIdImg,
      str1SacategChar: str1SacategChar ?? this.str1SacategChar,
      price: price ?? this.price,
      imgUrl: imgUrl ?? this.imgUrl,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      millId: millId ?? this.millId,
      remark: remark ?? this.remark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tr_id': trId,
      'seq_id': seqId,
      'seq_id_img': seqIdImg,
      'str1_sacateg_char': str1SacategChar,
      'price': price,
      'img_url': imgUrl,
      'created_date': createdDate,
      'modified_date': modifiedDate,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'mill_id': millId,
      'remark': remark,
    };
  }

  factory HistoryImage.fromMap(Map<String, dynamic> map) {
    return HistoryImage(
      trId: map['tr_id'] ?? '',
      seqId: map['seq_id'] ?? '',
      seqIdImg: map['seq_id_img'] ?? '',
      str1SacategChar: map['str1_sacateg_char'] ?? '',
      price: map['price'] ?? '',
      imgUrl: map['img_url'] ?? '',
      createdDate: map['created_date'] ?? '',
      modifiedDate: map['modified_date'] ?? '',
      createdBy: map['created_by'] ?? '',
      modifiedBy: map['modified_by'] ?? '',
      millId: map['mill_id'] ?? '',
      remark: map['remark'] ?? '',
    );

  }

  String toJson() => json.encode(toMap());

  factory HistoryImage.fromJson(String source) => HistoryImage.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HistoryImage(trId: $trId, seqId: $seqId, seqIdImg: $seqIdImg, str1SacategChar: $str1SacategChar, price: $price, imgUrl: $imgUrl, createdDate: $createdDate, modifiedDate: $modifiedDate, createdBy: $createdBy, modifiedBy: $modifiedBy, millId: $millId, remark: $remark)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HistoryImage &&
      other.trId == trId &&
      other.seqId == seqId &&
      other.seqIdImg == seqIdImg &&
      other.str1SacategChar == str1SacategChar &&
      other.price == price &&
      other.imgUrl == imgUrl &&
      other.createdDate == createdDate &&
      other.modifiedDate == modifiedDate &&
      other.createdBy == createdBy &&
      other.modifiedBy == modifiedBy &&
      other.millId == millId &&
      other.remark == remark;
  }

  @override
  int get hashCode {
    return trId.hashCode ^
      seqId.hashCode ^
      seqIdImg.hashCode ^
      str1SacategChar.hashCode ^
      price.hashCode ^
      imgUrl.hashCode ^
      createdDate.hashCode ^
      modifiedDate.hashCode ^
      createdBy.hashCode ^
      modifiedBy.hashCode ^
      millId.hashCode ^
      remark.hashCode;
  }
}