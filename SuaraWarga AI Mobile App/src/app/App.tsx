import { useState, useEffect, useRef, createContext, useContext } from "react";
import { motion, AnimatePresence } from "motion/react";

// ── Types ──────────────────────────────────────────────────────────────────
type Screen =
  | "login"
  | "register"
  | "home"
  | "listening"
  | "processing"
  | "govServices"
  | "letterInterpreter"
  | "formAssistant"
  | "docChecker"
  | "smartMobility"
  | "tropicalRoute"
  | "transitGuide"
  | "walkability"
  | "profile"
  | "history"
  | "notifications";

type NavTab = "home" | "history" | "notifications" | "profile";

interface EmergencyContact {
  name: string;
  phone: string;
  relationship: string;
}

type AppLang = "en" | "bm" | "zh" | "ta";

interface User {
  name: string;
  ic: string;
  phone: string;
  uiLang: AppLang;
  voiceLang: string;
  emergencyContact?: EmergencyContact;
}

// ── Translations ───────────────────────────────────────────────────────────
const T = {
  en: {
    greeting: "Good morning", tapToSpeak: "Tap to speak", trySaying: "Try saying...",
    homeSubtitle: "Speak naturally in your preferred language or dialect.",
    govServices: "Government Services", smartMobility: "Smart Mobility",
    aiTools: "4 AI tools", aiRoutes: "AI-powered routes",
    navHome: "Home", navHistory: "History", navAlerts: "Alerts", navProfile: "Profile",
    listening: "Listening...", recognising: "Recognising...", understood: "Understood",
    detectedDialect: "Detected Dialect", aiUnderstanding: "AI Understanding",
    continueBtn: "Continue", signIn: "Sign In", createAccount: "Create Account",
    signOut: "Sign Out", cancel: "Cancel",
    stepPersonal: "Personal Info", stepLanguage: "Language", stepPassword: "Set Password", stepEmergency: "Emergency Contact",
    profileTitle: "My Profile", langSection: "Language & Dialect",
    appLangLabel: "App Language", voiceLangLabel: "Voice Listening Language",
    voiceLangHint: "The language AI listens & responds in",
    accessibility: "Accessibility", largeText: "Large Text", highContrast: "High Contrast",
    voiceSpeed: "Voice Speed", voiceSpeedHint: "Tap a speed — AI will speak a preview",
    activityHistory: "Activity History", notifications: "Notifications",
    markAllRead: "Mark all as read", emergencyContact: "Emergency Contact",
    getStarted: "Get Started",
    splashTagline: "Your Voice. Your Access. Your Independence.",
    splashPowered: "Powered by AI · Developed for Track T5",
    signInToContinue: "Sign in to continue",
    welcomeBack: "Welcome Back",
    icNumberLabel: "IC Number (MyKad)",
    passwordLabel: "Password",
    enterPassword: "Enter your password",
    forgotPassword: "Forgot Password?",
    signingIn: "Signing in...",
    orText: "or",
    loginHelpHint: "Having trouble? Ask a family member to help you sign in.",
    noAccount: "New user?",
    regPersonalInfo: "Personal Info", regLangSetup: "Language Setup", regSetPassword: "Set Password", regEmergencyStep: "Emergency Contact",
    regStepOf: "Step", regStepOf2: "of 4 —",
    regFullName: "Full Name (as in IC)", regPhoneNumber: "Phone Number",
    regAppLang: "App Display Language",
    regAppLangDesc: "This controls the language used throughout the app.",
    regVoiceLangDesc: "The language or dialect the AI mic will listen for.",
    regLangTip: "You can change both settings any time from your Profile.",
    regNewPassword: "New Password", regMinCharsPlaceholder: "Min. 6 characters",
    regPassTip: "Use a password you can remember easily, like your child's name + birth year.",
    regConfirmPassword: "Confirm Password", regReenterPassword: "Re-enter password",
    regAccountSummary: "Account Summary",
    regEcWho: "Who should we call if you need help? This person will be shown on your profile.",
    regEcReachable: "This contact will be reachable from your profile at any time.",
    regContactFullName: "Contact Full Name", regContactPhone: "Contact Phone Number",
    regRelationship: "Relationship", regCreatingAccount: "Creating Account...",
    alreadyHaveAccount: "Already have an account?",
    relSon: "Son", relDaughter: "Daughter", relSpouse: "Spouse", relSibling: "Sibling",
    relGrandchild: "Grandchild", relFriend: "Friend", relCarer: "Carer",
    passWeak: "Weak", passFair: "Fair", passStrong: "Strong",
    qlLetterInterpreter: "Letter Interpreter", qlFormAssistant: "Smart Form Assistant",
    qlDocChecker: "Document Checker", qlWalkability: "Community Walkability",
    voiceInput: "Voice Input", processingWithAI: "Processing with AI...",
    aiProcessing: "AI Processing", openingNow: "Opening now",
    govHubSubtitle: "4 AI-powered tools", govBannerTitle: "AI Super-Assistant",
    govBannerDesc: "Handles IC, passport, utilities & more",
    govSvc1Title: "Voice & Dialect AI Assistant", govSvc1Desc: "Speak in Hokkien, Cantonese, Malay, or English",
    govSvc2Title: "Government Letter Interpreter", govSvc2Desc: "Scan letters — AI explains in simple language",
    govSvc3Title: "Smart Form Assistant", govSvc3Desc: "AI guides you through forms step-by-step",
    govSvc4Title: "Document Readiness Checker", govSvc4Desc: "Know exactly what documents to bring",
    govHint: "Just tap the mic and say what you need — AI will guide you automatically in your language.",
    listeningLabel: "Listening...", typeAnswer: "Type your answer...",
    letterTitle: "Letter Interpreter", letterSubtitle: "OCR + AI Explanation",
    uploadPhotoPrompt: "Upload or take a photo of your government letter",
    takePhoto: "Take Photo", uploadFile: "Upload File",
    supportedFormats: "Supports PDF, JPG, PNG",
    exampleLetters: "Example letters handled:",
    exampleLettersList: "MyKad renewal notice · LHDN · Utility bills · Court summons · Hospital appointment",
    textExtracted: "Text extracted", aiExplanationLabel: "AI Explanation",
    letterAiResult: "This is a letter from JPN. You must renew your MyKad before 28 Feb 2025.",
    deadlineLabel: "Deadline", askAboutLetter: "Ask about this letter",
    scanAnotherLetter: "Scan Another Letter",
    formAssistantTitle: "Smart Form Assistant", aiGuidesStep: "AI guides you step by step",
    formProgress: "Form Progress", formStepLabel: "Step", formOfLabel: "of",
    formPersonalInfo: "Personal Info", formAddressDetails: "Address Details", formFinalReview: "Final Review",
    docCheckerTitle: "Document Checker", docForMyKad: "For: MyKad Renewal",
    docReadyLabel: "Ready", docMissingLabel: "document(s) missing",
    docMyKad: "MyKad (IC)", docUtilityBill: "Utility Bill (latest 3 months)",
    docPassportPhoto: "Passport Photo (2 copies)", docBirthCert: "Birth Certificate",
    docBankStatement: "Bank Statement",
    missingDocsTitle: "Missing Documents — How to Get Them",
    visitJpnOffice: "Visit nearest photo studio or JPN office",
    askAiHelp: "Ask AI for Help",
    whereTo: "Where do you want to go?", findingRoute: "Finding best route...",
    destinationLabel: "Destination", awayLabel: "away",
    tempLabel: "Temp", humidityLabel: "Humidity", uvIndexLabel: "UV Index",
    aiRecommendation: "AI Recommendation", takePublicTransport: "Take Public Transport",
    tooHotForWalking: "Too hot & humid for walking",
    aiRecommendsBus: "AI recommends bus for comfort and safety.",
    walkingComfortScore: "Walking Comfort Score", lowComfort: "Low Comfort",
    aiRouteBtn: "AI Routes", busGuideBtn: "Bus Guide",
    tropicalRouteTitle: "TropicalRoute AI", aiMobilityEngine: "AI Smart Mobility Engine",
    routesCalculated: "4 routes calculated",
    routeFastest: "Fastest", routeCoolest: "Coolest", routeCovered: "Covered", routeBalanced: "Balanced",
    routeFastestDesc: "Shortest path, minimal shade",
    routeCoolestDesc: "Max shade, cooler temperature",
    routeCoveredDesc: "Covered walkways & shelters",
    routeBalancedDesc: "Best speed-comfort tradeoff",
    routeTimeLabel: "Time", routeShadeLabel: "Shade", routeTempLabel: "Temp", routeComfortLabel: "Comfort",
    startRouteBtn: "Start",
    publicTransportTitle: "Public Transport", voiceGuidedNav: "Voice-guided navigation",
    walkFromLocation: "180m walk from your location", arrivingLabel: "arriving",
    busStopInfo: "Bus Stop", stopsLeftLabel: "Stops Left", fareLabel: "Fare",
    voiceGuidedSteps: "Voice-Guided Steps",
    inProgressRoute: "In progress — follow the route",
    voiceNavOn: "Voice Navigation On", askNavigator: "Ask Navigator",
    transitStep1: "Walk 180m to Bus Stop BJ2-045",
    transitStep2: "Board Bus BJ2 heading to Hospital Sultanah Aminah",
    transitStep3: "Alight at Hospital Sultanah Aminah stop",
    aiCvMapping: "AI Computer Vision Mapping", uploadWalkwayPhoto: "Upload Walkway Photo",
    aiDetectFeatures: "AI will detect accessibility features",
    det8Trees: "8 Trees detected", detCoveredOverlay: "Covered walkway", detBusShelterOverlay: "Bus shelter",
    aiDetections: "AI Detections",
    detTrees: "Trees", detCoveredWalkway: "Covered Walkway", detBusShelter: "Bus Shelter", detSidewalk: "Sidewalk",
    communityContributions: "Community Contributions",
    photosLabel: "Photos", routesMappedLabel: "Routes Mapped", contributorsLabel: "Contributors",
    submitToCommunity: "Submit to Community Map", takeWalkwayPhoto: "Take Walkway Photo",
    largeTextActive: "Active — text is enlarged", largeTextDesc: "Increases all font sizes",
    largeTextPreview: "This is how large text looks across the app.",
    highContrastActive: "Active — stronger colours", highContrastDesc: "Darker text and borders",
    highContrastPreview: "High contrast is on — text is sharper and darker.",
    speedSlow: "Slow", speedNormal: "Normal", speedFast: "Fast",
    currentSpeed: "Current speed:", dialectAiHint: "AI will auto-detect your dialect during voice input",
    noEmergencyContact: "No emergency contact added.",
    addEcHint: "Sign out and create a new account to add one.",
    callLabel: "Call", signOutTitle: "Sign Out?",
    signOutDesc: "You will be signed out of SuaraWarga AI. Your data and history will be saved.",
    signedInAs: "Signed in as",
    recentAiInteractions: "Your recent AI interactions",
    historyInteractions: "6 interactions", historyLanguages: "3 languages",
    hist1Title: "MyKad Renewal", hist1Sub: "Renew IC via JPN — completed",
    hist2Title: "Route to Hospital Sultanah", hist2Sub: "Bus BJ2 · Covered route selected",
    hist3Title: "Letter Interpreted", hist3Sub: "LHDN tax notice explained",
    hist4Title: "Form Assistant", hist4Sub: "MyKad renewal form — 40% complete",
    hist5Title: "Walkability Photo Submitted", hist5Sub: "Jalan Wong Ah Fook — 4 features detected",
    hist6Title: "Route to Pasaraya", hist6Sub: "Coolest route · 38 min walk",
    statusDone: "Done", statusIncomplete: "Incomplete",
    alertsReminders: "Alerts, reminders & AI updates",
    notif1Title: "MyKad Renewal Deadline",
    notif1Body: "Your IC expires in 24 days. Visit JPN before 28 Feb 2025.",
    notif2Title: "Heat Advisory Today",
    notif2Body: "UV index 8 (High) · 33°C. AI recommends public transport for trips today.",
    notif3Title: "Bus BJ2 Delay",
    notif3Body: "Bus BJ2 is running 8 minutes late at stop BJ2-045.",
    notif4Title: "Resume Form Assistant",
    notif4Body: "Your MyKad renewal form is 40% complete. Continue where you left off.",
    notif5Title: "New Service: e-Faraid",
    notif5Body: "JPN now offers estate distribution assistance. AI can help you apply by voice.",
    notif6Title: "Community Thanks",
    notif6Body: "Your walkway photo at Jalan Wong Ah Fook helped 12 users plan safer routes.",
    typeUrgent: "Urgent", typeWeather: "Weather", typeTransit: "Transit",
    typeReminder: "Reminder", typeInfo: "Info", typeCommunity: "Community",
    aiReply1: "Sure! I have noted that. Let me help you with the next step.",
    aiReply2: "Thank you for that information. Please continue — I will guide you.",
    aiReply3: "Understood. Is there anything else you need clarification on?",
    aiReply4: "Got it! I am checking the details now. Please hold on a moment.",
    aiReply5: "No problem. I have recorded your answer. What would you like to do next?",
    voiceSample: "I want to renew my MyKad at Jalan Tebrau.",
    letterChatInit: "I have read your letter. What would you like to know? You can type or speak your question.",
    formChatInit1: "Hello! I will help you fill in your MyKad renewal form. Let us go step by step.",
    formChatInit2: "First: What is your full name as in your current IC?",
    formChatInit3: "Thank you! Next: What is your IC number?",
    formChatInit4: "Noted. Now, what is your current address? You can type or speak it.",
    docChatInit: "I can help you prepare your documents. Tap any item above to mark it ready, or ask me a question!",
    transitChatInit: "I am guiding you to Hospital Sultanah Aminah. Walk 180m to Bus Stop BJ2-045, then board Bus BJ2. Need help?",
  },
  bm: {
    greeting: "Selamat pagi", tapToSpeak: "Ketik untuk bercakap", trySaying: "Cuba sebut...",
    homeSubtitle: "Bercakap dalam bahasa atau dialek pilihan anda.",
    govServices: "Perkhidmatan Kerajaan", smartMobility: "Mobiliti Pintar",
    aiTools: "4 alat AI", aiRoutes: "Laluan AI",
    navHome: "Utama", navHistory: "Sejarah", navAlerts: "Amaran", navProfile: "Profil",
    listening: "Mendengar...", recognising: "Mengenal pasti...", understood: "Difahami",
    detectedDialect: "Dialek Dikesan", aiUnderstanding: "Kefahaman AI",
    continueBtn: "Teruskan", signIn: "Log Masuk", createAccount: "Buat Akaun",
    signOut: "Log Keluar", cancel: "Batal",
    stepPersonal: "Maklumat Peribadi", stepLanguage: "Bahasa", stepPassword: "Kata Laluan", stepEmergency: "Kenalan Kecemasan",
    profileTitle: "Profil Saya", langSection: "Bahasa & Dialek",
    appLangLabel: "Bahasa Aplikasi", voiceLangLabel: "Bahasa Pendengaran Suara",
    voiceLangHint: "Bahasa yang AI dengar & balas",
    accessibility: "Kebolehaksesan", largeText: "Teks Besar", highContrast: "Kontras Tinggi",
    voiceSpeed: "Kelajuan Suara", voiceSpeedHint: "Ketik kelajuan — AI akan bercakap sebagai pratonton",
    activityHistory: "Sejarah Aktiviti", notifications: "Pemberitahuan",
    markAllRead: "Tandai semua dibaca", emergencyContact: "Kenalan Kecemasan",
    getStarted: "Mulakan",
    splashTagline: "Suara Anda. Akses Anda. Kebebasan Anda.",
    splashPowered: "Dikuasai AI · Dibangunkan untuk Track T5",
    signInToContinue: "Log masuk untuk teruskan",
    welcomeBack: "Selamat Kembali",
    icNumberLabel: "Nombor IC (MyKad)",
    passwordLabel: "Kata Laluan",
    enterPassword: "Masukkan kata laluan anda",
    forgotPassword: "Lupa Kata Laluan?",
    signingIn: "Sedang log masuk...",
    orText: "atau",
    loginHelpHint: "Ada masalah? Minta ahli keluarga membantu anda log masuk.",
    noAccount: "Pengguna baru?",
    regPersonalInfo: "Maklumat Peribadi", regLangSetup: "Tetapan Bahasa", regSetPassword: "Tetapkan Kata Laluan", regEmergencyStep: "Kenalan Kecemasan",
    regStepOf: "Langkah", regStepOf2: "dari 4 —",
    regFullName: "Nama Penuh (seperti dalam IC)", regPhoneNumber: "Nombor Telefon",
    regAppLang: "Bahasa Paparan Aplikasi",
    regAppLangDesc: "Ini mengawal bahasa yang digunakan dalam aplikasi.",
    regVoiceLangDesc: "Bahasa atau dialek yang mikrofon AI akan dengar.",
    regLangTip: "Anda boleh tukar kedua-dua tetapan ini bila-bila masa dari Profil anda.",
    regNewPassword: "Kata Laluan Baru", regMinCharsPlaceholder: "Min. 6 aksara",
    regPassTip: "Gunakan kata laluan yang mudah diingat, seperti nama anak + tahun lahir.",
    regConfirmPassword: "Sahkan Kata Laluan", regReenterPassword: "Masukkan semula kata laluan",
    regAccountSummary: "Ringkasan Akaun",
    regEcWho: "Siapa yang perlu kami hubungi jika anda memerlukan bantuan?",
    regEcReachable: "Kenalan ini boleh dihubungi dari profil anda pada bila-bila masa.",
    regContactFullName: "Nama Penuh Kenalan", regContactPhone: "Nombor Telefon Kenalan",
    regRelationship: "Hubungan", regCreatingAccount: "Sedang mencipta akaun...",
    alreadyHaveAccount: "Sudah ada akaun?",
    relSon: "Anak Lelaki", relDaughter: "Anak Perempuan", relSpouse: "Pasangan", relSibling: "Adik-beradik",
    relGrandchild: "Cucu", relFriend: "Kawan", relCarer: "Penjaga",
    passWeak: "Lemah", passFair: "Sederhana", passStrong: "Kuat",
    qlLetterInterpreter: "Penterjemah Surat", qlFormAssistant: "Pembantu Borang",
    qlDocChecker: "Pemeriksa Dokumen", qlWalkability: "Peta Jalan Kaki",
    voiceInput: "Input Suara", processingWithAI: "Memproses dengan AI...",
    aiProcessing: "Pemprosesan AI", openingNow: "Membuka sekarang",
    govHubSubtitle: "4 alat berkuasa AI", govBannerTitle: "Pembantu Super AI",
    govBannerDesc: "Uruskan MyKad, pasport, utiliti & lagi",
    govSvc1Title: "Pembantu AI Suara & Dialek", govSvc1Desc: "Bercakap dalam Hokkien, Kantonis, Melayu, atau Inggeris",
    govSvc2Title: "Penterjemah Surat Kerajaan", govSvc2Desc: "Imbas surat — AI menjelaskan dalam bahasa mudah",
    govSvc3Title: "Pembantu Borang Pintar", govSvc3Desc: "AI panduan anda melalui borang langkah demi langkah",
    govSvc4Title: "Pemeriksa Kesediaan Dokumen", govSvc4Desc: "Tahu dengan tepat dokumen yang perlu dibawa",
    govHint: "Ketik mikrofon dan katakan apa yang anda perlukan — AI akan panduan anda secara automatik dalam bahasa anda.",
    listeningLabel: "Mendengar...", typeAnswer: "Taip jawapan anda...",
    letterTitle: "Penterjemah Surat", letterSubtitle: "OCR + Penjelasan AI",
    uploadPhotoPrompt: "Muat naik atau ambil foto surat kerajaan anda",
    takePhoto: "Ambil Foto", uploadFile: "Muat Naik Fail",
    supportedFormats: "Sokong PDF, JPG, PNG",
    exampleLetters: "Contoh surat yang dikendalikan:",
    exampleLettersList: "Notis pembaharuan MyKad · LHDN · Bil utiliti · Saman mahkamah · Temujanji hospital",
    textExtracted: "Teks diekstrak", aiExplanationLabel: "Penjelasan AI",
    letterAiResult: "Ini adalah surat dari JPN. Anda mesti memperbaharui MyKad sebelum 28 Feb 2025.",
    deadlineLabel: "Tarikh Akhir", askAboutLetter: "Tanya tentang surat ini",
    scanAnotherLetter: "Imbas Surat Lain",
    formAssistantTitle: "Pembantu Borang Pintar", aiGuidesStep: "AI panduan anda langkah demi langkah",
    formProgress: "Kemajuan Borang", formStepLabel: "Langkah", formOfLabel: "dari",
    formPersonalInfo: "Maklumat Peribadi", formAddressDetails: "Butiran Alamat", formFinalReview: "Semakan Akhir",
    docCheckerTitle: "Pemeriksa Dokumen", docForMyKad: "Untuk: Pembaharuan MyKad",
    docReadyLabel: "Sedia", docMissingLabel: "dokumen tidak lengkap",
    docMyKad: "MyKad (IC)", docUtilityBill: "Bil Utiliti (3 bulan terkini)",
    docPassportPhoto: "Gambar Pasport (2 salinan)", docBirthCert: "Sijil Kelahiran",
    docBankStatement: "Penyata Bank",
    missingDocsTitle: "Dokumen Hilang — Cara Mendapatkannya",
    visitJpnOffice: "Lawati studio foto atau pejabat JPN terdekat",
    askAiHelp: "Minta Bantuan AI",
    whereTo: "Di mana anda ingin pergi?", findingRoute: "Mencari laluan terbaik...",
    destinationLabel: "Destinasi", awayLabel: "jauh",
    tempLabel: "Suhu", humidityLabel: "Kelembapan", uvIndexLabel: "Indeks UV",
    aiRecommendation: "Saranan AI", takePublicTransport: "Naik Pengangkutan Awam",
    tooHotForWalking: "Terlalu panas & lembap untuk berjalan",
    aiRecommendsBus: "AI mengesyorkan bas untuk keselesaan dan keselamatan.",
    walkingComfortScore: "Skor Keselesaan Berjalan Kaki", lowComfort: "Keselesaan Rendah",
    aiRouteBtn: "Laluan AI", busGuideBtn: "Panduan Bas",
    tropicalRouteTitle: "TropicalRoute AI", aiMobilityEngine: "Enjin Mobiliti Pintar AI",
    routesCalculated: "4 laluan dikira",
    routeFastest: "Paling Pantas", routeCoolest: "Paling Sejuk", routeCovered: "Berteduh", routeBalanced: "Seimbang",
    routeFastestDesc: "Laluan terpendek, teduhan minimum",
    routeCoolestDesc: "Teduhan maksimum, suhu lebih sejuk",
    routeCoveredDesc: "Laluan tertutup & tempat berteduh",
    routeBalancedDesc: "Terbaik dari segi kelajuan & keselesaan",
    routeTimeLabel: "Masa", routeShadeLabel: "Teduhan", routeTempLabel: "Suhu", routeComfortLabel: "Keselesaan",
    startRouteBtn: "Mula",
    publicTransportTitle: "Pengangkutan Awam", voiceGuidedNav: "Navigasi berpandu suara",
    walkFromLocation: "Jalan 180m dari lokasi anda", arrivingLabel: "tiba",
    busStopInfo: "Perhentian Bas", stopsLeftLabel: "Hentian Tinggal", fareLabel: "Tambang",
    voiceGuidedSteps: "Langkah Berpandu Suara",
    inProgressRoute: "Sedang berjalan — ikuti laluan",
    voiceNavOn: "Navigasi Suara Aktif", askNavigator: "Tanya Navigator",
    transitStep1: "Jalan 180m ke Perhentian Bas BJ2-045",
    transitStep2: "Naik Bas BJ2 menuju Hospital Sultanah Aminah",
    transitStep3: "Turun di perhentian Hospital Sultanah Aminah",
    aiCvMapping: "Pemetaan Visi Komputer AI", uploadWalkwayPhoto: "Muat Naik Foto Laluan",
    aiDetectFeatures: "AI akan mengesan ciri-ciri kebolehaksesan",
    det8Trees: "8 Pokok dikesan", detCoveredOverlay: "Laluan berteduh", detBusShelterOverlay: "Tempat tunggu bas",
    aiDetections: "Pengesanan AI",
    detTrees: "Pokok", detCoveredWalkway: "Laluan Berteduh", detBusShelter: "Tempat Tunggu Bas", detSidewalk: "Trotoar",
    communityContributions: "Sumbangan Komuniti",
    photosLabel: "Foto", routesMappedLabel: "Laluan Dipetakan", contributorsLabel: "Penyumbang",
    submitToCommunity: "Hantar ke Peta Komuniti", takeWalkwayPhoto: "Ambil Foto Laluan",
    largeTextActive: "Aktif — teks dibesarkan", largeTextDesc: "Meningkatkan semua saiz fon",
    largeTextPreview: "Begini rupa teks besar dalam aplikasi.",
    highContrastActive: "Aktif — warna lebih terang", highContrastDesc: "Teks dan sempadan lebih gelap",
    highContrastPreview: "Kontras tinggi aktif — teks lebih tajam dan gelap.",
    speedSlow: "Perlahan", speedNormal: "Normal", speedFast: "Laju",
    currentSpeed: "Kelajuan semasa:", dialectAiHint: "AI akan auto-kesan dialek anda semasa input suara",
    noEmergencyContact: "Tiada kenalan kecemasan ditambah.",
    addEcHint: "Log keluar dan buat akaun baru untuk menambah satu.",
    callLabel: "Hubungi", signOutTitle: "Log Keluar?",
    signOutDesc: "Anda akan dilog keluar dari SuaraWarga AI. Data dan sejarah anda akan disimpan.",
    signedInAs: "Log masuk sebagai",
    recentAiInteractions: "Interaksi AI terkini anda",
    historyInteractions: "6 interaksi", historyLanguages: "3 bahasa",
    hist1Title: "Pembaharuan MyKad", hist1Sub: "Perbaharui IC melalui JPN — selesai",
    hist2Title: "Laluan ke Hospital Sultanah", hist2Sub: "Bas BJ2 · Laluan berteduh dipilih",
    hist3Title: "Surat Ditafsirkan", hist3Sub: "Notis cukai LHDN dijelaskan",
    hist4Title: "Pembantu Borang", hist4Sub: "Borang pembaharuan MyKad — 40% selesai",
    hist5Title: "Foto Laluan Dihantar", hist5Sub: "Jalan Wong Ah Fook — 4 ciri dikesan",
    hist6Title: "Laluan ke Pasaraya", hist6Sub: "Laluan paling sejuk · 38 min berjalan",
    statusDone: "Selesai", statusIncomplete: "Tidak Lengkap",
    alertsReminders: "Amaran, peringatan & kemas kini AI",
    notif1Title: "Tarikh Akhir Pembaharuan MyKad",
    notif1Body: "IC anda tamat tempoh dalam 24 hari. Lawati JPN sebelum 28 Feb 2025.",
    notif2Title: "Amaran Panas Hari Ini",
    notif2Body: "Indeks UV 8 (Tinggi) · 33°C. AI mengesyorkan pengangkutan awam untuk perjalanan hari ini.",
    notif3Title: "Kelewatan Bas BJ2",
    notif3Body: "Bas BJ2 lewat 8 minit di perhentian BJ2-045.",
    notif4Title: "Sambung Pembantu Borang",
    notif4Body: "Borang pembaharuan MyKad anda 40% selesai. Teruskan dari tempat anda berhenti.",
    notif5Title: "Perkhidmatan Baru: e-Faraid",
    notif5Body: "JPN kini menawarkan bantuan pembahagian harta pusaka. AI boleh membantu anda mohon melalui suara.",
    notif6Title: "Terima Kasih Komuniti",
    notif6Body: "Foto laluan anda di Jalan Wong Ah Fook membantu 12 pengguna merancang laluan lebih selamat.",
    typeUrgent: "Mendesak", typeWeather: "Cuaca", typeTransit: "Transit",
    typeReminder: "Peringatan", typeInfo: "Maklumat", typeCommunity: "Komuniti",
    aiReply1: "Baik! Saya telah catat. Mari saya bantu langkah seterusnya.",
    aiReply2: "Terima kasih atas maklumat tersebut. Sila teruskan — saya akan membimbing anda.",
    aiReply3: "Faham. Ada lagi yang perlu dijelaskan?",
    aiReply4: "Baik! Saya sedang menyemak maklumat sekarang. Sila tunggu sebentar.",
    aiReply5: "Tiada masalah. Saya telah rekod jawapan anda. Apa yang anda ingin lakukan seterusnya?",
    voiceSample: "No nak renew MyKad di Jalan Tebrau.",
    letterChatInit: "Saya telah membaca surat anda. Apa yang anda ingin tahu? Anda boleh taip atau bercakap soalan anda.",
    formChatInit1: "Helo! Saya akan membantu anda mengisi borang pembaharuan MyKad. Mari kita buat langkah demi langkah.",
    formChatInit2: "Pertama: Apakah nama penuh anda seperti dalam IC semasa?",
    formChatInit3: "Terima kasih! Seterusnya: Apakah nombor IC anda?",
    formChatInit4: "Direkod. Sekarang, apakah alamat semasa anda? Anda boleh taip atau sebut.",
    docChatInit: "Saya boleh membantu anda menyediakan dokumen. Ketik mana-mana item di atas untuk tandakan sedia, atau tanya saya soalan!",
    transitChatInit: "Saya memandu anda ke Hospital Sultanah Aminah. Jalan 180m ke Perhentian Bas BJ2-045, kemudian naik Bas BJ2. Perlukan bantuan?",
  },
  zh: {
    greeting: "早上好", tapToSpeak: "点击说话", trySaying: "试着说...",
    homeSubtitle: "用您喜欢的语言或方言自然说话。",
    govServices: "政府服务", smartMobility: "智能出行",
    aiTools: "4 个AI工具", aiRoutes: "AI智能路线",
    navHome: "首页", navHistory: "历史", navAlerts: "通知", navProfile: "档案",
    listening: "正在聆听...", recognising: "正在识别...", understood: "已理解",
    detectedDialect: "检测到的方言", aiUnderstanding: "AI理解",
    continueBtn: "继续", signIn: "登录", createAccount: "创建账户",
    signOut: "退出登录", cancel: "取消",
    stepPersonal: "个人信息", stepLanguage: "语言设置", stepPassword: "设置密码", stepEmergency: "紧急联系人",
    profileTitle: "我的档案", langSection: "语言与方言",
    appLangLabel: "应用语言", voiceLangLabel: "语音监听语言",
    voiceLangHint: "AI 聆听和回应的语言",
    accessibility: "无障碍设置", largeText: "大字体", highContrast: "高对比度",
    voiceSpeed: "语音速度", voiceSpeedHint: "点击速度 — AI 将播放预览",
    activityHistory: "活动历史", notifications: "通知",
    markAllRead: "全部标为已读", emergencyContact: "紧急联系人",
    getStarted: "开始使用",
    splashTagline: "您的声音。您的通道。您的独立。",
    splashPowered: "AI驱动 · 为Track T5开发",
    signInToContinue: "登录以继续",
    welcomeBack: "欢迎回来",
    icNumberLabel: "身份证号码 (MyKad)",
    passwordLabel: "密码",
    enterPassword: "输入您的密码",
    forgotPassword: "忘记密码？",
    signingIn: "正在登录...",
    orText: "或",
    loginHelpHint: "遇到困难？请家人帮助您登录。",
    noAccount: "新用户？",
    regPersonalInfo: "个人信息", regLangSetup: "语言设置", regSetPassword: "设置密码", regEmergencyStep: "紧急联系人",
    regStepOf: "第", regStepOf2: "步，共4步 —",
    regFullName: "全名（如身份证所示）", regPhoneNumber: "电话号码",
    regAppLang: "应用显示语言",
    regAppLangDesc: "这控制整个应用程序使用的语言。",
    regVoiceLangDesc: "AI麦克风将监听的语言或方言。",
    regLangTip: "您可以随时从您的个人资料更改这两项设置。",
    regNewPassword: "新密码", regMinCharsPlaceholder: "最少6个字符",
    regPassTip: "使用容易记住的密码，例如孩子的名字加出生年份。",
    regConfirmPassword: "确认密码", regReenterPassword: "重新输入密码",
    regAccountSummary: "账户摘要",
    regEcWho: "如果您需要帮助，我们应该联系谁？此人将显示在您的个人资料中。",
    regEcReachable: "此联系人可以随时从您的个人资料联系到。",
    regContactFullName: "联系人全名", regContactPhone: "联系人电话号码",
    regRelationship: "关系", regCreatingAccount: "正在创建账户...",
    alreadyHaveAccount: "已有账户？",
    relSon: "儿子", relDaughter: "女儿", relSpouse: "配偶", relSibling: "兄弟姐妹",
    relGrandchild: "孙子女", relFriend: "朋友", relCarer: "护理人员",
    passWeak: "弱", passFair: "一般", passStrong: "强",
    qlLetterInterpreter: "信件解读", qlFormAssistant: "表格助手",
    qlDocChecker: "文件检查", qlWalkability: "社区步行地图",
    voiceInput: "语音输入", processingWithAI: "AI处理中...",
    aiProcessing: "AI处理中", openingNow: "正在打开",
    govHubSubtitle: "4个AI工具", govBannerTitle: "AI超级助手",
    govBannerDesc: "处理身份证 (MyKad)、护照、水电费等",
    govSvc1Title: "语音与方言AI助手", govSvc1Desc: "用福建话、粤语、马来语或英语交谈",
    govSvc2Title: "政府信件解读", govSvc2Desc: "扫描信件 — AI用简单语言解释",
    govSvc3Title: "智能表格助手", govSvc3Desc: "AI逐步引导您填写表格",
    govSvc4Title: "文件准备检查器", govSvc4Desc: "确切知道需要携带哪些文件",
    govHint: "只需点击麦克风说出您的需求 — AI将用您的语言自动引导您。",
    listeningLabel: "正在聆听...", typeAnswer: "输入您的答案...",
    letterTitle: "信件解读", letterSubtitle: "OCR + AI解释",
    uploadPhotoPrompt: "上传或拍摄您的政府信件照片",
    takePhoto: "拍照", uploadFile: "上传文件",
    supportedFormats: "支持 PDF、JPG、PNG",
    exampleLetters: "处理过的信件示例：",
    exampleLettersList: "身份证 (MyKad) 续期通知 · 税务局 (LHDN) · 水电费 · 传票 · 医院预约",
    textExtracted: "已提取文字", aiExplanationLabel: "AI解释",
    letterAiResult: "这是来自国家登记局 (JPN) 的信件。您必须在2025年2月28日前续期身份证 (MyKad)。",
    deadlineLabel: "截止日期", askAboutLetter: "询问关于这封信",
    scanAnotherLetter: "扫描另一封信",
    formAssistantTitle: "智能表格助手", aiGuidesStep: "AI逐步引导您",
    formProgress: "表格进度", formStepLabel: "步骤", formOfLabel: "共",
    formPersonalInfo: "个人信息", formAddressDetails: "地址详情", formFinalReview: "最终审核",
    docCheckerTitle: "文件检查", docForMyKad: "用途：身份证 (MyKad) 续期",
    docReadyLabel: "已准备", docMissingLabel: "份文件缺失",
    docMyKad: "身份证 (MyKad)", docUtilityBill: "水电费单（最近3个月）",
    docPassportPhoto: "护照照片（2张）", docBirthCert: "出生证明",
    docBankStatement: "银行对账单",
    missingDocsTitle: "缺失文件 — 如何获取",
    visitJpnOffice: "前往最近的照相馆或国家登记局 (JPN) 办事处",
    askAiHelp: "向AI寻求帮助",
    whereTo: "您想去哪里？", findingRoute: "正在寻找最佳路线...",
    destinationLabel: "目的地", awayLabel: "距离",
    tempLabel: "温度", humidityLabel: "湿度", uvIndexLabel: "紫外线指数",
    aiRecommendation: "AI建议", takePublicTransport: "乘坐公共交通",
    tooHotForWalking: "步行太热太潮湿",
    aiRecommendsBus: "AI建议乘巴士以保证舒适和安全。",
    walkingComfortScore: "步行舒适度评分", lowComfort: "舒适度低",
    aiRouteBtn: "AI路线", busGuideBtn: "巴士指南",
    tropicalRouteTitle: "热带路线AI", aiMobilityEngine: "AI智能出行引擎",
    routesCalculated: "已计算4条路线",
    routeFastest: "最快", routeCoolest: "最凉快", routeCovered: "有遮盖", routeBalanced: "均衡",
    routeFastestDesc: "最短路径，遮荫最少",
    routeCoolestDesc: "最多遮荫，温度较低",
    routeCoveredDesc: "有遮盖走廊和遮蔽处",
    routeBalancedDesc: "速度与舒适的最佳平衡",
    routeTimeLabel: "时间", routeShadeLabel: "遮荫", routeTempLabel: "温度", routeComfortLabel: "舒适度",
    startRouteBtn: "开始",
    publicTransportTitle: "公共交通", voiceGuidedNav: "语音导航",
    walkFromLocation: "距您位置步行180米", arrivingLabel: "即将到达",
    busStopInfo: "巴士站", stopsLeftLabel: "剩余站数", fareLabel: "车费",
    voiceGuidedSteps: "语音引导步骤",
    inProgressRoute: "进行中 — 请跟随路线",
    voiceNavOn: "语音导航已开启", askNavigator: "询问导航员",
    transitStep1: "步行180米至巴士站BJ2-045",
    transitStep2: "乘坐BJ2路公交车前往苏丹阿米娜医院 (Hospital Sultanah Aminah)",
    transitStep3: "在苏丹阿米娜医院 (Hospital Sultanah Aminah) 站下车",
    aiCvMapping: "AI计算机视觉地图", uploadWalkwayPhoto: "上传走道照片",
    aiDetectFeatures: "AI将检测无障碍设施",
    det8Trees: "检测到8棵树", detCoveredOverlay: "有遮盖走道", detBusShelterOverlay: "巴士候车亭",
    aiDetections: "AI检测",
    detTrees: "树木", detCoveredWalkway: "有遮盖走道", detBusShelter: "巴士候车亭", detSidewalk: "人行道",
    communityContributions: "社区贡献",
    photosLabel: "照片", routesMappedLabel: "已绘制路线", contributorsLabel: "贡献者",
    submitToCommunity: "提交到社区地图", takeWalkwayPhoto: "拍摄走道照片",
    largeTextActive: "已激活 — 文字已放大", largeTextDesc: "增加所有字体大小",
    largeTextPreview: "这就是大字体在应用中的样子。",
    highContrastActive: "已激活 — 颜色更鲜明", highContrastDesc: "更深的文字和边框",
    highContrastPreview: "高对比度已开启 — 文字更清晰更深。",
    speedSlow: "慢", speedNormal: "正常", speedFast: "快",
    currentSpeed: "当前速度：", dialectAiHint: "AI将在语音输入时自动检测您的方言",
    noEmergencyContact: "未添加紧急联系人。",
    addEcHint: "退出登录并创建新账户以添加一个。",
    callLabel: "致电", signOutTitle: "退出登录？",
    signOutDesc: "您将退出SuaraWarga AI。您的数据和历史记录将被保存。",
    signedInAs: "已登录为",
    recentAiInteractions: "您最近的AI互动",
    historyInteractions: "6次互动", historyLanguages: "3种语言",
    hist1Title: "身份证 (MyKad) 续期", hist1Sub: "通过国家登记局 (JPN) 续期身份证 — 已完成",
    hist2Title: "前往苏丹阿米娜医院的路线", hist2Sub: "BJ2巴士 · 已选择有遮盖路线",
    hist3Title: "信件已解读", hist3Sub: "税务局 (LHDN) 税务通知已解释",
    hist4Title: "表格助手", hist4Sub: "身份证 (MyKad) 续期表格 — 40% 完成",
    hist5Title: "走道照片已提交", hist5Sub: "Jalan Wong Ah Fook — 检测到4个特征",
    hist6Title: "前往商场的路线", hist6Sub: "最凉快路线 · 步行38分钟",
    statusDone: "已完成", statusIncomplete: "未完成",
    alertsReminders: "警报、提醒和AI更新",
    notif1Title: "身份证 (MyKad) 续期截止日期",
    notif1Body: "您的身份证将在24天后过期。请在2025年2月28日前前往国家登记局 (JPN)。",
    notif2Title: "今日高温警报",
    notif2Body: "紫外线指数8（高）· 33°C。AI建议今日出行乘坐公共交通。",
    notif3Title: "BJ2巴士延误",
    notif3Body: "BJ2巴士在BJ2-045站晚点8分钟。",
    notif4Title: "继续表格助手",
    notif4Body: "您的身份证 (MyKad) 续期表格已完成40%。继续您上次停止的地方。",
    notif5Title: "新服务：e-Faraid",
    notif5Body: "国家登记局 (JPN) 现在提供遗产分配协助。AI可以帮助您通过语音申请。",
    notif6Title: "社区感谢",
    notif6Body: "您在Jalan Wong Ah Fook的走道照片帮助了12位用户规划更安全的路线。",
    typeUrgent: "紧急", typeWeather: "天气", typeTransit: "交通",
    typeReminder: "提醒", typeInfo: "信息", typeCommunity: "社区",
    aiReply1: "好的！我已记录。让我帮您进行下一步。",
    aiReply2: "感谢您提供信息。请继续 — 我将引导您。",
    aiReply3: "明白了。还有什么需要说明的吗？",
    aiReply4: "好的！我正在检查详情。请稍等片刻。",
    aiReply5: "没问题。我已记录您的回答。您接下来想做什么？",
    voiceSample: "我想在柔佛巴鲁续期身份证 (MyKad)。",
    letterChatInit: "我已阅读您的信件。您想了解什么？您可以打字或说出您的问题。",
    formChatInit1: "你好！我将帮助您填写身份证 (MyKad) 续期表格。让我们一步一步来。",
    formChatInit2: "首先：您在当前身份证上的全名是什么？",
    formChatInit3: "谢谢！接下来：您的身份证号码是什么？",
    formChatInit4: "已记录。现在，您目前的地址是什么？您可以打字或说出来。",
    docChatInit: "我可以帮助您准备文件。点击上方任何项目标记为已准备，或向我提问！",
    transitChatInit: "我正在引导您前往苏丹阿米娜医院 (Hospital Sultanah Aminah)。步行180米到BJ2-045巴士站，然后乘坐BJ2巴士。需要帮助吗？",
  },
  ta: {
    greeting: "காலை வணக்கம்", tapToSpeak: "பேச தட்டவும்", trySaying: "இதை சொல்லுங்கள்...",
    homeSubtitle: "உங்கள் விருப்பமான மொழியில் இயல்பாக பேசுங்கள்.",
    govServices: "அரசு சேவைகள்", smartMobility: "ஸ்மார்ட் மொபிலிட்டி",
    aiTools: "4 AI கருவிகள்", aiRoutes: "AI வழிகள்",
    navHome: "முகப்பு", navHistory: "வரலாறு", navAlerts: "எச்சரிக்கை", navProfile: "சுயவிவரம்",
    listening: "கேட்கிறது...", recognising: "அங்கீகரிக்கிறது...", understood: "புரிந்தது",
    detectedDialect: "கண்டறியப்பட்ட மொழி", aiUnderstanding: "AI புரிதல்",
    continueBtn: "தொடரவும்", signIn: "உள்நுழைக", createAccount: "கணக்கை உருவாக்கு",
    signOut: "வெளியேறு", cancel: "ரத்துசெய்",
    stepPersonal: "தனிப்பட்ட தகவல்", stepLanguage: "மொழி அமைப்புகள்", stepPassword: "கடவுச்சொல்", stepEmergency: "அவசர தொடர்பு",
    profileTitle: "என் சுயவிவரம்", langSection: "மொழி & வட்டாரவழக்கு",
    appLangLabel: "பயன்பாட்டு மொழி", voiceLangLabel: "குரல் கேட்கும் மொழி",
    voiceLangHint: "AI கேட்கும் மற்றும் பதிலளிக்கும் மொழி",
    accessibility: "அணுகல்தன்மை", largeText: "பெரிய உரை", highContrast: "உயர் மாறுபாடு",
    voiceSpeed: "குரல் வேகம்", voiceSpeedHint: "வேகத்தை தட்டவும் — AI முன்னோட்டம் பேசும்",
    activityHistory: "செயல்பாட்டு வரலாறு", notifications: "அறிவிப்புகள்",
    markAllRead: "அனைத்தையும் படித்ததாக குறி", emergencyContact: "அவசர தொடர்பு",
    getStarted: "தொடங்குங்கள்",
    splashTagline: "உங்கள் குரல். உங்கள் அணுகல். உங்கள் சுதந்திரம்.",
    splashPowered: "AI மூலம் இயங்குகிறது · Track T5-க்காக உருவாக்கப்பட்டது",
    signInToContinue: "தொடர உள்நுழைக",
    welcomeBack: "மீண்டும் வரவேற்கிறோம்",
    icNumberLabel: "அடையாள அட்டை எண் (MyKad)",
    passwordLabel: "கடவுச்சொல்",
    enterPassword: "உங்கள் கடவுச்சொல்லை உள்ளிடவும்",
    forgotPassword: "கடவுச்சொல் மறந்துவிட்டதா?",
    signingIn: "உள்நுழைகிறது...",
    orText: "அல்லது",
    loginHelpHint: "சிக்கல் உள்ளதா? குடும்பத்தினரை உதவி கேளுங்கள்.",
    noAccount: "புதிய பயனரா?",
    regPersonalInfo: "தனிப்பட்ட தகவல்", regLangSetup: "மொழி அமைவு", regSetPassword: "கடவுச்சொல் அமை", regEmergencyStep: "அவசர தொடர்பு",
    regStepOf: "படி", regStepOf2: "4-ல் —",
    regFullName: "முழு பெயர் (அடையாள அட்டையில் உள்ளபடி)", regPhoneNumber: "தொலைபேசி எண்",
    regAppLang: "பயன்பாட்டு காட்சி மொழி",
    regAppLangDesc: "இது பயன்பாட்டில் பயன்படுத்தப்படும் மொழியை கட்டுப்படுத்துகிறது.",
    regVoiceLangDesc: "AI மைக்ரோஃபோன் கேட்கும் மொழி அல்லது வட்டாரவழக்கு.",
    regLangTip: "இந்த இரண்டு அமைப்புகளையும் உங்கள் சுயவிவரத்திலிருந்து எந்த நேரத்திலும் மாற்றலாம்.",
    regNewPassword: "புதிய கடவுச்சொல்", regMinCharsPlaceholder: "குறைந்தது 6 எழுத்துகள்",
    regPassTip: "குழந்தையின் பெயர் + பிறந்த ஆண்டு போன்று நினைவில் வைக்க எளிதான கடவுச்சொல் பயன்படுத்தவும்.",
    regConfirmPassword: "கடவுச்சொல்லை உறுதிசெய்க", regReenterPassword: "கடவுச்சொல்லை மீண்டும் உள்ளிடவும்",
    regAccountSummary: "கணக்கு சுருக்கம்",
    regEcWho: "உங்களுக்கு உதவி தேவையானால் யாரை அழைக்கணும்? இந்த நபர் உங்கள் சுயவிவரத்தில் காட்டப்படுவார்.",
    regEcReachable: "இந்த தொடர்பை எந்த நேரத்திலும் உங்கள் சுயவிவரத்திலிருந்து அணுகலாம்.",
    regContactFullName: "தொடர்பு நபரின் முழு பெயர்", regContactPhone: "தொடர்பு நபரின் தொலைபேசி எண்",
    regRelationship: "உறவு", regCreatingAccount: "கணக்கை உருவாக்குகிறது...",
    alreadyHaveAccount: "ஏற்கனவே கணக்கு உள்ளதா?",
    relSon: "மகன்", relDaughter: "மகள்", relSpouse: "துணை", relSibling: "சகோதரர்/சகோதரி",
    relGrandchild: "பேரன்/பேத்தி", relFriend: "நண்பர்", relCarer: "பராமரிப்பாளர்",
    passWeak: "பலவீனமான", passFair: "நடுத்தரமான", passStrong: "வலிமையான",
    qlLetterInterpreter: "கடித விளக்கம்", qlFormAssistant: "படிவ உதவியாளர்",
    qlDocChecker: "ஆவண சரிபார்ப்பு", qlWalkability: "சமூக நடைபாதை வரைபடம்",
    voiceInput: "குரல் உள்ளீடு", processingWithAI: "AI மூலம் செயலாக்குகிறது...",
    aiProcessing: "AI செயலாக்கம்", openingNow: "இப்போது திறக்கிறது",
    govHubSubtitle: "4 AI-இயக்கும் கருவிகள்", govBannerTitle: "AI சூப்பர் உதவியாளர்",
    govBannerDesc: "அடையாள அட்டை (MyKad), கடவுச்சீட்டு, பயன்பாடுகள் & மேலும் கையாளுகிறது",
    govSvc1Title: "குரல் & வட்டாரவழக்கு AI உதவியாளர்", govSvc1Desc: "ஹொக்கியன், கன்டோனீஸ், மலாய் அல்லது ஆங்கிலத்தில் பேசுங்கள்",
    govSvc2Title: "அரசு கடித விளக்கி", govSvc2Desc: "கடிதங்களை ஸ்கேன் செய்யுங்கள் — AI எளிய மொழியில் விளக்குகிறது",
    govSvc3Title: "ஸ்மார்ட் படிவ உதவியாளர்", govSvc3Desc: "AI படிப்படியாக படிவங்களை நிரப்ப உங்களை வழிநடத்துகிறது",
    govSvc4Title: "ஆவண தயார்நிலை சரிபார்ப்பாளர்", govSvc4Desc: "எந்த ஆவணங்களை கொண்டு வர வேண்டும் என்று சரியாக தெரியும்",
    govHint: "மைக்ரோஃபோனை தட்டி உங்களுக்கு என்ன தேவை என்று சொல்லுங்கள் — AI உங்கள் மொழியில் தானாக உங்களை வழிநடத்தும்.",
    listeningLabel: "கேட்கிறது...", typeAnswer: "உங்கள் பதிலை தட்டச்சு செய்யுங்கள்...",
    letterTitle: "கடித விளக்கி", letterSubtitle: "OCR + AI விளக்கம்",
    uploadPhotoPrompt: "உங்கள் அரசு கடிதத்தின் புகைப்படத்தை பதிவேற்றுங்கள் அல்லது எடுங்கள்",
    takePhoto: "புகைப்படம் எடு", uploadFile: "கோப்பை பதிவேற்று",
    supportedFormats: "PDF, JPG, PNG ஆதரிக்கிறது",
    exampleLetters: "கையாளப்பட்ட கடித எடுத்துக்காட்டுகள்:",
    exampleLettersList: "அடையாள அட்டை (MyKad) புதுப்பிப்பு அறிவிப்பு · வருமான வரி (LHDN) · பயன்பாட்டு கட்டணங்கள் · நீதிமன்ற சம்மன் · மருத்துவமனை சந்திப்பு",
    textExtracted: "உரை பிரித்தெடுக்கப்பட்டது", aiExplanationLabel: "AI விளக்கம்",
    letterAiResult: "இது தேசிய பதிவு திணைக்களம் (JPN) இன் கடிதம். 2025 பிப்ரவரி 28 முன் அடையாள அட்டை (MyKad) புதுப்பிக்க வேண்டும்.",
    deadlineLabel: "கடைசி தேதி", askAboutLetter: "இந்த கடிதத்தைப் பற்றி கேளுங்கள்",
    scanAnotherLetter: "மற்றொரு கடிதத்தை ஸ்கேன் செய்க",
    formAssistantTitle: "ஸ்மார்ட் படிவ உதவியாளர்", aiGuidesStep: "AI படிப்படியாக உங்களை வழிநடத்துகிறது",
    formProgress: "படிவ முன்னேற்றம்", formStepLabel: "படி", formOfLabel: "இல்",
    formPersonalInfo: "தனிப்பட்ட தகவல்", formAddressDetails: "முகவரி விவரங்கள்", formFinalReview: "இறுதி மதிப்பாய்வு",
    docCheckerTitle: "ஆவண சரிபார்ப்பாளர்", docForMyKad: "நோக்கம்: அடையாள அட்டை (MyKad) புதுப்பிப்பு",
    docReadyLabel: "தயார்", docMissingLabel: "ஆவணங்கள் இல்லை",
    docMyKad: "அடையாள அட்டை (MyKad)", docUtilityBill: "பயன்பாட்டு கட்டண பில் (கடந்த 3 மாதங்கள்)",
    docPassportPhoto: "கடவுச்சீட்டு புகைப்படம் (2 நகல்கள்)", docBirthCert: "பிறப்பு சான்றிதழ்",
    docBankStatement: "வங்கி அறிக்கை",
    missingDocsTitle: "இல்லாத ஆவணங்கள் — எப்படி பெறுவது",
    visitJpnOffice: "அருகிலுள்ள புகைப்பட ஸ்டூடியோ அல்லது தேசிய பதிவு திணைக்களம் (JPN) அலுவலகத்திற்கு செல்லுங்கள்",
    askAiHelp: "AI உதவி கேளுங்கள்",
    whereTo: "நீங்கள் எங்கு செல்ல விரும்புகிறீர்கள்?", findingRoute: "சிறந்த வழியை தேடுகிறது...",
    destinationLabel: "இலக்கு", awayLabel: "தூரம்",
    tempLabel: "வெப்பநிலை", humidityLabel: "ஈரப்பதம்", uvIndexLabel: "UV குறியீடு",
    aiRecommendation: "AI பரிந்துரை", takePublicTransport: "பொது போக்குவரத்தை பயன்படுத்துங்கள்",
    tooHotForWalking: "நடைப்பயணத்திற்கு மிகவும் வெப்பமாகவும் ஈரப்பதமாகவும் உள்ளது",
    aiRecommendsBus: "AI வசதி மற்றும் பாதுகாப்பிற்காக பேருந்தை பரிந்துரைக்கிறது.",
    walkingComfortScore: "நடைப்பயண வசதி மதிப்பெண்", lowComfort: "குறைந்த வசதி",
    aiRouteBtn: "AI வழிகள்", busGuideBtn: "பேருந்து வழிகாட்டி",
    tropicalRouteTitle: "வெப்பமண்டல வழி AI", aiMobilityEngine: "AI ஸ்மார்ட் மொபிலிட்டி இயந்திரம்",
    routesCalculated: "4 வழிகள் கணக்கிடப்பட்டன",
    routeFastest: "மிக வேகமான", routeCoolest: "மிக குளிர்ச்சியான", routeCovered: "மூடப்பட்ட", routeBalanced: "சமச்சீரான",
    routeFastestDesc: "குறுகிய பாதை, குறைந்தபட்ச நிழல்",
    routeCoolestDesc: "அதிக நிழல், குளிர்ந்த வெப்பநிலை",
    routeCoveredDesc: "மூடப்பட்ட நடைபாதைகள் & தங்குமிடங்கள்",
    routeBalancedDesc: "வேகம்-வசதியின் சிறந்த சமன்பாடு",
    routeTimeLabel: "நேரம்", routeShadeLabel: "நிழல்", routeTempLabel: "வெப்பநிலை", routeComfortLabel: "வசதி",
    startRouteBtn: "தொடங்கு",
    publicTransportTitle: "பொது போக்குவரத்து", voiceGuidedNav: "குரல்-வழிகாட்டி வழிசெலுத்தல்",
    walkFromLocation: "உங்கள் இருப்பிடத்திலிருந்து 180 மீட்டர் நடை", arrivingLabel: "வருகிறது",
    busStopInfo: "பேருந்து நிறுத்தம்", stopsLeftLabel: "மீதமுள்ள நிறுத்தங்கள்", fareLabel: "கட்டணம்",
    voiceGuidedSteps: "குரல்-வழிகாட்டி படிகள்",
    inProgressRoute: "நடைபெறுகிறது — பாதையை பின்பற்றுங்கள்",
    voiceNavOn: "குரல் வழிசெலுத்தல் இயங்குகிறது", askNavigator: "வழிகாட்டியிடம் கேளுங்கள்",
    transitStep1: "பேருந்து நிறுத்தம் BJ2-045-க்கு 180 மீட்டர் நடக்கவும்",
    transitStep2: "சுல்தானா அமினா மருத்துவமனை (Hospital Sultanah Aminah)-க்கு BJ2 பேருந்தில் ஏறவும்",
    transitStep3: "சுல்தானா அமினா மருத்துவமனை (Hospital Sultanah Aminah) நிறுத்தத்தில் இறங்கவும்",
    aiCvMapping: "AI கணினி தொலைநோக்கி வரைபடம்", uploadWalkwayPhoto: "நடைபாதை புகைப்படத்தை பதிவேற்றுங்கள்",
    aiDetectFeatures: "AI அணுகல் அம்சங்களை கண்டறியும்",
    det8Trees: "8 மரங்கள் கண்டறியப்பட்டன", detCoveredOverlay: "மூடப்பட்ட நடைபாதை", detBusShelterOverlay: "பேருந்து தங்குமிடம்",
    aiDetections: "AI கண்டறிதல்கள்",
    detTrees: "மரங்கள்", detCoveredWalkway: "மூடப்பட்ட நடைபாதை", detBusShelter: "பேருந்து தங்குமிடம்", detSidewalk: "நடைபாதை",
    communityContributions: "சமூக பங்களிப்புகள்",
    photosLabel: "புகைப்படங்கள்", routesMappedLabel: "வரைபடமிட்ட வழிகள்", contributorsLabel: "பங்களிப்பாளர்கள்",
    submitToCommunity: "சமூக வரைபடத்தில் சமர்ப்பிக்கவும்", takeWalkwayPhoto: "நடைபாதை புகைப்படம் எடுங்கள்",
    largeTextActive: "செயல்பாட்டில் — உரை பெரிதாக்கப்பட்டது", largeTextDesc: "அனைத்து எழுத்துரு அளவுகளையும் அதிகரிக்கும்",
    largeTextPreview: "பயன்பாட்டில் பெரிய உரை எப்படி தெரியும்.",
    highContrastActive: "செயல்பாட்டில் — வண்ணங்கள் வலுவாகும்", highContrastDesc: "இருண்ட உரை மற்றும் எல்லைகள்",
    highContrastPreview: "உயர் மாறுபாடு இயங்குகிறது — உரை தெளிவாகவும் இருண்டதாகவும் உள்ளது.",
    speedSlow: "மெதுவாக", speedNormal: "சாதாரணம்", speedFast: "வேகமாக",
    currentSpeed: "தற்போதைய வேகம்:", dialectAiHint: "குரல் உள்ளீட்டின் போது AI உங்கள் வட்டாரவழக்கை தானாக கண்டறியும்",
    noEmergencyContact: "அவசர தொடர்பு சேர்க்கப்படவில்லை.",
    addEcHint: "வெளியேறி புதிய கணக்கை உருவாக்கி ஒன்றை சேர்க்கவும்.",
    callLabel: "அழைக்கவும்", signOutTitle: "வெளியேறுவதா?",
    signOutDesc: "நீங்கள் SuaraWarga AI-லிருந்து வெளியேறுவீர்கள். உங்கள் தரவு மற்றும் வரலாறு சேமிக்கப்படும்.",
    signedInAs: "இவராக உள்நுழைந்துள்ளீர்கள்",
    recentAiInteractions: "உங்கள் சமீபத்திய AI இடைவினைகள்",
    historyInteractions: "6 இடைவினைகள்", historyLanguages: "3 மொழிகள்",
    hist1Title: "அடையாள அட்டை (MyKad) புதுப்பிப்பு", hist1Sub: "தேசிய பதிவு திணைக்களம் (JPN) மூலம் அட்டை புதுப்பிப்பு — முடிந்தது",
    hist2Title: "சுல்தானா அமினா மருத்துவமனைக்கு வழி", hist2Sub: "BJ2 பேருந்து · மூடப்பட்ட வழி தேர்ந்தெடுக்கப்பட்டது",
    hist3Title: "கடிதம் விளக்கப்பட்டது", hist3Sub: "வருமான வரி (LHDN) அறிவிப்பு விளக்கப்பட்டது",
    hist4Title: "படிவ உதவியாளர்", hist4Sub: "அடையாள அட்டை (MyKad) புதுப்பிப்பு படிவம் — 40% முடிந்தது",
    hist5Title: "நடைபாதை புகைப்படம் சமர்ப்பிக்கப்பட்டது", hist5Sub: "Jalan Wong Ah Fook — 4 அம்சங்கள் கண்டறியப்பட்டன",
    hist6Title: "பாசாரயாவுக்கு வழி", hist6Sub: "மிகக் குளிர்ச்சியான வழி · 38 நிமிட நடை",
    statusDone: "முடிந்தது", statusIncomplete: "முடிக்கப்படவில்லை",
    alertsReminders: "எச்சரிக்கைகள், நினைவூட்டல்கள் & AI புதுப்பிப்புகள்",
    notif1Title: "அடையாள அட்டை (MyKad) புதுப்பிப்பு கடைசி தேதி",
    notif1Body: "உங்கள் அட்டை 24 நாட்களில் காலாவதியாகிறது. 2025 பிப்ரவரி 28 முன் தேசிய பதிவு திணைக்களம் (JPN)-க்கு செல்லவும்.",
    notif2Title: "இன்று வெப்ப எச்சரிக்கை",
    notif2Body: "UV குறியீடு 8 (உயர்) · 33°C. AI இன்று பயணங்களுக்கு பொது போக்குவரத்தை பரிந்துரைக்கிறது.",
    notif3Title: "BJ2 பேருந்து தாமதம்",
    notif3Body: "BJ2 பேருந்து நிறுத்தம் BJ2-045-ல் 8 நிமிடம் தாமதமாக உள்ளது.",
    notif4Title: "படிவ உதவியாளரை தொடரவும்",
    notif4Body: "உங்கள் அடையாள அட்டை (MyKad) புதுப்பிப்பு படிவம் 40% முடிந்தது. நீங்கள் நிறுத்திய இடத்திலிருந்து தொடரவும்.",
    notif5Title: "புதிய சேவை: e-Faraid",
    notif5Body: "தேசிய பதிவு திணைக்களம் (JPN) இப்போது சொத்து பகிர்வு உதவி வழங்குகிறது. AI குரல் மூலம் விண்ணப்பிக்க உதவும்.",
    notif6Title: "சமூக நன்றி",
    notif6Body: "Jalan Wong Ah Fook-ல் உங்கள் நடைபாதை புகைப்படம் 12 பயனர்களுக்கு பாதுகாப்பான வழிகளை திட்டமிட உதவியது.",
    typeUrgent: "அவசரம்", typeWeather: "வானிலை", typeTransit: "போக்குவரத்து",
    typeReminder: "நினைவூட்டல்", typeInfo: "தகவல்", typeCommunity: "சமூகம்",
    aiReply1: "சரி! நான் குறித்துக்கொண்டேன். அடுத்த படிக்கு உதவுகிறேன்.",
    aiReply2: "தகவலுக்கு நன்றி. தொடருங்கள் — நான் வழிகாட்டுவேன்.",
    aiReply3: "புரிந்தது. வேறு விளக்கம் தேவையா?",
    aiReply4: "சரி! விவரங்களை சரிபார்க்கிறேன். சற்று காத்திருங்கள்.",
    aiReply5: "பரவாயில்லை. உங்கள் பதிலை பதிவுசெய்தேன். அடுத்து என்ன செய்ய விரும்புகிறீர்கள்?",
    voiceSample: "நான் ஜாலன் தெப்ராவில் அடையாள அட்டை (MyKad) புதுப்பிக்க விரும்புகிறேன்.",
    letterChatInit: "உங்கள் கடிதத்தை படித்தேன். என்ன தெரிந்துகொள்ள விரும்புகிறீர்கள்? தட்டச்சு செய்யலாம் அல்லது பேசலாம்.",
    formChatInit1: "வணக்கம்! அடையாள அட்டை (MyKad) புதுப்பிப்பு படிவம் நிரப்ப உதவுகிறேன். படிப்படியாக செய்வோம்.",
    formChatInit2: "முதலில்: தற்போதைய அட்டையில் உள்ள முழு பெயர் என்ன?",
    formChatInit3: "நன்றி! அடுத்து: உங்கள் அட்டை எண் என்ன?",
    formChatInit4: "குறித்துக்கொண்டேன். இப்போது, தற்போதைய முகவரி என்ன? தட்டச்சு செய்யலாம் அல்லது சொல்லலாம்.",
    docChatInit: "ஆவணங்களை தயார்படுத்த உதவுகிறேன். மேலே உள்ள எந்த உருப்படியையும் தட்டி தயாராக குறிக்கவும், அல்லது கேள்வி கேளுங்கள்!",
    transitChatInit: "சுல்தானா அமினா மருத்துவமனை (Hospital Sultanah Aminah)-க்கு வழிகாட்டுகிறேன். BJ2-045 பேருந்து நிறுத்தத்திற்கு 180மீ நடந்து, BJ2 பேருந்தில் ஏறுங்கள். உதவி வேண்டுமா?",
  },
} as const;

