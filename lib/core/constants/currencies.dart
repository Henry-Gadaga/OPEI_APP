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
  Currency(name: 'USD', code: 'USD', symbol: '\$'),
  Currency(name: 'ZMW', code: 'ZMW', symbol: 'ZK'),
  Currency(name: 'MZN', code: 'MZN', symbol: 'MT'),
  Currency(name: 'MWK', code: 'MWK', symbol: 'MK'),
  Currency(name: 'ZAR', code: 'ZAR', symbol: 'R'),
];
