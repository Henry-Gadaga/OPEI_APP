class Currency {
  final String name;
  final String code;
  final String symbol;

  const Currency({
    required this.name,
    required this.code,
    required this.symbol,
  });
}

const List<Currency> currencies = [
  Currency(name: 'United States Dollar', code: 'USD', symbol: '\$'),
  Currency(name: 'Zambian Kwacha', code: 'ZMW', symbol: 'ZK'),
  Currency(name: 'Mozambican Metical', code: 'MZN', symbol: 'MT'),
  Currency(name: 'Malawian Kwacha', code: 'MWK', symbol: 'MK'),
  Currency(name: 'South African Rand', code: 'ZAR', symbol: 'R'),
];