type TKey = keyof typeof T.en;

// ── Language Context ───────────────────────────────────────────────────────
interface LangCtx {
  lang: AppLang;
  setLang: (l: AppLang) => void;
  t: (k: TKey) => string;
  voiceLang: string;
  setVoiceLang: (l: string) => void;
}
const LangContext = createContext<LangCtx>({
  lang: "en", setLang: () => {}, t: (k) => k,
  voiceLang: "English", setVoiceLang: () => {},
});
const useLang = () => useContext(LangContext);

// ── Voice Intents ─────────────────────────────────────────────────────────
interface VoiceIntent {
  phrase: string;
  detectedLang: string;
  service: string;
  serviceDesc: string;
  serviceIcon: string;
  serviceColor: string;
  targetScreen: Screen;
  pipelineSteps: { icon: string; label: string; tech: string; color: string; desc: string }[];
}

const VOICE_INTENTS: VoiceIntent[] = [
  {
    phrase: "Wa beh renew IC.",
    detectedLang: "Hokkien",
    service: "MyKad Renewal — Smart Form",
    serviceDesc: "JPN · Fill renewal form step by step",
    serviceIcon: "edit_document",
    serviceColor: "bg-amber-500",
    targetScreen: "formAssistant",
    pipelineSteps: [
      { icon: "mic",          label: "Speech Recognition",  tech: "ASR",        color: "bg-blue-600",   desc: "Hokkien audio captured" },
      { icon: "translate",    label: "Dialect Recognition", tech: "Dialect AI",  color: "bg-purple-600", desc: "Hokkien detected" },
      { icon: "psychology",   label: "Intent Recognition",  tech: "NLP + LLM",  color: "bg-amber-500",  desc: "Renew MyKad → JPN" },
      { icon: "edit_document",label: "Smart Form Assistant",tech: "Workflow AI", color: "bg-amber-500",  desc: "Opening IC renewal form" },
    ],
  },
  {
    phrase: "Ngo seung heui Hospital Sultanah Aminah.",
    detectedLang: "Cantonese",
    service: "Navigate to Hospital Sultanah",
    serviceDesc: "Smart Mobility · AI route selection",
    serviceIcon: "directions_bus",
    serviceColor: "bg-green-600",
    targetScreen: "transitGuide",
    pipelineSteps: [
      { icon: "mic",            label: "Speech Recognition",   tech: "ASR",        color: "bg-blue-600",  desc: "Cantonese audio captured" },
      { icon: "translate",      label: "Dialect Recognition",  tech: "Dialect AI", color: "bg-purple-600",desc: "Cantonese detected" },
      { icon: "psychology",     label: "Intent Recognition",   tech: "NLP + LLM",  color: "bg-amber-500", desc: "Go to Hospital Sultanah" },
      { icon: "directions_bus", label: "Public Transport Guide",tech: "Mobility AI",color: "bg-green-600", desc: "Bus BJ2 — arriving in 4 min" },
    ],
  },
  {
    phrase: "Saya nak renew MyKad.",
    detectedLang: "Malay",
    service: "Document Readiness Check",
    serviceDesc: "JPN · Know what to bring",
    serviceIcon: "checklist_rtl",
    serviceColor: "bg-green-600",
    targetScreen: "docChecker",
    pipelineSteps: [
      { icon: "mic",           label: "Speech Recognition",       tech: "ASR",        color: "bg-blue-600",  desc: "Bahasa Melayu captured" },
      { icon: "translate",     label: "Dialect Recognition",      tech: "Dialect AI", color: "bg-purple-600",desc: "Malay detected" },
      { icon: "psychology",    label: "Intent Recognition",       tech: "NLP + LLM",  color: "bg-amber-500", desc: "Renew MyKad — check documents" },
      { icon: "checklist_rtl", label: "Document Readiness Checker",tech: "AI Checklist",color: "bg-green-600",desc: "Checking IC, photo, utility bill" },
    ],
  },
  {
    phrase: "I need help with my bill.",
    detectedLang: "English",
    service: "Government Letter Interpreter",
    serviceDesc: "OCR + LLM · Explains in simple language",
    serviceIcon: "description",
    serviceColor: "bg-purple-600",
    targetScreen: "letterInterpreter",
    pipelineSteps: [
      { icon: "mic",        label: "Speech Recognition",      tech: "ASR",       color: "bg-blue-600",   desc: "English audio captured" },
      { icon: "translate",  label: "Dialect Recognition",     tech: "Dialect AI",color: "bg-purple-600", desc: "English detected" },
      { icon: "psychology", label: "Intent Recognition",      tech: "NLP + LLM", color: "bg-amber-500",  desc: "Help with bill → letter scan" },
      { icon: "description",label: "Letter Interpreter",      tech: "OCR + LLM", color: "bg-purple-600", desc: "Scan and explain your letter" },
    ],
  },
];

