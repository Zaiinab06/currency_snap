import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Data class representing a selectable currency option.
class CurrencyOption {
  final String code;
  final String name;
  final String country;
  final String countryCode;

  const CurrencyOption({
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
  });
}

/// Metadata containing human-readable name, country, and 2-letter flag code.
class CurrencyInfo {
  final String name;
  final String country;
  final String countryCode;

  const CurrencyInfo({
    required this.name,
    required this.country,
    required this.countryCode,
  });
}

/// Comprehensive ISO currency code to name, country, and 2-letter country code mappings.
const Map<String, CurrencyInfo> kCurrencyData = {
  'USD': CurrencyInfo(name: 'United States Dollar', country: 'United States', countryCode: 'US'),
  'EUR': CurrencyInfo(name: 'Euro', country: 'European Union', countryCode: 'EU'),
  'GBP': CurrencyInfo(name: 'British Pound Sterling', country: 'United Kingdom', countryCode: 'GB'),
  'PKR': CurrencyInfo(name: 'Pakistani Rupee', country: 'Pakistan', countryCode: 'PK'),
  'INR': CurrencyInfo(name: 'Indian Rupee', country: 'India', countryCode: 'IN'),
  'AED': CurrencyInfo(name: 'UAE Dirham', country: 'United Arab Emirates', countryCode: 'AE'),
  'SAR': CurrencyInfo(name: 'Saudi Riyal', country: 'Saudi Arabia', countryCode: 'SA'),
  'CAD': CurrencyInfo(name: 'Canadian Dollar', country: 'Canada', countryCode: 'CA'),
  'AUD': CurrencyInfo(name: 'Australian Dollar', country: 'Australia', countryCode: 'AU'),
  'JPY': CurrencyInfo(name: 'Japanese Yen', country: 'Japan', countryCode: 'JP'),
  'CNY': CurrencyInfo(name: 'Chinese Yuan', country: 'China', countryCode: 'CN'),
  'CHF': CurrencyInfo(name: 'Swiss Franc', country: 'Switzerland', countryCode: 'CH'),
  'SGD': CurrencyInfo(name: 'Singapore Dollar', country: 'Singapore', countryCode: 'SG'),
  'NZD': CurrencyInfo(name: 'New Zealand Dollar', country: 'New Zealand', countryCode: 'NZ'),
  'HKD': CurrencyInfo(name: 'Hong Kong Dollar', country: 'Hong Kong', countryCode: 'HK'),
  'QAR': CurrencyInfo(name: 'Qatari Riyal', country: 'Qatar', countryCode: 'QA'),
  'KWD': CurrencyInfo(name: 'Kuwaiti Dinar', country: 'Kuwait', countryCode: 'KW'),
  'BHD': CurrencyInfo(name: 'Bahraini Dinar', country: 'Bahrain', countryCode: 'BH'),
  'OMR': CurrencyInfo(name: 'Omani Rial', country: 'Oman', countryCode: 'OM'),
  'TRY': CurrencyInfo(name: 'Turkish Lira', country: 'Turkey', countryCode: 'TR'),
  'MYR': CurrencyInfo(name: 'Malaysian Ringgit', country: 'Malaysia', countryCode: 'MY'),
  'THB': CurrencyInfo(name: 'Thai Baht', country: 'Thailand', countryCode: 'TH'),
  'IDR': CurrencyInfo(name: 'Indonesian Rupiah', country: 'Indonesia', countryCode: 'ID'),
  'PHP': CurrencyInfo(name: 'Philippine Peso', country: 'Philippines', countryCode: 'PH'),
  'KRW': CurrencyInfo(name: 'South Korean Won', country: 'South Korea', countryCode: 'KR'),
  'BRL': CurrencyInfo(name: 'Brazilian Real', country: 'Brazil', countryCode: 'BR'),
  'ZAR': CurrencyInfo(name: 'South African Rand', country: 'South Africa', countryCode: 'ZA'),
  'MXN': CurrencyInfo(name: 'Mexican Peso', country: 'Mexico', countryCode: 'MX'),
  'SEK': CurrencyInfo(name: 'Swedish Krona', country: 'Sweden', countryCode: 'SE'),
  'NOK': CurrencyInfo(name: 'Norwegian Krone', country: 'Norway', countryCode: 'NO'),
  'DKK': CurrencyInfo(name: 'Danish Krone', country: 'Denmark', countryCode: 'DK'),
  'PLN': CurrencyInfo(name: 'Polish Zloty', country: 'Poland', countryCode: 'PL'),
  'EGP': CurrencyInfo(name: 'Egyptian Pound', country: 'Egypt', countryCode: 'EG'),
  'BDT': CurrencyInfo(name: 'Bangladeshi Taka', country: 'Bangladesh', countryCode: 'BD'),
  'LKR': CurrencyInfo(name: 'Sri Lankan Rupee', country: 'Sri Lanka', countryCode: 'LK'),
  'NPR': CurrencyInfo(name: 'Nepalese Rupee', country: 'Nepal', countryCode: 'NP'),
  'RUB': CurrencyInfo(name: 'Russian Ruble', country: 'Russia', countryCode: 'RU'),
  'VND': CurrencyInfo(name: 'Vietnamese Dong', country: 'Vietnam', countryCode: 'VN'),
  'NGN': CurrencyInfo(name: 'Nigerian Naira', country: 'Nigeria', countryCode: 'NG'),
  'KES': CurrencyInfo(name: 'Kenyan Shilling', country: 'Kenya', countryCode: 'KE'),
  'GHS': CurrencyInfo(name: 'Ghanaian Cedi', country: 'Ghana', countryCode: 'GH'),
  'ILS': CurrencyInfo(name: 'Israeli Shekel', country: 'Israel', countryCode: 'IL'),
  'CZK': CurrencyInfo(name: 'Czech Koruna', country: 'Czech Republic', countryCode: 'CZ'),
  'HUF': CurrencyInfo(name: 'Hungarian Forint', country: 'Hungary', countryCode: 'HU'),
  'CLP': CurrencyInfo(name: 'Chilean Peso', country: 'Chile', countryCode: 'CL'),
  'COP': CurrencyInfo(name: 'Colombian Peso', country: 'Colombia', countryCode: 'CO'),
  'PEN': CurrencyInfo(name: 'Peruvian Sol', country: 'Peru', countryCode: 'PE'),
  'ARS': CurrencyInfo(name: 'Argentine Peso', country: 'Argentina', countryCode: 'AR'),
  'TWD': CurrencyInfo(name: 'New Taiwan Dollar', country: 'Taiwan', countryCode: 'TW'),
  'JOD': CurrencyInfo(name: 'Jordanian Dinar', country: 'Jordan', countryCode: 'JO'),
  'MAD': CurrencyInfo(name: 'Moroccan Dirham', country: 'Morocco', countryCode: 'MA'),
  'DZD': CurrencyInfo(name: 'Algerian Dinar', country: 'Algeria', countryCode: 'DZ'),
  'TND': CurrencyInfo(name: 'Tunisian Dinar', country: 'Tunisia', countryCode: 'TN'),
  'IQD': CurrencyInfo(name: 'Iraqi Dinar', country: 'Iraq', countryCode: 'IQ'),
  'AFN': CurrencyInfo(name: 'Afghan Afghani', country: 'Afghanistan', countryCode: 'AF'),
  'ALL': CurrencyInfo(name: 'Albanian Lek', country: 'Albania', countryCode: 'AL'),
  'AMD': CurrencyInfo(name: 'Armenian Dram', country: 'Armenia', countryCode: 'AM'),
  'ANG': CurrencyInfo(name: 'Netherlands Antillean Guilder', country: 'Curaçao', countryCode: 'CW'),
  'AOA': CurrencyInfo(name: 'Angolan Kwanza', country: 'Angola', countryCode: 'AO'),
  'AWG': CurrencyInfo(name: 'Aruban Florin', country: 'Aruba', countryCode: 'AW'),
  'AZN': CurrencyInfo(name: 'Azerbaijani Manat', country: 'Azerbaijan', countryCode: 'AZ'),
  'BAM': CurrencyInfo(name: 'Bosnia Mark', country: 'Bosnia and Herzegovina', countryCode: 'BA'),
  'BBD': CurrencyInfo(name: 'Barbadian Dollar', country: 'Barbados', countryCode: 'BB'),
  'BGN': CurrencyInfo(name: 'Bulgarian Lev', country: 'Bulgaria', countryCode: 'BG'),
  'BIF': CurrencyInfo(name: 'Burundian Franc', country: 'Burundi', countryCode: 'BI'),
  'BMD': CurrencyInfo(name: 'Bermudan Dollar', country: 'Bermuda', countryCode: 'BM'),
  'BND': CurrencyInfo(name: 'Brunei Dollar', country: 'Brunei', countryCode: 'BN'),
  'BOB': CurrencyInfo(name: 'Bolivian Boliviano', country: 'Bolivia', countryCode: 'BO'),
  'BSD': CurrencyInfo(name: 'Bahamian Dollar', country: 'Bahamas', countryCode: 'BS'),
  'BTN': CurrencyInfo(name: 'Bhutanese Ngultrum', country: 'Bhutan', countryCode: 'BT'),
  'BWP': CurrencyInfo(name: 'Botswanan Pula', country: 'Botswana', countryCode: 'BW'),
  'BYN': CurrencyInfo(name: 'Belarusian Ruble', country: 'Belarus', countryCode: 'BY'),
  'BZD': CurrencyInfo(name: 'Belize Dollar', country: 'Belize', countryCode: 'BZ'),
  'CDF': CurrencyInfo(name: 'Congolese Franc', country: 'DR Congo', countryCode: 'CD'),
  'CRC': CurrencyInfo(name: 'Costa Rican Colon', country: 'Costa Rica', countryCode: 'CR'),
  'CUP': CurrencyInfo(name: 'Cuban Peso', country: 'Cuba', countryCode: 'CU'),
  'CVE': CurrencyInfo(name: 'Cape Verdean Escudo', country: 'Cape Verde', countryCode: 'CV'),
  'DJF': CurrencyInfo(name: 'Djiboutian Franc', country: 'Djibouti', countryCode: 'DJ'),
  'DOP': CurrencyInfo(name: 'Dominican Peso', country: 'Dominican Republic', countryCode: 'DO'),
  'ERN': CurrencyInfo(name: 'Eritrean Nakfa', country: 'Eritrea', countryCode: 'ER'),
  'ETB': CurrencyInfo(name: 'Ethiopian Birr', country: 'Ethiopia', countryCode: 'ET'),
  'FJD': CurrencyInfo(name: 'Fijian Dollar', country: 'Fiji', countryCode: 'FJ'),
  'FKP': CurrencyInfo(name: 'Falkland Islands Pound', country: 'Falkland Islands', countryCode: 'FK'),
  'GEL': CurrencyInfo(name: 'Georgian Lari', country: 'Georgia', countryCode: 'GE'),
  'GIP': CurrencyInfo(name: 'Gibraltar Pound', country: 'Gibraltar', countryCode: 'GI'),
  'GMD': CurrencyInfo(name: 'Gambian Dalasi', country: 'Gambia', countryCode: 'GM'),
  'GNF': CurrencyInfo(name: 'Guinean Franc', country: 'Guinea', countryCode: 'GN'),
  'GTQ': CurrencyInfo(name: 'Guatemalan Quetzal', country: 'Guatemala', countryCode: 'GT'),
  'GYD': CurrencyInfo(name: 'Guyanaese Dollar', country: 'Guyana', countryCode: 'GY'),
  'HNL': CurrencyInfo(name: 'Honduran Lempira', country: 'Honduras', countryCode: 'HN'),
  'HRK': CurrencyInfo(name: 'Croatian Kuna', country: 'Croatia', countryCode: 'HR'),
  'HTG': CurrencyInfo(name: 'Haitian Gourde', country: 'Haiti', countryCode: 'HT'),
  'ISK': CurrencyInfo(name: 'Icelandic Krona', country: 'Iceland', countryCode: 'IS'),
  'JMD': CurrencyInfo(name: 'Jamaican Dollar', country: 'Jamaica', countryCode: 'JM'),
  'KGS': CurrencyInfo(name: 'Kyrgystani Som', country: 'Kyrgyzstan', countryCode: 'KG'),
  'KHR': CurrencyInfo(name: 'Cambodian Riel', country: 'Cambodia', countryCode: 'KH'),
  'KMF': CurrencyInfo(name: 'Comorian Franc', country: 'Comoros', countryCode: 'KM'),
  'KYD': CurrencyInfo(name: 'Cayman Islands Dollar', country: 'Cayman Islands', countryCode: 'KY'),
  'KZT': CurrencyInfo(name: 'Kazakhstani Tenge', country: 'Kazakhstan', countryCode: 'KZ'),
  'LAK': CurrencyInfo(name: 'Laotian Kip', country: 'Laos', countryCode: 'LA'),
  'LBP': CurrencyInfo(name: 'Lebanese Pound', country: 'Lebanon', countryCode: 'LB'),
  'LRD': CurrencyInfo(name: 'Liberian Dollar', country: 'Liberia', countryCode: 'LR'),
  'LSL': CurrencyInfo(name: 'Lesotho Loti', country: 'Lesotho', countryCode: 'LS'),
  'LYD': CurrencyInfo(name: 'Libyan Dinar', country: 'Libya', countryCode: 'LY'),
  'MDL': CurrencyInfo(name: 'Moldovan Leu', country: 'Moldova', countryCode: 'MD'),
  'MGA': CurrencyInfo(name: 'Malagasy Ariary', country: 'Madagascar', countryCode: 'MG'),
  'MKD': CurrencyInfo(name: 'Macedonian Denar', country: 'North Macedonia', countryCode: 'MK'),
  'MMK': CurrencyInfo(name: 'Myanmar Kyat', country: 'Myanmar', countryCode: 'MM'),
  'MNT': CurrencyInfo(name: 'Mongolian Tugrik', country: 'Mongolia', countryCode: 'MN'),
  'MOP': CurrencyInfo(name: 'Macanese Pataca', country: 'Macau', countryCode: 'MO'),
  'MRU': CurrencyInfo(name: 'Mauritanian Ouguiya', country: 'Mauritania', countryCode: 'MR'),
  'MUR': CurrencyInfo(name: 'Mauritian Rupee', country: 'Mauritius', countryCode: 'MU'),
  'MVR': CurrencyInfo(name: 'Maldivian Rufiyaa', country: 'Maldives', countryCode: 'MV'),
  'MWK': CurrencyInfo(name: 'Malawian Kwacha', country: 'Malawi', countryCode: 'MW'),
  'MZN': CurrencyInfo(name: 'Mozambican Metical', country: 'Mozambique', countryCode: 'MZ'),
  'NAD': CurrencyInfo(name: 'Namibian Dollar', country: 'Namibia', countryCode: 'NA'),
  'NIO': CurrencyInfo(name: 'Nicaraguan Cordoba', country: 'Nicaragua', countryCode: 'NI'),
  'PAB': CurrencyInfo(name: 'Panamanian Balboa', country: 'Panama', countryCode: 'PA'),
  'PGK': CurrencyInfo(name: 'Papua New Guinean Kina', country: 'Papua New Guinea', countryCode: 'PG'),
  'PYG': CurrencyInfo(name: 'Paraguayan Guarani', country: 'Paraguay', countryCode: 'PY'),
  'RON': CurrencyInfo(name: 'Romanian Leu', country: 'Romania', countryCode: 'RO'),
  'RSD': CurrencyInfo(name: 'Serbian Dinar', country: 'Serbia', countryCode: 'RS'),
  'RWF': CurrencyInfo(name: 'Rwandan Franc', country: 'Rwanda', countryCode: 'RW'),
  'SBD': CurrencyInfo(name: 'Solomon Islands Dollar', country: 'Solomon Islands', countryCode: 'SB'),
  'SCR': CurrencyInfo(name: 'Seychellois Rupee', country: 'Seychelles', countryCode: 'SC'),
  'SDG': CurrencyInfo(name: 'Sudanese Pound', country: 'Sudan', countryCode: 'SD'),
  'SOS': CurrencyInfo(name: 'Somali Shilling', country: 'Somalia', countryCode: 'SO'),
  'SRD': CurrencyInfo(name: 'Surinamese Dollar', country: 'Suriname', countryCode: 'SR'),
  'SSP': CurrencyInfo(name: 'South Sudanese Pound', country: 'South Sudan', countryCode: 'SS'),
  'STN': CurrencyInfo(name: 'Sao Tome Dobra', country: 'Sao Tome and Principe', countryCode: 'ST'),
  'SYP': CurrencyInfo(name: 'Syrian Pound', country: 'Syria', countryCode: 'SY'),
  'SZL': CurrencyInfo(name: 'Swazi Lilangeni', country: 'Eswatini', countryCode: 'SZ'),
  'TJS': CurrencyInfo(name: 'Tajikistani Somoni', country: 'Tajikistan', countryCode: 'TJ'),
  'TMT': CurrencyInfo(name: 'Turkmenistani Manat', country: 'Turkmenistan', countryCode: 'TM'),
  'TOP': CurrencyInfo(name: 'Tongan Paanga', country: 'Tonga', countryCode: 'TO'),
  'TTD': CurrencyInfo(name: 'Trinidad Dollar', country: 'Trinidad and Tobago', countryCode: 'TT'),
  'TZS': CurrencyInfo(name: 'Tanzanian Shilling', country: 'Tanzania', countryCode: 'TZ'),
  'UAH': CurrencyInfo(name: 'Ukrainian Hryvnia', country: 'Ukraine', countryCode: 'UA'),
  'UGX': CurrencyInfo(name: 'Ugandan Shilling', country: 'Uganda', countryCode: 'UG'),
  'UYU': CurrencyInfo(name: 'Uruguayan Peso', country: 'Uruguay', countryCode: 'UY'),
  'UZS': CurrencyInfo(name: 'Uzbekistani Som', country: 'Uzbekistan', countryCode: 'UZ'),
  'VES': CurrencyInfo(name: 'Venezuelan Bolivar', country: 'Venezuela', countryCode: 'VE'),
  'VUV': CurrencyInfo(name: 'Vanuatu Vatu', country: 'Vanuatu', countryCode: 'VU'),
  'WST': CurrencyInfo(name: 'Samoan Tala', country: 'Samoa', countryCode: 'WS'),
  'XAF': CurrencyInfo(name: 'Central African CFA Franc', country: 'Central Africa', countryCode: 'CM'),
  'XCD': CurrencyInfo(name: 'East Caribbean Dollar', country: 'East Caribbean', countryCode: 'AG'),
  'XOF': CurrencyInfo(name: 'West African CFA Franc', country: 'West Africa', countryCode: 'SN'),
  'XPF': CurrencyInfo(name: 'CFP Franc', country: 'French Polynesia', countryCode: 'PF'),
  'YER': CurrencyInfo(name: 'Yemeni Rial', country: 'Yemen', countryCode: 'YE'),
  'ZMW': CurrencyInfo(name: 'Zambian Kwacha', country: 'Zambia', countryCode: 'ZM'),
  'ZWL': CurrencyInfo(name: 'Zimbabwean Dollar', country: 'Zimbabwe', countryCode: 'ZW'),
};

