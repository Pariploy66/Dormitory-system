class AppStrings {
  final String loginTitle;
  final String loginButton;
  final String registerTitle;
  final String registerButton;
  final String email;
  final String password;
  final String passwordHint;
  final String name;
  final String phone;
  final String dashboard;
  final String history;
  final String setting;
  final String noStudentLinked;
  final String noStudentLinkedSub;
  final String logout;
  final String logoutTitle;
  final String logoutConfirm;
  final String cancel;
  final String entry;
  final String exit;
  final String allStatus;
  final String today;
  final String yesterday;
  final String searchHint;
  final String noData;
  final String retry;
  final String failedToLoad;
  final String recentActivity;
  final String currentStatus;
  final String changePassword;
  final String language;
  final String alreadyRegistered;
  final String loginLink;
  final String registerLink;
  final String wrongCredentials;
  final String last3Days;
  final String last7Days;
  final String noActivityToday;
  final String account;
  final String accountInfo;
  // Dashboard status card
  final String statusLabel;
  final String lateStatus;
  final String onTime;
  final String updateLabel;
  // Recent Activity header
  final String updatedAt;
  final String noRecentActivity;
  // Today count button
  final String entryLabel;
  // Error messages
  final String networkError;
  final String serverError;
  final String validationError;

  const AppStrings({
    required this.loginTitle,
    required this.loginButton,
    required this.registerTitle,
    required this.registerButton,
    required this.email,
    required this.password,
    required this.passwordHint,
    required this.name,
    required this.phone,
    required this.dashboard,
    required this.history,
    required this.setting,
    required this.noStudentLinked,
    required this.noStudentLinkedSub,
    required this.logout,
    required this.logoutTitle,
    required this.logoutConfirm,
    required this.cancel,
    required this.entry,
    required this.exit,
    required this.allStatus,
    required this.today,
    required this.yesterday,
    required this.searchHint,
    required this.noData,
    required this.retry,
    required this.failedToLoad,
    required this.recentActivity,
    required this.currentStatus,
    required this.changePassword,
    required this.language,
    required this.alreadyRegistered,
    required this.loginLink,
    required this.registerLink,
    required this.wrongCredentials,
    required this.last3Days,
    required this.last7Days,
    required this.noActivityToday,
    required this.account,
    required this.accountInfo,
    required this.statusLabel,
    required this.lateStatus,
    required this.onTime,
    required this.updateLabel,
    required this.updatedAt,
    required this.noRecentActivity,
    required this.entryLabel,
    required this.networkError,
    required this.serverError,
    required this.validationError,
  });

  static const en = AppStrings(
    loginTitle: 'MFU Dormitory',
    loginButton: 'Login with Thai ID',
    registerTitle: 'Register',
    registerButton: 'Register',
    email: 'Email',
    password: 'Password',
    passwordHint: 'Password (≥ 8 chars)',
    name: 'Full Name',
    phone: 'Phone',
    dashboard: 'Dashboard',
    history: 'History',
    setting: 'Setting',
    noStudentLinked: 'No Student Linked',
    noStudentLinkedSub: 'Please contact staff to link your student account',
    logout: 'Logout',
    logoutTitle: 'Logout',
    logoutConfirm: 'Are you sure you want to logout?',
    cancel: 'Cancel',
    entry: 'Entry',
    exit: 'Exit',
    allStatus: 'All Status',
    today: 'Today',
    yesterday: 'Yesterday',
    searchHint: 'Search by gate or date (e.g. 23 May)',
    noData: 'No data found',
    retry: 'Retry',
    failedToLoad: 'Failed to load data',
    recentActivity: 'Recent Activity',
    currentStatus: 'Current status',
    changePassword: 'Change Password',
    language: 'Language',
    alreadyRegistered: 'This email/phone is already registered',
    loginLink: 'Login',
    registerLink: 'Register',
    wrongCredentials: 'Email or password is incorrect',
    last3Days: 'Last 3 Days',
    last7Days: 'Last 7 Days',
    noActivityToday: 'No activity for today',
    account: 'Account',
    accountInfo: 'Account Info',
    statusLabel: 'Status :',
    lateStatus: 'late',
    onTime: 'on time',
    updateLabel: 'update :',
    updatedAt: 'Updated',
    noRecentActivity: 'No recent activity',
    entryLabel: 'entry',
    networkError: 'Cannot connect to server. Please check your connection.',
    serverError: 'Server error. Please try again.',
    validationError: 'Please check your information and try again.',
  );

  static const th = AppStrings(
    loginTitle: 'หอพัก มฟล.',
    loginButton: 'เข้าสู่ระบบด้วย Thai ID',
    registerTitle: 'สมัครสมาชิก',
    registerButton: 'สมัครสมาชิก',
    email: 'อีเมล',
    password: 'รหัสผ่าน',
    passwordHint: 'รหัสผ่าน (≥ 8 ตัว)',
    name: 'ชื่อ-นามสกุล',
    phone: 'เบอร์โทร',
    dashboard: 'หน้าหลัก',
    history: 'ประวัติ',
    setting: 'ตั้งค่า',
    noStudentLinked: 'ยังไม่ได้เชื่อมต่อนักศึกษา',
    noStudentLinkedSub: 'กรุณาติดต่อเจ้าหน้าที่เพื่อเชื่อมต่อข้อมูลนักศึกษา',
    logout: 'ออกจากระบบ',
    logoutTitle: 'ออกจากระบบ',
    logoutConfirm: 'คุณต้องการออกจากระบบใช่หรือไม่?',
    cancel: 'ยกเลิก',
    entry: 'เข้า',
    exit: 'ออก',
    allStatus: 'ทุกสถานะ',
    today: 'วันนี้',
    yesterday: 'เมื่อวาน',
    searchHint: 'ค้นหาชื่อประตู หรือวันที่ (เช่น 23 พ.ค.)',
    noData: 'ไม่พบข้อมูล',
    retry: 'ลองใหม่',
    failedToLoad: 'โหลดข้อมูลไม่สำเร็จ',
    recentActivity: 'กิจกรรมล่าสุด',
    currentStatus: 'สถานะปัจจุบัน',
    changePassword: 'เปลี่ยนรหัสผ่าน',
    language: 'ภาษา',
    alreadyRegistered: 'อีเมล/เบอร์โทรนี้ถูกใช้งานแล้ว',
    loginLink: 'เข้าสู่ระบบ',
    registerLink: 'สมัครสมาชิก',
    wrongCredentials: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
    last3Days: '3 วันล่าสุด',
    last7Days: '7 วันล่าสุด',
    noActivityToday: 'ยังไม่มีกิจกรรมวันนี้',
    account: 'บัญชี',
    accountInfo: 'ข้อมูลบัญชี',
    statusLabel: 'สถานะ :',
    lateStatus: 'สาย',
    onTime: 'ตรงเวลา',
    updateLabel: 'อัปเดต :',
    updatedAt: 'อัปเดตเมื่อ',
    noRecentActivity: 'ยังไม่มีกิจกรรมล่าสุด',
    entryLabel: 'ครั้ง',
    networkError: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่อ',
    serverError: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ กรุณาลองใหม่',
    validationError: 'กรุณาตรวจสอบข้อมูลที่กรอก',
  );
}