const DEFAULT_INTENT = VOICE_INTENTS[0];

// ── Language meta ─────────────────────────────────────────────────────────
const APP_LANGS: { id: AppLang; label: string; native: string; flag: string }[] = [
  { id: "en", label: "English",       native: "English",    flag: "🇬🇧" },
  { id: "bm", label: "Bahasa Melayu", native: "BM",         flag: "🇲🇾" },
  { id: "zh", label: "Chinese",       native: "中文",        flag: "🇨🇳" },
  { id: "ta", label: "Tamil",         native: "தமிழ்",       flag: "🇮🇳" },
];

const VOICE_LANGS = [
  { id: "Hokkien",  label: "Hokkien",        sub: "福建话",    icon: "record_voice_over" },
  { id: "Cantonese",label: "Cantonese",       sub: "广东话",    icon: "record_voice_over" },
  { id: "Malay",    label: "Bahasa Melayu",   sub: "Melayu",   icon: "language" },
  { id: "English",  label: "English",         sub: "English",  icon: "language" },
  { id: "Mandarin", label: "Mandarin",        sub: "普通话",    icon: "record_voice_over" },
  { id: "Tamil",    label: "Tamil",           sub: "தமிழ்",    icon: "language" },
];

// ── Material Symbol Icon ───────────────────────────────────────────────────
function Icon({ name, size = 28, fill = 1, weight = 600, className = "" }: {
  name: string; size?: number; fill?: number; weight?: number; className?: string;
}) {
  return (
    <span
      className={`material-symbols-rounded select-none ${className}`}
      style={{ fontSize: size, fontVariationSettings: `'FILL' ${fill}, 'wght' ${weight}, 'GRAD' 0, 'opsz' ${size}` }}
    >
      {name}
    </span>
  );
}

