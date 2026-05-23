// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sighra';

  @override
  String get tabBreathing => 'Respirar';

  @override
  String get tabStats => 'Estadísticas';

  @override
  String get tabSounds => 'Sonidos';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get exerciseBoxTitle => 'Respiración de Caja (4-4-4-4)';

  @override
  String get exerciseBoxDesc =>
      'Duraciones iguales de inhalar, retener, exhalar y retener para un balance profundo.';

  @override
  String get exercise478Title => 'Técnica 4-7-8';

  @override
  String get exercise478Desc =>
      'El tranquilizante natural del Dr. Weil para el sistema nervioso, ideal para conciliar el sueño.';

  @override
  String get exerciseCardioTitle => 'Coherencia Cardíaca (5-5)';

  @override
  String get exerciseCardioDesc =>
      'Estabiliza el ritmo cardíaco, reduce los niveles de cortisol y el estrés general.';

  @override
  String get stateIdle => 'Toca para Iniciar';

  @override
  String get stateInhale => 'Inhala';

  @override
  String get stateHoldIn => 'Retén';

  @override
  String get stateExhale => 'Exhala';

  @override
  String get stateHoldOut => 'Descansa y Retén';

  @override
  String get stateCompleted => 'Bien Hecho';

  @override
  String get statsHeader => 'Estadísticas de Calma';

  @override
  String get statsMinutesBreathed => 'Minutos Totales';

  @override
  String get statsSessionsCount => 'Sesiones Hechas';

  @override
  String get statsActiveStreak => 'Racha de Días';

  @override
  String get statsHistoryTitle => 'Sesiones Calmantes Recientes';

  @override
  String get statsEmptyHistory =>
      'No hay sesiones registradas. Practica ahora para encontrar calma.';

  @override
  String get soundTitle => 'Sonidos de Enfoque';

  @override
  String get soundSubtitle =>
      'Mezclador de ruido ambiental offline de alta fidelidad.';

  @override
  String get soundBrownNoise => 'Ruido Marrón';

  @override
  String get soundOcean => 'Olas del Mar';

  @override
  String get soundRain => 'Lluvia Sutil';

  @override
  String get soundPinkNoise => 'Ruido Rosa';

  @override
  String get soundSolfeggio => 'Solfeggio 528 Hz';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Apariencia (Modo Oscuro)';

  @override
  String get settingsHaptics => 'Guías de Vibración';

  @override
  String get settingsHapticsDesc =>
      'Guía mediante vibraciones en transiciones para respirar sin mirar la pantalla.';

  @override
  String get settingsAbout => 'Sobre Sighra';

  @override
  String get settingsDonate => 'Apoyar el proyecto (Buy Me a Coffee)';

  @override
  String get settingsBackup => 'Copia de Seguridad Local';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get btnBuyCoffee => 'Invítame a un café ☕';

  @override
  String get settingsBackupSuccess => 'Datos exportados correctamente';

  @override
  String get settingsRestoreSuccess => 'Datos restaurados correctamente';
}
