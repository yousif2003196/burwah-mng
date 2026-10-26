const chatAccounts = <String, (String, String)>{
  'finance': ('المشرف المالي', 'Finance supervisor'),
  'merchant': ('مشرف التجار', 'Merchant supervisor'),
  'products': ('مشرف المنتجات', 'Product supervisor'),
  'wasalny': ('مشرف وصلني', 'Wasalny supervisor'),
  'services': ('مشرف الخدمات', 'Services supervisor'),
  'head': ('رئيس المشرفين', 'Head supervisor'),
  'admin': ('الأدمن', 'Admin'),
};

String chatAccountName(String id, bool isArabic) {
  final names = chatAccounts[id];
  if (names == null) return id;
  return isArabic ? names.$1 : names.$2;
}
