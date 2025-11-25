import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(CurrencyState('RWF', 'RWF', 1.0)) {
    _loadCurrency();
  }

  void _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('selectedCurrency') ?? 'RWF';
    final symbol = currency == 'USD' ? '\$' : 'RWF';
    final rate = currency == 'USD' ? 0.00077 : 1.0; // 1 RWF = 0.00077 USD
    emit(CurrencyState(currency, symbol, rate));
  }

  void changeCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', currency);
    final symbol = currency == 'USD' ? '\$' : 'RWF';
    final rate = currency == 'USD' ? 0.00077 : 1.0;
    emit(CurrencyState(currency, symbol, rate));
  }

  String formatAmount(num amount) {
    final convertedAmount = amount * state.exchangeRate;
    if (state.currency == 'USD') {
      return '\$${convertedAmount.toStringAsFixed(2)}';
    }
    return 'RWF ${convertedAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}