// ── Pill Badge ─────────────────────────────────────────────────────────────
function Badge({ label, color = "blue" }: { label: string; color?: "blue" | "green" | "orange" | "purple" }) {
  const map = {
    blue: "bg-blue-100 text-blue-700",
    green: "bg-green-100 text-green-700",
    orange: "bg-amber-100 text-amber-700",
    purple: "bg-purple-100 text-purple-700",
  };
  return (
    <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold ${map[color]}`}>
      {label}
    </span>
  );
}

// ── AI Tag ─────────────────────────────────────────────────────────────────
function AITag({ label }: { label: string }) {
  return (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-blue-50 border border-blue-200 text-blue-600 text-[10px] font-bold tracking-wide uppercase">
      <span className="w-1.5 h-1.5 rounded-full bg-blue-500 animate-pulse" />
      {label}
    </span>
  );
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────
function BottomNav({ active, onChange }: { active: NavTab; onChange: (t: NavTab) => void }) {
  const { t } = useLang();
  const tabs: { id: NavTab; icon: string; labelKey: TKey }[] = [
    { id: "home",          icon: "home",          labelKey: "navHome" },
    { id: "history",       icon: "history",        labelKey: "navHistory" },
    { id: "notifications", icon: "notifications",  labelKey: "navAlerts" },
    { id: "profile",       icon: "person",         labelKey: "navProfile" },
  ];
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-white border-t border-blue-100 flex pb-2 pt-1 z-30">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onChange(tab.id)}
          className={`flex-1 flex flex-col items-center gap-0.5 py-1 transition-colors ${active === tab.id ? "text-blue-600" : "text-slate-400"}`}
        >
          <Icon name={tab.icon} size={24} fill={active === tab.id ? 1 : 0} weight={active === tab.id ? 700 : 400} />
          <span className="text-[11px] font-semibold">{t(tab.labelKey)}</span>
          {active === tab.id && <span className="w-1 h-1 rounded-full bg-blue-600" />}
        </button>
      ))}
    </div>
  );
}

// ── Screen Header ──────────────────────────────────────────────────────────
function Header({ title, onBack, subtitle }: { title: string; onBack?: () => void; subtitle?: string }) {
  return (
    <div className="flex items-center gap-3 px-5 pt-12 pb-4">
      {onBack && (
        <button onClick={onBack} className="w-10 h-10 rounded-2xl bg-blue-50 flex items-center justify-center text-blue-600 shrink-0">
          <Icon name="arrow_back" size={22} />
        </button>
      )}
      <div className="flex-1 min-w-0">
        <h1 className="text-xl font-bold text-slate-900 truncate">{title}</h1>
        {subtitle && <p className="text-sm text-slate-500 mt-0.5">{subtitle}</p>}
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 1 — Splash
// ══════════════════════════════════════════════════════════════════════════
function SplashScreen({ onNext }: { onNext: () => void }) {
  const { t } = useLang();
  return (
    <div className="flex flex-col items-center justify-between h-full bg-gradient-to-b from-blue-600 via-blue-700 to-blue-900 px-8 py-16 text-white">
      {/* Top decoration */}
      <div className="flex flex-col items-center gap-3 mt-4">
        <motion.div
          initial={{ scale: 0.7, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
          className="w-24 h-24 rounded-3xl bg-white/20 backdrop-blur-sm flex items-center justify-center shadow-2xl border border-white/30"
        >
          <Icon name="hearing" size={52} fill={1} className="text-white" />
        </motion.div>
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="text-center"
        >
          <h1 className="text-4xl font-black tracking-tight">SuaraWarga</h1>
          <span className="text-2xl font-light tracking-widest text-blue-200">AI</span>
        </motion.div>
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5, duration: 0.5 }}
          className="flex gap-2 flex-wrap justify-center mt-1"
        >
          <Badge label="AI-Powered" color="blue" />
          <Badge label="Voice-First" color="green" />
          <Badge label="Accessibility" color="orange" />
        </motion.div>
      </div>

      {/* Illustration */}
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.6 }}
        className="flex flex-col items-center gap-4"
      >
        {/* Elderly person illustration (SVG) */}
        <div className="relative w-64 h-52">
          <div className="absolute inset-0 rounded-3xl bg-white/10 backdrop-blur-sm border border-white/20" />
          {/* Simple SVG illustration */}
          <svg viewBox="0 0 240 200" className="w-full h-full p-4">
            {/* Background circles */}
            <circle cx="120" cy="100" r="70" fill="rgba(255,255,255,0.08)" />
            <circle cx="120" cy="100" r="50" fill="rgba(255,255,255,0.08)" />
            {/* Sound waves */}
            {[30, 40, 52].map((r, i) => (
              <circle key={i} cx="120" cy="130" r={r} fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="1.5"
                strokeDasharray="4 3" />
            ))}
            {/* Person body */}
            <ellipse cx="120" cy="150" rx="28" ry="14" fill="rgba(255,255,255,0.15)" />
            <rect x="108" y="108" width="24" height="42" rx="8" fill="rgba(255,255,255,0.85)" />
            {/* Head */}
            <circle cx="120" cy="92" r="18" fill="rgba(255,255,255,0.9)" />
            {/* Hair */}
            <path d="M102 90 Q120 72 138 90" fill="rgba(150,150,150,0.6)" />
            {/* Face */}
            <circle cx="114" cy="90" r="2.5" fill="#2563EB" />
            <circle cx="126" cy="90" r="2.5" fill="#2563EB" />
            <path d="M114 97 Q120 102 126 97" stroke="#2563EB" strokeWidth="2" fill="none" strokeLinecap="round" />
            {/* Cane */}
            <line x1="138" y1="120" x2="152" y2="165" stroke="rgba(255,255,255,0.7)" strokeWidth="3" strokeLinecap="round" />
            <ellipse cx="152" cy="166" rx="5" ry="3" fill="rgba(255,255,255,0.5)" />
            {/* Microphone icon near mouth */}
            <rect x="115" y="100" width="10" height="14" rx="5" fill="#22C55E" />
            <path d="M110 110 Q110 118 120 118 Q130 118 130 110" fill="none" stroke="#22C55E" strokeWidth="2" />
            <line x1="120" y1="118" x2="120" y2="124" stroke="#22C55E" strokeWidth="2" />
          </svg>
        </div>
        <div className="text-center px-4">
          <p className="text-xl font-semibold leading-tight text-amber-300">
            "{t("splashTagline")}"
          </p>
        </div>

        {/* Language chips */}
        <div className="flex gap-2 flex-wrap justify-center">
          {["Hokkien", "Cantonese", "Malay", "English"].map((lang) => (
            <span key={lang} className="px-3 py-1 rounded-full bg-white/20 text-sm font-medium text-white border border-white/30">
              {lang}
            </span>
          ))}
        </div>
      </motion.div>

      {/* CTA */}
      <motion.button
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.7, duration: 0.5 }}
        onClick={onNext}
        whileTap={{ scale: 0.97 }}
        className="w-full py-5 rounded-3xl bg-white text-blue-700 font-bold text-xl shadow-2xl shadow-blue-900/40 flex items-center justify-center gap-3"
      >
        <Icon name="play_arrow" size={28} fill={1} className="text-blue-600" />
        {t("getStarted")}
      </motion.button>

      {/* Bottom tag */}
      <p className="text-blue-300 text-xs text-center mt-2">{t("splashPowered")}</p>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN — Login
// ══════════════════════════════════════════════════════════════════════════
function LoginScreen({ onLogin, onRegister }: {
  onLogin: (user: User) => void;
  onRegister: () => void;
}) {
  const { t } = useLang();
  const [ic, setIc] = useState("");
  const [password, setPassword] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = () => {
    if (!ic.trim() || !password.trim()) { setError("Please fill in all fields."); return; }
    if (ic.replace(/\D/g, "").length < 12) { setError("Please enter a valid IC number."); return; }
    setError("");
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      onLogin({ name: "Ahmad bin Abdullah", ic: ic.replace(/-/g, ""), phone: "+60 12-345 6789", uiLang: "en", voiceLang: "Hokkien" });
    }, 1400);
  };

  // Auto-format IC: 570814-01-5432
  const handleIcChange = (val: string) => {
    const digits = val.replace(/\D/g, "").slice(0, 12);
    let formatted = digits;
    if (digits.length > 6) formatted = digits.slice(0, 6) + "-" + digits.slice(6);
    if (digits.length > 8) formatted = digits.slice(0, 6) + "-" + digits.slice(6, 8) + "-" + digits.slice(8);
    setIc(formatted);
  };

  return (
    <div className="flex flex-col h-full bg-gradient-to-b from-blue-600 via-blue-700 to-blue-900">
      {/* Top branding */}
      <div className="flex flex-col items-center pt-16 pb-8 px-6">
        <motion.div
          initial={{ scale: 0.7, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="w-20 h-20 rounded-3xl bg-white/20 border border-white/30 flex items-center justify-center mb-4 shadow-xl"
        >
          <Icon name="hearing" size={44} fill={1} className="text-white" />
        </motion.div>
        <motion.div
          initial={{ y: 16, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2, duration: 0.4 }}
          className="text-center"
        >
          <h1 className="text-3xl font-black text-white tracking-tight">SuaraWarga AI</h1>
          <p className="text-blue-200 text-sm mt-1">{t("signInToContinue")}</p>
        </motion.div>
      </div>

      {/* Card */}
      <motion.div
        initial={{ y: 40, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="flex-1 bg-white rounded-t-[2.5rem] px-6 pt-8 pb-6 flex flex-col gap-5"
      >
        <h2 className="text-2xl font-black text-slate-900">{t("welcomeBack")} 👋</h2>

        {/* IC field */}
        <div className="space-y-1.5">
          <label className="text-sm font-bold text-slate-600 flex items-center gap-1.5">
            <Icon name="badge" size={16} fill={1} className="text-blue-600" />
            {t("icNumberLabel")}
          </label>
          <div className={`flex items-center gap-3 px-4 h-14 rounded-2xl border-2 bg-blue-50 transition-colors ${error && !ic ? "border-red-400" : "border-blue-100 focus-within:border-blue-500"}`}>
            <Icon name="badge" size={20} fill={1} className="text-slate-400 shrink-0" />
            <input
              type="tel"
              placeholder="570814-01-5432"
              value={ic}
              onChange={(e) => handleIcChange(e.target.value)}
              className="flex-1 bg-transparent text-slate-800 text-lg font-semibold placeholder:text-slate-300 outline-none"
            />
          </div>
        </div>

        {/* Password field */}
        <div className="space-y-1.5">
          <label className="text-sm font-bold text-slate-600 flex items-center gap-1.5">
            <Icon name="lock" size={16} fill={1} className="text-blue-600" />
            {t("passwordLabel")}
          </label>
          <div className={`flex items-center gap-3 px-4 h-14 rounded-2xl border-2 bg-blue-50 transition-colors ${error && !password ? "border-red-400" : "border-blue-100 focus-within:border-blue-500"}`}>
            <Icon name="lock" size={20} fill={1} className="text-slate-400 shrink-0" />
            <input
              type={showPass ? "text" : "password"}
              placeholder={t("enterPassword")}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleLogin()}
              className="flex-1 bg-transparent text-slate-800 text-lg font-semibold placeholder:text-slate-300 outline-none"
            />
            <button onClick={() => setShowPass(!showPass)} className="shrink-0 text-slate-400">
              <Icon name={showPass ? "visibility_off" : "visibility"} size={20} fill={1} />
            </button>
          </div>
        </div>

        {/* Error */}
        <AnimatePresence>
          {error && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="flex items-center gap-2 bg-red-50 border border-red-200 rounded-2xl px-4 py-3"
            >
              <Icon name="error" size={18} fill={1} className="text-red-500 shrink-0" />
              <p className="text-red-600 text-sm font-medium">{error}</p>
            </motion.div>
          )}
        </AnimatePresence>

        <div className="flex justify-end -mt-2">
          <button className="text-blue-600 text-sm font-semibold">{t("forgotPassword")}</button>
        </div>

        {/* Login button */}
        <motion.button
          onClick={handleLogin}
          whileTap={{ scale: 0.97 }}
          disabled={loading}
          className="w-full h-16 rounded-3xl bg-blue-600 text-white font-black text-xl shadow-lg shadow-blue-200 flex items-center justify-center gap-3 disabled:opacity-80"
        >
          {loading ? (
            <>
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 0.8, repeat: Infinity, ease: "linear" }}
                className="w-6 h-6 rounded-full border-3 border-white/30 border-t-white"
                style={{ borderWidth: 3 }}
              />
              {t("signingIn")}
            </>
          ) : (
            <>
              <Icon name="login" size={26} fill={1} />
              {t("signIn")}
            </>
          )}
        </motion.button>

        {/* Divider */}
        <div className="flex items-center gap-3">
          <div className="flex-1 h-px bg-slate-200" />
          <span className="text-slate-400 text-sm font-medium">{t("orText")}</span>
          <div className="flex-1 h-px bg-slate-200" />
        </div>

        {/* Voice login hint */}
        <div className="flex items-center gap-3 bg-blue-50 rounded-2xl px-4 py-3 border border-blue-100">
          <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center shrink-0">
            <Icon name="mic" size={22} fill={1} className="text-blue-600" />
          </div>
          <p className="text-blue-700 text-sm font-medium flex-1">
            {t("loginHelpHint")}
          </p>
        </div>

        {/* Register */}
        <div className="flex items-center justify-center gap-2 mt-auto pt-2">
          <p className="text-slate-500 text-base">{t("noAccount")}</p>
          <button onClick={onRegister} className="text-blue-600 font-black text-base">
            {t("createAccount")}
          </button>
        </div>
      </motion.div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN — Register
// ══════════════════════════════════════════════════════════════════════════
function RegisterScreen({ onDone, onLogin }: { onDone: (user: User) => void; onLogin: () => void }) {
  const [step, setStep] = useState(1);
  const [name, setName] = useState("");
  const [ic, setIc] = useState("");
  const [phone, setPhone] = useState("");
  const [regUiLang, setRegUiLang] = useState<AppLang>("en");
  const [regVoiceLang, setRegVoiceLang] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [ecName, setEcName] = useState("");
  const [ecPhone, setEcPhone] = useState("");
  const [ecRelationship, setEcRelationship] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  // Mirror app language while on register so labels update live
  const { t, setLang, setVoiceLang } = useLang();
  useEffect(() => { setLang(regUiLang); }, [regUiLang]);

  const handleIcChange = (val: string) => {
    const digits = val.replace(/\D/g, "").slice(0, 12);
    let formatted = digits;
    if (digits.length > 6) formatted = digits.slice(0, 6) + "-" + digits.slice(6);
    if (digits.length > 8) formatted = digits.slice(0, 6) + "-" + digits.slice(6, 8) + "-" + digits.slice(8);
    setIc(formatted);
  };

  const nextStep = () => {
    setError("");
    if (step === 1) {
      if (!name.trim()) { setError("Please enter your full name."); return; }
      if (ic.replace(/\D/g, "").length < 12) { setError("Please enter a valid 12-digit IC number."); return; }
      if (phone.replace(/\D/g, "").length < 10) { setError("Please enter a valid phone number."); return; }
    }
    if (step === 2) {
      if (!regVoiceLang) { setError("Please select your voice listening language."); return; }
    }
    if (step === 3) {
      if (password.length < 6) { setError("Password must be at least 6 characters."); return; }
      if (password !== confirm) { setError("Passwords do not match."); return; }
    }
    if (step === 4) {
      if (!ecName.trim()) { setError("Please enter your emergency contact's name."); return; }
      if (ecPhone.replace(/\D/g, "").length < 10) { setError("Please enter a valid phone number."); return; }
      if (!ecRelationship) { setError("Please select a relationship."); return; }
      setLoading(true);
      const ec: EmergencyContact = { name: ecName, phone: ecPhone, relationship: ecRelationship };
      setVoiceLang(regVoiceLang);
      setTimeout(() => {
        setLoading(false);
        onDone({ name, ic, phone, uiLang: regUiLang, voiceLang: regVoiceLang, emergencyContact: ec });
      }, 1600);
      return;
    }
    setStep(step + 1);
  };

  const relationships: { key: TKey; value: string }[] = [
    { key: "relSon", value: "Son" }, { key: "relDaughter", value: "Daughter" },
    { key: "relSpouse", value: "Spouse" }, { key: "relSibling", value: "Sibling" },
    { key: "relGrandchild", value: "Grandchild" }, { key: "relFriend", value: "Friend" },
    { key: "relCarer", value: "Carer" },
  ];
  const stepLabelKeys: TKey[] = ["regPersonalInfo", "regLangSetup", "regSetPassword", "regEmergencyStep"];

  return (
    <div className="flex flex-col h-full bg-gradient-to-b from-blue-600 via-blue-700 to-blue-900">
      {/* Top */}
      <div className="flex items-center gap-3 px-5 pt-12 pb-6">
        {step > 1 ? (
          <button onClick={() => { setStep(step - 1); setError(""); }} className="w-10 h-10 rounded-2xl bg-white/20 flex items-center justify-center">
            <Icon name="arrow_back" size={22} className="text-white" />
          </button>
        ) : (
          <button onClick={onLogin} className="w-10 h-10 rounded-2xl bg-white/20 flex items-center justify-center">
            <Icon name="close" size={22} className="text-white" />
          </button>
        )}
        <div>
          <h1 className="text-2xl font-black text-white">{t("createAccount")}</h1>
          <p className="text-blue-200 text-sm">{t("regStepOf")} {step} {t("regStepOf2")} {t(stepLabelKeys[step - 1])}</p>
        </div>
      </div>

      {/* Progress */}
      <div className="flex gap-2 px-6 mb-6">
        {[1, 2, 3, 4].map((s) => (
          <motion.div
            key={s}
            className={`h-1.5 rounded-full flex-1 transition-colors duration-300 ${s <= step ? "bg-white" : "bg-white/25"}`}
            animate={{ scaleX: s <= step ? 1 : 0.6 }}
          />
        ))}
      </div>

      {/* Card */}
      <motion.div
        key={step}
        initial={{ x: 40, opacity: 0 }}
        animate={{ x: 0, opacity: 1 }}
        transition={{ duration: 0.3 }}
        className="flex-1 bg-white rounded-t-[2.5rem] px-6 pt-8 pb-6 flex flex-col gap-5 overflow-y-auto"
      >
        {step === 1 && (
          <>
            <h2 className="text-2xl font-black text-slate-900">{t("regPersonalInfo")}</h2>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regFullName")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="person" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type="text"
                  placeholder="Ahmad bin Abdullah"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("icNumberLabel")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="badge" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type="tel"
                  placeholder="570814-01-5432"
                  value={ic}
                  onChange={(e) => handleIcChange(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-lg font-semibold placeholder:text-slate-300 outline-none"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regPhoneNumber")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="phone" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type="tel"
                  placeholder="+60 12-345 6789"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
              </div>
            </div>
          </>
        )}

        {step === 2 && (
          <>
            <h2 className="text-2xl font-black text-slate-900">{t("regLangSetup")}</h2>

            {/* App UI Language */}
            <div>
              <p className="font-bold text-slate-800 mb-1 flex items-center gap-2">
                <Icon name="phone_android" size={18} fill={1} className="text-blue-600" />
                {t("regAppLang")}
              </p>
              <p className="text-slate-500 text-sm mb-3">{t("regAppLangDesc")}</p>
              <div className="grid grid-cols-2 gap-2">
                {APP_LANGS.map((l) => (
                  <button
                    key={l.id}
                    onClick={() => setRegUiLang(l.id)}
                    className={`flex items-center gap-3 px-4 py-3.5 rounded-2xl border-2 font-bold text-base transition-all ${
                      regUiLang === l.id
                        ? "bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-200"
                        : "bg-white text-slate-700 border-slate-200"
                    }`}
                  >
                    <span className="text-xl">{l.flag}</span>
                    <div className="text-left">
                      <p className={`text-sm font-black leading-tight ${regUiLang === l.id ? "text-white" : "text-slate-800"}`}>{l.native}</p>
                      <p className={`text-xs font-medium ${regUiLang === l.id ? "text-blue-200" : "text-slate-400"}`}>{l.label}</p>
                    </div>
                    {regUiLang === l.id && <Icon name="check_circle" size={18} fill={1} className="text-white ml-auto" />}
                  </button>
                ))}
              </div>
            </div>

            {/* Voice Listening Language */}
            <div>
              <p className="font-bold text-slate-800 mb-1 flex items-center gap-2">
                <Icon name="mic" size={18} fill={1} className="text-green-600" />
                {t("voiceLangLabel")}
              </p>
              <p className="text-slate-500 text-sm mb-3">{t("regVoiceLangDesc")}</p>
              <div className="grid grid-cols-2 gap-2">
                {VOICE_LANGS.map((vl) => (
                  <button
                    key={vl.id}
                    onClick={() => setRegVoiceLang(vl.id)}
                    className={`flex items-center gap-3 px-3 py-3.5 rounded-2xl border-2 font-bold transition-all ${
                      regVoiceLang === vl.id
                        ? "bg-green-500 text-white border-green-500 shadow-md shadow-green-200"
                        : "bg-white text-slate-700 border-slate-200"
                    }`}
                  >
                    <Icon name={vl.icon} size={20} fill={1} className={regVoiceLang === vl.id ? "text-white" : "text-slate-400"} />
                    <div className="text-left">
                      <p className={`text-sm font-black leading-tight ${regVoiceLang === vl.id ? "text-white" : "text-slate-800"}`}>{vl.label}</p>
                      <p className={`text-xs font-medium ${regVoiceLang === vl.id ? "text-green-100" : "text-slate-400"}`}>{vl.sub}</p>
                    </div>
                  </button>
                ))}
              </div>
            </div>

            <div className="bg-blue-50 rounded-2xl p-3 flex gap-2 border border-blue-100">
              <AITag label="Dialect AI" />
              <p className="text-blue-700 text-sm font-medium">{t("regLangTip")}</p>
            </div>
          </>
        )}

        {step === 3 && (
          <>
            <h2 className="text-2xl font-black text-slate-900">{t("regSetPassword")}</h2>

            <div className="bg-amber-50 border border-amber-200 rounded-2xl px-4 py-3 flex items-start gap-3">
              <Icon name="tips_and_updates" size={20} fill={1} className="text-amber-600 shrink-0 mt-0.5" />
              <p className="text-amber-800 text-sm font-medium">{t("regPassTip")}</p>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regNewPassword")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="lock" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type={showPass ? "text" : "password"}
                  placeholder={t("regMinCharsPlaceholder")}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
                <button onClick={() => setShowPass(!showPass)} className="text-slate-400 shrink-0">
                  <Icon name={showPass ? "visibility_off" : "visibility"} size={20} fill={1} />
                </button>
              </div>
              {/* Strength bar */}
              {password.length > 0 && (
                <div className="flex items-center gap-2 mt-1">
                  <div className="flex-1 h-1.5 rounded-full bg-slate-200 overflow-hidden">
                    <div className={`h-full rounded-full transition-all duration-300 ${
                      password.length < 4 ? "w-1/4 bg-red-400" :
                      password.length < 7 ? "w-2/4 bg-amber-400" :
                      "w-full bg-green-500"
                    }`} />
                  </div>
                  <span className={`text-xs font-bold ${
                    password.length < 4 ? "text-red-500" :
                    password.length < 7 ? "text-amber-600" : "text-green-600"
                  }`}>
                    {password.length < 4 ? t("passWeak") : password.length < 7 ? t("passFair") : t("passStrong")}
                  </span>
                </div>
              )}
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regConfirmPassword")}</label>
              <div className={`flex items-center gap-3 px-4 h-14 rounded-2xl border-2 bg-blue-50 focus-within:border-blue-500 ${
                confirm.length > 0 && confirm !== password ? "border-red-400" : "border-blue-100"
              }`}>
                <Icon name="lock_reset" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type={showPass ? "text" : "password"}
                  placeholder={t("regReenterPassword")}
                  value={confirm}
                  onChange={(e) => setConfirm(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && nextStep()}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
                {confirm.length > 0 && (
                  <Icon
                    name={confirm === password ? "check_circle" : "cancel"}
                    size={20} fill={1}
                    className={confirm === password ? "text-green-500" : "text-red-400"}
                  />
                )}
              </div>
            </div>

            {/* Account summary */}
            <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 space-y-2">
              <p className="font-bold text-slate-700 text-sm">{t("regAccountSummary")}</p>
              {[
                { icon: "person", label: name || "—" },
                { icon: "badge", label: ic || "—" },
                { icon: "phone_android", label: APP_LANGS.find(l => l.id === regUiLang)?.label || "—" },
                { icon: "mic", label: regVoiceLang || "—" },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2">
                  <Icon name={item.icon} size={16} fill={1} className="text-slate-400" />
                  <span className="text-slate-600 text-sm font-medium">{item.label}</span>
                </div>
              ))}
            </div>
          </>
        )}

        {step === 4 && (
          <>
            <h2 className="text-2xl font-black text-slate-900">{t("emergencyContact")}</h2>
            <p className="text-slate-500 text-base -mt-2 leading-relaxed">{t("regEcWho")}</p>

            <div className="bg-red-50 border border-red-200 rounded-2xl px-4 py-3 flex items-center gap-3">
              <Icon name="favorite" size={20} fill={1} className="text-red-500 shrink-0" />
              <p className="text-red-700 text-sm font-medium">{t("regEcReachable")}</p>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regContactFullName")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="person" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type="text"
                  placeholder="e.g. Siti Aminah"
                  value={ecName}
                  onChange={(e) => setEcName(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-bold text-slate-600">{t("regContactPhone")}</label>
              <div className="flex items-center gap-3 px-4 h-14 rounded-2xl border-2 border-blue-100 bg-blue-50 focus-within:border-blue-500">
                <Icon name="phone" size={20} fill={1} className="text-slate-400 shrink-0" />
                <input
                  type="tel"
                  placeholder="+60 12-345 6789"
                  value={ecPhone}
                  onChange={(e) => setEcPhone(e.target.value)}
                  className="flex-1 bg-transparent text-slate-800 text-base font-semibold placeholder:text-slate-300 outline-none"
                />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-600">{t("regRelationship")}</label>
              <div className="grid grid-cols-3 gap-2">
                {relationships.map((r) => (
                  <button
                    key={r.value}
                    onClick={() => setEcRelationship(r.value)}
                    className={`py-3 px-2 rounded-2xl text-sm font-bold border-2 transition-all ${
                      ecRelationship === r.value
                        ? "bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-200"
                        : "bg-white text-slate-600 border-slate-200"
                    }`}
                  >
                    {t(r.key)}
                  </button>
                ))}
              </div>
            </div>

            {/* Summary */}
            {ecName && ecPhone && ecRelationship && (
              <motion.div
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-red-50 border border-red-200 rounded-2xl p-4 flex items-center gap-4"
              >
                <div className="w-12 h-12 rounded-2xl bg-red-100 flex items-center justify-center shrink-0">
                  <Icon name="person" size={26} fill={1} className="text-red-600" />
                </div>
                <div>
                  <p className="font-bold text-slate-800">{ecName}</p>
                  <p className="text-slate-500 text-sm">{ecPhone} · {ecRelationship}</p>
                </div>
              </motion.div>
            )}
          </>
        )}

        <AnimatePresence>
          {error && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="flex items-center gap-2 bg-red-50 border border-red-200 rounded-2xl px-4 py-3"
            >
              <Icon name="error" size={18} fill={1} className="text-red-500 shrink-0" />
              <p className="text-red-600 text-sm font-medium">{error}</p>
            </motion.div>
          )}
        </AnimatePresence>

        <motion.button
          onClick={nextStep}
          whileTap={{ scale: 0.97 }}
          disabled={loading}
          className="w-full h-16 rounded-3xl bg-blue-600 text-white font-black text-xl shadow-lg shadow-blue-200 flex items-center justify-center gap-3 mt-auto disabled:opacity-80"
        >
          {loading ? (
            <>
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 0.8, repeat: Infinity, ease: "linear" }}
                className="w-6 h-6 rounded-full border-t-white"
                style={{ borderWidth: 3, borderColor: "rgba(255,255,255,0.3)", borderTopColor: "white" }}
              />
              {t("regCreatingAccount")}
            </>
          ) : step < 4 ? (
            <>
              {t("continueBtn")}
              <Icon name="arrow_forward" size={24} fill={1} />
            </>
          ) : (
            <>
              <Icon name="how_to_reg" size={26} fill={1} />
              {t("createAccount")}
            </>
          )}
        </motion.button>

        <div className="flex items-center justify-center gap-2">
          <p className="text-slate-500 text-base">{t("alreadyHaveAccount")}</p>
          <button onClick={onLogin} className="text-blue-600 font-black text-base">{t("signIn")}</button>
        </div>
      </motion.div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 2 — Home
// ══════════════════════════════════════════════════════════════════════════
// ── Inline Language Switcher ───────────────────────────────────────────────
function LangSwitcher({ compact = false }: { compact?: boolean }) {
  const { lang, setLang } = useLang();
  return (
    <div className={`flex gap-1.5 ${compact ? "" : "flex-wrap"}`}>
      {APP_LANGS.map((l) => (
        <button
          key={l.id}
          onClick={() => setLang(l.id)}
          className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold border transition-all ${
            lang === l.id
              ? "bg-white text-blue-700 border-white shadow-sm"
              : "bg-white/15 text-white/80 border-white/20 hover:bg-white/25"
          }`}
        >
          <span>{l.flag}</span>
          <span>{l.native}</span>
        </button>
      ))}
    </div>
  );
}

