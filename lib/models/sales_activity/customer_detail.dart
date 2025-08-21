import 'dart:convert';

class CustomerDetail {
  final String customerId;
  final String salesId;
  final String namaCustomer;
  final String alamat;
  final String kota;
  final String telepon;
  final String perTanggal;
  final String fax;
  final String npwp;
  final String person;
  final String jabatan;
  final String realCity;
  final String propinsi;
  final String region;
  final String banned;
  final String payterm;
  final String creditLimit;
  final String bannedFee;
  final String custGroup;
  final String email;
  final String businessStartDate;
  final String businessStatus;
  final String businessEntities;
  final String kindOfBusiness;
  final String building;
  final String employeeNum;
  final String taxStatus;
  final String officeType;
  final String ownership;
  final String knownFrom;
  final String omzet;
  final String ownerName;
  final String dob;
  final String cityOfBirth;
  final String husbandWife;
  final String idCard;
  final String idCardNo;
  final String copiIdCard;
  final String ownerAddress;
  final String ownerProvince;
  final String ownerCity;
  final String ownerPhone;
  final String ownerHp;
  final String ownerEmail;
  final String hariRaya;
  final String bank1;
  final String bank2;
  final String bank3;
  final String bankAtasNama1;
  final String bankAtasNama2;
  final String bankAtasNama3;
  final String paymentTipe1;
  final String paymentTipe2;
  final String paymentTipe3;
  final String alamatPenagihan;
  final String propinsiPenagihan;
  final String kotaPenagihan;
  final String tlpPenagihan;
  final String faxPenagihan;
  final String hariPenagihan;
  final String character;
  final String characterDesc;
  final String capacity;
  final String capacityDesc;
  final String capital;
  final String capitalDesc;
  final String collateral;
  final String collateralDesc;
  final String condition;
  final String conditionDesc;
  final String custNote;
  final String trDate;
  final String approve1Date;
  final String approve2Date;
  final String activeFlag;
  final String cofficeId;
  final String salesman;
  final String affiliate;
  final String district;
  final String vilage;
  final String cv;
  final String priceRole;
  final String priceRole2;
  final String cvId;
  final String noNib;
  final String noSkd;
  final String picOrder;
  final String picOrderJabatan;
  final String picOrderTelp;
  final String picOrderEmail;
  final String picTagihan;
  final String picTagihanJabatan;
  final String picTagihanTelp;
  final String picTagihanEmail;
  final String metodeBayar;
  final String dtModified;
  final String skbdn;
  final String custType;
  final String npwpGroup;
  final String latitude;
  final String longitude;
  final String gpsSetBy;
  final String gpsDtModified;
  final String nooDate;
  CustomerDetail({
    required this.customerId,
    required this.salesId,
    required this.namaCustomer,
    required this.alamat,
    required this.kota,
    required this.telepon,
    required this.perTanggal,
    required this.fax,
    required this.npwp,
    required this.person,
    required this.jabatan,
    required this.realCity,
    required this.propinsi,
    required this.region,
    required this.banned,
    required this.payterm,
    required this.creditLimit,
    required this.bannedFee,
    required this.custGroup,
    required this.email,
    required this.businessStartDate,
    required this.businessStatus,
    required this.businessEntities,
    required this.kindOfBusiness,
    required this.building,
    required this.employeeNum,
    required this.taxStatus,
    required this.officeType,
    required this.ownership,
    required this.knownFrom,
    required this.omzet,
    required this.ownerName,
    required this.dob,
    required this.cityOfBirth,
    required this.husbandWife,
    required this.idCard,
    required this.idCardNo,
    required this.copiIdCard,
    required this.ownerAddress,
    required this.ownerProvince,
    required this.ownerCity,
    required this.ownerPhone,
    required this.ownerHp,
    required this.ownerEmail,
    required this.hariRaya,
    required this.bank1,
    required this.bank2,
    required this.bank3,
    required this.bankAtasNama1,
    required this.bankAtasNama2,
    required this.bankAtasNama3,
    required this.paymentTipe1,
    required this.paymentTipe2,
    required this.paymentTipe3,
    required this.alamatPenagihan,
    required this.propinsiPenagihan,
    required this.kotaPenagihan,
    required this.tlpPenagihan,
    required this.faxPenagihan,
    required this.hariPenagihan,
    required this.character,
    required this.characterDesc,
    required this.capacity,
    required this.capacityDesc,
    required this.capital,
    required this.capitalDesc,
    required this.collateral,
    required this.collateralDesc,
    required this.condition,
    required this.conditionDesc,
    required this.custNote,
    required this.trDate,
    required this.approve1Date,
    required this.approve2Date,
    required this.activeFlag,
    required this.cofficeId,
    required this.salesman,
    required this.affiliate,
    required this.district,
    required this.vilage,
    required this.cv,
    required this.priceRole,
    required this.priceRole2,
    required this.cvId,
    required this.noNib,
    required this.noSkd,
    required this.picOrder,
    required this.picOrderJabatan,
    required this.picOrderTelp,
    required this.picOrderEmail,
    required this.picTagihan,
    required this.picTagihanJabatan,
    required this.picTagihanTelp,
    required this.picTagihanEmail,
    required this.metodeBayar,
    required this.dtModified,
    required this.skbdn,
    required this.custType,
    required this.npwpGroup,
    required this.latitude,
    required this.longitude,
    required this.gpsSetBy,
    required this.gpsDtModified,
    required this.nooDate,
  });

