class DefaultConfigs {
  static const Map<String, dynamic> defaultDocumentRules = {
    "ic_renewal_damaged": {
      "agency": "JPN (Jabatan Pendaftaran Negara)",
      "fee": "RM10",
      "requires_police_report": false,
      "required_items": [
        "Damaged MyKad",
        "1 passport-size photo (if requested)"
      ],
      "official_portal": "https://www.jpn.gov.my",
      "last_verified": "2026-08-24"
    },
    "ic_renewal_lost_first": {
      "agency": "JPN (Jabatan Pendaftaran Negara)",
      "fee": "RM110 (RM100 penalty + RM10 application)",
      "requires_police_report": true,
      "required_items": [
        "Police report",
        "1 passport-size photo"
      ],
      "official_portal": "https://www.jpn.gov.my",
      "last_verified": "2026-08-24"
    },
    "ic_renewal_lost_second": {
      "agency": "JPN (Jabatan Pendaftaran Negara)",
      "fee": "RM310",
      "requires_police_report": true,
      "required_items": [
        "Police report",
        "1 passport-size photo"
      ],
      "official_portal": "https://www.jpn.gov.my",
      "last_verified": "2026-08-24"
    },
    "ic_renewal_lost_third_plus": {
      "agency": "JPN (Jabatan Pendaftaran Negara)",
      "fee": "RM1,010",
      "requires_police_report": true,
      "required_items": [
        "Police report",
        "1 passport-size photo"
      ],
      "official_portal": "https://www.jpn.gov.my",
      "last_verified": "2026-08-24"
    },
    "ic_renewal_address_change": {
      "agency": "JPN (Jabatan Pendaftaran Negara)",
      "fee": "RM10",
      "requires_police_report": false,
      "required_items": [
        "Current MyKad",
        "Proof of new address (e.g. Utility bill under own name)"
      ],
      "official_portal": "https://www.jpn.gov.my",
      "last_verified": "2026-08-24"
    },
    "roadtax_driving_license": {
      "agency": "JPJ / Pos Malaysia / MyEG",
      "fee": null,
      "requires_police_report": false,
      "required_items": [
        "Valid vehicle insurance (cover note or policy)",
        "Valid Puspakom inspection certificate (if commercial or expired > 3 years)",
        "Current Driving License / MyKad"
      ],
      "official_portal": "https://www.jpj.gov.my",
      "last_verified": "2026-08-24"
    },
    "income_tax": {
      "agency": "LHDN (Lembaga Hasil Dalam Negeri)",
      "fee": null,
      "requires_police_report": false,
      "required_items": [
        "Tax assessment form or notice",
        "MyTax Portal login / MyDigital ID",
        "Bank account details for refund/payment"
      ],
      "official_portal": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "traffic_summons": {
      "agency": "PDRM (Polis Diraja Malaysia) / JPJ",
      "fee": null,
      "requires_police_report": false,
      "required_items": [
        "Summons notice / Compound number",
        "MyKad or Driving License for payment identification"
      ],
      "official_portal": "https://mybayar.rmp.gov.my",
      "last_verified": "2026-08-24"
    },
    "epf_kwsp": {
      "agency": "KWSP (Kumpulan Wang Simpanan Pekerja)",
      "fee": "Free",
      "requires_police_report": false,
      "required_items": [
        "MyKad (IC)",
        "EPF i-Akaun Mobile App / Login ID"
      ],
      "official_portal": "https://www.kwsp.gov.my",
      "last_verified": "2026-08-24"
    },
    "socso_perkeso": {
      "agency": "PERKESO (Pertubuhan Keselamatan Sosial)",
      "fee": "Free",
      "requires_police_report": false,
      "required_items": [
        "MyKad (IC)",
        "Employer confirmation letter (for claims)",
        "Medical reports (if applicable)"
      ],
      "official_portal": "https://www.perkeso.gov.my",
      "last_verified": "2026-08-24"
    },
    "electricity_tnb": {
      "agency": "TNB (Tenaga Nasional Berhad)",
      "fee": null,
      "requires_police_report": false,
      "required_items": [
        "TNB bill statement",
        "MyTNB App or online portal account"
      ],
      "official_portal": "https://www.mytnb.com.my",
      "last_verified": "2026-08-24"
    },
    "lhdn_notice_of_assessment": {
      "agency": "LHDN (Inland Revenue Board of Malaysia)",
      "fee": "Calculated upon assessment",
      "requires_police_report": false,
      "required_items": [
        "Tax assessment notice Borang J",
        "EA/EC form / Income statements",
        "Receipt of previous tax payments"
      ],
      "official_portal": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "lhdn_notice_of_additional_assessment": {
      "agency": "LHDN (Inland Revenue Board of Malaysia)",
      "fee": "Varies based on audit findings",
      "requires_police_report": false,
      "required_items": [
        "Notice of additional assessment Borang JA",
        "Tax audit findings statement",
        "Ledgers and receipts supporting claims"
      ],
      "official_portal": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "lhdn_cp500": {
      "agency": "LHDN (Inland Revenue Board of Malaysia)",
      "fee": "Instalment amount on CP500 notice",
      "requires_police_report": false,
      "required_items": [
        "CP500 payment notice",
        "Taxpayer IC number",
        "MyTax Portal login / Bill number"
      ],
      "official_portal": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "lhdn_audit_notice": {
      "agency": "LHDN (Inland Revenue Board of Malaysia)",
      "fee": "None (Audits do not require upfront payment)",
      "requires_police_report": false,
      "required_items": [
        "Official LHDN Audit notice letter",
        "Bank statements and ledger files",
        "Receipts for tax reliefs claimed"
      ],
      "official_portal": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "court_notice": {
      "agency": "Malaysian Judiciary",
      "fee": "Varies depending on hearing details",
      "requires_police_report": false,
      "required_items": [
        "Court summons / Writ / Subpoena",
        "MyKad (IC)",
        "Evidence supporting the legal dispute"
      ],
      "official_portal": "https://ekehakiman.kehakiman.gov.my",
      "last_verified": "2026-08-24"
    },
    "epf_kwsp_letter": {
      "agency": "KWSP (Employees Provident Fund)",
      "fee": "Free",
      "requires_police_report": false,
      "required_items": [
        "KWSP official letter / statement",
        "MyKad (IC)",
        "i-Akaun app / login details"
      ],
      "official_portal": "https://www.kwsp.gov.my",
      "last_verified": "2026-08-24"
    },
    "socso_perkeso_letter": {
      "agency": "PERKESO (Pertubuhan Keselamatan Sosial)",
      "fee": "Free",
      "requires_police_report": false,
      "required_items": [
        "PERKESO official letter / notice",
        "MyKad (IC)",
        "Medical records or claims files"
      ],
      "official_portal": "https://www.perkeso.gov.my",
      "last_verified": "2026-08-24"
    },
    "unknown": {
      "agency": "MyGovernment Central Portal",
      "fee": null,
      "requires_police_report": false,
      "required_items": [
        "MyKad (IC)",
        "Original document for reference"
      ],
      "official_portal": "https://www.malaysia.gov.my",
      "last_verified": "2026-08-24"
    }
  };

  static const Map<String, dynamic> defaultGovernmentDirectory = {
    "ic_mykad": {
      "portal": "https://www.jpn.gov.my",
      "online_service": "Sistem Gantian MyKad (online MyKad replacement, login via MyDigital ID)",
      "app": "MyGov / MyDigital ID",
      "last_verified": "2026-08-24"
    },
    "roadtax_driving_license": {
      "apps": ["MyJPJ", "MyEG", "Pos Malaysia app"],
      "portal": "https://www.jpj.gov.my",
      "last_verified": "2026-08-24"
    },
    "traffic_summons": {
      "app": "PDRM app / MyBayar PDRM",
      "portal": "https://mybayar.rmp.gov.my",
      "last_verified": "2026-08-24"
    },
    "income_tax": {
      "portal": "MyTax Portal (LHDN)",
      "url": "https://mytax.hasil.gov.my",
      "last_verified": "2026-08-24"
    },
    "passport": {
      "service": "MyIMMs / Online Passport Renewal",
      "portal": "https://imigresen-online.imi.gov.my/eservices/myPasport",
      "last_verified": "2026-08-24"
    },
    "epf_kwsp": {
      "app": "EPF i-Akaun",
      "portal": "https://www.kwsp.gov.my",
      "last_verified": "2026-08-24"
    },
    "socso_perkeso": {
      "portal": "https://www.perkeso.gov.my",
      "last_verified": "2026-08-24"
    },
    "pension_retirees": {
      "app": "MyPesara",
      "portal": "https://jpapencen.gov.my",
      "last_verified": "2026-08-24"
    },
    "electricity_tnb": {
      "app": "myTNB",
      "portal": "https://www.mytnb.com.my",
      "last_verified": "2026-08-24"
    },
    "central_gateway": {
      "portal": "https://www.malaysia.gov.my",
      "app_directory": "https://gamma.malaysia.gov.my",
      "digital_id": "MyDigital ID",
      "last_verified": "2026-08-24"
    }
  };

  static const Map<String, dynamic> defaultVerificationContacts = {
    "lhdn": {
      "agency_name": "LHDN (Lembaga Hasil Dalam Negeri)",
      "hotline": "1-800-88-5436",
      "portal": "mytax.hasil.gov.my",
      "app": "MyTax App"
    },
    "jpn": {
      "agency_name": "JPN (Jabatan Pendaftaran Negara)",
      "hotline": "03-8000 8000",
      "portal": "jpn.gov.my",
      "app": "MyGov / MyDigital ID"
    },
    "jpj": {
      "agency_name": "JPJ (Jabatan Pengangkutan Jalan)",
      "hotline": "03-8000 8000",
      "portal": "jpj.gov.my",
      "app": "MyJPJ"
    },
    "pdrm": {
      "agency_name": "PDRM (Polis Diraja Malaysia)",
      "hotline": "03-2610 1222",
      "portal": "mybayar.rmp.gov.my",
      "app": "MyBayar PDRM"
    },
    "kwsp": {
      "agency_name": "KWSP (Employees Provident Fund)",
      "hotline": "03-8922 6000",
      "portal": "kwsp.gov.my",
      "app": "EPF i-Akaun"
    },
    "perkeso": {
      "agency_name": "PERKESO (SOCSO)",
      "hotline": "1-300-22-8000",
      "portal": "perkeso.gov.my",
      "app": "Matrix Portal"
    },
    "central_gateway": {
      "agency_name": "MyGovernment Central Gateway",
      "hotline": "03-8000 8000",
      "portal": "malaysia.gov.my",
      "app": "MyGov"
    }
  };
}