function HomeScreen({ onScreen, nav, setNav, userName, onIntent }: {
  onScreen: (s: Screen) => void;
  nav: NavTab;
  setNav: (tab: NavTab) => void;
  userName: string;
  onIntent: (intent: VoiceIntent) => void;
}) {
  const { t, voiceLang } = useLang();

  const startListening = (intent: VoiceIntent) => {
    onIntent(intent);
    onScreen("listening");
  };

  return (
    <div className="flex flex-col h-full bg-background overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-b from-blue-600 to-blue-500 px-5 pt-12 pb-5 rounded-b-[2rem]">
        <div className="flex items-center justify-between mb-3">
          <div>
            <p className="text-blue-200 text-sm font-medium">{t("greeting")},</p>
            <h1 className="text-2xl font-black text-white">{userName} 👋</h1>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-white/20 flex items-center justify-center">
            <Icon name="waving_hand" size={26} fill={1} className="text-amber-300" />
          </div>
        </div>

        {/* Language switcher strip */}
        <LangSwitcher />

        <div className="mt-3 px-3 py-2 rounded-2xl bg-white/15 border border-white/20 flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse" />
          <Icon name="mic" size={14} fill={1} className="text-white/70" />
          <span className="text-white text-sm font-medium">{t("voiceLangLabel")}: <strong>{voiceLang}</strong></span>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-28 pt-5 space-y-5">
        {/* Giant Mic Button */}
        <div className="flex flex-col items-center py-4">
          <p className="text-slate-500 text-base text-center mb-5 font-medium leading-relaxed">
            {t("homeSubtitle")}
          </p>
          <motion.button
            onClick={() => startListening(DEFAULT_INTENT)}
            whileTap={{ scale: 0.94 }}
            className="relative w-36 h-36 rounded-full bg-blue-600 shadow-[0_8px_40px_rgba(37,99,235,0.45)] flex items-center justify-center"
          >
            {[1, 2].map((i) => (
              <motion.div
                key={i}
                className="absolute inset-0 rounded-full border-2 border-blue-400"
                animate={{ scale: [1, 1.4, 1.7], opacity: [0.5, 0.2, 0] }}
                transition={{ duration: 2, delay: i * 0.6, repeat: Infinity }}
              />
            ))}
            <Icon name="mic" size={60} fill={1} className="text-white" />
          </motion.button>
          <p className="text-slate-400 text-sm mt-4 font-medium">{t("tapToSpeak")}</p>
        </div>

        {/* Example chips — each maps to a specific service */}
        <div>
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3">{t("trySaying")}</p>
          <div className="flex flex-col gap-2">
            {VOICE_INTENTS.map((intent) => (
              <button
                key={intent.phrase}
                onClick={() => startListening(intent)}
                className="flex items-center gap-3 px-4 py-3 rounded-2xl bg-white border border-blue-100 shadow-sm active:scale-[0.98] transition-transform text-left"
              >
                <div className={`w-9 h-9 rounded-xl ${intent.serviceColor} flex items-center justify-center shrink-0`}>
                  <Icon name={intent.serviceIcon} size={18} fill={1} className="text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-slate-700 text-sm font-semibold truncate">"{intent.phrase}"</p>
                  <p className="text-slate-400 text-xs mt-0.5">→ {intent.service}</p>
                </div>
                <Badge label={intent.detectedLang} color="blue" />
              </button>
            ))}
          </div>
        </div>

        {/* Feature Cards */}
        <div className="grid grid-cols-2 gap-3">
          <motion.button
            onClick={() => onScreen("govServices")}
            whileTap={{ scale: 0.96 }}
            className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-3xl p-4 text-left shadow-lg shadow-blue-200 flex flex-col gap-3"
          >
            <div className="w-11 h-11 rounded-2xl bg-white/20 flex items-center justify-center">
              <Icon name="account_balance" size={24} fill={1} className="text-white" />
            </div>
            <div>
              <p className="text-white font-bold text-base leading-tight">{t("govServices")}</p>
              <p className="text-blue-200 text-xs mt-1">{t("aiTools")}</p>
            </div>
          </motion.button>

          <motion.button
            onClick={() => onScreen("smartMobility")}
            whileTap={{ scale: 0.96 }}
            className="bg-gradient-to-br from-green-500 to-green-600 rounded-3xl p-4 text-left shadow-lg shadow-green-200 flex flex-col gap-3"
          >
            <div className="w-11 h-11 rounded-2xl bg-white/20 flex items-center justify-center">
              <Icon name="directions_walk" size={24} fill={1} className="text-white" />
            </div>
            <div>
              <p className="text-white font-bold text-base leading-tight">{t("smartMobility")}</p>
              <p className="text-green-200 text-xs mt-1">{t("aiRoutes")}</p>
            </div>
          </motion.button>
        </div>

        {/* Quick links */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 overflow-hidden">
          {([
            { icon: "description", labelKey: "qlLetterInterpreter" as TKey, screen: "letterInterpreter" as Screen, color: "text-purple-600" },
            { icon: "edit_document", labelKey: "qlFormAssistant" as TKey, screen: "formAssistant" as Screen, color: "text-blue-600" },
            { icon: "checklist", labelKey: "qlDocChecker" as TKey, screen: "docChecker" as Screen, color: "text-green-600" },
            { icon: "map", labelKey: "qlWalkability" as TKey, screen: "walkability" as Screen, color: "text-amber-600" },
          ]).map((item, i, arr) => (
            <button
              key={item.labelKey}
              onClick={() => onScreen(item.screen)}
              className={`w-full flex items-center gap-4 px-5 py-4 active:bg-blue-50 transition-colors ${i < arr.length - 1 ? "border-b border-blue-50" : ""}`}
            >
              <div className={`w-10 h-10 rounded-2xl bg-slate-50 flex items-center justify-center ${item.color}`}>
                <Icon name={item.icon} size={22} fill={1} />
              </div>
              <span className="text-slate-800 font-semibold text-base flex-1 text-left">{t(item.labelKey)}</span>
              <Icon name="chevron_right" size={20} className="text-slate-300" />
            </button>
          ))}
        </div>
      </div>

      <BottomNav active={nav} onChange={(tab) => {
        setNav(tab);
        if (tab === "profile") onScreen("profile");
        if (tab === "history") onScreen("history");
        if (tab === "notifications") onScreen("notifications");
      }} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 3 — Voice Listening
// ══════════════════════════════════════════════════════════════════════════
function ListeningScreen({ onNext, onBack, intent }: {
  onNext: () => void;
  onBack: () => void;
  intent: VoiceIntent;
}) {
  const [phase, setPhase] = useState<"listening" | "transcribing" | "done">("listening");
  const [transcript, setTranscript] = useState("");

  useEffect(() => {
    const t1 = setTimeout(() => setPhase("transcribing"), 2500);
    const t2 = setTimeout(() => {
      let i = 0;
      const interval = setInterval(() => {
        setTranscript(intent.phrase.slice(0, ++i));
        if (i >= intent.phrase.length) {
          clearInterval(interval);
          setPhase("done");
        }
      }, 80);
      return () => clearInterval(interval);
    }, 3200);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, [intent.phrase]);

  const { t, voiceLang } = useLang();

  return (
    <div className="flex flex-col h-full bg-gradient-to-b from-slate-950 to-blue-950 text-white">
      <div className="flex items-center gap-3 px-5 pt-12 pb-4">
        <button onClick={onBack} className="w-10 h-10 rounded-2xl bg-white/10 flex items-center justify-center">
          <Icon name="close" size={22} className="text-white" />
        </button>
        <div className="flex-1">
          <h1 className="text-xl font-bold">{t("voiceInput")}</h1>
          <p className="text-white/50 text-xs mt-0.5">{t("voiceLangLabel")}: <span className="text-amber-300 font-semibold">{voiceLang}</span></p>
        </div>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-6 gap-8">
        {/* Animated mic */}
        <div className="relative flex items-center justify-center">
          {phase === "listening" && [1, 2, 3].map((i) => (
            <motion.div
              key={i}
              className="absolute rounded-full border border-blue-400/40"
              style={{ width: 80 + i * 50, height: 80 + i * 50 }}
              animate={{ scale: [1, 1.08, 1], opacity: [0.4, 0.1, 0.4] }}
              transition={{ duration: 1.5, delay: i * 0.3, repeat: Infinity }}
            />
          ))}
          <motion.div
            className={`w-28 h-28 rounded-full flex items-center justify-center shadow-2xl ${phase === "done" ? "bg-green-500" : "bg-blue-600"}`}
            animate={phase === "listening" ? { scale: [1, 1.04, 1] } : {}}
            transition={{ duration: 0.8, repeat: phase === "listening" ? Infinity : 0 }}
          >
            <Icon name={phase === "done" ? "check" : "mic"} size={56} fill={1} className="text-white" />
          </motion.div>
        </div>

        {/* Wave bars */}
        {phase === "listening" && (
          <div className="flex items-center gap-1.5 h-12">
            {Array.from({ length: 22 }).map((_, i) => (
              <motion.div
                key={i}
                className="w-1.5 rounded-full bg-blue-400"
                animate={{ height: [8, Math.random() * 36 + 12, 8] }}
                transition={{ duration: 0.6 + Math.random() * 0.4, delay: i * 0.05, repeat: Infinity }}
              />
            ))}
          </div>
        )}

        {/* Status */}
        <div className="w-full space-y-4">
          <div className="bg-white/10 backdrop-blur-sm rounded-3xl p-4 border border-white/10">
            <div className="flex items-center gap-2 mb-2">
              {phase === "listening" && <span className="w-2 h-2 rounded-full bg-red-400 animate-pulse" />}
              {phase === "transcribing" && <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />}
              {phase === "done" && <span className="w-2 h-2 rounded-full bg-green-400" />}
              <p className="text-xs font-bold uppercase tracking-widest text-white/60">
                {phase === "listening" ? t("listening") : phase === "transcribing" ? t("recognising") : t("understood")}
              </p>
              <AITag label="ASR" />
            </div>
            <p className="text-lg font-semibold text-white min-h-[1.75rem]">{transcript || "—"}</p>
          </div>

          {(phase === "transcribing" || phase === "done") && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-white/10 backdrop-blur-sm rounded-3xl p-4 border border-white/10"
            >
              <div className="flex items-center gap-2 mb-2">
                <AITag label="Dialect AI" />
              </div>
              <p className="text-xs text-white/60 font-semibold uppercase tracking-wide mb-1">{t("detectedDialect")}</p>
              <p className="text-lg font-bold text-amber-300">{intent.detectedLang}</p>
            </motion.div>
          )}

          {phase === "done" && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="bg-white/10 backdrop-blur-sm rounded-3xl p-4 border border-white/10"
            >
              <div className="flex items-center gap-2 mb-2">
                <AITag label="NLP" />
                <AITag label="Intent" />
              </div>
              <p className="text-xs text-white/60 font-semibold uppercase tracking-wide mb-1">{t("aiUnderstanding")}</p>
              <div className="flex items-center gap-3 mt-1">
                <div className={`w-9 h-9 rounded-xl ${intent.serviceColor} flex items-center justify-center shrink-0`}>
                  <Icon name={intent.serviceIcon} size={18} fill={1} className="text-white" />
                </div>
                <div>
                  <p className="text-base font-bold text-green-300">{intent.service}</p>
                  <p className="text-xs text-white/50 mt-0.5">{intent.serviceDesc}</p>
                </div>
              </div>
            </motion.div>
          )}
        </div>
      </div>

      {phase === "done" && (
        <motion.div
          initial={{ y: 40, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="px-5 pb-10"
        >
          <button
            onClick={onNext}
            className="w-full py-5 rounded-3xl bg-green-500 text-white font-bold text-xl shadow-2xl shadow-green-900/40 flex items-center justify-center gap-3"
          >
            <Icon name="auto_awesome" size={26} fill={1} />
            {t("processingWithAI")}
          </button>
        </motion.div>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 4 — AI Processing Pipeline
// ══════════════════════════════════════════════════════════════════════════
function ProcessingScreen({ onNext, intent }: { onNext: () => void; intent: VoiceIntent }) {
  const { t } = useLang();
  const steps = intent.pipelineSteps;
  const [active, setActive] = useState(0);

  useEffect(() => {
    if (active < steps.length - 1) {
      const timer = setTimeout(() => setActive((a) => a + 1), 800);
      return () => clearTimeout(timer);
    } else {
      const timer = setTimeout(() => onNext(), 900);
      return () => clearTimeout(timer);
    }
  }, [active, steps.length]);

  const lastStep = steps[steps.length - 1];

  return (
    <div className="flex flex-col h-full bg-gradient-to-b from-blue-700 to-blue-900 px-5 text-white">
      <div className="pt-14 pb-5 text-center">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
          className="w-16 h-16 rounded-full border-4 border-white/20 border-t-white mx-auto mb-4"
        />
        <h1 className="text-2xl font-black">{t("aiProcessing")}</h1>
        <p className="text-blue-200 text-sm mt-1">"{intent.phrase}"</p>
      </div>

      <div className="flex-1 flex flex-col gap-3 pb-6">
        {steps.map((step, i) => (
          <motion.div
            key={i}
            initial={{ x: -30, opacity: 0 }}
            animate={i <= active ? { x: 0, opacity: 1 } : {}}
            transition={{ duration: 0.4 }}
            className={`flex items-center gap-4 p-4 rounded-3xl border transition-all duration-300 ${
              i === active
                ? "bg-white text-slate-900 border-white shadow-2xl scale-[1.02]"
                : i < active
                ? "bg-white/20 border-white/20 text-white"
                : "bg-white/5 border-white/10 text-white/40"
            }`}
          >
            <div className={`w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 ${i <= active ? step.color : "bg-white/10"}`}>
              <Icon name={step.icon} size={26} fill={1} className="text-white" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-0.5">
                <p className="font-bold text-base">{step.label}</p>
                {i <= active && (
                  <span className="px-2 py-0.5 rounded-full bg-white/20 text-[10px] font-bold uppercase tracking-wide">
                    {step.tech}
                  </span>
                )}
              </div>
              <p className={`text-sm ${i === active ? "text-slate-600" : "text-white/60"}`}>{step.desc}</p>
            </div>
            {i < active && <Icon name="check_circle" size={24} fill={1} className="text-green-400 shrink-0" />}
            {i === active && (
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                className="w-6 h-6 rounded-full border-2 border-blue-600/30 border-t-blue-600 shrink-0"
              />
            )}
          </motion.div>
        ))}

        {/* Final destination card */}
        {active === steps.length - 1 && (
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-green-500/20 border border-green-400/30 rounded-3xl p-4 flex items-center gap-4"
          >
            <div className={`w-12 h-12 rounded-2xl ${lastStep.color} flex items-center justify-center shrink-0`}>
              <Icon name={lastStep.icon} size={26} fill={1} className="text-white" />
            </div>
            <div>
              <p className="text-white/60 text-xs font-bold uppercase tracking-widest mb-0.5">{t("openingNow")}</p>
              <p className="text-white font-black text-base">{intent.service}</p>
              <p className="text-green-300 text-xs mt-0.5">{intent.serviceDesc}</p>
            </div>
            <Icon name="arrow_forward" size={22} className="text-green-300 ml-auto shrink-0" />
          </motion.div>
        )}
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 5 — Government Services
// ══════════════════════════════════════════════════════════════════════════
function GovServicesScreen({ onScreen, onBack }: { onScreen: (s: Screen) => void; onBack: () => void }) {
  const { t } = useLang();
  const services = [
    { icon: "record_voice_over", titleKey: "govSvc1Title" as TKey, descKey: "govSvc1Desc" as TKey, color: "from-blue-500 to-blue-600", tags: ["ASR", "NLP"], screen: "listening" as Screen },
    { icon: "description", titleKey: "govSvc2Title" as TKey, descKey: "govSvc2Desc" as TKey, color: "from-purple-500 to-purple-600", tags: ["OCR", "LLM"], screen: "letterInterpreter" as Screen },
    { icon: "edit_document", titleKey: "govSvc3Title" as TKey, descKey: "govSvc3Desc" as TKey, color: "from-amber-500 to-amber-600", tags: ["LLM", "NLP"], screen: "formAssistant" as Screen },
    { icon: "checklist_rtl", titleKey: "govSvc4Title" as TKey, descKey: "govSvc4Desc" as TKey, color: "from-green-500 to-green-600", tags: ["AI Checklist"], screen: "docChecker" as Screen },
  ];

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("govServices")} subtitle={t("govHubSubtitle")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        {/* Banner */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-3xl p-4 flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-white/20 flex items-center justify-center shrink-0">
            <Icon name="smart_toy" size={32} fill={1} className="text-white" />
          </div>
          <div>
            <p className="text-white font-bold text-base">{t("govBannerTitle")}</p>
            <p className="text-blue-200 text-sm">{t("govBannerDesc")}</p>
          </div>
        </div>

        {services.map((svc) => (
          <motion.button
            key={svc.titleKey}
            onClick={() => onScreen(svc.screen)}
            whileTap={{ scale: 0.97 }}
            className="w-full bg-white rounded-3xl shadow-sm border border-blue-50 p-5 text-left flex items-start gap-4"
          >
            <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${svc.color} flex items-center justify-center shrink-0`}>
              <Icon name={svc.icon} size={28} fill={1} className="text-white" />
            </div>
            <div className="flex-1">
              <p className="font-bold text-slate-900 text-base">{t(svc.titleKey)}</p>
              <p className="text-slate-500 text-sm mt-1 leading-relaxed">{t(svc.descKey)}</p>
              <div className="flex gap-1.5 mt-2">
                {svc.tags.map((tag) => <AITag key={tag} label={tag} />)}
              </div>
            </div>
            <Icon name="chevron_right" size={22} className="text-slate-300 mt-1 shrink-0" />
          </motion.button>
        ))}

        <div className="bg-amber-50 border border-amber-200 rounded-3xl p-4 flex gap-3">
          <Icon name="info" size={22} fill={1} className="text-amber-600 shrink-0 mt-0.5" />
          <p className="text-amber-800 text-sm font-medium leading-relaxed">{t("govHint")}</p>
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SHARED — Service Chat Bar + helpers
// ══════════════════════════════════════════════════════════════════════════

interface ChatMsg { role: "user" | "ai"; text: string; isVoice?: boolean; }

function useServiceChat(initial: ChatMsg[]) {
  const { t } = useLang();
  const [messages, setMessages] = useState<ChatMsg[]>(initial);
  const [input, setInput] = useState("");
  const [isListening, setIsListening] = useState(false);
  const [isThinking, setIsThinking] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  const sendMessage = (text: string, isVoice = false) => {
    if (!text.trim()) return;
    const userMsg: ChatMsg = { role: "user", text: text.trim(), isVoice };
    setMessages((m) => [...m, userMsg]);
    setInput("");
    setIsThinking(true);
    setTimeout(() => {
      const replies = [
        t("aiReply1"), t("aiReply2"), t("aiReply3"), t("aiReply4"), t("aiReply5"),
      ];
      const reply = replies[Math.floor(Math.random() * replies.length)];
      setMessages((m) => [...m, { role: "ai", text: reply }]);
      setIsThinking(false);
    }, 1200);
  };

  const toggleMic = () => {
    const sample = t("voiceSample");
    if (isListening) {
      setIsListening(false);
      sendMessage(sample, true);
    } else {
      setIsListening(true);
      setTimeout(() => {
        setIsListening(false);
        sendMessage(sample, true);
      }, 2500);
    }
  };

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isThinking]);

  return { messages, input, setInput, isListening, isThinking, sendMessage, toggleMic, bottomRef };
}

function ChatBubble({ msg }: { msg: ChatMsg }) {
  return (
    <div className={`flex ${msg.role === "user" ? "justify-end" : "justify-start"} items-end gap-2`}>
      {msg.role === "ai" && (
        <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center shrink-0 mb-0.5">
          <Icon name="smart_toy" size={18} fill={1} className="text-white" />
        </div>
      )}
      <div className={`max-w-[78%] px-4 py-3 rounded-3xl text-base font-medium leading-relaxed ${
        msg.role === "user"
          ? "bg-blue-600 text-white rounded-br-lg"
          : "bg-white text-slate-800 shadow-sm border border-blue-50 rounded-bl-lg"
      }`}>
        {msg.isVoice && (
          <div className="flex items-center gap-1.5 mb-1.5">
            <Icon name="mic" size={14} fill={1} className="text-blue-200" />
            <span className="text-[11px] text-blue-200 font-semibold uppercase tracking-wide">Voice</span>
          </div>
        )}
        {msg.text}
      </div>
      {msg.role === "user" && (
        <div className="w-8 h-8 rounded-full bg-slate-200 flex items-center justify-center shrink-0 mb-0.5">
          <Icon name="person" size={18} fill={1} className="text-slate-500" />
        </div>
      )}
    </div>
  );
}

function ThinkingBubble() {
  return (
    <div className="flex items-end gap-2">
      <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center shrink-0">
        <Icon name="smart_toy" size={18} fill={1} className="text-white" />
      </div>
      <div className="bg-white rounded-3xl rounded-bl-lg px-4 py-3 shadow-sm border border-blue-50 flex gap-1.5">
        {[0, 0.2, 0.4].map((delay, i) => (
          <motion.div
            key={i}
            className="w-2 h-2 rounded-full bg-blue-400"
            animate={{ y: [0, -5, 0] }}
            transition={{ duration: 0.6, delay, repeat: Infinity }}
          />
        ))}
      </div>
    </div>
  );
}

function ServiceChatBar({
  input, setInput, isListening, isThinking, onSend, onToggleMic,
}: {
  input: string;
  setInput: (v: string) => void;
  isListening: boolean;
  isThinking: boolean;
  onSend: (text: string) => void;
  onToggleMic: () => void;
}) {
  const { t } = useLang();
  return (
    <div className="px-4 pb-6 pt-3 flex gap-2 border-t border-blue-50 bg-white">
      {/* Text input */}
      <div className={`flex-1 min-h-[52px] rounded-2xl border flex items-center px-4 gap-2 transition-all ${
        isListening ? "bg-red-50 border-red-300" : "bg-blue-50 border-blue-100"
      }`}>
        {isListening ? (
          <div className="flex-1 flex items-center gap-2">
            <motion.div
              className="w-2.5 h-2.5 rounded-full bg-red-500"
              animate={{ scale: [1, 1.5, 1], opacity: [1, 0.5, 1] }}
              transition={{ duration: 0.8, repeat: Infinity }}
            />
            <span className="text-red-600 font-semibold text-base">{t("listeningLabel")}</span>
          </div>
        ) : (
          <input
            className="flex-1 bg-transparent text-slate-800 placeholder-slate-400 text-base outline-none"
            placeholder={t("typeAnswer")}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && !isThinking && onSend(input)}
          />
        )}
        {input.length > 0 && !isListening && (
          <button
            onClick={() => onSend(input)}
            disabled={isThinking}
            className="w-8 h-8 rounded-xl bg-blue-600 flex items-center justify-center shrink-0 disabled:opacity-40"
          >
            <Icon name="send" size={18} fill={1} className="text-white" />
          </button>
        )}
      </div>

      {/* Mic button */}
      <button
        onClick={onToggleMic}
        disabled={isThinking}
        className={`w-[52px] h-[52px] rounded-2xl flex items-center justify-center shadow-md shrink-0 transition-all disabled:opacity-40 ${
          isListening ? "bg-red-500 shadow-red-200" : "bg-blue-600 shadow-blue-200"
        }`}
      >
        <Icon name={isListening ? "stop" : "mic"} size={26} fill={1} className="text-white" />
      </button>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 6 — Government Letter Interpreter
// ══════════════════════════════════════════════════════════════════════════
function LetterInterpreterScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const [state, setState] = useState<"upload" | "result">("upload");
  const chat = useServiceChat([
    { role: "ai", text: t("letterChatInit") },
  ]);

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("letterTitle")} subtitle={t("letterSubtitle")} onBack={onBack} />

      {state === "upload" ? (
        <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
          <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-5">
            <p className="text-slate-700 font-semibold mb-4">{t("uploadPhotoPrompt")}</p>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setState("result")}
                className="flex flex-col items-center gap-3 p-5 rounded-2xl border-2 border-dashed border-blue-300 bg-blue-50 active:bg-blue-100 transition-colors"
              >
                <Icon name="camera_alt" size={36} fill={1} className="text-blue-600" />
                <span className="text-blue-700 font-bold text-sm">{t("takePhoto")}</span>
              </button>
              <button
                onClick={() => setState("result")}
                className="flex flex-col items-center gap-3 p-5 rounded-2xl border-2 border-dashed border-purple-300 bg-purple-50 active:bg-purple-100 transition-colors"
              >
                <Icon name="upload_file" size={36} fill={1} className="text-purple-600" />
                <span className="text-purple-700 font-bold text-sm">{t("uploadFile")}</span>
              </button>
            </div>
            <div className="flex items-center gap-2 mt-3">
              <AITag label="OCR" />
              <AITag label="LLM" />
              <span className="text-xs text-slate-400">{t("supportedFormats")}</span>
            </div>
          </div>
          <div className="bg-slate-50 rounded-3xl border border-slate-100 p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-slate-200 flex items-center justify-center shrink-0">
              <Icon name="description" size={26} className="text-slate-500" />
            </div>
            <div>
              <p className="text-slate-600 font-semibold text-sm">{t("exampleLetters")}</p>
              <p className="text-slate-400 text-xs mt-1">{t("exampleLettersList")}</p>
            </div>
          </div>
        </div>
      ) : (
        <>
          <div className="flex-1 overflow-y-auto px-5 pt-2 pb-4 space-y-4">
            {/* OCR Result */}
            <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-4">
              <div className="flex items-center gap-2 mb-3">
                <AITag label="OCR" />
                <span className="text-xs text-slate-400">{t("textExtracted")}</span>
              </div>
              <div className="bg-slate-50 rounded-2xl p-3 text-xs text-slate-600 font-mono leading-relaxed border border-slate-100">
                JABATAN PENDAFTARAN NEGARA<br />
                Ref: JPN/IC/2024/00847<br />
                Tarikh: 15 Januari 2025<br />
                NOTIS PEMBAHARUAN KAD PENGENALAN<br />
                Kad pengenalan anda akan tamat tempoh pada 28 Februari 2025...
              </div>
            </div>

            {/* AI Explanation */}
            <div className="bg-blue-50 rounded-3xl border border-blue-100 p-4">
              <div className="flex items-center gap-2 mb-2">
                <Icon name="smart_toy" size={20} fill={1} className="text-blue-600" />
                <span className="font-bold text-blue-700 text-sm">{t("aiExplanationLabel")}</span>
                <AITag label="LLM" />
              </div>
              <p className="text-slate-700 text-base leading-relaxed font-medium">{t("letterAiResult")}</p>
            </div>

            {/* Deadline */}
            <div className="bg-red-50 rounded-3xl border border-red-200 p-4 flex items-center gap-4">
              <div className="w-12 h-12 rounded-2xl bg-red-100 flex items-center justify-center shrink-0">
                <Icon name="event_busy" size={26} fill={1} className="text-red-600" />
              </div>
              <div>
                <p className="text-xs font-bold text-red-500 uppercase tracking-widest">{t("deadlineLabel")}</p>
                <p className="text-red-700 font-bold text-lg">28 February 2025</p>
              </div>
              <button className="ml-auto w-10 h-10 rounded-2xl bg-blue-600 flex items-center justify-center shrink-0">
                <Icon name="volume_up" size={22} fill={1} className="text-white" />
              </button>
            </div>

            {/* Divider — Ask AI */}
            <div className="flex items-center gap-3">
              <div className="flex-1 h-px bg-blue-100" />
              <span className="text-xs font-bold text-blue-400 uppercase tracking-widest">{t("askAboutLetter")}</span>
              <div className="flex-1 h-px bg-blue-100" />
            </div>

            {/* Chat messages */}
            <div className="space-y-3">
              {chat.messages.map((msg, i) => <ChatBubble key={i} msg={msg} />)}
              {chat.isThinking && <ThinkingBubble />}
              <div ref={chat.bottomRef} />
            </div>

            <button onClick={() => setState("upload")} className="w-full py-3 rounded-3xl border-2 border-blue-200 text-blue-600 font-bold text-base">
              {t("scanAnotherLetter")}
            </button>
          </div>

          <ServiceChatBar
            input={chat.input}
            setInput={chat.setInput}
            isListening={chat.isListening}
            isThinking={chat.isThinking}
            onSend={chat.sendMessage}
            onToggleMic={chat.toggleMic}
          />
        </>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 7 — Smart Form Assistant
// ══════════════════════════════════════════════════════════════════════════
function FormAssistantScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const [step, setStep] = useState(3);
  const totalSteps = 7;
  const chat = useServiceChat([
    { role: "ai", text: t("formChatInit1") },
    { role: "ai", text: t("formChatInit2") },
    { role: "user", text: "Ahmad bin Abdullah" },
    { role: "ai", text: t("formChatInit3") },
    { role: "user", text: "570814-01-5432" },
    { role: "ai", text: t("formChatInit4") },
  ]);

  const handleSend = (text: string, isVoice = false) => {
    chat.sendMessage(text, isVoice);
    if (step < totalSteps) setStep((s) => Math.min(s + 1, totalSteps));
  };

  const progress = (step / totalSteps) * 100;

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("formAssistantTitle")} subtitle={t("aiGuidesStep")} onBack={onBack} />

      {/* Progress */}
      <div className="px-5 pb-3">
        <div className="flex items-center justify-between mb-2">
          <p className="text-xs font-bold text-slate-500 uppercase tracking-widest">{t("formProgress")}</p>
          <div className="flex gap-1.5">
            <AITag label="LLM" />
            <AITag label="NLP" />
          </div>
        </div>
        <div className="w-full h-3 bg-blue-100 rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-blue-600 rounded-full"
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.5, ease: "easeOut" }}
          />
        </div>
        <p className="text-xs text-slate-400 mt-1">{t("formStepLabel")} {step} {t("formOfLabel")} {totalSteps} — {step < 4 ? t("formPersonalInfo") : step < 6 ? t("formAddressDetails") : t("formFinalReview")}</p>
      </div>

      {/* Chat */}
      <div className="flex-1 overflow-y-auto px-5 pb-4 space-y-3">
        {chat.messages.map((msg, i) => <ChatBubble key={i} msg={msg} />)}
        {chat.isThinking && <ThinkingBubble />}
        <div ref={chat.bottomRef} />
      </div>

      <ServiceChatBar
        input={chat.input}
        setInput={chat.setInput}
        isListening={chat.isListening}
        isThinking={chat.isThinking}
        onSend={handleSend}
        onToggleMic={() => {
          if (chat.isListening) {
            chat.toggleMic();
          } else {
            chat.toggleMic();
          }
          if (step < totalSteps) setStep((s) => Math.min(s + 1, totalSteps));
        }}
      />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 8 — Document Readiness Checker
// ══════════════════════════════════════════════════════════════════════════
function DocCheckerScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const [docs, setDocs] = useState([
    { nameKey: "docMyKad" as TKey, ready: true, icon: "badge" },
    { nameKey: "docUtilityBill" as TKey, ready: true, icon: "receipt_long" },
    { nameKey: "docPassportPhoto" as TKey, ready: false, icon: "photo_camera" },
    { nameKey: "docBirthCert" as TKey, ready: true, icon: "description" },
    { nameKey: "docBankStatement" as TKey, ready: false, icon: "account_balance" },
  ]);
  const docChat = useServiceChat([
    { role: "ai", text: t("docChatInit") },
  ]);

  const ready = docs.filter((d) => d.ready).length;

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("docCheckerTitle")} subtitle={t("docForMyKad")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        {/* Status card */}
        <div className={`rounded-3xl p-5 flex items-center gap-4 ${ready >= docs.length - 1 ? "bg-amber-50 border border-amber-200" : "bg-green-50 border border-green-200"}`}>
          <div className={`w-16 h-16 rounded-2xl flex items-center justify-center shrink-0 ${ready === docs.length ? "bg-green-500" : "bg-amber-500"}`}>
            <Icon name={ready === docs.length ? "check_circle" : "warning"} size={36} fill={1} className="text-white" />
          </div>
          <div>
            <p className={`text-2xl font-black ${ready === docs.length ? "text-green-700" : "text-amber-700"}`}>
              {ready} / {docs.length} {t("docReadyLabel")}
            </p>
            <p className={`text-sm font-medium mt-0.5 ${ready === docs.length ? "text-green-600" : "text-amber-600"}`}>
              {docs.length - ready} {t("docMissingLabel")}
            </p>
          </div>
        </div>

        {/* Checklist */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 overflow-hidden">
          {docs.map((doc, i) => (
            <button
              key={doc.nameKey}
              onClick={() => setDocs((d) => d.map((item, idx) => idx === i ? { ...item, ready: !item.ready } : item))}
              className={`w-full flex items-center gap-4 px-5 py-4 active:bg-blue-50 transition-colors ${i < docs.length - 1 ? "border-b border-blue-50" : ""}`}
            >
              <div className={`w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 ${doc.ready ? "bg-green-100" : "bg-red-100"}`}>
                <Icon name={doc.icon} size={24} fill={1} className={doc.ready ? "text-green-600" : "text-red-500"} />
              </div>
              <p className={`flex-1 text-left font-semibold text-base ${doc.ready ? "text-slate-800" : "text-slate-500"}`}>
                {t(doc.nameKey)}
              </p>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center ${doc.ready ? "bg-green-500" : "bg-slate-200"}`}>
                <Icon name={doc.ready ? "check" : "close"} size={18} fill={1} className={doc.ready ? "text-white" : "text-slate-400"} />
              </div>
            </button>
          ))}
        </div>

        {/* Missing actions */}
        <div className="bg-red-50 rounded-3xl border border-red-100 p-4">
          <p className="font-bold text-red-700 mb-3">{t("missingDocsTitle")}</p>
          {docs.filter((d) => !d.ready).map((doc) => (
            <div key={doc.nameKey} className="flex items-center gap-3 mb-2">
              <Icon name="info" size={18} fill={1} className="text-red-400 shrink-0" />
              <p className="text-red-700 text-sm font-medium">
                <strong>{t(doc.nameKey)}</strong> — {t("visitJpnOffice")}
              </p>
            </div>
          ))}
        </div>

        {/* Ask AI section */}
        <div className="flex items-center gap-3">
          <div className="flex-1 h-px bg-blue-100" />
          <span className="text-xs font-bold text-blue-400 uppercase tracking-widest">{t("askAiHelp")}</span>
          <div className="flex-1 h-px bg-blue-100" />
        </div>

        <div className="space-y-3">
          {docChat.messages.map((msg, i) => <ChatBubble key={i} msg={msg} />)}
          {docChat.isThinking && <ThinkingBubble />}
          <div ref={docChat.bottomRef} />
        </div>
      </div>

      <ServiceChatBar
        input={docChat.input}
        setInput={docChat.setInput}
        isListening={docChat.isListening}
        isThinking={docChat.isThinking}
        onSend={docChat.sendMessage}
        onToggleMic={docChat.toggleMic}
      />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 9 — Smart Mobility
// ══════════════════════════════════════════════════════════════════════════
const MOBILITY_SUGGESTIONS = [
  { label: "Hospital Sultanah Aminah", icon: "local_hospital", dist: "2.4 km", color: "text-green-600", bg: "bg-green-50" },
  { label: "JPN Office Johor Bahru", icon: "account_balance", dist: "1.1 km", color: "text-blue-600", bg: "bg-blue-50" },
  { label: "KWSP Cawangan JB", icon: "savings", dist: "3.2 km", color: "text-amber-600", bg: "bg-amber-50" },
  { label: "Pos Malaysia Larkin", icon: "mail", dist: "0.8 km", color: "text-purple-600", bg: "bg-purple-50" },
  { label: "Klinik Kesihatan Tebrau", icon: "medical_services", dist: "1.7 km", color: "text-red-600", bg: "bg-red-50" },
];

function SmartMobilityScreen({ onScreen, onBack }: { onScreen: (s: Screen) => void; onBack: () => void }) {
  const { t } = useLang();
  const [destination, setDestination] = useState("Hospital Sultanah Aminah");
  const [inputText, setInputText] = useState("");
  const [isListening, setIsListening] = useState(false);
  const [searching, setSearching] = useState(false);
  const [confirmed, setConfirmed] = useState(true);
  const inputRef = useRef<HTMLInputElement>(null);

  const suggestions = inputText.length > 0
    ? MOBILITY_SUGGESTIONS.filter((s) => s.label.toLowerCase().includes(inputText.toLowerCase()))
    : MOBILITY_SUGGESTIONS;

  const confirmDest = (label: string) => {
    setSearching(true);
    setInputText("");
    setTimeout(() => {
      setDestination(label);
      setSearching(false);
      setConfirmed(true);
    }, 900);
  };

  const handleSearch = () => {
    if (inputText.trim()) confirmDest(inputText.trim());
  };

  const toggleMic = () => {
    if (isListening) {
      setIsListening(false);
    } else {
      setIsListening(true);
      setInputText("");
      setConfirmed(false);
      setTimeout(() => {
        setIsListening(false);
        confirmDest("Hospital Sultanah Aminah");
      }, 2200);
    }
  };

  const currentSuggestion = MOBILITY_SUGGESTIONS.find((s) => s.label === destination) ?? MOBILITY_SUGGESTIONS[0];

  return (
    <div className="flex flex-col h-full bg-background">
      <div className="bg-gradient-to-b from-green-600 to-green-500 px-5 pt-12 pb-5 rounded-b-[2rem]">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={onBack} className="w-10 h-10 rounded-2xl bg-white/20 flex items-center justify-center text-white">
            <Icon name="arrow_back" size={22} />
          </button>
          <h1 className="text-2xl font-black text-white">{t("smartMobility")}</h1>
        </div>

        {/* Destination input */}
        <div className={`rounded-2xl border flex items-center gap-2 px-3 transition-all ${
          isListening ? "bg-red-50/20 border-red-300/50" : "bg-white border-white/80"
        }`}>
          <Icon name="location_on" size={22} fill={1} className={isListening ? "text-red-300" : "text-green-600"} />
          {isListening ? (
            <div className="flex-1 flex items-center gap-2 py-3.5">
              <motion.div
                className="w-2.5 h-2.5 rounded-full bg-red-400"
                animate={{ scale: [1, 1.6, 1], opacity: [1, 0.4, 1] }}
                transition={{ duration: 0.7, repeat: Infinity }}
              />
              <span className="text-red-200 font-semibold text-base">{t("listeningLabel")}</span>
            </div>
          ) : (
            <input
              ref={inputRef}
              className="flex-1 py-3.5 bg-transparent text-slate-800 placeholder-slate-400 text-base font-semibold outline-none"
              placeholder={t("whereTo")}
              value={inputText}
              onChange={(e) => { setInputText(e.target.value); setConfirmed(false); }}
              onKeyDown={(e) => e.key === "Enter" && handleSearch()}
            />
          )}
          {inputText.length > 0 && !isListening && (
            <button onClick={handleSearch} className="w-9 h-9 rounded-xl bg-green-600 flex items-center justify-center shrink-0">
              <Icon name="search" size={20} fill={1} className="text-white" />
            </button>
          )}
          <button
            onClick={toggleMic}
            className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 transition-colors ${
              isListening ? "bg-red-500/80" : "bg-green-100"
            }`}
          >
            <Icon name={isListening ? "stop" : "mic"} size={20} fill={1} className={isListening ? "text-white" : "text-green-700"} />
          </button>
        </div>

        {/* Suggestions dropdown */}
        {!confirmed && !isListening && suggestions.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-2 bg-white rounded-2xl shadow-lg overflow-hidden border border-green-100"
          >
            {suggestions.slice(0, 4).map((s, i) => (
              <button
                key={s.label}
                onClick={() => confirmDest(s.label)}
                className={`w-full flex items-center gap-3 px-4 py-3 active:bg-green-50 transition-colors text-left ${i > 0 ? "border-t border-slate-50" : ""}`}
              >
                <div className={`w-8 h-8 rounded-xl ${s.bg} flex items-center justify-center shrink-0`}>
                  <Icon name={s.icon} size={18} fill={1} className={s.color} />
                </div>
                <div className="flex-1">
                  <p className="text-slate-800 font-semibold text-sm">{s.label}</p>
                  <p className="text-slate-400 text-xs">{s.dist} {t("awayLabel")}</p>
                </div>
                <Icon name="north_west" size={16} className="text-slate-300 shrink-0" />
              </button>
            ))}
          </motion.div>
        )}
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-4 space-y-4">
        {/* Searching indicator */}
        {searching && (
          <div className="flex items-center justify-center gap-3 py-6">
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 1.2, repeat: Infinity, ease: "linear" }}
              className="w-6 h-6 rounded-full border-2 border-green-200 border-t-green-600"
            />
            <p className="text-green-600 font-semibold">{t("findingRoute")}</p>
          </div>
        )}

        {/* Destination card */}
        {!searching && (
        <div className="bg-white rounded-3xl shadow-sm border border-green-100 p-4 flex items-center gap-4">
          <div className={`w-14 h-14 rounded-2xl ${currentSuggestion.bg} flex items-center justify-center shrink-0`}>
            <Icon name={currentSuggestion.icon} size={30} fill={1} className={currentSuggestion.color} />
          </div>
          <div className="flex-1">
            <p className="text-xs text-slate-400 font-semibold uppercase tracking-widest">{t("destinationLabel")}</p>
            <p className="text-lg font-black text-slate-900">{destination}</p>
            <p className="text-slate-500 text-sm">Johor Bahru · {currentSuggestion.dist} {t("awayLabel")}</p>
          </div>
          <button
            onClick={() => { setConfirmed(false); setInputText(destination); setTimeout(() => inputRef.current?.focus(), 50); }}
            className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center shrink-0"
          >
            <Icon name="edit" size={18} fill={1} className="text-slate-500" />
          </button>
        </div>
        )}

        {!searching && (<>
        {/* Environmental data */}
        <div className="grid grid-cols-3 gap-3">
          {[
            { icon: "thermostat", labelKey: "tempLabel" as TKey, value: "33°C", color: "text-red-600", bg: "bg-red-50" },
            { icon: "water_drop", labelKey: "humidityLabel" as TKey, value: "78%", color: "text-blue-600", bg: "bg-blue-50" },
            { icon: "wb_sunny", labelKey: "uvIndexLabel" as TKey, value: "8 High", color: "text-amber-600", bg: "bg-amber-50" },
          ].map((item) => (
            <div key={item.label} className={`${item.bg} rounded-2xl p-3 text-center`}>
              <Icon name={item.icon} size={22} fill={1} className={`${item.color} mx-auto`} />
              <p className="text-xs text-slate-500 font-medium mt-1">{t(item.labelKey)}</p>
              <p className={`text-sm font-bold ${item.color}`}>{item.value}</p>
            </div>
          ))}
        </div>

        {/* AI Recommendation */}
        <div className="bg-gradient-to-r from-green-600 to-green-700 rounded-3xl p-5">
          <div className="flex items-center gap-2 mb-3">
            <Icon name="smart_toy" size={22} fill={1} className="text-white" />
            <span className="text-white font-bold">{t("aiRecommendation")}</span>
            <AITag label="Decision Engine" />
          </div>
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 rounded-2xl bg-white/20 flex items-center justify-center">
              <Icon name="directions_bus" size={36} fill={1} className="text-white" />
            </div>
            <div>
              <p className="text-white text-xl font-black">{t("takePublicTransport")}</p>
              <p className="text-green-200 text-sm font-medium">{t("tooHotForWalking")}</p>
            </div>
          </div>
          <div className="bg-white/15 rounded-2xl p-3 text-sm text-green-100">
            Distance {currentSuggestion.dist} · Temp 33°C · UV High · 78% humidity — <strong className="text-white">{t("aiRecommendsBus")}</strong>
          </div>
        </div>

        {/* Walking Comfort Score */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-4">
          <p className="font-bold text-slate-800 mb-3">{t("walkingComfortScore")}</p>
          <div className="flex items-center gap-4">
            <div className="relative w-20 h-20 shrink-0">
              <svg viewBox="0 0 80 80" className="w-full h-full -rotate-90">
                <circle cx="40" cy="40" r="32" fill="none" stroke="#E2E8F0" strokeWidth="8" />
                <circle cx="40" cy="40" r="32" fill="none" stroke="#F59E0B" strokeWidth="8"
                  strokeDasharray={`${32 * 2 * Math.PI * 0.38} ${32 * 2 * Math.PI}`} strokeLinecap="round" />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <p className="text-xl font-black text-amber-600">38</p>
                <p className="text-xs text-slate-400">/100</p>
              </div>
            </div>
            <div className="flex-1">
              <p className="text-amber-600 font-bold text-base">{t("lowComfort")}</p>
              <p className="text-slate-500 text-sm mt-1">Based on temperature, humidity, UV, shade coverage, and your walking profile</p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => onScreen("tropicalRoute")}
            className="py-4 rounded-2xl bg-green-600 text-white font-bold text-base flex flex-col items-center gap-1 shadow-md shadow-green-200"
          >
            <Icon name="alt_route" size={24} fill={1} />
            {t("aiRouteBtn")}
          </button>
          <button
            onClick={() => onScreen("transitGuide")}
            className="py-4 rounded-2xl bg-blue-600 text-white font-bold text-base flex flex-col items-center gap-1 shadow-md shadow-blue-200"
          >
            <Icon name="directions_bus" size={24} fill={1} />
            {t("busGuideBtn")}
          </button>
        </div>
        </>)}
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 10 — TropicalRoute AI
// ══════════════════════════════════════════════════════════════════════════
function TropicalRouteScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const [selected, setSelected] = useState(2);

  const routes = [
    { labelKey: "routeFastest" as TKey, descKey: "routeFastestDesc" as TKey, icon: "bolt", time: "28 min", shade: "18%", temp: "34°C", comfort: 42, color: "bg-blue-600", comfortColor: "text-red-500" },
    { labelKey: "routeCoolest" as TKey, descKey: "routeCoolestDesc" as TKey, icon: "ac_unit", time: "38 min", shade: "72%", temp: "29°C", comfort: 81, color: "bg-purple-600", comfortColor: "text-green-600" },
    { labelKey: "routeCovered" as TKey, descKey: "routeCoveredDesc" as TKey, icon: "umbrella", time: "34 min", shade: "85%", temp: "30°C", comfort: 78, color: "bg-amber-500", comfortColor: "text-green-600" },
    { labelKey: "routeBalanced" as TKey, descKey: "routeBalancedDesc" as TKey, icon: "balance", time: "31 min", shade: "55%", temp: "31°C", comfort: 68, color: "bg-green-600", comfortColor: "text-amber-600" },
  ];

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("tropicalRouteTitle")} subtitle={t("aiMobilityEngine")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        <div className="flex items-center gap-2 flex-wrap">
          <AITag label="Weather API" />
          <AITag label="Computer Vision" />
          <AITag label="Decision Engine" />
          <AITag label="LLM" />
        </div>

        {/* Map placeholder */}
        <div className="relative w-full h-48 rounded-3xl overflow-hidden bg-slate-200">
          <img
            src="https://images.unsplash.com/photo-1508791290064-c27cc1ef7a9a?w=600&h=300&fit=crop&auto=format"
            alt="Johor Bahru map aerial"
            className="w-full h-full object-cover opacity-70"
          />
          {/* Route overlay */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="bg-white/90 backdrop-blur-sm rounded-2xl px-4 py-2 flex items-center gap-2 shadow-lg">
              <Icon name="route" size={20} fill={1} className="text-green-600" />
              <span className="font-bold text-slate-800 text-sm">{t("routesCalculated")}</span>
            </div>
          </div>
          {/* Markers */}
          <div className="absolute top-4 left-4 w-8 h-8 rounded-full bg-green-500 border-2 border-white flex items-center justify-center shadow-md">
            <Icon name="my_location" size={16} fill={1} className="text-white" />
          </div>
          <div className="absolute bottom-4 right-4 w-8 h-8 rounded-full bg-red-500 border-2 border-white flex items-center justify-center shadow-md">
            <Icon name="local_hospital" size={16} fill={1} className="text-white" />
          </div>
        </div>

        {/* Route cards */}
        <div className="space-y-3">
          {routes.map((route, i) => (
            <motion.button
              key={route.labelKey}
              onClick={() => setSelected(i)}
              whileTap={{ scale: 0.98 }}
              className={`w-full rounded-3xl p-4 border-2 transition-all text-left ${
                selected === i
                  ? "border-blue-500 bg-white shadow-lg shadow-blue-100"
                  : "border-transparent bg-white shadow-sm"
              }`}
            >
              <div className="flex items-center gap-3 mb-3">
                <div className={`w-11 h-11 rounded-2xl ${route.color} flex items-center justify-center shrink-0`}>
                  <Icon name={route.icon} size={22} fill={1} className="text-white" />
                </div>
                <div className="flex-1">
                  <p className="font-black text-slate-900 text-base">{t(route.labelKey)}</p>
                  <p className="text-slate-500 text-xs">{t(route.descKey)}</p>
                </div>
                {selected === i && <Icon name="radio_button_checked" size={22} fill={1} className="text-blue-600 shrink-0" />}
                {selected !== i && <Icon name="radio_button_unchecked" size={22} className="text-slate-300 shrink-0" />}
              </div>
              <div className="grid grid-cols-4 gap-2">
                {[
                  { icon: "schedule", labelKey: "routeTimeLabel" as TKey, value: route.time, isComfort: false },
                  { icon: "park", labelKey: "routeShadeLabel" as TKey, value: route.shade, isComfort: false },
                  { icon: "thermostat", labelKey: "routeTempLabel" as TKey, value: route.temp, isComfort: false },
                  { icon: "sentiment_satisfied", labelKey: "routeComfortLabel" as TKey, value: `${route.comfort}`, isComfort: true },
                ].map((stat) => (
                  <div key={stat.labelKey} className="bg-slate-50 rounded-xl p-2 text-center">
                    <Icon name={stat.icon} size={16} fill={1} className="text-slate-500 mx-auto" />
                    <p className="text-[10px] text-slate-400 mt-0.5">{t(stat.labelKey)}</p>
                    <p className={`text-xs font-bold ${stat.isComfort ? route.comfortColor : "text-slate-700"}`}>
                      {stat.value}
                    </p>
                  </div>
                ))}
              </div>
            </motion.button>
          ))}
        </div>

        <button className="w-full py-4 rounded-3xl bg-green-600 text-white font-bold text-lg flex items-center justify-center gap-3 shadow-lg shadow-green-200">
          <Icon name="navigation" size={26} fill={1} />
          {t("startRouteBtn")} {t(routes[selected].labelKey)}
        </button>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 11 — Public Transport Guide
// ══════════════════════════════════════════════════════════════════════════
function TransitGuideScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const chat = useServiceChat([
    { role: "ai", text: t("transitChatInit") },
  ]);

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("publicTransportTitle")} subtitle={t("voiceGuidedNav")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        {/* Map */}
        <div className="relative w-full h-48 rounded-3xl overflow-hidden bg-blue-100">
          <img
            src="https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&h=300&fit=crop&auto=format"
            alt="Bus stop street view"
            className="w-full h-full object-cover opacity-60"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-blue-900/60 to-transparent" />
          <div className="absolute bottom-3 left-3 right-3 flex items-center gap-2">
            <div className="w-10 h-10 rounded-xl bg-amber-500 flex items-center justify-center">
              <Icon name="directions_bus" size={22} fill={1} className="text-white" />
            </div>
            <div>
              <p className="text-white font-bold">Bus Stop: Jalan Wong Ah Fook</p>
              <p className="text-blue-200 text-sm">{t("walkFromLocation")}</p>
            </div>
          </div>
        </div>

        {/* Bus info */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-5">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-14 h-14 rounded-2xl bg-blue-600 flex items-center justify-center">
                <span className="text-white font-black text-xl">BJ2</span>
              </div>
              <div>
                <p className="font-black text-slate-900 text-lg">Bus BJ2</p>
                <p className="text-slate-500 text-sm">Jalan Skudai → Hospital Sultanah</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-green-600 font-black text-2xl">4 min</p>
              <p className="text-slate-400 text-xs">{t("arrivingLabel")}</p>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            {[
              { labelKey: "busStopInfo" as TKey, value: "BJ2-045", icon: "location_on" },
              { labelKey: "stopsLeftLabel" as TKey, value: "6 stops", icon: "timeline" },
              { labelKey: "fareLabel" as TKey, value: "RM 1.50", icon: "toll" },
            ].map((item) => (
              <div key={item.labelKey} className="bg-blue-50 rounded-2xl p-3 text-center">
                <Icon name={item.icon} size={20} fill={1} className="text-blue-600 mx-auto" />
                <p className="text-xs text-slate-500 mt-1">{t(item.labelKey)}</p>
                <p className="text-sm font-bold text-slate-800">{item.value}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Step-by-step */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-4">
          <p className="font-bold text-slate-800 mb-4">{t("voiceGuidedSteps")}</p>
          {[
            { icon: "directions_walk", stepKey: "transitStep1" as TKey, status: "current", color: "bg-blue-600" },
            { icon: "directions_bus", stepKey: "transitStep2" as TKey, status: "next", color: "bg-slate-300" },
            { icon: "transfer_within_a_station", stepKey: "transitStep3" as TKey, status: "upcoming", color: "bg-slate-200" },
          ].map((item, i) => (
            <div key={i} className={`flex items-start gap-4 mb-4 ${item.status === "current" ? "opacity-100" : "opacity-50"}`}>
              <div className={`w-10 h-10 rounded-2xl ${item.color} flex items-center justify-center shrink-0`}>
                <Icon name={item.icon} size={20} fill={1} className="text-white" />
              </div>
              <div className="flex-1">
                <p className={`font-semibold text-base ${item.status === "current" ? "text-slate-900" : "text-slate-500"}`}>{t(item.stepKey)}</p>
                {item.status === "current" && (
                  <p className="text-blue-600 text-xs font-bold mt-0.5">{t("inProgressRoute")}</p>
                )}
              </div>
            </div>
          ))}
        </div>

        <button className="w-full py-4 rounded-3xl bg-blue-600 text-white font-bold text-lg flex items-center justify-center gap-3 shadow-lg shadow-blue-200">
          <Icon name="volume_up" size={26} fill={1} />
          {t("voiceNavOn")}
        </button>

        {/* Divider */}
        <div className="flex items-center gap-3">
          <div className="flex-1 h-px bg-blue-100" />
          <span className="text-xs font-bold text-blue-400 uppercase tracking-widest">{t("askNavigator")}</span>
          <div className="flex-1 h-px bg-blue-100" />
        </div>

        <div className="space-y-3">
          {chat.messages.map((msg, i) => <ChatBubble key={i} msg={msg} />)}
          {chat.isThinking && <ThinkingBubble />}
          <div ref={chat.bottomRef} />
        </div>
      </div>

      <ServiceChatBar
        input={chat.input}
        setInput={chat.setInput}
        isListening={chat.isListening}
        isThinking={chat.isThinking}
        onSend={chat.sendMessage}
        onToggleMic={chat.toggleMic}
      />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 12 — Community Walkability
// ══════════════════════════════════════════════════════════════════════════
function WalkabilityScreen({ onBack }: { onBack: () => void }) {
  const { t } = useLang();
  const [uploaded, setUploaded] = useState(false);

  const detections = [
    { icon: "park", labelKey: "detTrees" as TKey, count: 8, color: "bg-green-500", percent: 72 },
    { icon: "umbrella", labelKey: "detCoveredWalkway" as TKey, count: 1, color: "bg-blue-500", percent: 45 },
    { icon: "directions_bus", labelKey: "detBusShelter" as TKey, count: 1, color: "bg-amber-500", percent: 100 },
    { icon: "directions_walk", labelKey: "detSidewalk" as TKey, count: 1, color: "bg-purple-500", percent: 88 },
  ];

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title="Community Walkability" subtitle={t("aiCvMapping")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        <div className="flex items-center gap-2 flex-wrap">
          <AITag label="Computer Vision" />
          <AITag label="AI Detection" />
          <AITag label="Community AI" />
        </div>

        {/* Upload area */}
        {!uploaded ? (
          <button
            onClick={() => setUploaded(true)}
            className="w-full h-44 rounded-3xl border-2 border-dashed border-green-300 bg-green-50 flex flex-col items-center justify-center gap-3 active:bg-green-100 transition-colors"
          >
            <div className="w-16 h-16 rounded-2xl bg-green-100 flex items-center justify-center">
              <Icon name="add_a_photo" size={34} fill={1} className="text-green-600" />
            </div>
            <p className="text-green-700 font-bold text-base">{t("uploadWalkwayPhoto")}</p>
            <p className="text-green-500 text-sm">{t("aiDetectFeatures")}</p>
          </button>
        ) : (
          <div className="relative w-full h-52 rounded-3xl overflow-hidden bg-green-100">
            <img
              src="https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=600&h=300&fit=crop&auto=format"
              alt="Malaysian street walkway with trees"
              className="w-full h-full object-cover"
            />
            {/* AI Detection overlays */}
            <div className="absolute top-3 left-3 bg-green-500/90 backdrop-blur-sm rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <Icon name="park" size={16} fill={1} className="text-white" />
              <span className="text-white text-xs font-bold">{t("det8Trees")}</span>
            </div>
            <div className="absolute top-3 right-3 bg-blue-500/90 backdrop-blur-sm rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <Icon name="umbrella" size={16} fill={1} className="text-white" />
              <span className="text-white text-xs font-bold">{t("detCoveredOverlay")}</span>
            </div>
            <div className="absolute bottom-3 left-3 bg-amber-500/90 backdrop-blur-sm rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <Icon name="directions_bus" size={16} fill={1} className="text-white" />
              <span className="text-white text-xs font-bold">{t("detBusShelterOverlay")}</span>
            </div>
            <div className="absolute inset-0 border-2 border-green-400/30 rounded-3xl pointer-events-none" />
            {/* Scan line */}
            <motion.div
              className="absolute left-0 right-0 h-0.5 bg-green-400/60"
              animate={{ top: ["0%", "100%"] }}
              transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
            />
          </div>
        )}

        {/* AI Detection results */}
        {uploaded && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-3xl shadow-sm border border-blue-50 p-4 space-y-3"
          >
            <p className="font-bold text-slate-800">{t("aiDetections")}</p>
            {detections.map((det) => (
              <div key={det.labelKey} className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl ${det.color} flex items-center justify-center shrink-0`}>
                  <Icon name={det.icon} size={20} fill={1} className="text-white" />
                </div>
                <div className="flex-1">
                  <div className="flex justify-between items-center mb-1">
                    <p className="text-sm font-semibold text-slate-700">{t(det.labelKey)}</p>
                    <span className="text-xs font-bold text-slate-500">{det.count} found · {det.percent}%</span>
                  </div>
                  <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                    <motion.div
                      className={`h-full rounded-full ${det.color}`}
                      initial={{ width: 0 }}
                      animate={{ width: `${det.percent}%` }}
                      transition={{ duration: 0.8, ease: "easeOut" }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </motion.div>
        )}

        {/* Community stats */}
        <div className="bg-gradient-to-r from-green-600 to-green-700 rounded-3xl p-4">
          <p className="text-white font-bold mb-3">{t("communityContributions")}</p>
          <div className="grid grid-cols-3 gap-3">
            {[
              { labelKey: "photosLabel" as TKey, value: "1,247" },
              { labelKey: "routesMappedLabel" as TKey, value: "89" },
              { labelKey: "contributorsLabel" as TKey, value: "342" },
            ].map((stat) => (
              <div key={stat.labelKey} className="bg-white/20 rounded-2xl p-3 text-center">
                <p className="text-white font-black text-xl">{stat.value}</p>
                <p className="text-green-200 text-xs mt-0.5">{t(stat.labelKey)}</p>
              </div>
            ))}
          </div>
        </div>

        <button className="w-full py-4 rounded-3xl bg-green-600 text-white font-bold text-lg flex items-center justify-center gap-3 shadow-lg shadow-green-200">
          <Icon name="cloud_upload" size={26} fill={1} />
          {uploaded ? t("submitToCommunity") : t("takeWalkwayPhoto")}
        </button>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN 13 — Profile
// ══════════════════════════════════════════════════════════════════════════
function ProfileScreen({ onBack, user, onLogout, largeText, setLargeText, highContrast, setHighContrast, voiceSpeed, setVoiceSpeed }: {
  onBack: () => void;
  user: User;
  onLogout: () => void;
  largeText: boolean;
  setLargeText: (v: boolean) => void;
  highContrast: boolean;
  setHighContrast: (v: boolean) => void;
  voiceSpeed: 0.75 | 1 | 1.25;
  setVoiceSpeed: (v: 0.75 | 1 | 1.25) => void;
}) {
  const { lang, setLang, t, voiceLang, setVoiceLang } = useLang();
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  return (
    <div className="flex flex-col h-full bg-background">
      <Header title={t("profileTitle")} onBack={onBack} />

      <div className="flex-1 overflow-y-auto px-5 pb-8 pt-2 space-y-4">
        {/* Profile card */}
        <div className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-3xl p-5 flex items-center gap-4">
          <div className="w-20 h-20 rounded-2xl bg-white/20 flex items-center justify-center border-2 border-white/30 shrink-0">
            <Icon name="person" size={44} fill={1} className="text-white" />
          </div>
          <div>
            <p className="text-white font-black text-xl">{user.name}</p>
            <p className="text-blue-200 text-sm">IC: {user.ic}</p>
            <div className="flex gap-1.5 mt-2">
              <AITag label="AI Profile" />
              <Badge label="Senior" color="orange" />
            </div>
          </div>
        </div>

        {/* Language & Dialect */}
        <div className="bg-white rounded-3xl shadow-sm border border-blue-50 p-5 space-y-5">
          <p className="font-bold text-slate-800 flex items-center gap-2">
            <Icon name="language" size={20} fill={1} className="text-blue-600" />
            {t("langSection")}
          </p>

          {/* App UI Language */}
          <div>
            <p className="text-sm font-bold text-slate-600 mb-2 flex items-center gap-1.5">
              <Icon name="phone_android" size={15} fill={1} className="text-blue-500" />
              {t("appLangLabel")}
            </p>
            <div className="grid grid-cols-2 gap-2">
              {APP_LANGS.map((l) => (
                <button
                  key={l.id}
                  onClick={() => setLang(l.id)}
                  className={`flex items-center gap-2.5 px-3 py-3 rounded-2xl border-2 font-bold transition-all ${
                    lang === l.id
                      ? "bg-blue-600 text-white border-blue-600 shadow-sm"
                      : "bg-white text-slate-700 border-slate-200"
                  }`}
                >
                  <span className="text-lg">{l.flag}</span>
                  <div className="text-left">
                    <p className={`text-xs font-black leading-tight ${lang === l.id ? "text-white" : "text-slate-800"}`}>{l.native}</p>
                    <p className={`text-[11px] ${lang === l.id ? "text-blue-200" : "text-slate-400"}`}>{l.label}</p>
                  </div>
                  {lang === l.id && <Icon name="check_circle" size={16} fill={1} className="text-white ml-auto" />}
                </button>
              ))}
            </div>
          </div>

          {/* Voice Listening Language */}
          <div>
            <p className="text-sm font-bold text-slate-600 mb-1 flex items-center gap-1.5">
              <Icon name="mic" size={15} fill={1} className="text-green-600" />
              {t("voiceLangLabel")}
            </p>
            <p className="text-xs text-slate-400 mb-2">{t("voiceLangHint")}</p>
            <div className="grid grid-cols-2 gap-2">
              {VOICE_LANGS.map((vl) => (
                <button
                  key={vl.id}
                  onClick={() => setVoiceLang(vl.id)}
                  className={`flex items-center gap-2.5 px-3 py-3 rounded-2xl border-2 font-bold transition-all ${
                    voiceLang === vl.id
                      ? "bg-green-500 text-white border-green-500 shadow-sm"
                      : "bg-white text-slate-700 border-slate-200"
                  }`}
                >
                  <Icon name={vl.icon} size={18} fill={1} className={voiceLang === vl.id ? "text-white" : "text-slate-400"} />
                  <div className="text-left">
                    <p className={`text-xs font-black leading-tight ${voiceLang === vl.id ? "text-white" : "text-slate-800"}`}>{vl.label}</p>
                    <p className={`text-[11px] ${voiceLang === vl.id ? "text-green-100" : "text-slate-400"}`}>{vl.sub}</p>
                  </div>
                  {voiceLang === vl.id && <Icon name="check_circle" size={16} fill={1} className="text-white ml-auto" />}
                </button>
              ))}
            </div>
          </div>

          <div className="bg-blue-50 rounded-2xl p-3 flex items-center gap-2 border border-blue-100">
            <AITag label="Dialect AI" />
            <p className="text-blue-700 text-sm font-medium">{t("dialectAiHint")}</p>
          </div>
        </div>

        {/* Accessibility */}
        <div className={`rounded-3xl shadow-sm border p-5 ${highContrast ? "bg-white border-black" : "bg-white border-blue-50"}`}>
          <p className={`font-bold mb-5 flex items-center gap-2 ${highContrast ? "text-black" : "text-slate-800"}`}>
            <Icon name="accessibility_new" size={20} fill={1} className="text-purple-600" />
            {t("accessibility")}
          </p>

          {/* Large Text toggle */}
          <div className="flex items-center justify-between mb-5">
            <div>
              <p className={`font-semibold text-base ${highContrast ? "text-black" : "text-slate-800"}`}>{t("largeText")}</p>
              <p className={`text-sm mt-0.5 ${highContrast ? "text-black/70" : "text-slate-400"}`}>
                {largeText ? t("largeTextActive") : t("largeTextDesc")}
              </p>
            </div>
            <button
              onClick={() => setLargeText(!largeText)}
              className={`w-16 h-9 rounded-full transition-colors duration-200 relative shrink-0 ${largeText ? "bg-blue-600" : "bg-slate-300"}`}
              aria-label="Toggle large text"
            >
              <motion.div
                className={`w-7 h-7 rounded-full shadow-md absolute top-1 ${largeText ? "bg-white" : "bg-white"}`}
                animate={{ left: largeText ? "calc(100% - 32px)" : "4px" }}
                transition={{ type: "spring", stiffness: 400, damping: 30 }}
              />
            </button>
          </div>

          {/* Large text live preview */}
          <AnimatePresence>
            {largeText && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden mb-5"
              >
                <div className="bg-blue-50 border border-blue-200 rounded-2xl px-4 py-3">
                  <p className="text-blue-700 font-semibold" style={{ fontSize: "19px" }}>
                    {t("largeTextPreview")}
                  </p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* High Contrast toggle */}
          <div className="flex items-center justify-between mb-5">
            <div>
              <p className={`font-semibold text-base ${highContrast ? "text-black" : "text-slate-800"}`}>{t("highContrast")}</p>
              <p className={`text-sm mt-0.5 ${highContrast ? "text-black/70" : "text-slate-400"}`}>
                {highContrast ? t("highContrastActive") : t("highContrastDesc")}
              </p>
            </div>
            <button
              onClick={() => setHighContrast(!highContrast)}
              className={`w-16 h-9 rounded-full transition-colors duration-200 relative shrink-0 ${highContrast ? "bg-blue-600" : "bg-slate-300"}`}
              aria-label="Toggle high contrast"
            >
              <motion.div
                className="w-7 h-7 rounded-full bg-white shadow-md absolute top-1"
                animate={{ left: highContrast ? "calc(100% - 32px)" : "4px" }}
                transition={{ type: "spring", stiffness: 400, damping: 30 }}
              />
            </button>
          </div>

          {/* High contrast preview */}
          <AnimatePresence>
            {highContrast && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden mb-5"
              >
                <div className="bg-black rounded-2xl px-4 py-3">
                  <p className="text-white font-semibold text-base">{t("highContrastPreview")}</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Voice Speed */}
          <div>
            <p className={`font-semibold text-base mb-1 ${highContrast ? "text-black" : "text-slate-800"}`}>{t("voiceSpeed")}</p>
            <p className={`text-sm mb-3 ${highContrast ? "text-black/70" : "text-slate-400"}`}>
              {t("voiceSpeedHint")}
            </p>
            <div className="grid grid-cols-3 gap-2">
              {([0.75, 1, 1.25] as const).map((rate) => (
                <button
                  key={rate}
                  onClick={() => setVoiceSpeed(rate)}
                  className={`py-4 rounded-2xl font-bold text-base border-2 transition-all flex flex-col items-center gap-1 ${
                    voiceSpeed === rate
                      ? "bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-200"
                      : highContrast
                      ? "bg-white text-black border-black"
                      : "bg-slate-50 text-slate-600 border-slate-200"
                  }`}
                >
                  <Icon
                    name={rate < 1 ? "slow_motion_video" : rate === 1 ? "play_circle" : "fast_forward"}
                    size={22} fill={1}
                    className={voiceSpeed === rate ? "text-white" : highContrast ? "text-black" : "text-slate-500"}
                  />
                  <span>{rate}x</span>
                  <span className={`text-xs font-medium ${voiceSpeed === rate ? "text-blue-200" : highContrast ? "text-black/60" : "text-slate-400"}`}>
                    {rate < 1 ? t("speedSlow") : rate === 1 ? t("speedNormal") : t("speedFast")}
                  </span>
                </button>
              ))}
            </div>
            <div className={`mt-3 rounded-2xl px-4 py-3 flex items-center gap-2 ${highContrast ? "bg-black/10 border border-black/20" : "bg-blue-50 border border-blue-100"}`}>
              <Icon name="volume_up" size={18} fill={1} className={highContrast ? "text-black" : "text-blue-600"} />
              <p className={`text-sm font-medium ${highContrast ? "text-black" : "text-blue-700"}`}>
                {t("currentSpeed")}: <strong>{voiceSpeed}x — {voiceSpeed < 1 ? t("speedSlow") : voiceSpeed === 1 ? t("speedNormal") : t("speedFast")}</strong>
              </p>
            </div>
          </div>
        </div>

        {/* Emergency Contact */}
        <div className="bg-red-50 rounded-3xl border border-red-200 p-5">
          <p className="font-bold text-red-700 mb-3 flex items-center gap-2">
            <Icon name="emergency" size={20} fill={1} className="text-red-600" />
            {t("emergencyContact")}
          </p>
          {user.emergencyContact ? (
            <>
              <div className="flex items-center gap-4 mb-3">
                <div className="w-14 h-14 rounded-2xl bg-red-100 flex items-center justify-center shrink-0">
                  <Icon name="person" size={30} fill={1} className="text-red-600" />
                </div>
                <div className="flex-1">
                  <p className="font-black text-slate-900 text-lg">{user.emergencyContact.name}</p>
                  <p className="text-slate-500 text-sm mt-0.5">{user.emergencyContact.phone}</p>
                  <span className="inline-block mt-1 px-2.5 py-0.5 rounded-full bg-red-100 text-red-700 text-xs font-bold">
                    {user.emergencyContact.relationship}
                  </span>
                </div>
              </div>
              <button
                onClick={() => {
                  if (user.emergencyContact?.phone) window.open(`tel:${user.emergencyContact.phone}`);
                }}
                className="w-full py-4 rounded-2xl bg-red-600 text-white font-bold text-base flex items-center justify-center gap-2 shadow-md shadow-red-200"
              >
                <Icon name="phone" size={22} fill={1} />
                {t("callLabel")} {user.emergencyContact.name}
              </button>
            </>
          ) : (
            <div className="flex flex-col items-center py-4 gap-3 text-center">
              <div className="w-14 h-14 rounded-2xl bg-red-100 flex items-center justify-center">
                <Icon name="person_add" size={30} fill={1} className="text-red-400" />
              </div>
              <p className="text-slate-500 text-sm font-medium">{t("noEmergencyContact")}</p>
              <p className="text-slate-400 text-xs">{t("addEcHint")}</p>
            </div>
          )}
        </div>

        {/* App info */}
        <div className="text-center pb-2">
          <p className="text-slate-400 text-xs">SuaraWarga AI v1.0.0 · Track T5: AI for Public Services</p>
          <p className="text-slate-300 text-xs mt-1">Powered by ASR · Dialect AI · NLP · LLM · Computer Vision</p>
        </div>

        {/* Logout button */}
        <button
          onClick={() => setShowLogoutModal(true)}
          className="w-full py-4 rounded-3xl border-2 border-red-200 text-red-600 font-bold text-lg flex items-center justify-center gap-3 bg-red-50 active:bg-red-100 transition-colors"
        >
          <Icon name="logout" size={24} fill={1} className="text-red-500" />
          {t("signOutTitle")}
        </button>
      </div>

      {/* Logout confirmation modal */}
      <AnimatePresence>
        {showLogoutModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm flex items-end z-50"
            onClick={() => setShowLogoutModal(false)}
          >
            <motion.div
              initial={{ y: 80, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: 80, opacity: 0 }}
              transition={{ type: "spring", stiffness: 400, damping: 35 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full bg-white rounded-t-[2.5rem] px-6 pt-6 pb-10 space-y-5"
            >
              {/* Handle */}
              <div className="w-12 h-1.5 rounded-full bg-slate-200 mx-auto mb-2" />

              <div className="flex flex-col items-center text-center gap-3">
                <div className="w-20 h-20 rounded-3xl bg-red-100 flex items-center justify-center">
                  <Icon name="logout" size={42} fill={1} className="text-red-500" />
                </div>
                <h2 className="text-2xl font-black text-slate-900">{t("signOutTitle")}</h2>
                <p className="text-slate-500 text-base leading-relaxed">
                  {t("signOutDesc")}
                </p>
              </div>

              <div className="bg-amber-50 border border-amber-200 rounded-2xl px-4 py-3 flex items-center gap-3">
                <Icon name="info" size={20} fill={1} className="text-amber-600 shrink-0" />
                <p className="text-amber-800 text-sm font-medium">
                  {t("signedInAs")} <strong>{user.name}</strong> · IC {user.ic}
                </p>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setShowLogoutModal(false)}
                  className="flex-1 py-4 rounded-3xl border-2 border-slate-200 text-slate-700 font-bold text-lg bg-slate-50"
                >
                  {t("cancel")}
                </button>
                <button
                  onClick={() => { setShowLogoutModal(false); onLogout(); }}
                  className="flex-1 py-4 rounded-3xl bg-red-600 text-white font-bold text-lg shadow-lg shadow-red-200 flex items-center justify-center gap-2"
                >
                  <Icon name="logout" size={22} fill={1} />
                  {t("signOutTitle")}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN — History
// ══════════════════════════════════════════════════════════════════════════
function HistoryScreen({ onScreen, nav, setNav }: {
  onScreen: (s: Screen) => void;
  nav: NavTab;
  setNav: (t: NavTab) => void;
}) {
  const { t } = useLang();

  const items: { icon: string; titleKey: TKey; subtitleKey: TKey; time: string; dialect: string; status: "done" | "incomplete"; screen: Screen }[] = [
    { icon: "badge", titleKey: "hist1Title", subtitleKey: "hist1Sub", time: "Today, 9:14 AM", dialect: "Hokkien", status: "done", screen: "govServices" },
    { icon: "directions_bus", titleKey: "hist2Title", subtitleKey: "hist2Sub", time: "Yesterday, 2:30 PM", dialect: "Hokkien", status: "done", screen: "tropicalRoute" },
    { icon: "description", titleKey: "hist3Title", subtitleKey: "hist3Sub", time: "Mon, 10:05 AM", dialect: "Malay", status: "done", screen: "letterInterpreter" },
    { icon: "edit_document", titleKey: "hist4Title", subtitleKey: "hist4Sub", time: "Mon, 9:45 AM", dialect: "Hokkien", status: "incomplete", screen: "formAssistant" },
    { icon: "map", titleKey: "hist5Title", subtitleKey: "hist5Sub", time: "Sun, 4:18 PM", dialect: "English", status: "done", screen: "walkability" },
    { icon: "directions_walk", titleKey: "hist6Title", subtitleKey: "hist6Sub", time: "Sat, 8:02 AM", dialect: "Cantonese", status: "done", screen: "tropicalRoute" },
  ];

  return (
    <div className="flex flex-col h-full bg-background">
      <div className="bg-gradient-to-b from-blue-600 to-blue-500 px-5 pt-12 pb-5 rounded-b-[2rem]">
        <h1 className="text-2xl font-black text-white">{t("activityHistory")}</h1>
        <p className="text-blue-200 text-sm mt-1">{t("recentAiInteractions")}</p>
        <div className="mt-3 flex gap-2">
          <AITag label={t("historyInteractions")} />
          <AITag label={t("historyLanguages")} />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-28 pt-4 space-y-3">
        {items.map((item, i) => (
          <motion.button
            key={i}
            onClick={() => onScreen(item.screen)}
            whileTap={{ scale: 0.97 }}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.06 }}
            className="w-full bg-white rounded-3xl shadow-sm border border-blue-50 p-4 flex items-center gap-4 text-left"
          >
            <div className="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center shrink-0">
              <Icon name={item.icon} size={26} fill={1} className="text-blue-600" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-0.5">
                <p className="font-bold text-slate-900 text-base truncate">{t(item.titleKey)}</p>
              </div>
              <p className="text-slate-500 text-sm truncate">{t(item.subtitleKey)}</p>
              <div className="flex items-center gap-2 mt-1.5">
                <span className="text-xs text-slate-400">{item.time}</span>
                <span className="w-1 h-1 rounded-full bg-slate-300" />
                <span className="text-xs text-blue-500 font-medium">{item.dialect}</span>
              </div>
            </div>
            <div className="flex flex-col items-end gap-2 shrink-0">
              <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${item.status === "done" ? "bg-green-100 text-green-700" : "bg-amber-100 text-amber-700"}`}>
                {item.status === "done" ? t("statusDone") : t("statusIncomplete")}
              </span>
              <Icon name="chevron_right" size={18} className="text-slate-300" />
            </div>
          </motion.button>
        ))}
      </div>

      <BottomNav active={nav} onChange={(t) => {
        setNav(t);
        if (t === "home") onScreen("home");
        if (t === "profile") onScreen("profile");
        if (t === "notifications") onScreen("notifications");
      }} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// SCREEN — Notifications
// ══════════════════════════════════════════════════════════════════════════
function NotificationsScreen({ onScreen, nav, setNav }: {
  onScreen: (s: Screen) => void;
  nav: NavTab;
  setNav: (t: NavTab) => void;
}) {
  const { t } = useLang();
  const [read, setRead] = useState<number[]>([]);

  const alerts: { icon: string; titleKey: TKey; bodyKey: TKey; time: string; type: string; typeKey: TKey; screen: Screen }[] = [
    { icon: "event_busy", titleKey: "notif1Title", bodyKey: "notif1Body", time: "Just now", type: "urgent", typeKey: "typeUrgent", screen: "docChecker" },
    { icon: "wb_sunny", titleKey: "notif2Title", bodyKey: "notif2Body", time: "8:30 AM", type: "weather", typeKey: "typeWeather", screen: "smartMobility" },
    { icon: "directions_bus", titleKey: "notif3Title", bodyKey: "notif3Body", time: "9:00 AM", type: "transit", typeKey: "typeTransit", screen: "transitGuide" },
    { icon: "edit_document", titleKey: "notif4Title", bodyKey: "notif4Body", time: "Yesterday", type: "reminder", typeKey: "typeReminder", screen: "formAssistant" },
    { icon: "campaign", titleKey: "notif5Title", bodyKey: "notif5Body", time: "Mon", type: "info", typeKey: "typeInfo", screen: "govServices" },
    { icon: "map", titleKey: "notif6Title", bodyKey: "notif6Body", time: "Sun", type: "community", typeKey: "typeCommunity", screen: "walkability" },
  ];

  const typeStyle: Record<string, { icon: string; bg: string; iconColor: string; badge: string; badgeText: string }> = {
    urgent:    { icon: "warning",       bg: "bg-red-50 border-red-200",    iconColor: "text-red-600",    badge: "bg-red-100",    badgeText: "text-red-700" },
    weather:   { icon: "wb_sunny",      bg: "bg-amber-50 border-amber-200", iconColor: "text-amber-600",  badge: "bg-amber-100",  badgeText: "text-amber-700" },
    transit:   { icon: "directions_bus",bg: "bg-blue-50 border-blue-200",  iconColor: "text-blue-600",   badge: "bg-blue-100",   badgeText: "text-blue-700" },
    reminder:  { icon: "notifications", bg: "bg-purple-50 border-purple-200", iconColor: "text-purple-600", badge: "bg-purple-100", badgeText: "text-purple-700" },
    info:      { icon: "info",          bg: "bg-green-50 border-green-200", iconColor: "text-green-600",  badge: "bg-green-100",  badgeText: "text-green-700" },
    community: { icon: "groups",        bg: "bg-teal-50 border-teal-200",   iconColor: "text-teal-600",   badge: "bg-teal-100",   badgeText: "text-teal-700" },
  };

  const unread = alerts.length - read.length;

  return (
    <div className="flex flex-col h-full bg-background">
      <div className="bg-gradient-to-b from-blue-600 to-blue-500 px-5 pt-12 pb-5 rounded-b-[2rem]">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-black text-white">{t("notifications")}</h1>
            <p className="text-blue-200 text-sm mt-1">{t("alertsReminders")}</p>
          </div>
          {unread > 0 && (
            <div className="w-10 h-10 rounded-2xl bg-white/20 flex items-center justify-center">
              <span className="text-white font-black text-lg">{unread}</span>
            </div>
          )}
        </div>
        {unread > 0 && (
          <button
            onClick={() => setRead(alerts.map((_, i) => i))}
            className="mt-3 px-4 py-1.5 rounded-full bg-white/20 border border-white/30 text-white text-sm font-semibold"
          >
            {t("markAllRead")}
          </button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-28 pt-4 space-y-3">
        {alerts.map((alert, i) => {
          const style = typeStyle[alert.type];
          const isRead = read.includes(i);
          return (
            <motion.button
              key={i}
              onClick={() => { setRead((r) => [...new Set([...r, i])]); onScreen(alert.screen); }}
              whileTap={{ scale: 0.97 }}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.06 }}
              className={`w-full rounded-3xl border p-4 flex items-start gap-4 text-left transition-opacity ${style.bg} ${isRead ? "opacity-60" : "opacity-100"}`}
            >
              <div className={`w-12 h-12 rounded-2xl bg-white flex items-center justify-center shrink-0 shadow-sm`}>
                <Icon name={alert.icon} size={26} fill={1} className={style.iconColor} />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <p className="font-bold text-slate-900 text-base leading-tight">{t(alert.titleKey)}</p>
                  {!isRead && <span className="w-2.5 h-2.5 rounded-full bg-blue-500 shrink-0 mt-1" />}
                </div>
                <p className="text-slate-600 text-sm leading-relaxed">{t(alert.bodyKey)}</p>
                <div className="flex items-center gap-2 mt-2">
                  <span className="text-xs text-slate-400">{alert.time}</span>
                  <span className="w-1 h-1 rounded-full bg-slate-300" />
                  <span className={`px-2 py-0.5 rounded-full text-[11px] font-bold ${style.badge} ${style.badgeText}`}>
                    {t(alert.typeKey)}
                  </span>
                </div>
              </div>
            </motion.button>
          );
        })}
      </div>

      <BottomNav active={nav} onChange={(t) => {
        setNav(t);
        if (t === "home") onScreen("home");
        if (t === "profile") onScreen("profile");
        if (t === "history") onScreen("history");
      }} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════
// ROOT APP
// ══════════════════════════════════════════════════════════════════════════
export default function App() {
  const [screen, setScreen] = useState<Screen>("login");
  const [nav, setNav] = useState<NavTab>("home");
  const [user, setUser] = useState<User | null>(null);
  const [appLang, setAppLang] = useState<AppLang>("en");
  const [voiceLang, setVoiceLang] = useState("English");
  const [largeText, setLargeText] = useState(false);
  const [highContrast, setHighContrast] = useState(false);
  const [voiceSpeed, setVoiceSpeed] = useState<0.75 | 1 | 1.25>(1);
  const [pendingIntent, setPendingIntent] = useState<VoiceIntent>(DEFAULT_INTENT);
  const prevScreen = useRef<Screen>("login");

  const t = (k: TKey): string => T[appLang][k] ?? T.en[k];

  const speakPreview = (rate: number) => {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance("Hello, this is your voice speed preview.");
    u.rate = rate;
    u.lang = appLang === "zh" ? "zh-CN" : appLang === "ta" ? "ta-IN" : appLang === "bm" ? "ms-MY" : "en-US";
    window.speechSynthesis.speak(u);
  };

  useEffect(() => {
    const root = document.documentElement;
    if (highContrast) {
      root.style.setProperty("--foreground", "#000000");
      root.style.setProperty("--card-foreground", "#000000");
      root.style.setProperty("--muted-foreground", "#1a1a1a");
      root.style.setProperty("--border", "rgba(0,0,0,0.35)");
    } else {
      root.style.removeProperty("--foreground");
      root.style.removeProperty("--card-foreground");
      root.style.removeProperty("--muted-foreground");
      root.style.removeProperty("--border");
    }
  }, [highContrast]);

  useEffect(() => {
    document.documentElement.style.setProperty("--font-size", largeText ? "19px" : "16px");
  }, [largeText]);

  const goTo = (s: Screen) => {
    prevScreen.current = screen;
    setScreen(s);
    if (s === "home") setNav("home");
    if (s === "history") setNav("history");
    if (s === "notifications") setNav("notifications");
    if (s === "profile") setNav("profile");
  };

  const handleLogin = (u: User) => {
    setUser(u);
    setAppLang(u.uiLang);
    setVoiceLang(u.voiceLang);
    goTo("home");
  };

  const handleLogout = () => {
    setUser(null);
    setAppLang("en");
    setVoiceLang("English");
    setNav("home");
    goTo("login");
  };

  const defaultUser: User = {
    name: "Ahmad bin Abdullah", ic: "570814-01-5432", phone: "+60 12-345 6789",
    uiLang: "en", voiceLang: "Hokkien",
    emergencyContact: { name: "Siti Aminah", phone: "+60 12-345 6789", relationship: "Daughter" },
  };

  const langCtxValue = { lang: appLang, setLang: setAppLang, t, voiceLang, setVoiceLang };

  return (
    <LangContext.Provider value={langCtxValue}>
      <div
        className={`w-full min-h-screen bg-[#F0F4FF] relative overflow-hidden ${highContrast ? "hc" : ""}`}
        style={{ fontFamily: "'Inter', system-ui, -apple-system, sans-serif", fontSize: largeText ? "19px" : "16px" } as React.CSSProperties}
      >
        <AnimatePresence mode="wait">
          <motion.div
            key={screen}
            className="absolute inset-0"
            initial={{ opacity: 0, x: 24 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -24 }}
            transition={{ duration: 0.22, ease: "easeInOut" }}
          >
            {screen === "login" && <LoginScreen onLogin={handleLogin} onRegister={() => goTo("register")} />}
            {screen === "register" && <RegisterScreen onDone={handleLogin} onLogin={() => goTo("login")} />}
            {screen === "home" && <HomeScreen onScreen={goTo} nav={nav} setNav={setNav} userName={user?.name ?? defaultUser.name} onIntent={setPendingIntent} />}
            {screen === "listening" && <ListeningScreen onNext={() => goTo("processing")} onBack={() => goTo("home")} intent={pendingIntent} />}
            {screen === "processing" && <ProcessingScreen intent={pendingIntent} onNext={() => goTo(pendingIntent.targetScreen)} />}
            {screen === "govServices" && <GovServicesScreen onScreen={goTo} onBack={() => goTo("home")} />}
            {screen === "letterInterpreter" && <LetterInterpreterScreen onBack={() => goTo("govServices")} />}
            {screen === "formAssistant" && <FormAssistantScreen onBack={() => goTo("govServices")} />}
            {screen === "docChecker" && <DocCheckerScreen onBack={() => goTo("govServices")} />}
            {screen === "smartMobility" && <SmartMobilityScreen onScreen={goTo} onBack={() => goTo("home")} />}
            {screen === "tropicalRoute" && <TropicalRouteScreen onBack={() => goTo("smartMobility")} />}
            {screen === "transitGuide" && <TransitGuideScreen onBack={() => goTo("smartMobility")} />}
            {screen === "walkability" && <WalkabilityScreen onBack={() => goTo("home")} />}
            {screen === "profile" && (
              <ProfileScreen
                onBack={() => goTo("home")}
                user={user ?? defaultUser}
                onLogout={handleLogout}
                largeText={largeText}
                setLargeText={setLargeText}
                highContrast={highContrast}
                setHighContrast={setHighContrast}
                voiceSpeed={voiceSpeed}
                setVoiceSpeed={(v) => { setVoiceSpeed(v); speakPreview(v); }}
              />
            )}
            {screen === "history" && <HistoryScreen onScreen={goTo} nav={nav} setNav={setNav} />}
            {screen === "notifications" && <NotificationsScreen onScreen={goTo} nav={nav} setNav={setNav} />}
          </motion.div>
        </AnimatePresence>
      </div>
    </LangContext.Provider>
  );
}
