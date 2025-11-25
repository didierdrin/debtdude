import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

part 'sms_analysis_state.dart';

class SmsAnalysisCubit extends Cubit<SmsAnalysisState> {
  SmsAnalysisCubit() : super(SmsAnalysisState(false)) {
    _loadSmsAnalysisState();
  }

  void _loadSmsAnalysisState() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('smsAnalysisEnabled') ?? false;
    final hasPermission = await Permission.sms.isGranted;
    emit(SmsAnalysisState(isEnabled && hasPermission));
  }

  void toggleSmsAnalysis() async {
    if (!state.isEnabled) {
      final permission = await Permission.sms.request();
      if (permission.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('smsAnalysisEnabled', true);
        emit(SmsAnalysisState(true));
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('smsAnalysisEnabled', false);
      emit(SmsAnalysisState(false));
    }
  }

  Future<void> checkPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('smsAnalysisEnabled') ?? false;
    final hasPermission = await Permission.sms.isGranted;
    emit(SmsAnalysisState(isEnabled && hasPermission));
  }
}