/// Opens the currency picker as a modal bottom sheet and returns the
/// selected currency code, or null if dismissed without a selection.
Future<String?> showCurrencyPickerSheet({
  required BuildContext context,
  required String selectedCode,
  Iterable<String>? availableCodes,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _CurrencyPickerContent(
      selectedCode: selectedCode,
      availableCodes: availableCodes,
    ),
  );
}

class _CurrencyPickerContent extends StatefulWidget {
  final String selectedCode;
  final Iterable<String>? availableCodes;

  const _CurrencyPickerContent({
    required this.selectedCode,
    this.availableCodes,
  });

  @override
  State<_CurrencyPickerContent> createState() => _CurrencyPickerContentState();
}

class _CurrencyPickerContentState extends State<_CurrencyPickerContent> {
  String _query = '';
  String _selectedLetter = 'ALL';
  late final List<CurrencyOption> _allOptions;

  static const List<String> _recentCodes = [
    'USD', 'EUR', 'GBP', 'PKR', 'INR', 'AED', 'SAR', 'CAD', 'JPY', 'AUD', 'CHF', 'CNY',
  ];

  static const List<String> _alphabet = [
    'ALL', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  void initState() {
    super.initState();
    _allOptions = _buildOptions();
  }

  List<CurrencyOption> _buildOptions() {
    final Set<String> codes = widget.availableCodes != null &&
            widget.availableCodes!.isNotEmpty
        ? widget.availableCodes!.toSet()
        : kCurrencyData.keys.toSet();

    final List<CurrencyOption> options = codes.map((code) {
      final info = kCurrencyData[code];
      final name = info?.name ?? '$code Currency';
      final country = info?.country ?? 'Global';
      final countryCode = info?.countryCode ??          code.substring(0, code.length > 2 ? 2 : code.length);
      return CurrencyOption(
        code: code,
        name: name,
        country: country,
        countryCode: countryCode,
      );
    }).toList();

    // Sort alphabetically by currency code
    options.sort((a, b) => a.code.compareTo(b.code));
    return options;
  }

  List<CurrencyOption> get _filtered {
    var list = _allOptions;
    if (_selectedLetter != 'ALL') {
      list = list.where((c) => c.code.toUpperCase().startsWith(_selectedLetter)).toList();
    }
    if (_query.trim().isEmpty) return list;
    final q = _query.trim().toLowerCase();
    return list.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;
    final primaryLightColor = theme.colorScheme.secondary;
    final borderColor = theme.dividerColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: scaffoldBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Select Currency',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(CupertinoIcons.xmark),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search code, currency, or country...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Recent Currencies Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.clock, size: 14, color: primaryLightColor),
                    const SizedBox(width: 6),
                    const Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentCodes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final code = _recentCodes[index];
                    final countryCode = kCurrencyData[code]?.countryCode ??
                        code.substring(0, code.length > 2 ? 2 : code.length);
                    final isSelected = code == widget.selectedCode;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(code),
                        borderRadius: BorderRadius.circular(19),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.25)
                                : surfaceColor,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: isSelected ? primaryColor : borderColor,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                    width: 0.8,
                                  ),
                                ),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: FlagCode.fromCurrencyCode(code) != null
                                        ? CountryFlag.fromCurrencyCode(
                                            code,
                                            shape: const Circle(),
                                          )
                                        : CountryFlag.fromCountryCode(
                                            countryCode,
                                            shape: const Circle(),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? primaryLightColor
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // A-Z Jump Bar
              SizedBox(
                height: 28,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _alphabet.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final letter = _alphabet[index];
                    final isSelected = _selectedLetter == letter;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLetter = letter;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Main Currency Grid
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No currencies found matching "$_query"',
                            style: const TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.55,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final option = _filtered[index];
                          final isSelected = option.code == widget.selectedCode;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(option.code),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor.withValues(alpha: 0.2)
                                      : surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryLightColor
                                        : borderColor,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: 0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              option.code,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                letterSpacing: -0.2,
                                                color: isSelected
                                                    ? primaryLightColor
                                                    : theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                CupertinoIcons.checkmark_alt_circle_fill,
                                                size: 15,
                                                color: primaryLightColor,
                                              ),
                                            ],
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.colorScheme.outlineVariant,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: FlagCode.fromCurrencyCode(option.code) != null
                                                  ? CountryFlag.fromCurrencyCode(
                                                      option.code,
                                                      shape: const Circle(),
                                                    )
                                                  : CountryFlag.fromCountryCode(
                                                      option.countryCode,
                                                      shape: const Circle(),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          option.country,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