  CustomerDetail copyWith({
    String? customerId,
    String? salesId,
    String? namaCustomer,
    String? alamat,
    String? kota,
    String? telepon,
    String? perTanggal,
    String? fax,
    String? npwp,
    String? person,
    String? jabatan,
    String? realCity,
    String? propinsi,
    String? region,
    String? banned,
    String? payterm,
    String? creditLimit,
    String? bannedFee,
    String? custGroup,
    String? email,
    String? businessStartDate,
    String? businessStatus,
    String? businessEntities,
    String? kindOfBusiness,
    String? building,
    String? employeeNum,
    String? taxStatus,
    String? officeType,
    String? ownership,
    String? knownFrom,
    String? omzet,
    String? ownerName,
    String? dob,
    String? cityOfBirth,
    String? husbandWife,
    String? idCard,
    String? idCardNo,
    String? copiIdCard,
    String? ownerAddress,
    String? ownerProvince,
    String? ownerCity,
    String? ownerPhone,
    String? ownerHp,
    String? ownerEmail,
    String? hariRaya,
    String? bank1,
    String? bank2,
    String? bank3,
    String? bankAtasNama1,
    String? bankAtasNama2,
    String? bankAtasNama3,
    String? paymentTipe1,
    String? paymentTipe2,
    String? paymentTipe3,
    String? alamatPenagihan,
    String? propinsiPenagihan,
    String? kotaPenagihan,
    String? tlpPenagihan,
    String? faxPenagihan,
    String? hariPenagihan,
    String? character,
    String? characterDesc,
    String? capacity,
    String? capacityDesc,
    String? capital,
    String? capitalDesc,
    String? collateral,
    String? collateralDesc,
    String? condition,
    String? conditionDesc,
    String? custNote,
    String? trDate,
    String? approve1Date,
    String? approve2Date,
    String? activeFlag,
    String? cofficeId,
    String? salesman,
    String? affiliate,
    String? district,
    String? vilage,
    String? cv,
    String? priceRole,
    String? priceRole2,
    String? cvId,
    String? noNib,
    String? noSkd,
    String? picOrder,
    String? picOrderJabatan,
    String? picOrderTelp,
    String? picOrderEmail,
    String? picTagihan,
    String? picTagihanJabatan,
    String? picTagihanTelp,
    String? picTagihanEmail,
    String? metodeBayar,
    String? dtModified,
    String? skbdn,
    String? custType,
    String? npwpGroup,
    String? latitude,
    String? longitude,
    String? gpsSetBy,
    String? gpsDtModified,
    String? nooDate,
  }) {
    return CustomerDetail(
      customerId: customerId ?? this.customerId,
      salesId: salesId ?? this.salesId,
      namaCustomer: namaCustomer ?? this.namaCustomer,
      alamat: alamat ?? this.alamat,
      kota: kota ?? this.kota,
      telepon: telepon ?? this.telepon,
      perTanggal: perTanggal ?? this.perTanggal,
      fax: fax ?? this.fax,
      npwp: npwp ?? this.npwp,
      person: person ?? this.person,
      jabatan: jabatan ?? this.jabatan,
      realCity: realCity ?? this.realCity,
      propinsi: propinsi ?? this.propinsi,
      region: region ?? this.region,
      banned: banned ?? this.banned,
      payterm: payterm ?? this.payterm,
      creditLimit: creditLimit ?? this.creditLimit,
      bannedFee: bannedFee ?? this.bannedFee,
      custGroup: custGroup ?? this.custGroup,
      email: email ?? this.email,
      businessStartDate: businessStartDate ?? this.businessStartDate,
      businessStatus: businessStatus ?? this.businessStatus,
      businessEntities: businessEntities ?? this.businessEntities,
      kindOfBusiness: kindOfBusiness ?? this.kindOfBusiness,
      building: building ?? this.building,
      employeeNum: employeeNum ?? this.employeeNum,
      taxStatus: taxStatus ?? this.taxStatus,
      officeType: officeType ?? this.officeType,
      ownership: ownership ?? this.ownership,
      knownFrom: knownFrom ?? this.knownFrom,
      omzet: omzet ?? this.omzet,
      ownerName: ownerName ?? this.ownerName,
      dob: dob ?? this.dob,
      cityOfBirth: cityOfBirth ?? this.cityOfBirth,
      husbandWife: husbandWife ?? this.husbandWife,
      idCard: idCard ?? this.idCard,
      idCardNo: idCardNo ?? this.idCardNo,
      copiIdCard: copiIdCard ?? this.copiIdCard,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownerProvince: ownerProvince ?? this.ownerProvince,
      ownerCity: ownerCity ?? this.ownerCity,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerHp: ownerHp ?? this.ownerHp,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      hariRaya: hariRaya ?? this.hariRaya,
      bank1: bank1 ?? this.bank1,
      bank2: bank2 ?? this.bank2,
      bank3: bank3 ?? this.bank3,
      bankAtasNama1: bankAtasNama1 ?? this.bankAtasNama1,
      bankAtasNama2: bankAtasNama2 ?? this.bankAtasNama2,
      bankAtasNama3: bankAtasNama3 ?? this.bankAtasNama3,
      paymentTipe1: paymentTipe1 ?? this.paymentTipe1,
      paymentTipe2: paymentTipe2 ?? this.paymentTipe2,
      paymentTipe3: paymentTipe3 ?? this.paymentTipe3,
      alamatPenagihan: alamatPenagihan ?? this.alamatPenagihan,
      propinsiPenagihan: propinsiPenagihan ?? this.propinsiPenagihan,
      kotaPenagihan: kotaPenagihan ?? this.kotaPenagihan,
      tlpPenagihan: tlpPenagihan ?? this.tlpPenagihan,
      faxPenagihan: faxPenagihan ?? this.faxPenagihan,
      hariPenagihan: hariPenagihan ?? this.hariPenagihan,
      character: character ?? this.character,
      characterDesc: characterDesc ?? this.characterDesc,
      capacity: capacity ?? this.capacity,
      capacityDesc: capacityDesc ?? this.capacityDesc,
      capital: capital ?? this.capital,
      capitalDesc: capitalDesc ?? this.capitalDesc,
      collateral: collateral ?? this.collateral,
      collateralDesc: collateralDesc ?? this.collateralDesc,
      condition: condition ?? this.condition,
      conditionDesc: conditionDesc ?? this.conditionDesc,
      custNote: custNote ?? this.custNote,
      trDate: trDate ?? this.trDate,
      approve1Date: approve1Date ?? this.approve1Date,
      approve2Date: approve2Date ?? this.approve2Date,
      activeFlag: activeFlag ?? this.activeFlag,
      cofficeId: cofficeId ?? this.cofficeId,
      salesman: salesman ?? this.salesman,
      affiliate: affiliate ?? this.affiliate,
      district: district ?? this.district,
      vilage: vilage ?? this.vilage,
      cv: cv ?? this.cv,
      priceRole: priceRole ?? this.priceRole,
      priceRole2: priceRole2 ?? this.priceRole2,
      cvId: cvId ?? this.cvId,
      noNib: noNib ?? this.noNib,
      noSkd: noSkd ?? this.noSkd,
      picOrder: picOrder ?? this.picOrder,
      picOrderJabatan: picOrderJabatan ?? this.picOrderJabatan,
      picOrderTelp: picOrderTelp ?? this.picOrderTelp,
      picOrderEmail: picOrderEmail ?? this.picOrderEmail,
      picTagihan: picTagihan ?? this.picTagihan,
      picTagihanJabatan: picTagihanJabatan ?? this.picTagihanJabatan,
      picTagihanTelp: picTagihanTelp ?? this.picTagihanTelp,
      picTagihanEmail: picTagihanEmail ?? this.picTagihanEmail,
      metodeBayar: metodeBayar ?? this.metodeBayar,
      dtModified: dtModified ?? this.dtModified,
      skbdn: skbdn ?? this.skbdn,
      custType: custType ?? this.custType,
      npwpGroup: npwpGroup ?? this.npwpGroup,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsSetBy: gpsSetBy ?? this.gpsSetBy,
      gpsDtModified: gpsDtModified ?? this.gpsDtModified,
      nooDate: nooDate ?? this.nooDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CustomerId': customerId,
      'SalesId': salesId,
      'NamaCustomer': namaCustomer,
      'Alamat': alamat,
      'Kota': kota,
      'Telepon': telepon,
      'PerTanggal': perTanggal,
      'Fax': fax,
      'NPWP': npwp,
      'Person': person,
      'Jabatan': jabatan,
      'Real_City': realCity,
      'Propinsi': propinsi,
      'Region': region,
      'Banned': banned,
      'payterm': payterm,
      'credit_limit': creditLimit,
      'banned_fee': bannedFee,
      'cust_group': custGroup,
      'email': email,
      'business_start_date': businessStartDate,
      'business_status': businessStatus,
      'business_entities': businessEntities,
      'kind_of_business': kindOfBusiness,
      'building': building,
      'employee_num': employeeNum,
      'tax_status': taxStatus,
      'office_tipe': officeType,
      'ownership': ownership,
      'known_from': knownFrom,
      'omzet': omzet,
      'owner_name': ownerName,
      'dob': dob,
      'city_of_birth': cityOfBirth,
      'husband_wife': husbandWife,
      'id_card': idCard,
      'id_card_no': idCardNo,
      'copi_id_card': copiIdCard,
      'owner_address': ownerAddress,
      'owner_province': ownerProvince,
      'owner_city': ownerCity,
      'owner_phone': ownerPhone,
      'owner_hp': ownerHp,
      'owner_email': ownerEmail,
      'hari_raya': hariRaya,
      'bank1': bank1,
      'bank2': bank2,
      'bank3': bank3,
      'bank_atas_nama1': bankAtasNama1,
      'bank_atas_nama2': bankAtasNama2,
      'bank_atas_nama3': bankAtasNama3,
      'payment_tipe1': paymentTipe1,
      'payment_tipe2': paymentTipe2,
      'payment_tipe3': paymentTipe3,
      'alamat_penagihan': alamatPenagihan,
      'propinsi_penagihan': propinsiPenagihan,
      'kota_penagihan': kotaPenagihan,
      'tlp_penagihan': tlpPenagihan,
      'fax_penagihan': faxPenagihan,
      'hari_penagihan': hariPenagihan,
      'character': character,
      'character_desc': characterDesc,
      'capacity': capacity,
      'capacity_desc': capacityDesc,
      'capital': capital,
      'capital_desc': capitalDesc,
      'collateral': collateral,
      'collateral_dessc': collateralDesc,
      'condition': condition,
      'condition_desc': conditionDesc,
      'cust_note': custNote,
      'tr_date': trDate,
      'approve1_date': approve1Date,
      'approve2_date': approve2Date,
      'active_flag': activeFlag,
      'coffice_id': cofficeId,
      'salesman': salesman,
      'affiliate': affiliate,
      'district': district,
      'vilage': vilage,
      'cv': cv,
      'price_role': priceRole,
      'price_role2': priceRole2,
      'cv_id': cvId,
      'no_nib': noNib,
      'no_skd': noSkd,
      'pic_order': picOrder,
      'pic_order_jabatan': picOrderJabatan,
      'pic_order_telp': picOrderTelp,
      'pic_order_email': picOrderEmail,
      'pic_tagihan': picTagihan,
      'pic_tagihan_jabatan': picTagihanJabatan,
      'pic_tagihan_telp': picTagihanTelp,
      'pic_tagihan_email': picTagihanEmail,
      'metode_bayar': metodeBayar,
      'dt_modified': dtModified,
      'skbdn': skbdn,
      'cust_type': custType,
      'npwp_group': npwpGroup,
      'latitude': latitude,
      'longitude': longitude,
      'gps_set_by': gpsSetBy,
      'gps_dt_modified': gpsDtModified,
      'noo_date': nooDate,
    };
  }

