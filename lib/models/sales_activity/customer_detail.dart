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
  final String real_City;
  final String propinsi;
  final String region;
  final String banned;
  final String payterm;
  final String credit_limit;
  final String banned_fee;
  final String cust_group;
  final String email;
  final String business_start_date;
  final String business_status;
  final String business_entities;
  final String kind_of_business;
  final String building;
  final String employee_num;
  final String tax_status;
  final String office_tipe;
  final String ownership;
  final String known_from;
  final String omzet;
  final String owner_name;
  final String dob;
  final String city_of_birth;
  final String husband_wife;
  final String id_card;
  final String id_card_no;
  final String copi_id_card;
  final String owner_address;
  final String owner_province;
  final String owner_city;
  final String owner_phone;
  final String owner_hp;
  final String owner_email;
  final String hari_raya;
  final String bank1;
  final String bank2;
  final String bank3;
  final String bank_atas_nama1;
  final String bank_atas_nama2;
  final String bank_atas_nama3;
  final String payment_tipe1;
  final String payment_tipe2;
  final String payment_tipe3;
  final String alamat_penagihan;
  final String propinsi_penagihan;
  final String kota_penagihan;
  final String tlp_penagihan;
  final String fax_penagihan;
  final String hari_penagihan;
  final String character;
  final String character_desc;
  final String capacity;
  final String capacity_desc;
  final String capital;
  final String capital_desc;
  final String collateral;
  final String collateral_dessc;
  final String condition;
  final String condition_desc;
  final String cust_note;
  final String tr_date;
  final String approve1_date;
  final String approve2_date;
  final String active_flag;
  final String coffice_id;
  final String salesman;
  final String affiliate;
  final String district;
  final String vilage;
  final String cv;
  final String price_role;
  final String price_role2;
  final String cv_id;
  final String no_nib;
  final String no_skd;
  final String pic_order;
  final String pic_order_jabatan;
  final String pic_order_telp;
  final String pic_order_email;
  final String pic_tagihan;
  final String pic_tagihan_jabatan;
  final String pic_tagihan_telp;
  final String pic_tagihan_email;
  final String metode_bayar;
  final String dt_modified;
  final String skbdn;
  final String cust_type;
  final String npwp_group;
  final String latitude;
  final String longitude;
  final String gps_set_by;
  final String gps_dt_modified;
  final String noo_date;
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
    required this.real_City,
    required this.propinsi,
    required this.region,
    required this.banned,
    required this.payterm,
    required this.credit_limit,
    required this.banned_fee,
    required this.cust_group,
    required this.email,
    required this.business_start_date,
    required this.business_status,
    required this.business_entities,
    required this.kind_of_business,
    required this.building,
    required this.employee_num,
    required this.tax_status,
    required this.office_tipe,
    required this.ownership,
    required this.known_from,
    required this.omzet,
    required this.owner_name,
    required this.dob,
    required this.city_of_birth,
    required this.husband_wife,
    required this.id_card,
    required this.id_card_no,
    required this.copi_id_card,
    required this.owner_address,
    required this.owner_province,
    required this.owner_city,
    required this.owner_phone,
    required this.owner_hp,
    required this.owner_email,
    required this.hari_raya,
    required this.bank1,
    required this.bank2,
    required this.bank3,
    required this.bank_atas_nama1,
    required this.bank_atas_nama2,
    required this.bank_atas_nama3,
    required this.payment_tipe1,
    required this.payment_tipe2,
    required this.payment_tipe3,
    required this.alamat_penagihan,
    required this.propinsi_penagihan,
    required this.kota_penagihan,
    required this.tlp_penagihan,
    required this.fax_penagihan,
    required this.hari_penagihan,
    required this.character,
    required this.character_desc,
    required this.capacity,
    required this.capacity_desc,
    required this.capital,
    required this.capital_desc,
    required this.collateral,
    required this.collateral_dessc,
    required this.condition,
    required this.condition_desc,
    required this.cust_note,
    required this.tr_date,
    required this.approve1_date,
    required this.approve2_date,
    required this.active_flag,
    required this.coffice_id,
    required this.salesman,
    required this.affiliate,
    required this.district,
    required this.vilage,
    required this.cv,
    required this.price_role,
    required this.price_role2,
    required this.cv_id,
    required this.no_nib,
    required this.no_skd,
    required this.pic_order,
    required this.pic_order_jabatan,
    required this.pic_order_telp,
    required this.pic_order_email,
    required this.pic_tagihan,
    required this.pic_tagihan_jabatan,
    required this.pic_tagihan_telp,
    required this.pic_tagihan_email,
    required this.metode_bayar,
    required this.dt_modified,
    required this.skbdn,
    required this.cust_type,
    required this.npwp_group,
    required this.latitude,
    required this.longitude,
    required this.gps_set_by,
    required this.gps_dt_modified,
    required this.noo_date,
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
    String? real_City,
    String? propinsi,
    String? region,
    String? banned,
    String? payterm,
    String? credit_limit,
    String? banned_fee,
    String? cust_group,
    String? email,
    String? business_start_date,
    String? business_status,
    String? business_entities,
    String? kind_of_business,
    String? building,
    String? employee_num,
    String? tax_status,
    String? office_tipe,
    String? ownership,
    String? known_from,
    String? omzet,
    String? owner_name,
    String? dob,
    String? city_of_birth,
    String? husband_wife,
    String? id_card,
    String? id_card_no,
    String? copi_id_card,
    String? owner_address,
    String? owner_province,
    String? owner_city,
    String? owner_phone,
    String? owner_hp,
    String? owner_email,
    String? hari_raya,
    String? bank1,
    String? bank2,
    String? bank3,
    String? bank_atas_nama1,
    String? bank_atas_nama2,
    String? bank_atas_nama3,
    String? payment_tipe1,
    String? payment_tipe2,
    String? payment_tipe3,
    String? alamat_penagihan,
    String? propinsi_penagihan,
    String? kota_penagihan,
    String? tlp_penagihan,
    String? fax_penagihan,
    String? hari_penagihan,
    String? character,
    String? character_desc,
    String? capacity,
    String? capacity_desc,
    String? capital,
    String? capital_desc,
    String? collateral,
    String? collateral_dessc,
    String? condition,
    String? condition_desc,
    String? cust_note,
    String? tr_date,
    String? approve1_date,
    String? approve2_date,
    String? active_flag,
    String? coffice_id,
    String? salesman,
    String? affiliate,
    String? district,
    String? vilage,
    String? cv,
    String? price_role,
    String? price_role2,
    String? cv_id,
    String? no_nib,
    String? no_skd,
    String? pic_order,
    String? pic_order_jabatan,
    String? pic_order_telp,
    String? pic_order_email,
    String? pic_tagihan,
    String? pic_tagihan_jabatan,
    String? pic_tagihan_telp,
    String? pic_tagihan_email,
    String? metode_bayar,
    String? dt_modified,
    String? skbdn,
    String? cust_type,
    String? npwp_group,
    String? latitude,
    String? longitude,
    String? gps_set_by,
    String? gps_dt_modified,
    String? noo_date,
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
      real_City: real_City ?? this.real_City,
      propinsi: propinsi ?? this.propinsi,
      region: region ?? this.region,
      banned: banned ?? this.banned,
      payterm: payterm ?? this.payterm,
      credit_limit: credit_limit ?? this.credit_limit,
      banned_fee: banned_fee ?? this.banned_fee,
      cust_group: cust_group ?? this.cust_group,
      email: email ?? this.email,
      business_start_date: business_start_date ?? this.business_start_date,
      business_status: business_status ?? this.business_status,
      business_entities: business_entities ?? this.business_entities,
      kind_of_business: kind_of_business ?? this.kind_of_business,
      building: building ?? this.building,
      employee_num: employee_num ?? this.employee_num,
      tax_status: tax_status ?? this.tax_status,
      office_tipe: office_tipe ?? this.office_tipe,
      ownership: ownership ?? this.ownership,
      known_from: known_from ?? this.known_from,
      omzet: omzet ?? this.omzet,
      owner_name: owner_name ?? this.owner_name,
      dob: dob ?? this.dob,
      city_of_birth: city_of_birth ?? this.city_of_birth,
      husband_wife: husband_wife ?? this.husband_wife,
      id_card: id_card ?? this.id_card,
      id_card_no: id_card_no ?? this.id_card_no,
      copi_id_card: copi_id_card ?? this.copi_id_card,
      owner_address: owner_address ?? this.owner_address,
      owner_province: owner_province ?? this.owner_province,
      owner_city: owner_city ?? this.owner_city,
      owner_phone: owner_phone ?? this.owner_phone,
      owner_hp: owner_hp ?? this.owner_hp,
      owner_email: owner_email ?? this.owner_email,
      hari_raya: hari_raya ?? this.hari_raya,
      bank1: bank1 ?? this.bank1,
      bank2: bank2 ?? this.bank2,
      bank3: bank3 ?? this.bank3,
      bank_atas_nama1: bank_atas_nama1 ?? this.bank_atas_nama1,
      bank_atas_nama2: bank_atas_nama2 ?? this.bank_atas_nama2,
      bank_atas_nama3: bank_atas_nama3 ?? this.bank_atas_nama3,
      payment_tipe1: payment_tipe1 ?? this.payment_tipe1,
      payment_tipe2: payment_tipe2 ?? this.payment_tipe2,
      payment_tipe3: payment_tipe3 ?? this.payment_tipe3,
      alamat_penagihan: alamat_penagihan ?? this.alamat_penagihan,
      propinsi_penagihan: propinsi_penagihan ?? this.propinsi_penagihan,
      kota_penagihan: kota_penagihan ?? this.kota_penagihan,
      tlp_penagihan: tlp_penagihan ?? this.tlp_penagihan,
      fax_penagihan: fax_penagihan ?? this.fax_penagihan,
      hari_penagihan: hari_penagihan ?? this.hari_penagihan,
      character: character ?? this.character,
      character_desc: character_desc ?? this.character_desc,
      capacity: capacity ?? this.capacity,
      capacity_desc: capacity_desc ?? this.capacity_desc,
      capital: capital ?? this.capital,
      capital_desc: capital_desc ?? this.capital_desc,
      collateral: collateral ?? this.collateral,
      collateral_dessc: collateral_dessc ?? this.collateral_dessc,
      condition: condition ?? this.condition,
      condition_desc: condition_desc ?? this.condition_desc,
      cust_note: cust_note ?? this.cust_note,
      tr_date: tr_date ?? this.tr_date,
      approve1_date: approve1_date ?? this.approve1_date,
      approve2_date: approve2_date ?? this.approve2_date,
      active_flag: active_flag ?? this.active_flag,
      coffice_id: coffice_id ?? this.coffice_id,
      salesman: salesman ?? this.salesman,
      affiliate: affiliate ?? this.affiliate,
      district: district ?? this.district,
      vilage: vilage ?? this.vilage,
      cv: cv ?? this.cv,
      price_role: price_role ?? this.price_role,
      price_role2: price_role2 ?? this.price_role2,
      cv_id: cv_id ?? this.cv_id,
      no_nib: no_nib ?? this.no_nib,
      no_skd: no_skd ?? this.no_skd,
      pic_order: pic_order ?? this.pic_order,
      pic_order_jabatan: pic_order_jabatan ?? this.pic_order_jabatan,
      pic_order_telp: pic_order_telp ?? this.pic_order_telp,
      pic_order_email: pic_order_email ?? this.pic_order_email,
      pic_tagihan: pic_tagihan ?? this.pic_tagihan,
      pic_tagihan_jabatan: pic_tagihan_jabatan ?? this.pic_tagihan_jabatan,
      pic_tagihan_telp: pic_tagihan_telp ?? this.pic_tagihan_telp,
      pic_tagihan_email: pic_tagihan_email ?? this.pic_tagihan_email,
      metode_bayar: metode_bayar ?? this.metode_bayar,
      dt_modified: dt_modified ?? this.dt_modified,
      skbdn: skbdn ?? this.skbdn,
      cust_type: cust_type ?? this.cust_type,
      npwp_group: npwp_group ?? this.npwp_group,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gps_set_by: gps_set_by ?? this.gps_set_by,
      gps_dt_modified: gps_dt_modified ?? this.gps_dt_modified,
      noo_date: noo_date ?? this.noo_date,
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
      'Real_City': real_City,
      'Propinsi': propinsi,
      'Region': region,
      'Banned': banned,
      'payterm': payterm,
      'credit_limit': credit_limit,
      'banned_fee': banned_fee,
      'cust_group': cust_group,
      'email': email,
      'business_start_date': business_start_date,
      'business_status': business_status,
      'business_entities': business_entities,
      'kind_of_business': kind_of_business,
      'building': building,
      'employee_num': employee_num,
      'tax_status': tax_status,
      'office_tipe': office_tipe,
      'ownership': ownership,
      'known_from': known_from,
      'omzet': omzet,
      'owner_name': owner_name,
      'dob': dob,
      'city_of_birth': city_of_birth,
      'husband_wife': husband_wife,
      'id_card': id_card,
      'id_card_no': id_card_no,
      'copi_id_card': copi_id_card,
      'owner_address': owner_address,
      'owner_province': owner_province,
      'owner_city': owner_city,
      'owner_phone': owner_phone,
      'owner_hp': owner_hp,
      'owner_email': owner_email,
      'hari_raya': hari_raya,
      'bank1': bank1,
      'bank2': bank2,
      'bank3': bank3,
      'bank_atas_nama1': bank_atas_nama1,
      'bank_atas_nama2': bank_atas_nama2,
      'bank_atas_nama3': bank_atas_nama3,
      'payment_tipe1': payment_tipe1,
      'payment_tipe2': payment_tipe2,
      'payment_tipe3': payment_tipe3,
      'alamat_penagihan': alamat_penagihan,
      'propinsi_penagihan': propinsi_penagihan,
      'kota_penagihan': kota_penagihan,
      'tlp_penagihan': tlp_penagihan,
      'fax_penagihan': fax_penagihan,
      'hari_penagihan': hari_penagihan,
      'character': character,
      'character_desc': character_desc,
      'capacity': capacity,
      'capacity_desc': capacity_desc,
      'capital': capital,
      'capital_desc': capital_desc,
      'collateral': collateral,
      'collateral_dessc': collateral_dessc,
      'condition': condition,
      'condition_desc': condition_desc,
      'cust_note': cust_note,
      'tr_date': tr_date,
      'approve1_date': approve1_date,
      'approve2_date': approve2_date,
      'active_flag': active_flag,
      'coffice_id': coffice_id,
      'salesman': salesman,
      'affiliate': affiliate,
      'district': district,
      'vilage': vilage,
      'cv': cv,
      'price_role': price_role,
      'price_role2': price_role2,
      'cv_id': cv_id,
      'no_nib': no_nib,
      'no_skd': no_skd,
      'pic_order': pic_order,
      'pic_order_jabatan': pic_order_jabatan,
      'pic_order_telp': pic_order_telp,
      'pic_order_email': pic_order_email,
      'pic_tagihan': pic_tagihan,
      'pic_tagihan_jabatan': pic_tagihan_jabatan,
      'pic_tagihan_telp': pic_tagihan_telp,
      'pic_tagihan_email': pic_tagihan_email,
      'metode_bayar': metode_bayar,
      'dt_modified': dt_modified,
      'skbdn': skbdn,
      'cust_type': cust_type,
      'npwp_group': npwp_group,
      'latitude': latitude,
      'longitude': longitude,
      'gps_set_by': gps_set_by,
      'gps_dt_modified': gps_dt_modified,
      'noo_date': noo_date,
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
      real_City: map['Real_City'] ?? '',
      propinsi: map['Propinsi'] ?? '',
      region: map['Region'] ?? '',
      banned: map['Banned'] ?? '',
      payterm: map['payterm'] ?? '',
      credit_limit: map['credit_limit'] ?? '',
      banned_fee: map['banned_fee'] ?? '',
      cust_group: map['cust_group'] ?? '',
      email: map['email'] ?? '',
      business_start_date: map['business_start_date'] ?? '',
      business_status: map['business_status'] ?? '',
      business_entities: map['business_entities'] ?? '',
      kind_of_business: map['kind_of_business'] ?? '',
      building: map['building'] ?? '',
      employee_num: map['employee_num'] ?? '',
      tax_status: map['tax_status'] ?? '',
      office_tipe: map['office_tipe'] ?? '',
      ownership: map['ownership'] ?? '',
      known_from: map['known_from'] ?? '',
      omzet: map['omzet'] ?? '',
      owner_name: map['owner_name'] ?? '',
      dob: map['dob'] ?? '',
      city_of_birth: map['city_of_birth'] ?? '',
      husband_wife: map['husband_wife'] ?? '',
      id_card: map['id_card'] ?? '',
      id_card_no: map['id_card_no'] ?? '',
      copi_id_card: map['copi_id_card'] ?? '',
      owner_address: map['owner_address'] ?? '',
      owner_province: map['owner_province'] ?? '',
      owner_city: map['owner_city'] ?? '',
      owner_phone: map['owner_phone'] ?? '',
      owner_hp: map['owner_hp'] ?? '',
      owner_email: map['owner_email'] ?? '',
      hari_raya: map['hari_raya'] ?? '',
      bank1: map['bank1'] ?? '',
      bank2: map['bank2'] ?? '',
      bank3: map['bank3'] ?? '',
      bank_atas_nama1: map['bank_atas_nama1'] ?? '',
      bank_atas_nama2: map['bank_atas_nama2'] ?? '',
      bank_atas_nama3: map['bank_atas_nama3'] ?? '',
      payment_tipe1: map['payment_tipe1'] ?? '',
      payment_tipe2: map['payment_tipe2'] ?? '',
      payment_tipe3: map['payment_tipe3'] ?? '',
      alamat_penagihan: map['alamat_penagihan'] ?? '',
      propinsi_penagihan: map['propinsi_penagihan'] ?? '',
      kota_penagihan: map['kota_penagihan'] ?? '',
      tlp_penagihan: map['tlp_penagihan'] ?? '',
      fax_penagihan: map['fax_penagihan'] ?? '',
      hari_penagihan: map['hari_penagihan'] ?? '',
      character: map['character'] ?? '',
      character_desc: map['character_desc'] ?? '',
      capacity: map['capacity'] ?? '',
      capacity_desc: map['capacity_desc'] ?? '',
      capital: map['capital'] ?? '',
      capital_desc: map['capital_desc'] ?? '',
      collateral: map['collateral'] ?? '',
      collateral_dessc: map['collateral_dessc'] ?? '',
      condition: map['condition'] ?? '',
      condition_desc: map['condition_desc'] ?? '',
      cust_note: map['cust_note'] ?? '',
      tr_date: map['tr_date'] ?? '',
      approve1_date: map['approve1_date'] ?? '',
      approve2_date: map['approve2_date'] ?? '',
      active_flag: map['active_flag'] ?? '',
      coffice_id: map['coffice_id'] ?? '',
      salesman: map['salesman'] ?? '',
      affiliate: map['affiliate'] ?? '',
      district: map['district'] ?? '',
      vilage: map['vilage'] ?? '',
      cv: map['cv'] ?? '',
      price_role: map['price_role'] ?? '',
      price_role2: map['price_role2'] ?? '',
      cv_id: map['cv_id'] ?? '',
      no_nib: map['no_nib'] ?? '',
      no_skd: map['no_skd'] ?? '',
      pic_order: map['pic_order'] ?? '',
      pic_order_jabatan: map['pic_order_jabatan'] ?? '',
      pic_order_telp: map['pic_order_telp'] ?? '',
      pic_order_email: map['pic_order_email'] ?? '',
      pic_tagihan: map['pic_tagihan'] ?? '',
      pic_tagihan_jabatan: map['pic_tagihan_jabatan'] ?? '',
      pic_tagihan_telp: map['pic_tagihan_telp'] ?? '',
      pic_tagihan_email: map['pic_tagihan_email'] ?? '',
      metode_bayar: map['metode_bayar'] ?? '',
      dt_modified: map['dt_modified'] ?? '',
      skbdn: map['skbdn'] ?? '',
      cust_type: map['cust_type'] ?? '',
      npwp_group: map['npwp_group'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      gps_set_by: map['gps_set_by'] ?? '',
      gps_dt_modified: map['gps_dt_modified'] ?? '',
      noo_date: map['noo_date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerDetail.fromJson(String source) =>
      CustomerDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CustomerDetail(customerId: $customerId, salesId: $salesId, namaCustomer: $namaCustomer, alamat: $alamat, kota: $kota, telepon: $telepon, perTanggal: $perTanggal, fax: $fax, npwp: $npwp, person: $person, jabatan: $jabatan, real_City: $real_City, propinsi: $propinsi, region: $region, banned: $banned, payterm: $payterm, credit_limit: $credit_limit, banned_fee: $banned_fee, cust_group: $cust_group, email: $email, business_start_date: $business_start_date, business_status: $business_status, business_entities: $business_entities, kind_of_business: $kind_of_business, building: $building, employee_num: $employee_num, tax_status: $tax_status, office_tipe: $office_tipe, ownership: $ownership, known_from: $known_from, omzet: $omzet, owner_name: $owner_name, dob: $dob, city_of_birth: $city_of_birth, husband_wife: $husband_wife, id_card: $id_card, id_card_no: $id_card_no, copi_id_card: $copi_id_card, owner_address: $owner_address, owner_province: $owner_province, owner_city: $owner_city, owner_phone: $owner_phone, owner_hp: $owner_hp, owner_email: $owner_email, hari_raya: $hari_raya, bank1: $bank1, bank2: $bank2, bank3: $bank3, bank_atas_nama1: $bank_atas_nama1, bank_atas_nama2: $bank_atas_nama2, bank_atas_nama3: $bank_atas_nama3, payment_tipe1: $payment_tipe1, payment_tipe2: $payment_tipe2, payment_tipe3: $payment_tipe3, alamat_penagihan: $alamat_penagihan, propinsi_penagihan: $propinsi_penagihan, kota_penagihan: $kota_penagihan, tlp_penagihan: $tlp_penagihan, fax_penagihan: $fax_penagihan, hari_penagihan: $hari_penagihan, character: $character, character_desc: $character_desc, capacity: $capacity, capacity_desc: $capacity_desc, capital: $capital, capital_desc: $capital_desc, collateral: $collateral, collateral_dessc: $collateral_dessc, condition: $condition, condition_desc: $condition_desc, cust_note: $cust_note, tr_date: $tr_date, approve1_date: $approve1_date, approve2_date: $approve2_date, active_flag: $active_flag, coffice_id: $coffice_id, salesman: $salesman, affiliate: $affiliate, district: $district, vilage: $vilage, cv: $cv, price_role: $price_role, price_role2: $price_role2, cv_id: $cv_id, no_nib: $no_nib, no_skd: $no_skd, pic_order: $pic_order, pic_order_jabatan: $pic_order_jabatan, pic_order_telp: $pic_order_telp, pic_order_email: $pic_order_email, pic_tagihan: $pic_tagihan, pic_tagihan_jabatan: $pic_tagihan_jabatan, pic_tagihan_telp: $pic_tagihan_telp, pic_tagihan_email: $pic_tagihan_email, metode_bayar: $metode_bayar, dt_modified: $dt_modified, skbdn: $skbdn, cust_type: $cust_type, npwp_group: $npwp_group, latitude: $latitude, longitude: $longitude, gps_set_by: $gps_set_by, gps_dt_modified: $gps_dt_modified, noo_date: $noo_date)';
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
        other.real_City == real_City &&
        other.propinsi == propinsi &&
        other.region == region &&
        other.banned == banned &&
        other.payterm == payterm &&
        other.credit_limit == credit_limit &&
        other.banned_fee == banned_fee &&
        other.cust_group == cust_group &&
        other.email == email &&
        other.business_start_date == business_start_date &&
        other.business_status == business_status &&
        other.business_entities == business_entities &&
        other.kind_of_business == kind_of_business &&
        other.building == building &&
        other.employee_num == employee_num &&
        other.tax_status == tax_status &&
        other.office_tipe == office_tipe &&
        other.ownership == ownership &&
        other.known_from == known_from &&
        other.omzet == omzet &&
        other.owner_name == owner_name &&
        other.dob == dob &&
        other.city_of_birth == city_of_birth &&
        other.husband_wife == husband_wife &&
        other.id_card == id_card &&
        other.id_card_no == id_card_no &&
        other.copi_id_card == copi_id_card &&
        other.owner_address == owner_address &&
        other.owner_province == owner_province &&
        other.owner_city == owner_city &&
        other.owner_phone == owner_phone &&
        other.owner_hp == owner_hp &&
        other.owner_email == owner_email &&
        other.hari_raya == hari_raya &&
        other.bank1 == bank1 &&
        other.bank2 == bank2 &&
        other.bank3 == bank3 &&
        other.bank_atas_nama1 == bank_atas_nama1 &&
        other.bank_atas_nama2 == bank_atas_nama2 &&
        other.bank_atas_nama3 == bank_atas_nama3 &&
        other.payment_tipe1 == payment_tipe1 &&
        other.payment_tipe2 == payment_tipe2 &&
        other.payment_tipe3 == payment_tipe3 &&
        other.alamat_penagihan == alamat_penagihan &&
        other.propinsi_penagihan == propinsi_penagihan &&
        other.kota_penagihan == kota_penagihan &&
        other.tlp_penagihan == tlp_penagihan &&
        other.fax_penagihan == fax_penagihan &&
        other.hari_penagihan == hari_penagihan &&
        other.character == character &&
        other.character_desc == character_desc &&
        other.capacity == capacity &&
        other.capacity_desc == capacity_desc &&
        other.capital == capital &&
        other.capital_desc == capital_desc &&
        other.collateral == collateral &&
        other.collateral_dessc == collateral_dessc &&
        other.condition == condition &&
        other.condition_desc == condition_desc &&
        other.cust_note == cust_note &&
        other.tr_date == tr_date &&
        other.approve1_date == approve1_date &&
        other.approve2_date == approve2_date &&
        other.active_flag == active_flag &&
        other.coffice_id == coffice_id &&
        other.salesman == salesman &&
        other.affiliate == affiliate &&
        other.district == district &&
        other.vilage == vilage &&
        other.cv == cv &&
        other.price_role == price_role &&
        other.price_role2 == price_role2 &&
        other.cv_id == cv_id &&
        other.no_nib == no_nib &&
        other.no_skd == no_skd &&
        other.pic_order == pic_order &&
        other.pic_order_jabatan == pic_order_jabatan &&
        other.pic_order_telp == pic_order_telp &&
        other.pic_order_email == pic_order_email &&
        other.pic_tagihan == pic_tagihan &&
        other.pic_tagihan_jabatan == pic_tagihan_jabatan &&
        other.pic_tagihan_telp == pic_tagihan_telp &&
        other.pic_tagihan_email == pic_tagihan_email &&
        other.metode_bayar == metode_bayar &&
        other.dt_modified == dt_modified &&
        other.skbdn == skbdn &&
        other.cust_type == cust_type &&
        other.npwp_group == npwp_group &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.gps_set_by == gps_set_by &&
        other.gps_dt_modified == gps_dt_modified &&
        other.noo_date == noo_date;
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
        real_City.hashCode ^
        propinsi.hashCode ^
        region.hashCode ^
        banned.hashCode ^
        payterm.hashCode ^
        credit_limit.hashCode ^
        banned_fee.hashCode ^
        cust_group.hashCode ^
        email.hashCode ^
        business_start_date.hashCode ^
        business_status.hashCode ^
        business_entities.hashCode ^
        kind_of_business.hashCode ^
        building.hashCode ^
        employee_num.hashCode ^
        tax_status.hashCode ^
        office_tipe.hashCode ^
        ownership.hashCode ^
        known_from.hashCode ^
        omzet.hashCode ^
        owner_name.hashCode ^
        dob.hashCode ^
        city_of_birth.hashCode ^
        husband_wife.hashCode ^
        id_card.hashCode ^
        id_card_no.hashCode ^
        copi_id_card.hashCode ^
        owner_address.hashCode ^
        owner_province.hashCode ^
        owner_city.hashCode ^
        owner_phone.hashCode ^
        owner_hp.hashCode ^
        owner_email.hashCode ^
        hari_raya.hashCode ^
        bank1.hashCode ^
        bank2.hashCode ^
        bank3.hashCode ^
        bank_atas_nama1.hashCode ^
        bank_atas_nama2.hashCode ^
        bank_atas_nama3.hashCode ^
        payment_tipe1.hashCode ^
        payment_tipe2.hashCode ^
        payment_tipe3.hashCode ^
        alamat_penagihan.hashCode ^
        propinsi_penagihan.hashCode ^
        kota_penagihan.hashCode ^
        tlp_penagihan.hashCode ^
        fax_penagihan.hashCode ^
        hari_penagihan.hashCode ^
        character.hashCode ^
        character_desc.hashCode ^
        capacity.hashCode ^
        capacity_desc.hashCode ^
        capital.hashCode ^
        capital_desc.hashCode ^
        collateral.hashCode ^
        collateral_dessc.hashCode ^
        condition.hashCode ^
        condition_desc.hashCode ^
        cust_note.hashCode ^
        tr_date.hashCode ^
        approve1_date.hashCode ^
        approve2_date.hashCode ^
        active_flag.hashCode ^
        coffice_id.hashCode ^
        salesman.hashCode ^
        affiliate.hashCode ^
        district.hashCode ^
        vilage.hashCode ^
        cv.hashCode ^
        price_role.hashCode ^
        price_role2.hashCode ^
        cv_id.hashCode ^
        no_nib.hashCode ^
        no_skd.hashCode ^
        pic_order.hashCode ^
        pic_order_jabatan.hashCode ^
        pic_order_telp.hashCode ^
        pic_order_email.hashCode ^
        pic_tagihan.hashCode ^
        pic_tagihan_jabatan.hashCode ^
        pic_tagihan_telp.hashCode ^
        pic_tagihan_email.hashCode ^
        metode_bayar.hashCode ^
        dt_modified.hashCode ^
        skbdn.hashCode ^
        cust_type.hashCode ^
        npwp_group.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        gps_set_by.hashCode ^
        gps_dt_modified.hashCode ^
        noo_date.hashCode;
  }
}