  factory CustomerDetail.fromMap(Map<String, dynamic> map) {
    return CustomerDetail(
      customerId: map['CustomerId'] ?? '',
      salesId: map['SalesId'] ?? '',
      namaCustomer: map['NamaCustomer'] ?? '',
      alamat: map['Alamat'] ?? '',
      kota: map['Kota'] ?? '',
      telepon: map['Telepon'] ?? '',
      perTanggal: map['PerTanggal'] ?? '',
      fax: map['Fax'] ?? '',
      npwp: map['NPWP'] ?? '',
      person: map['Person'] ?? '',
      jabatan: map['Jabatan'] ?? '',
      realCity: map['Real_City'] ?? '',
      propinsi: map['Propinsi'] ?? '',
      region: map['Region'] ?? '',
      banned: map['Banned'] ?? '',
      payterm: map['payterm'] ?? '',
      creditLimit: map['credit_limit'] ?? '',
      bannedFee: map['banned_fee'] ?? '',
      custGroup: map['cust_group'] ?? '',
      email: map['email'] ?? '',
      businessStartDate: map['business_start_date'] ?? '',
      businessStatus: map['business_status'] ?? '',
      businessEntities: map['business_entities'] ?? '',
      kindOfBusiness: map['kind_of_business'] ?? '',
      building: map['building'] ?? '',
      employeeNum: map['employee_num'] ?? '',
      taxStatus: map['tax_status'] ?? '',
      officeType: map['office_tipe'] ?? '',
      ownership: map['ownership'] ?? '',
      knownFrom: map['known_from'] ?? '',
      omzet: map['omzet'] ?? '',
      ownerName: map['owner_name'] ?? '',
      dob: map['dob'] ?? '',
      cityOfBirth: map['city_of_birth'] ?? '',
      husbandWife: map['husband_wife'] ?? '',
      idCard: map['id_card'] ?? '',
      idCardNo: map['id_card_no'] ?? '',
      copiIdCard: map['copi_id_card'] ?? '',
      ownerAddress: map['owner_address'] ?? '',
      ownerProvince: map['owner_province'] ?? '',
      ownerCity: map['owner_city'] ?? '',
      ownerPhone: map['owner_phone'] ?? '',
      ownerHp: map['owner_hp'] ?? '',
      ownerEmail: map['owner_email'] ?? '',
      hariRaya: map['hari_raya'] ?? '',
      bank1: map['bank1'] ?? '',
      bank2: map['bank2'] ?? '',
      bank3: map['bank3'] ?? '',
      bankAtasNama1: map['bank_atas_nama1'] ?? '',
      bankAtasNama2: map['bank_atas_nama2'] ?? '',
      bankAtasNama3: map['bank_atas_nama3'] ?? '',
      paymentTipe1: map['payment_tipe1'] ?? '',
      paymentTipe2: map['payment_tipe2'] ?? '',
      paymentTipe3: map['payment_tipe3'] ?? '',
      alamatPenagihan: map['alamat_penagihan'] ?? '',
      propinsiPenagihan: map['propinsi_penagihan'] ?? '',
      kotaPenagihan: map['kota_penagihan'] ?? '',
      tlpPenagihan: map['tlp_penagihan'] ?? '',
      faxPenagihan: map['fax_penagihan'] ?? '',
      hariPenagihan: map['hari_penagihan'] ?? '',
      character: map['character'] ?? '',
      characterDesc: map['character_desc'] ?? '',
      capacity: map['capacity'] ?? '',
      capacityDesc: map['capacity_desc'] ?? '',
      capital: map['capital'] ?? '',
      capitalDesc: map['capital_desc'] ?? '',
      collateral: map['collateral'] ?? '',
      collateralDesc: map['collateral_dessc'] ?? '',
      condition: map['condition'] ?? '',
      conditionDesc: map['condition_desc'] ?? '',
      custNote: map['cust_note'] ?? '',
      trDate: map['tr_date'] ?? '',
      approve1Date: map['approve1_date'] ?? '',
      approve2Date: map['approve2_date'] ?? '',
      activeFlag: map['active_flag'] ?? '',
      cofficeId: map['coffice_id'] ?? '',
      salesman: map['salesman'] ?? '',
      affiliate: map['affiliate'] ?? '',
      district: map['district'] ?? '',
      vilage: map['vilage'] ?? '',
      cv: map['cv'] ?? '',
      priceRole: map['price_role'] ?? '',
      priceRole2: map['price_role2'] ?? '',
      cvId: map['cv_id'] ?? '',
      noNib: map['no_nib'] ?? '',
      noSkd: map['no_skd'] ?? '',
      picOrder: map['pic_order'] ?? '',
      picOrderJabatan: map['pic_order_jabatan'] ?? '',
      picOrderTelp: map['pic_order_telp'] ?? '',
      picOrderEmail: map['pic_order_email'] ?? '',
      picTagihan: map['pic_tagihan'] ?? '',
      picTagihanJabatan: map['pic_tagihan_jabatan'] ?? '',
      picTagihanTelp: map['pic_tagihan_telp'] ?? '',
      picTagihanEmail: map['pic_tagihan_email'] ?? '',
      metodeBayar: map['metode_bayar'] ?? '',
      dtModified: map['dt_modified'] ?? '',
      skbdn: map['skbdn'] ?? '',
      custType: map['cust_type'] ?? '',
      npwpGroup: map['npwp_group'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      gpsSetBy: map['gps_set_by'] ?? '',
      gpsDtModified: map['gps_dt_modified'] ?? '',
      nooDate: map['noo_date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerDetail.fromJson(String source) =>
      CustomerDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CustomerDetail(customerId: $customerId, salesId: $salesId, namaCustomer: $namaCustomer, alamat: $alamat, kota: $kota, telepon: $telepon, perTanggal: $perTanggal, fax: $fax, npwp: $npwp, person: $person, jabatan: $jabatan, realCity: $realCity, propinsi: $propinsi, region: $region, banned: $banned, payterm: $payterm, creditLimit: $creditLimit, bannedFee: $bannedFee, custGroup: $custGroup, email: $email, businessStartDate: $businessStartDate, businessStatus: $businessStatus, businessEntities: $businessEntities, kindOfBusiness: $kindOfBusiness, building: $building, employeeNum: $employeeNum, taxStatus: $taxStatus, officeType: $officeType, ownership: $ownership, knownFrom: $knownFrom, omzet: $omzet, ownerName: $ownerName, dob: $dob, cityOfBirth: $cityOfBirth, husbandWife: $husbandWife, idCard: $idCard, idCardNo: $idCardNo, copiIdCard: $copiIdCard, ownerAddress: $ownerAddress, ownerProvince: $ownerProvince, ownerCity: $ownerCity, ownerPhone: $ownerPhone, ownerHp: $ownerHp, ownerEmail: $ownerEmail, hariRaya: $hariRaya, bank1: $bank1, bank2: $bank2, bank3: $bank3, bankAtasNama1: $bankAtasNama1, bankAtasNama2: $bankAtasNama2, bankAtasNama3: $bankAtasNama3, paymentTipe1: $paymentTipe1, paymentTipe2: $paymentTipe2, paymentTipe3: $paymentTipe3, alamatPenagihan: $alamatPenagihan, propinsiPenagihan: $propinsiPenagihan, kotaPenagihan: $kotaPenagihan, tlpPenagihan: $tlpPenagihan, faxPenagihan: $faxPenagihan, hariPenagihan: $hariPenagihan, character: $character, characterDesc: $characterDesc, capacity: $capacity, capacityDesc: $capacityDesc, capital: $capital, capitalDesc: $capitalDesc, collateral: $collateral, collateralDesc: $collateralDesc, condition: $condition, conditionDesc: $conditionDesc, custNote: $custNote, trDate: $trDate, approve1Date: $approve1Date, approve2Date: $approve2Date, activeFlag: $activeFlag, cofficeId: $cofficeId, salesman: $salesman, affiliate: $affiliate, district: $district, vilage: $vilage, cv: $cv, priceRole: $priceRole, priceRole2: $priceRole2, cvId: $cvId, noNib: $noNib, noSkd: $noSkd, picOrder: $picOrder, picOrderJabatan: $picOrderJabatan, picOrderTelp: $picOrderTelp, picOrderEmail: $picOrderEmail, picTagihan: $picTagihan, picTagihanJabatan: $picTagihanJabatan, picTagihanTelp: $picTagihanTelp, picTagihanEmail: $picTagihanEmail, metodeBayar: $metodeBayar, dtModified: $dtModified, skbdn: $skbdn, custType: $custType, npwpGroup: $npwpGroup, latitude: $latitude, longitude: $longitude, gpsSetBy: $gpsSetBy, gpsDtModified: $gpsDtModified, nooDate: $nooDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerDetail &&
        other.customerId == customerId &&
        other.salesId == salesId &&
        other.namaCustomer == namaCustomer &&
        other.alamat == alamat &&
        other.kota == kota &&
        other.telepon == telepon &&
        other.perTanggal == perTanggal &&
        other.fax == fax &&
        other.npwp == npwp &&
        other.person == person &&
        other.jabatan == jabatan &&
        other.realCity == realCity &&
        other.propinsi == propinsi &&
        other.region == region &&
        other.banned == banned &&
        other.payterm == payterm &&
        other.creditLimit == creditLimit &&
        other.bannedFee == bannedFee &&
        other.custGroup == custGroup &&
        other.email == email &&
        other.businessStartDate == businessStartDate &&
        other.businessStatus == businessStatus &&
        other.businessEntities == businessEntities &&
        other.kindOfBusiness == kindOfBusiness &&
        other.building == building &&
        other.employeeNum == employeeNum &&
        other.taxStatus == taxStatus &&
        other.officeType == officeType &&
        other.ownership == ownership &&
        other.knownFrom == knownFrom &&
        other.omzet == omzet &&
        other.ownerName == ownerName &&
        other.dob == dob &&
        other.cityOfBirth == cityOfBirth &&
        other.husbandWife == husbandWife &&
        other.idCard == idCard &&
        other.idCardNo == idCardNo &&
        other.copiIdCard == copiIdCard &&
        other.ownerAddress == ownerAddress &&
        other.ownerProvince == ownerProvince &&
        other.ownerCity == ownerCity &&
        other.ownerPhone == ownerPhone &&
        other.ownerHp == ownerHp &&
        other.ownerEmail == ownerEmail &&
        other.hariRaya == hariRaya &&
        other.bank1 == bank1 &&
        other.bank2 == bank2 &&
        other.bank3 == bank3 &&
        other.bankAtasNama1 == bankAtasNama1 &&
        other.bankAtasNama2 == bankAtasNama2 &&
        other.bankAtasNama3 == bankAtasNama3 &&
        other.paymentTipe1 == paymentTipe1 &&
        other.paymentTipe2 == paymentTipe2 &&
        other.paymentTipe3 == paymentTipe3 &&
        other.alamatPenagihan == alamatPenagihan &&
        other.propinsiPenagihan == propinsiPenagihan &&
        other.kotaPenagihan == kotaPenagihan &&
        other.tlpPenagihan == tlpPenagihan &&
        other.faxPenagihan == faxPenagihan &&
        other.hariPenagihan == hariPenagihan &&
        other.character == character &&
        other.characterDesc == characterDesc &&
        other.capacity == capacity &&
        other.capacityDesc == capacityDesc &&
        other.capital == capital &&
        other.capitalDesc == capitalDesc &&
        other.collateral == collateral &&
        other.collateralDesc == collateralDesc &&
        other.condition == condition &&
        other.conditionDesc == conditionDesc &&
        other.custNote == custNote &&
        other.trDate == trDate &&
        other.approve1Date == approve1Date &&
        other.approve2Date == approve2Date &&
        other.activeFlag == activeFlag &&
        other.cofficeId == cofficeId &&
        other.salesman == salesman &&
        other.affiliate == affiliate &&
        other.district == district &&
        other.vilage == vilage &&
        other.cv == cv &&
        other.priceRole == priceRole &&
        other.priceRole2 == priceRole2 &&
        other.cvId == cvId &&
        other.noNib == noNib &&
        other.noSkd == noSkd &&
        other.picOrder == picOrder &&
        other.picOrderJabatan == picOrderJabatan &&
        other.picOrderTelp == picOrderTelp &&
        other.picOrderEmail == picOrderEmail &&
        other.picTagihan == picTagihan &&
        other.picTagihanJabatan == picTagihanJabatan &&
        other.picTagihanTelp == picTagihanTelp &&
        other.picTagihanEmail == picTagihanEmail &&
        other.metodeBayar == metodeBayar &&
        other.dtModified == dtModified &&
        other.skbdn == skbdn &&
        other.custType == custType &&
        other.npwpGroup == npwpGroup &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.gpsSetBy == gpsSetBy &&
        other.gpsDtModified == gpsDtModified &&
        other.nooDate == nooDate;
  }

  @override
  int get hashCode {
    return customerId.hashCode ^
        salesId.hashCode ^
        namaCustomer.hashCode ^
        alamat.hashCode ^
        kota.hashCode ^
        telepon.hashCode ^
        perTanggal.hashCode ^
        fax.hashCode ^
        npwp.hashCode ^
        person.hashCode ^
        jabatan.hashCode ^
        realCity.hashCode ^
        propinsi.hashCode ^
        region.hashCode ^
        banned.hashCode ^
        payterm.hashCode ^
        creditLimit.hashCode ^
        bannedFee.hashCode ^
        custGroup.hashCode ^
        email.hashCode ^
        businessStartDate.hashCode ^
        businessStatus.hashCode ^
        businessEntities.hashCode ^
        kindOfBusiness.hashCode ^
        building.hashCode ^
        employeeNum.hashCode ^
        taxStatus.hashCode ^
        officeType.hashCode ^
        ownership.hashCode ^
        knownFrom.hashCode ^
        omzet.hashCode ^
        ownerName.hashCode ^
        dob.hashCode ^
        cityOfBirth.hashCode ^
        husbandWife.hashCode ^
        idCard.hashCode ^
        idCardNo.hashCode ^
        copiIdCard.hashCode ^
        ownerAddress.hashCode ^
        ownerProvince.hashCode ^
        ownerCity.hashCode ^
        ownerPhone.hashCode ^
        ownerHp.hashCode ^
        ownerEmail.hashCode ^
        hariRaya.hashCode ^
        bank1.hashCode ^
        bank2.hashCode ^
        bank3.hashCode ^
        bankAtasNama1.hashCode ^
        bankAtasNama2.hashCode ^
        bankAtasNama3.hashCode ^
        paymentTipe1.hashCode ^
        paymentTipe2.hashCode ^
        paymentTipe3.hashCode ^
        alamatPenagihan.hashCode ^
        propinsiPenagihan.hashCode ^
        kotaPenagihan.hashCode ^
        tlpPenagihan.hashCode ^
        faxPenagihan.hashCode ^
        hariRaya.hashCode ^
        character.hashCode ^
        characterDesc.hashCode ^
        capacity.hashCode ^
        capacityDesc.hashCode ^
        capital.hashCode ^
        capitalDesc.hashCode ^
        collateral.hashCode ^
        collateralDesc.hashCode ^
        condition.hashCode ^
        conditionDesc.hashCode ^
        custNote.hashCode ^
        trDate.hashCode ^
        approve1Date.hashCode ^
        approve2Date.hashCode ^
        activeFlag.hashCode ^
        cofficeId.hashCode ^
        salesman.hashCode ^
        affiliate.hashCode ^
        district.hashCode ^
        vilage.hashCode ^
        cv.hashCode ^
        priceRole.hashCode ^
        priceRole2.hashCode ^
        cvId.hashCode ^
        noNib.hashCode ^
        noSkd.hashCode ^
        picOrder.hashCode ^
        picOrderJabatan.hashCode ^
        picOrderTelp.hashCode ^
        picOrderEmail.hashCode ^
        picTagihan.hashCode ^
        picTagihanJabatan.hashCode ^
        picTagihanTelp.hashCode ^
        picTagihanEmail.hashCode ^
        metodeBayar.hashCode ^
        dtModified.hashCode ^
        skbdn.hashCode ^
        custType.hashCode ^
        npwpGroup.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        gpsSetBy.hashCode ^
        gpsDtModified.hashCode ^
        nooDate.hashCode;
  }
}
