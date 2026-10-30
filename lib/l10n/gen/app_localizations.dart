import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Mordakte'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ein kooperativer Krimi'**
  String get appSubtitle;

  /// No description provided for @appLoading.
  ///
  /// In de, this message translates to:
  /// **'Akten werden geladen …'**
  String get appLoading;

  /// No description provided for @common_back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get common_back;

  /// No description provided for @common_cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get common_cancel;

  /// No description provided for @common_ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get common_save;

  /// No description provided for @common_close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get common_close;

  /// No description provided for @common_locked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get common_locked;

  /// No description provided for @common_you.
  ///
  /// In de, this message translates to:
  /// **'Du'**
  String get common_you;

  /// No description provided for @common_unlock_at.
  ///
  /// In de, this message translates to:
  /// **'ab {rank}'**
  String common_unlock_at(String rank);

  /// No description provided for @common_minutes.
  ///
  /// In de, this message translates to:
  /// **'{n} Min.'**
  String common_minutes(int n);

  /// No description provided for @common_xp.
  ///
  /// In de, this message translates to:
  /// **'{xp} XP'**
  String common_xp(int xp);

  /// No description provided for @common_xp_gain.
  ///
  /// In de, this message translates to:
  /// **'+{xp} XP'**
  String common_xp_gain(int xp);

  /// No description provided for @hub_welcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück, {name}.'**
  String hub_welcome(String name);

  /// No description provided for @hub_cases.
  ///
  /// In de, this message translates to:
  /// **'Fallakten'**
  String get hub_cases;

  /// No description provided for @hub_cases_sub.
  ///
  /// In de, this message translates to:
  /// **'Solo mit KI-Partnern'**
  String get hub_cases_sub;

  /// No description provided for @hub_online.
  ///
  /// In de, this message translates to:
  /// **'Online spielen'**
  String get hub_online;

  /// No description provided for @hub_online_sub.
  ///
  /// In de, this message translates to:
  /// **'Mit bis zu fünf Freunden'**
  String get hub_online_sub;

  /// No description provided for @hub_party.
  ///
  /// In de, this message translates to:
  /// **'Partyabend: Spuk im Schlosskeller'**
  String get hub_party;

  /// No description provided for @hub_party_sub.
  ///
  /// In de, this message translates to:
  /// **'Ein Krimi für 4 bis 20 Gäste, einen Detektiv und auf Wunsch einen Erzähler'**
  String get hub_party_sub;

  /// No description provided for @hub_section_party.
  ///
  /// In de, this message translates to:
  /// **'Partyabende'**
  String get hub_section_party;

  /// No description provided for @party_menu.
  ///
  /// In de, this message translates to:
  /// **'Andere Abende & Fälle'**
  String get party_menu;

  /// No description provided for @party_solo_spielweise.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du spielen?'**
  String get party_solo_spielweise;

  /// No description provided for @party_solo_party.
  ///
  /// In de, this message translates to:
  /// **'Party am Gerät'**
  String get party_solo_party;

  /// No description provided for @party_solo_solo.
  ///
  /// In de, this message translates to:
  /// **'Solo mit Bots'**
  String get party_solo_solo;

  /// No description provided for @party_solo_einrichtung.
  ///
  /// In de, this message translates to:
  /// **'Du ermittelst allein. Die Gäste sprechen und wählen als Bots; ihre geheimen Rollenkarten bleiben zu.'**
  String get party_solo_einrichtung;

  /// No description provided for @party_solo_rollen.
  ///
  /// In de, this message translates to:
  /// **'Gäste mit Stimmrecht'**
  String get party_solo_rollen;

  /// No description provided for @party_solo_rollen_anzahl.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Bot-Rollen'**
  String party_solo_rollen_anzahl(Object anzahl);

  /// No description provided for @party_solo_rollen_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Diese Gäste übernehmen die Rollen und wählen verdeckt. Weitere Gäste melden sich mit ihrem öffentlichen Wissen, wenn es gebraucht wird.'**
  String get party_solo_rollen_hinweis;

  /// No description provided for @party_solo_name.
  ///
  /// In de, this message translates to:
  /// **'Dein Name als Detektiv'**
  String get party_solo_name;

  /// No description provided for @party_solo_name_feld.
  ///
  /// In de, this message translates to:
  /// **'Name (freiwillig)'**
  String get party_solo_name_feld;

  /// No description provided for @party_solo_rollen_start.
  ///
  /// In de, this message translates to:
  /// **'Du bist der Detektiv. Die folgenden Rollen werden vom Spiel übernommen. Ihre Dossiers kannst du nicht öffnen; alle nötigen Aussagen hörst du in den Runden.'**
  String get party_solo_rollen_start;

  /// No description provided for @party_solo_gespraeche.
  ///
  /// In de, this message translates to:
  /// **'Gespräche mit den Gästen'**
  String get party_solo_gespraeche;

  /// No description provided for @party_solo_gespraeche_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Höre die öffentlichen Aussagen an, bevor du ermittelst. Behauptungen können falsch sein. Die Sprechblasen bleiben danach im Notizbuch.'**
  String get party_solo_gespraeche_hinweis;

  /// No description provided for @party_solo_fortschritt.
  ///
  /// In de, this message translates to:
  /// **'Gespräch {nr} von {gesamt}'**
  String party_solo_fortschritt(Object gesamt, Object nr);

  /// No description provided for @party_solo_gehoert.
  ///
  /// In de, this message translates to:
  /// **'Gehört – nächstes Gespräch'**
  String get party_solo_gehoert;

  /// No description provided for @party_solo_vorheriges.
  ///
  /// In de, this message translates to:
  /// **'Vorheriges Gespräch'**
  String get party_solo_vorheriges;

  /// No description provided for @party_solo_fertig.
  ///
  /// In de, this message translates to:
  /// **'Alle Aussagen gehört. Jetzt entscheidest du auf der Karte.'**
  String get party_solo_fertig;

  /// No description provided for @party_solo_gruppenwahl.
  ///
  /// In de, this message translates to:
  /// **'Die Bots haben verdeckt gewählt. Sie kooperieren mit 70 % Wahrscheinlichkeit. Nur die Täterrolle kann mit ihrer Wahl sabotieren; Stimmen und Hinweisqualität bleiben geheim.'**
  String get party_solo_gruppenwahl;

  /// No description provided for @party_solo_gast.
  ///
  /// In de, this message translates to:
  /// **'Diese Figur wird vom Spiel übernommen.'**
  String get party_solo_gast;

  /// No description provided for @party_solo_npc.
  ///
  /// In de, this message translates to:
  /// **'Gast ohne Stimmrolle'**
  String get party_solo_npc;

  /// No description provided for @party_solo_notizen.
  ///
  /// In de, this message translates to:
  /// **'Gehörte Gespräche'**
  String get party_solo_notizen;

  /// No description provided for @hub_section_classic.
  ///
  /// In de, this message translates to:
  /// **'Klassische Fälle'**
  String get hub_section_classic;

  /// No description provided for @hub_section_meta.
  ///
  /// In de, this message translates to:
  /// **'Sammlung und Profil'**
  String get hub_section_meta;

  /// No description provided for @hub_party_keller.
  ///
  /// In de, this message translates to:
  /// **'Spuk im Schlosskeller'**
  String get hub_party_keller;

  /// No description provided for @hub_party_keller_sub.
  ///
  /// In de, this message translates to:
  /// **'Party am Gerät oder Solo mit Bots'**
  String get hub_party_keller_sub;

  /// No description provided for @hub_party_gewoelbe.
  ///
  /// In de, this message translates to:
  /// **'Spuk im Gewölbe'**
  String get hub_party_gewoelbe;

  /// No description provided for @hub_party_gewoelbe_sub.
  ///
  /// In de, this message translates to:
  /// **'Krimidinner auf Burg Schartenfels · Besetzung, Steckbriefe, Mappen'**
  String get hub_party_gewoelbe_sub;

  /// No description provided for @hub_online_rejoin.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Raum {code}'**
  String hub_online_rejoin(String code);

  /// No description provided for @hud_room.
  ///
  /// In de, this message translates to:
  /// **'RAUM {code}'**
  String hud_room(String code);

  /// No description provided for @toast_combo_known.
  ///
  /// In de, this message translates to:
  /// **'„{combo}“ habt ihr schon kombiniert.'**
  String toast_combo_known(String combo);

  /// No description provided for @hub_collection.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get hub_collection;

  /// No description provided for @hub_profile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get hub_profile;

  /// No description provided for @hub_streak.
  ///
  /// In de, this message translates to:
  /// **'{days, plural, =0{Keine Serie} =1{1 Tag in Folge} other{{days} Tage in Folge}}'**
  String hub_streak(int days);

  /// No description provided for @hub_daily_title.
  ///
  /// In de, this message translates to:
  /// **'Fall des Tages'**
  String get hub_daily_title;

  /// No description provided for @hub_daily_play.
  ///
  /// In de, this message translates to:
  /// **'Ermitteln'**
  String get hub_daily_play;

  /// No description provided for @hub_daily_done.
  ///
  /// In de, this message translates to:
  /// **'Heute gelöst'**
  String get hub_daily_done;

  /// No description provided for @hub_daily_bonus.
  ///
  /// In de, this message translates to:
  /// **'+{xp} XP Bonus'**
  String hub_daily_bonus(int xp);

  /// No description provided for @hub_rank_progress.
  ///
  /// In de, this message translates to:
  /// **'{xp} / {next} XP'**
  String hub_rank_progress(int xp, int next);

  /// No description provided for @hub_rank_max.
  ///
  /// In de, this message translates to:
  /// **'Höchster Rang erreicht'**
  String get hub_rank_max;

  /// No description provided for @hub_motto.
  ///
  /// In de, this message translates to:
  /// **'Niemand verlässt das Haus, bevor der Fall gelöst ist.'**
  String get hub_motto;

  /// No description provided for @name_prompt_title.
  ///
  /// In de, this message translates to:
  /// **'Wie lautet Ihr Name, Detektiv?'**
  String get name_prompt_title;

  /// No description provided for @name_prompt_text.
  ///
  /// In de, this message translates to:
  /// **'Er steht ab sofort auf Ihrer Dienstmarke.'**
  String get name_prompt_text;

  /// No description provided for @name_prompt_hint.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name_prompt_hint;

  /// No description provided for @name_prompt_title_du.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt du, Detektiv?'**
  String get name_prompt_title_du;

  /// No description provided for @name_prompt_text_du.
  ///
  /// In de, this message translates to:
  /// **'Dein Name steht ab sofort auf deiner Dienstmarke.'**
  String get name_prompt_text_du;

  /// No description provided for @name_prompt_confirm.
  ///
  /// In de, this message translates to:
  /// **'Dienstmarke ausstellen'**
  String get name_prompt_confirm;

  /// No description provided for @name_edit.
  ///
  /// In de, this message translates to:
  /// **'Name ändern'**
  String get name_edit;

  /// No description provided for @name_default.
  ///
  /// In de, this message translates to:
  /// **'Detektiv'**
  String get name_default;

  /// No description provided for @cases_title.
  ///
  /// In de, this message translates to:
  /// **'Fallakten'**
  String get cases_title;

  /// No description provided for @cases_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Akte. Deine KI-Partner warten schon.'**
  String get cases_subtitle;

  /// No description provided for @case_file_no.
  ///
  /// In de, this message translates to:
  /// **'Akte Nr. {n}'**
  String case_file_no(String n);

  /// No description provided for @case_difficulty.
  ///
  /// In de, this message translates to:
  /// **'Schwierigkeit'**
  String get case_difficulty;

  /// No description provided for @case_endings.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch kein Ende entdeckt} =1{1 Ende entdeckt} other{{count} Enden entdeckt}}'**
  String case_endings(int count);

  /// No description provided for @case_story_solved.
  ///
  /// In de, this message translates to:
  /// **'Story gelöst'**
  String get case_story_solved;

  /// No description provided for @case_daily_badge.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get case_daily_badge;

  /// No description provided for @case_start.
  ///
  /// In de, this message translates to:
  /// **'Akte öffnen'**
  String get case_start;

  /// No description provided for @case_starting.
  ///
  /// In de, this message translates to:
  /// **'Akte wird geöffnet …'**
  String get case_starting;

  /// No description provided for @mode_story.
  ///
  /// In de, this message translates to:
  /// **'Story'**
  String get mode_story;

  /// No description provided for @mode_story_desc.
  ///
  /// In de, this message translates to:
  /// **'Der Originalfall – ideal für den ersten Durchlauf.'**
  String get mode_story_desc;

  /// No description provided for @mode_random.
  ///
  /// In de, this message translates to:
  /// **'Zufallsfall'**
  String get mode_random;

  /// No description provided for @mode_random_desc.
  ///
  /// In de, this message translates to:
  /// **'Neuer Täter, neues Motiv, neue Waffe.'**
  String get mode_random_desc;

  /// No description provided for @mode_daily.
  ///
  /// In de, this message translates to:
  /// **'Fall des Tages'**
  String get mode_daily;

  /// No description provided for @mode_daily_desc.
  ///
  /// In de, this message translates to:
  /// **'Für alle gleich. Heute mit Bonus-XP.'**
  String get mode_daily_desc;

  /// No description provided for @mode_daily_other.
  ///
  /// In de, this message translates to:
  /// **'Heute ist eine andere Akte dran.'**
  String get mode_daily_other;

  /// No description provided for @online_title.
  ///
  /// In de, this message translates to:
  /// **'Online spielen'**
  String get online_title;

  /// No description provided for @online_create.
  ///
  /// In de, this message translates to:
  /// **'Raum erstellen'**
  String get online_create;

  /// No description provided for @online_create_sub.
  ///
  /// In de, this message translates to:
  /// **'Du bist Gastgeber und wählst den Fall.'**
  String get online_create_sub;

  /// No description provided for @online_join.
  ///
  /// In de, this message translates to:
  /// **'Raum beitreten'**
  String get online_join;

  /// No description provided for @online_join_sub.
  ///
  /// In de, this message translates to:
  /// **'Gib den vierstelligen Code deines Gastgebers ein.'**
  String get online_join_sub;

  /// No description provided for @online_join_button.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get online_join_button;

  /// No description provided for @online_advanced.
  ///
  /// In de, this message translates to:
  /// **'Erweitert'**
  String get online_advanced;

  /// No description provided for @online_server.
  ///
  /// In de, this message translates to:
  /// **'Server-Adresse'**
  String get online_server;

  /// No description provided for @online_server_reset.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get online_server_reset;

  /// No description provided for @online_connecting.
  ///
  /// In de, this message translates to:
  /// **'Verbinde …'**
  String get online_connecting;

  /// No description provided for @online_playing_as.
  ///
  /// In de, this message translates to:
  /// **'Du spielst als {name}'**
  String online_playing_as(String name);

  /// No description provided for @error_room_not_found.
  ///
  /// In de, this message translates to:
  /// **'Diesen Raum gibt es nicht. Prüfe den Code.'**
  String get error_room_not_found;

  /// No description provided for @error_room_full.
  ///
  /// In de, this message translates to:
  /// **'Der Raum ist voll.'**
  String get error_room_full;

  /// No description provided for @error_game_running.
  ///
  /// In de, this message translates to:
  /// **'In diesem Raum läuft bereits ein Fall.'**
  String get error_game_running;

  /// No description provided for @error_not_host.
  ///
  /// In de, this message translates to:
  /// **'Das darf nur der Gastgeber.'**
  String get error_not_host;

  /// No description provided for @error_too_far.
  ///
  /// In de, this message translates to:
  /// **'Zu weit entfernt.'**
  String get error_too_far;

  /// No description provided for @error_inventory_full.
  ///
  /// In de, this message translates to:
  /// **'Deine Taschen sind voll.'**
  String get error_inventory_full;

  /// No description provided for @error_cooldown.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht wieder bereit.'**
  String get error_cooldown;

  /// No description provided for @error_not_in_phase.
  ///
  /// In de, this message translates to:
  /// **'Das geht gerade nicht.'**
  String get error_not_in_phase;

  /// No description provided for @error_no_charges.
  ///
  /// In de, this message translates to:
  /// **'Keine Ladungen mehr in dieser Nacht.'**
  String get error_no_charges;

  /// No description provided for @error_invalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Eingabe.'**
  String get error_invalid;

  /// No description provided for @error_connection.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zum Server.'**
  String get error_connection;

  /// No description provided for @error_server_missing.
  ///
  /// In de, this message translates to:
  /// **'Der öffentliche Spielserver ist noch nicht eingerichtet. Trage unter Erweitert die freigegebene Server-Adresse ein. Offline kannst du sofort spielen.'**
  String get error_server_missing;

  /// No description provided for @error_server_invalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine öffentliche wss-Adresse mit dem Pfad /ws eingeben. Lokale Adressen und Zugangsdaten in der URL sind nicht erlaubt.'**
  String get error_server_invalid;

  /// No description provided for @error_unavailable.
  ///
  /// In de, this message translates to:
  /// **'Der Online-Modus ist noch nicht verfügbar.'**
  String get error_unavailable;

  /// No description provided for @error_unknown.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen.'**
  String get error_unknown;

  /// No description provided for @lobby_title.
  ///
  /// In de, this message translates to:
  /// **'Lagebesprechung'**
  String get lobby_title;

  /// No description provided for @lobby_room_code.
  ///
  /// In de, this message translates to:
  /// **'Raumcode'**
  String get lobby_room_code;

  /// No description provided for @lobby_copied.
  ///
  /// In de, this message translates to:
  /// **'Code kopiert'**
  String get lobby_copied;

  /// No description provided for @lobby_players.
  ///
  /// In de, this message translates to:
  /// **'Ermittler ({count}/6)'**
  String lobby_players(int count);

  /// No description provided for @lobby_bot.
  ///
  /// In de, this message translates to:
  /// **'KI'**
  String get lobby_bot;

  /// No description provided for @lobby_host.
  ///
  /// In de, this message translates to:
  /// **'Gastgeber'**
  String get lobby_host;

  /// No description provided for @lobby_ready.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get lobby_ready;

  /// No description provided for @lobby_waiting.
  ///
  /// In de, this message translates to:
  /// **'Wartet'**
  String get lobby_waiting;

  /// No description provided for @lobby_offline.
  ///
  /// In de, this message translates to:
  /// **'Getrennt'**
  String get lobby_offline;

  /// No description provided for @lobby_loadout.
  ///
  /// In de, this message translates to:
  /// **'Deine Ausrüstung'**
  String get lobby_loadout;

  /// No description provided for @lobby_class.
  ///
  /// In de, this message translates to:
  /// **'Klasse'**
  String get lobby_class;

  /// No description provided for @lobby_coat.
  ///
  /// In de, this message translates to:
  /// **'Mantel'**
  String get lobby_coat;

  /// No description provided for @lobby_hat.
  ///
  /// In de, this message translates to:
  /// **'Hut'**
  String get lobby_hat;

  /// No description provided for @lobby_ability.
  ///
  /// In de, this message translates to:
  /// **'Fähigkeit'**
  String get lobby_ability;

  /// No description provided for @lobby_passive.
  ///
  /// In de, this message translates to:
  /// **'Passiv'**
  String get lobby_passive;

  /// No description provided for @lobby_case.
  ///
  /// In de, this message translates to:
  /// **'Der Fall'**
  String get lobby_case;

  /// No description provided for @lobby_scenario.
  ///
  /// In de, this message translates to:
  /// **'Akte'**
  String get lobby_scenario;

  /// No description provided for @lobby_mode.
  ///
  /// In de, this message translates to:
  /// **'Modus'**
  String get lobby_mode;

  /// No description provided for @lobby_bots.
  ///
  /// In de, this message translates to:
  /// **'KI-Partner'**
  String get lobby_bots;

  /// No description provided for @lobby_start.
  ///
  /// In de, this message translates to:
  /// **'Ermittlung beginnen'**
  String get lobby_start;

  /// No description provided for @lobby_set_ready.
  ///
  /// In de, this message translates to:
  /// **'Ich bin bereit'**
  String get lobby_set_ready;

  /// No description provided for @lobby_unready.
  ///
  /// In de, this message translates to:
  /// **'Doch nicht bereit'**
  String get lobby_unready;

  /// No description provided for @lobby_wait_host.
  ///
  /// In de, this message translates to:
  /// **'Warte auf den Gastgeber …'**
  String get lobby_wait_host;

  /// No description provided for @lobby_pick_case.
  ///
  /// In de, this message translates to:
  /// **'Akte wählen …'**
  String get lobby_pick_case;

  /// No description provided for @lobby_need_case.
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst eine Akte – dann kann die Ermittlung beginnen.'**
  String get lobby_need_case;

  /// No description provided for @lobby_leave.
  ///
  /// In de, this message translates to:
  /// **'Lobby verlassen'**
  String get lobby_leave;

  /// No description provided for @lobby_empty_slot.
  ///
  /// In de, this message translates to:
  /// **'Freier Platz'**
  String get lobby_empty_slot;

  /// No description provided for @class_forensic_name.
  ///
  /// In de, this message translates to:
  /// **'Forensikerin'**
  String get class_forensic_name;

  /// No description provided for @class_forensic_ability.
  ///
  /// In de, this message translates to:
  /// **'Adlerauge: 15 s lang verborgene Spuren sehen und schneller suchen.'**
  String get class_forensic_ability;

  /// No description provided for @class_forensic_passive.
  ///
  /// In de, this message translates to:
  /// **'Laboranalysen gehen doppelt so schnell.'**
  String get class_forensic_passive;

  /// No description provided for @class_profiler_name.
  ///
  /// In de, this message translates to:
  /// **'Profiler'**
  String get class_profiler_name;

  /// No description provided for @class_profiler_ability.
  ///
  /// In de, this message translates to:
  /// **'Ruhe bewahren: Fokus für alle in der Nähe, heilt Panik.'**
  String get class_profiler_ability;

  /// No description provided for @class_profiler_passive.
  ///
  /// In de, this message translates to:
  /// **'Erkennt Lügen im Verhör.'**
  String get class_profiler_passive;

  /// No description provided for @class_excop_name.
  ///
  /// In de, this message translates to:
  /// **'Ex-Polizist'**
  String get class_excop_name;

  /// No description provided for @class_excop_ability.
  ///
  /// In de, this message translates to:
  /// **'Verscheuchen: Der Schatten in deiner Nähe flieht. 1× pro Nacht.'**
  String get class_excop_ability;

  /// No description provided for @class_excop_passive.
  ///
  /// In de, this message translates to:
  /// **'Vier statt drei Herzen.'**
  String get class_excop_passive;

  /// No description provided for @class_journalist_name.
  ///
  /// In de, this message translates to:
  /// **'Journalistin'**
  String get class_journalist_name;

  /// No description provided for @class_journalist_ability.
  ///
  /// In de, this message translates to:
  /// **'Quellen: Markiert den Ort eines ungefundenen Hinweises.'**
  String get class_journalist_ability;

  /// No description provided for @class_journalist_passive.
  ///
  /// In de, this message translates to:
  /// **'Kann Verdächtige nach Gerüchten fragen.'**
  String get class_journalist_passive;

  /// No description provided for @class_medic_name.
  ///
  /// In de, this message translates to:
  /// **'Sanitäter'**
  String get class_medic_name;

  /// No description provided for @class_medic_ability.
  ///
  /// In de, this message translates to:
  /// **'Erste Hilfe: +1 Herz, heilt Verletzung und Gift beim nächsten Detektiv.'**
  String get class_medic_ability;

  /// No description provided for @class_medic_passive.
  ///
  /// In de, this message translates to:
  /// **'Wiederbelebt doppelt so schnell.'**
  String get class_medic_passive;

  /// No description provided for @ability_scan.
  ///
  /// In de, this message translates to:
  /// **'Adlerauge'**
  String get ability_scan;

  /// No description provided for @ability_calm.
  ///
  /// In de, this message translates to:
  /// **'Ruhe bewahren'**
  String get ability_calm;

  /// No description provided for @ability_scare.
  ///
  /// In de, this message translates to:
  /// **'Verscheuchen'**
  String get ability_scare;

  /// No description provided for @ability_sources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get ability_sources;

  /// No description provided for @ability_firstaid.
  ///
  /// In de, this message translates to:
  /// **'Erste Hilfe'**
  String get ability_firstaid;

  /// No description provided for @hat_fedora.
  ///
  /// In de, this message translates to:
  /// **'Fedora'**
  String get hat_fedora;

  /// No description provided for @hat_bowler.
  ///
  /// In de, this message translates to:
  /// **'Melone'**
  String get hat_bowler;

  /// No description provided for @hat_cap.
  ///
  /// In de, this message translates to:
  /// **'Schiebermütze'**
  String get hat_cap;

  /// No description provided for @hat_beret.
  ///
  /// In de, this message translates to:
  /// **'Baskenmütze'**
  String get hat_beret;

  /// No description provided for @hat_cloche.
  ///
  /// In de, this message translates to:
  /// **'Glockenhut'**
  String get hat_cloche;

  /// No description provided for @hat_top.
  ///
  /// In de, this message translates to:
  /// **'Zylinder'**
  String get hat_top;

  /// No description provided for @hat_none.
  ///
  /// In de, this message translates to:
  /// **'Ohne Hut'**
  String get hat_none;

  /// No description provided for @coat_name.
  ///
  /// In de, this message translates to:
  /// **'Mantel {n}'**
  String coat_name(int n);

  /// No description provided for @effect_caffeine.
  ///
  /// In de, this message translates to:
  /// **'Koffein'**
  String get effect_caffeine;

  /// No description provided for @effect_caffeine_desc.
  ///
  /// In de, this message translates to:
  /// **'Du läufst und suchst schneller.'**
  String get effect_caffeine_desc;

  /// No description provided for @effect_teamgeist.
  ///
  /// In de, this message translates to:
  /// **'Teamgeist'**
  String get effect_teamgeist;

  /// No description provided for @effect_teamgeist_desc.
  ///
  /// In de, this message translates to:
  /// **'In der Gruppe: schneller suchen, ruhige Nerven, Schutz vor dem Schatten.'**
  String get effect_teamgeist_desc;

  /// No description provided for @effect_adrenaline.
  ///
  /// In de, this message translates to:
  /// **'Adrenalin'**
  String get effect_adrenaline;

  /// No description provided for @effect_adrenaline_desc.
  ///
  /// In de, this message translates to:
  /// **'Ein kurzer Sprint – nichts wie weg!'**
  String get effect_adrenaline_desc;

  /// No description provided for @effect_eagle_eye.
  ///
  /// In de, this message translates to:
  /// **'Adlerauge'**
  String get effect_eagle_eye;

  /// No description provided for @effect_eagle_eye_desc.
  ///
  /// In de, this message translates to:
  /// **'Du siehst verborgene Spuren und suchst schneller.'**
  String get effect_eagle_eye_desc;

  /// No description provided for @effect_focused.
  ///
  /// In de, this message translates to:
  /// **'Fokussiert'**
  String get effect_focused;

  /// No description provided for @effect_focused_desc.
  ///
  /// In de, this message translates to:
  /// **'Deine Nerven erholen sich rasch, du suchst schneller.'**
  String get effect_focused_desc;

  /// No description provided for @effect_bright.
  ///
  /// In de, this message translates to:
  /// **'Helle Lampe'**
  String get effect_bright;

  /// No description provided for @effect_bright_desc.
  ///
  /// In de, this message translates to:
  /// **'Deine Lampe leuchtet weiter.'**
  String get effect_bright_desc;

  /// No description provided for @effect_hidden.
  ///
  /// In de, this message translates to:
  /// **'Versteckt'**
  String get effect_hidden;

  /// No description provided for @effect_hidden_desc.
  ///
  /// In de, this message translates to:
  /// **'Unsichtbar für den Schatten – aber du kannst dich nicht bewegen.'**
  String get effect_hidden_desc;

  /// No description provided for @effect_injured.
  ///
  /// In de, this message translates to:
  /// **'Verletzt'**
  String get effect_injured;

  /// No description provided for @effect_injured_desc.
  ///
  /// In de, this message translates to:
  /// **'Du bist langsamer.'**
  String get effect_injured_desc;

  /// No description provided for @effect_panic.
  ///
  /// In de, this message translates to:
  /// **'Panik'**
  String get effect_panic;

  /// No description provided for @effect_panic_desc.
  ///
  /// In de, this message translates to:
  /// **'Weniger Licht, langsameres Suchen. Bleib bei den anderen!'**
  String get effect_panic_desc;

  /// No description provided for @effect_poisoned.
  ///
  /// In de, this message translates to:
  /// **'Vergiftet'**
  String get effect_poisoned;

  /// No description provided for @effect_poisoned_desc.
  ///
  /// In de, this message translates to:
  /// **'Du verlierst jede Minute ein Herz. Ein Gegengift hilft.'**
  String get effect_poisoned_desc;

  /// No description provided for @effect_blinded.
  ///
  /// In de, this message translates to:
  /// **'Geblendet'**
  String get effect_blinded;

  /// No description provided for @effect_blinded_desc.
  ///
  /// In de, this message translates to:
  /// **'Du siehst kaum etwas.'**
  String get effect_blinded_desc;

  /// No description provided for @effect_suspicious.
  ///
  /// In de, this message translates to:
  /// **'Verdächtig'**
  String get effect_suspicious;

  /// No description provided for @effect_suspicious_desc.
  ///
  /// In de, this message translates to:
  /// **'Verdächtige verweigern das Gespräch mit dir.'**
  String get effect_suspicious_desc;

  /// No description provided for @effect_buff.
  ///
  /// In de, this message translates to:
  /// **'Vorteil'**
  String get effect_buff;

  /// No description provided for @effect_debuff.
  ///
  /// In de, this message translates to:
  /// **'Nachteil'**
  String get effect_debuff;

  /// No description provided for @item_coffee.
  ///
  /// In de, this message translates to:
  /// **'Kaffee'**
  String get item_coffee;

  /// No description provided for @item_coffee_desc.
  ///
  /// In de, this message translates to:
  /// **'Koffein: schneller laufen und suchen.'**
  String get item_coffee_desc;

  /// No description provided for @item_battery.
  ///
  /// In de, this message translates to:
  /// **'Batterie'**
  String get item_battery;

  /// No description provided for @item_battery_desc.
  ///
  /// In de, this message translates to:
  /// **'Deine Lampe leuchtet weiter.'**
  String get item_battery_desc;

  /// No description provided for @item_salts.
  ///
  /// In de, this message translates to:
  /// **'Riechsalz'**
  String get item_salts;

  /// No description provided for @item_salts_desc.
  ///
  /// In de, this message translates to:
  /// **'Fokus: Nerven beruhigen, Panik vertreiben.'**
  String get item_salts_desc;

  /// No description provided for @item_antidote.
  ///
  /// In de, this message translates to:
  /// **'Gegengift'**
  String get item_antidote;

  /// No description provided for @item_antidote_desc.
  ///
  /// In de, this message translates to:
  /// **'Heilt Vergiftung.'**
  String get item_antidote_desc;

  /// No description provided for @item_medkit.
  ///
  /// In de, this message translates to:
  /// **'Verbandskasten'**
  String get item_medkit;

  /// No description provided for @item_medkit_desc.
  ///
  /// In de, this message translates to:
  /// **'+1 Herz, heilt Verletzungen.'**
  String get item_medkit_desc;

  /// No description provided for @item_flare.
  ///
  /// In de, this message translates to:
  /// **'Leuchtfackel'**
  String get item_flare;

  /// No description provided for @item_flare_desc.
  ///
  /// In de, this message translates to:
  /// **'Vertreibt den Schatten in deiner Nähe.'**
  String get item_flare_desc;

  /// No description provided for @quick_come_here.
  ///
  /// In de, this message translates to:
  /// **'Komm her!'**
  String get quick_come_here;

  /// No description provided for @quick_found_clue.
  ///
  /// In de, this message translates to:
  /// **'Ich habe was gefunden!'**
  String get quick_found_clue;

  /// No description provided for @quick_help.
  ///
  /// In de, this message translates to:
  /// **'Hilfe!'**
  String get quick_help;

  /// No description provided for @quick_stay_together.
  ///
  /// In de, this message translates to:
  /// **'Bleibt zusammen!'**
  String get quick_stay_together;

  /// No description provided for @quick_split_up.
  ///
  /// In de, this message translates to:
  /// **'Wir teilen uns auf.'**
  String get quick_split_up;

  /// No description provided for @quick_suspect.
  ///
  /// In de, this message translates to:
  /// **'Ich habe einen Verdacht.'**
  String get quick_suspect;

  /// No description provided for @quick_danger.
  ///
  /// In de, this message translates to:
  /// **'Vorsicht, Gefahr!'**
  String get quick_danger;

  /// No description provided for @quick_thanks.
  ///
  /// In de, this message translates to:
  /// **'Danke!'**
  String get quick_thanks;

  /// No description provided for @emote_wave.
  ///
  /// In de, this message translates to:
  /// **'Winken'**
  String get emote_wave;

  /// No description provided for @emote_shock.
  ///
  /// In de, this message translates to:
  /// **'Schock'**
  String get emote_shock;

  /// No description provided for @emote_think.
  ///
  /// In de, this message translates to:
  /// **'Grübeln'**
  String get emote_think;

  /// No description provided for @emote_laugh.
  ///
  /// In de, this message translates to:
  /// **'Lachen'**
  String get emote_laugh;

  /// No description provided for @emote_scared.
  ///
  /// In de, this message translates to:
  /// **'Angst'**
  String get emote_scared;

  /// No description provided for @emote_thumbs.
  ///
  /// In de, this message translates to:
  /// **'Daumen hoch'**
  String get emote_thumbs;

  /// No description provided for @award_spurensucher.
  ///
  /// In de, this message translates to:
  /// **'Spurensucher'**
  String get award_spurensucher;

  /// No description provided for @award_spurensucher_desc.
  ///
  /// In de, this message translates to:
  /// **'Die meisten Hinweise gefunden.'**
  String get award_spurensucher_desc;

  /// No description provided for @award_lebensretter.
  ///
  /// In de, this message translates to:
  /// **'Lebensretter'**
  String get award_lebensretter;

  /// No description provided for @award_lebensretter_desc.
  ///
  /// In de, this message translates to:
  /// **'Die meisten Kollegen wiederbelebt.'**
  String get award_lebensretter_desc;

  /// No description provided for @award_kombinierer.
  ///
  /// In de, this message translates to:
  /// **'Kombinierer'**
  String get award_kombinierer;

  /// No description provided for @award_kombinierer_desc.
  ///
  /// In de, this message translates to:
  /// **'Die meisten Schlussfolgerungen gezogen.'**
  String get award_kombinierer_desc;

  /// No description provided for @award_ueberlebender.
  ///
  /// In de, this message translates to:
  /// **'Überlebender'**
  String get award_ueberlebender;

  /// No description provided for @award_ueberlebender_desc.
  ///
  /// In de, this message translates to:
  /// **'Nie zu Boden gegangen.'**
  String get award_ueberlebender_desc;

  /// No description provided for @award_geist.
  ///
  /// In de, this message translates to:
  /// **'Rastloser Geist'**
  String get award_geist;

  /// No description provided for @award_geist_desc.
  ///
  /// In de, this message translates to:
  /// **'Auch als Geist weiterermittelt.'**
  String get award_geist_desc;

  /// No description provided for @award_teamplayer.
  ///
  /// In de, this message translates to:
  /// **'Teamplayer'**
  String get award_teamplayer;

  /// No description provided for @award_teamplayer_desc.
  ///
  /// In de, this message translates to:
  /// **'Die meisten Hinweise geteilt.'**
  String get award_teamplayer_desc;

  /// No description provided for @rank_0.
  ///
  /// In de, this message translates to:
  /// **'Anwärter'**
  String get rank_0;

  /// No description provided for @rank_1.
  ///
  /// In de, this message translates to:
  /// **'Ermittler'**
  String get rank_1;

  /// No description provided for @rank_2.
  ///
  /// In de, this message translates to:
  /// **'Inspektor'**
  String get rank_2;

  /// No description provided for @rank_3.
  ///
  /// In de, this message translates to:
  /// **'Kommissar'**
  String get rank_3;

  /// No description provided for @rank_4.
  ///
  /// In de, this message translates to:
  /// **'Hauptkommissar'**
  String get rank_4;

  /// No description provided for @rank_5.
  ///
  /// In de, this message translates to:
  /// **'Legende'**
  String get rank_5;

  /// No description provided for @phase_lobby.
  ///
  /// In de, this message translates to:
  /// **'Lobby'**
  String get phase_lobby;

  /// No description provided for @phase_intro.
  ///
  /// In de, this message translates to:
  /// **'Einleitung'**
  String get phase_intro;

  /// No description provided for @phase_investigation.
  ///
  /// In de, this message translates to:
  /// **'Ermittlung'**
  String get phase_investigation;

  /// No description provided for @phase_council.
  ///
  /// In de, this message translates to:
  /// **'Beratung'**
  String get phase_council;

  /// No description provided for @phase_night.
  ///
  /// In de, this message translates to:
  /// **'Nacht'**
  String get phase_night;

  /// No description provided for @phase_accusation.
  ///
  /// In de, this message translates to:
  /// **'Anklage'**
  String get phase_accusation;

  /// No description provided for @phase_ending.
  ///
  /// In de, this message translates to:
  /// **'Abschluss'**
  String get phase_ending;

  /// No description provided for @hud_chapter.
  ///
  /// In de, this message translates to:
  /// **'Kapitel {n}/3'**
  String hud_chapter(int n);

  /// No description provided for @hud_notebook.
  ///
  /// In de, this message translates to:
  /// **'Notizbuch'**
  String get hud_notebook;

  /// No description provided for @hud_signals.
  ///
  /// In de, this message translates to:
  /// **'Signale'**
  String get hud_signals;

  /// No description provided for @hud_map.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get hud_map;

  /// No description provided for @hud_map_ping.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf die Karte, um einen Ort zu markieren ({left} übrig).'**
  String hud_map_ping(int left);

  /// No description provided for @hud_map_no_ping.
  ///
  /// In de, this message translates to:
  /// **'Keine Markierung mehr in diesem Kapitel.'**
  String get hud_map_no_ping;

  /// No description provided for @hud_emotes.
  ///
  /// In de, this message translates to:
  /// **'Gesten'**
  String get hud_emotes;

  /// No description provided for @hud_quick_chat.
  ///
  /// In de, this message translates to:
  /// **'Schnellchat'**
  String get hud_quick_chat;

  /// No description provided for @hud_nerves.
  ///
  /// In de, this message translates to:
  /// **'Nerven'**
  String get hud_nerves;

  /// No description provided for @hud_ability_ready.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get hud_ability_ready;

  /// No description provided for @hud_menu.
  ///
  /// In de, this message translates to:
  /// **'Menü'**
  String get hud_menu;

  /// No description provided for @hud_leave_title.
  ///
  /// In de, this message translates to:
  /// **'Fall verlassen?'**
  String get hud_leave_title;

  /// No description provided for @hud_leave_text.
  ///
  /// In de, this message translates to:
  /// **'Dein Fortschritt in diesem Fall geht verloren.'**
  String get hud_leave_text;

  /// No description provided for @hud_leave_confirm.
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get hud_leave_confirm;

  /// No description provided for @hud_disconnected.
  ///
  /// In de, this message translates to:
  /// **'Verbindung unterbrochen – verbinde neu …'**
  String get hud_disconnected;

  /// No description provided for @hud_inventory_empty.
  ///
  /// In de, this message translates to:
  /// **'Leerer Slot'**
  String get hud_inventory_empty;

  /// No description provided for @toast_clue_found.
  ///
  /// In de, this message translates to:
  /// **'Hinweis gefunden: {clue}'**
  String toast_clue_found(String clue);

  /// No description provided for @toast_hotspot_empty.
  ///
  /// In de, this message translates to:
  /// **'{player} war schneller – hier ist nichts mehr.'**
  String toast_hotspot_empty(String player);

  /// No description provided for @toast_nothing_found.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden: {place}'**
  String toast_nothing_found(String place);

  /// No description provided for @toast_clue_shared_me.
  ///
  /// In de, this message translates to:
  /// **'An die Beweiswand gepinnt: {clue}'**
  String toast_clue_shared_me(String clue);

  /// No description provided for @toast_clue_shared.
  ///
  /// In de, this message translates to:
  /// **'{player} hat einen Hinweis geteilt: {clue}'**
  String toast_clue_shared(String player, String clue);

  /// No description provided for @toast_clue_evolved.
  ///
  /// In de, this message translates to:
  /// **'Neue Erkenntnis: {clue}'**
  String toast_clue_evolved(String clue);

  /// No description provided for @toast_clue_lost.
  ///
  /// In de, this message translates to:
  /// **'Der Schatten hat Notizen zerstört: {clue}'**
  String toast_clue_lost(String clue);

  /// No description provided for @toast_clue_lost_damaged.
  ///
  /// In de, this message translates to:
  /// **'Der Schatten hat {clue} beschädigt – erneut ins Labor bringen.'**
  String toast_clue_lost_damaged(String clue);

  /// No description provided for @toast_clue_lost_stolen.
  ///
  /// In de, this message translates to:
  /// **'Der Schatten hat {clue} gestohlen – die Spur ist noch an ihrer Quelle.'**
  String toast_clue_lost_stolen(String clue);

  /// No description provided for @toast_clues_faded.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Eine Spur ist verblasst.} other{{count} Spuren sind verblasst.}}'**
  String toast_clues_faded(int count);

  /// No description provided for @toast_combo.
  ///
  /// In de, this message translates to:
  /// **'Schlussfolgerung: {combo}'**
  String toast_combo(String combo);

  /// No description provided for @toast_combo_fail.
  ///
  /// In de, this message translates to:
  /// **'Das passt nicht zusammen.'**
  String get toast_combo_fail;

  /// No description provided for @toast_refused_silenced.
  ///
  /// In de, this message translates to:
  /// **'{npc} will nicht mit dir reden.'**
  String toast_refused_silenced(String npc);

  /// No description provided for @toast_refused_dead.
  ///
  /// In de, this message translates to:
  /// **'{npc} wird nie wieder sprechen.'**
  String toast_refused_dead(String npc);

  /// No description provided for @toast_refused_busy.
  ///
  /// In de, this message translates to:
  /// **'{npc} spricht gerade mit jemand anderem.'**
  String toast_refused_busy(String npc);

  /// No description provided for @accuse_contradicted.
  ///
  /// In de, this message translates to:
  /// **'Widerspruch aufgedeckt'**
  String get accuse_contradicted;

  /// No description provided for @toast_contradiction.
  ///
  /// In de, this message translates to:
  /// **'Widerspruch! {npc} hat gelogen. Beweisstärke +1'**
  String toast_contradiction(String npc);

  /// No description provided for @toast_effect_on.
  ///
  /// In de, this message translates to:
  /// **'{effect}: {desc}'**
  String toast_effect_on(String effect, String desc);

  /// No description provided for @toast_effect_off.
  ///
  /// In de, this message translates to:
  /// **'{effect} lässt nach.'**
  String toast_effect_off(String effect);

  /// No description provided for @toast_attacked_me.
  ///
  /// In de, this message translates to:
  /// **'Du wurdest angegriffen!'**
  String get toast_attacked_me;

  /// No description provided for @toast_attacked.
  ///
  /// In de, this message translates to:
  /// **'{player} wurde angegriffen!'**
  String toast_attacked(String player);

  /// No description provided for @toast_downed_me.
  ///
  /// In de, this message translates to:
  /// **'Du bist niedergeschlagen!'**
  String get toast_downed_me;

  /// No description provided for @toast_downed.
  ///
  /// In de, this message translates to:
  /// **'{player} liegt am Boden – hilf!'**
  String toast_downed(String player);

  /// No description provided for @toast_revived.
  ///
  /// In de, this message translates to:
  /// **'{by} hat {player} wiederbelebt.'**
  String toast_revived(String by, String player);

  /// No description provided for @toast_revived_me.
  ///
  /// In de, this message translates to:
  /// **'{by} hat dich gerettet!'**
  String toast_revived_me(String by);

  /// No description provided for @toast_died.
  ///
  /// In de, this message translates to:
  /// **'Der Schatten hat {player} getötet.'**
  String toast_died(String player);

  /// No description provided for @toast_died_me.
  ///
  /// In de, this message translates to:
  /// **'Du bist gestorben … aber noch nicht fort.'**
  String get toast_died_me;

  /// No description provided for @toast_npc_killed.
  ///
  /// In de, this message translates to:
  /// **'Der Schatten hat {npc} getötet.'**
  String toast_npc_killed(String npc);

  /// No description provided for @toast_repelled_group.
  ///
  /// In de, this message translates to:
  /// **'Gemeinsam habt ihr den Schatten vertrieben!'**
  String get toast_repelled_group;

  /// No description provided for @toast_repelled_scare.
  ///
  /// In de, this message translates to:
  /// **'{player} hat den Schatten verscheucht!'**
  String toast_repelled_scare(String player);

  /// No description provided for @toast_repelled_flare.
  ///
  /// In de, this message translates to:
  /// **'Leuchtfackel! Der Schatten flieht.'**
  String get toast_repelled_flare;

  /// No description provided for @toast_shadow_near.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist ganz nah …'**
  String get toast_shadow_near;

  /// No description provided for @toast_lead_chosen.
  ///
  /// In de, this message translates to:
  /// **'Spur gewählt: {lead}'**
  String toast_lead_chosen(String lead);

  /// No description provided for @toast_ping.
  ///
  /// In de, this message translates to:
  /// **'{player} hat einen Ort markiert.'**
  String toast_ping(String player);

  /// No description provided for @toast_signal.
  ///
  /// In de, this message translates to:
  /// **'{player}: {text}'**
  String toast_signal(String player, String text);

  /// No description provided for @toast_item_picked.
  ///
  /// In de, this message translates to:
  /// **'Eingesteckt: {item}'**
  String toast_item_picked(String item);

  /// No description provided for @toast_item_used_me.
  ///
  /// In de, this message translates to:
  /// **'{item} benutzt.'**
  String toast_item_used_me(String item);

  /// No description provided for @toast_item_used.
  ///
  /// In de, this message translates to:
  /// **'{player} benutzt: {item}'**
  String toast_item_used(String player, String item);

  /// No description provided for @toast_ability_me.
  ///
  /// In de, this message translates to:
  /// **'{ability} aktiviert.'**
  String toast_ability_me(String ability);

  /// No description provided for @toast_ability.
  ///
  /// In de, this message translates to:
  /// **'{player} nutzt {ability}.'**
  String toast_ability(String player, String ability);

  /// No description provided for @toast_sources.
  ///
  /// In de, this message translates to:
  /// **'Quelle markiert: {place}'**
  String toast_sources(String place);

  /// No description provided for @toast_lab_done.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Labor: nichts zu analysieren.} =1{Labor: ein Hinweis analysiert.} other{Labor: {count} Hinweise analysiert.}}'**
  String toast_lab_done(int count);

  /// No description provided for @toast_hidden.
  ///
  /// In de, this message translates to:
  /// **'Du versteckst dich.'**
  String get toast_hidden;

  /// No description provided for @toast_unhidden.
  ///
  /// In de, this message translates to:
  /// **'Du verlässt das Versteck.'**
  String get toast_unhidden;

  /// No description provided for @toast_phase.
  ///
  /// In de, this message translates to:
  /// **'{phase} · Kapitel {chapter}'**
  String toast_phase(String phase, int chapter);

  /// No description provided for @intro_ready.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get intro_ready;

  /// No description provided for @intro_waiting.
  ///
  /// In de, this message translates to:
  /// **'Warte auf die anderen …'**
  String get intro_waiting;

  /// No description provided for @intro_victim.
  ///
  /// In de, this message translates to:
  /// **'Das Opfer'**
  String get intro_victim;

  /// No description provided for @intro_tap_to_skip.
  ///
  /// In de, this message translates to:
  /// **'Tippen, um den Text sofort zu zeigen'**
  String get intro_tap_to_skip;

  /// No description provided for @notebook_title.
  ///
  /// In de, this message translates to:
  /// **'Notizbuch'**
  String get notebook_title;

  /// No description provided for @notebook_mine.
  ///
  /// In de, this message translates to:
  /// **'Meine Hinweise'**
  String get notebook_mine;

  /// No description provided for @notebook_board.
  ///
  /// In de, this message translates to:
  /// **'Beweiswand'**
  String get notebook_board;

  /// No description provided for @notebook_empty_mine.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Hinweise. Durchsuche Orte und befrage Verdächtige.'**
  String get notebook_empty_mine;

  /// No description provided for @notebook_empty_board.
  ///
  /// In de, this message translates to:
  /// **'Die Wand ist leer. Teile Hinweise, damit das ganze Team sie sieht.'**
  String get notebook_empty_board;

  /// No description provided for @notebook_share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get notebook_share;

  /// No description provided for @notebook_share_hint.
  ///
  /// In de, this message translates to:
  /// **'Ungeteilte Notizen sind nachts in Gefahr.'**
  String get notebook_share_hint;

  /// No description provided for @notebook_combine.
  ///
  /// In de, this message translates to:
  /// **'Kombinieren'**
  String get notebook_combine;

  /// No description provided for @notebook_combine_hint.
  ///
  /// In de, this message translates to:
  /// **'Wähle zwei Hinweise, die zusammenpassen.'**
  String get notebook_combine_hint;

  /// No description provided for @notebook_combine_hint_second.
  ///
  /// In de, this message translates to:
  /// **'Und jetzt den zweiten Hinweis.'**
  String get notebook_combine_hint_second;

  /// No description provided for @notebook_deductions.
  ///
  /// In de, this message translates to:
  /// **'Schlussfolgerungen'**
  String get notebook_deductions;

  /// No description provided for @notebook_strength.
  ///
  /// In de, this message translates to:
  /// **'Beweisstärke'**
  String get notebook_strength;

  /// No description provided for @notebook_strength_hint.
  ///
  /// In de, this message translates to:
  /// **'Überführt ab {solid}, lückenlos ab {perfect}.'**
  String notebook_strength_hint(int solid, int perfect);

  /// No description provided for @notebook_contradictions.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Widersprüche} =1{1 Widerspruch} other{{count} Widersprüche}}'**
  String notebook_contradictions(int count);

  /// No description provided for @clue_kind_trait.
  ///
  /// In de, this message translates to:
  /// **'Merkmal'**
  String get clue_kind_trait;

  /// No description provided for @clue_kind_motive.
  ///
  /// In de, this message translates to:
  /// **'Motiv'**
  String get clue_kind_motive;

  /// No description provided for @clue_kind_weapon.
  ///
  /// In de, this message translates to:
  /// **'Tatwaffe'**
  String get clue_kind_weapon;

  /// No description provided for @clue_kind_alibi.
  ///
  /// In de, this message translates to:
  /// **'Alibi'**
  String get clue_kind_alibi;

  /// No description provided for @clue_kind_story.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get clue_kind_story;

  /// No description provided for @clue_kind_sighting.
  ///
  /// In de, this message translates to:
  /// **'Sichtung'**
  String get clue_kind_sighting;

  /// No description provided for @clue_kind_other.
  ///
  /// In de, this message translates to:
  /// **'Hinweis'**
  String get clue_kind_other;

  /// No description provided for @clue_pending_lab.
  ///
  /// In de, this message translates to:
  /// **'Im Labor analysieren'**
  String get clue_pending_lab;

  /// No description provided for @clue_pending_time.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis in Kapitel {chapter}'**
  String clue_pending_time(int chapter);

  /// No description provided for @clue_sighting_title.
  ///
  /// In de, this message translates to:
  /// **'Sichtung'**
  String get clue_sighting_title;

  /// No description provided for @clue_sighting.
  ///
  /// In de, this message translates to:
  /// **'Sichtung: {trait} – {value}'**
  String clue_sighting(String trait, String value);

  /// No description provided for @clue_found_by.
  ///
  /// In de, this message translates to:
  /// **'gefunden von {player}'**
  String clue_found_by(String player);

  /// No description provided for @clue_shared_by.
  ///
  /// In de, this message translates to:
  /// **'geteilt von {player}'**
  String clue_shared_by(String player);

  /// No description provided for @clue_unknown.
  ///
  /// In de, this message translates to:
  /// **'Ein unleserlicher Zettel.'**
  String get clue_unknown;

  /// No description provided for @dialogue_topics.
  ///
  /// In de, this message translates to:
  /// **'Befragen'**
  String get dialogue_topics;

  /// No description provided for @topic_alibi.
  ///
  /// In de, this message translates to:
  /// **'Wo waren Sie zur Tatzeit?'**
  String get topic_alibi;

  /// No description provided for @topic_victim.
  ///
  /// In de, this message translates to:
  /// **'Was wissen Sie über das Opfer?'**
  String get topic_victim;

  /// No description provided for @topic_observation.
  ///
  /// In de, this message translates to:
  /// **'Ist Ihnen etwas aufgefallen?'**
  String get topic_observation;

  /// No description provided for @topic_rumor.
  ///
  /// In de, this message translates to:
  /// **'Was erzählt man sich?'**
  String get topic_rumor;

  /// No description provided for @topic_alibi_short.
  ///
  /// In de, this message translates to:
  /// **'Alibi'**
  String get topic_alibi_short;

  /// No description provided for @topic_victim_short.
  ///
  /// In de, this message translates to:
  /// **'Opfer'**
  String get topic_victim_short;

  /// No description provided for @topic_observation_short.
  ///
  /// In de, this message translates to:
  /// **'Beobachtung'**
  String get topic_observation_short;

  /// No description provided for @topic_rumor_short.
  ///
  /// In de, this message translates to:
  /// **'Gerüchte'**
  String get topic_rumor_short;

  /// No description provided for @dialogue_lie.
  ///
  /// In de, this message translates to:
  /// **'Lüge erkannt'**
  String get dialogue_lie;

  /// No description provided for @dialogue_present.
  ///
  /// In de, this message translates to:
  /// **'Beweis vorlegen'**
  String get dialogue_present;

  /// No description provided for @dialogue_present_title.
  ///
  /// In de, this message translates to:
  /// **'Welchen Beweis legst du vor?'**
  String get dialogue_present_title;

  /// No description provided for @dialogue_present_empty.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch nichts in der Hand.'**
  String get dialogue_present_empty;

  /// No description provided for @dialogue_reaction_nervous.
  ///
  /// In de, this message translates to:
  /// **'wirkt nervös'**
  String get dialogue_reaction_nervous;

  /// No description provided for @dialogue_reaction_annoyed.
  ///
  /// In de, this message translates to:
  /// **'reagiert gereizt'**
  String get dialogue_reaction_annoyed;

  /// No description provided for @dialogue_reaction_neutral.
  ///
  /// In de, this message translates to:
  /// **'zeigt keine Regung.'**
  String get dialogue_reaction_neutral;

  /// No description provided for @dialogue_heard.
  ///
  /// In de, this message translates to:
  /// **'schon gehört'**
  String get dialogue_heard;

  /// No description provided for @dialogue_heard_team.
  ///
  /// In de, this message translates to:
  /// **'Team hat gefragt'**
  String get dialogue_heard_team;

  /// No description provided for @dialogue_team_note.
  ///
  /// In de, this message translates to:
  /// **'Dein Team hat {name} schon befragt ({topics}). Frag selbst nach, um die Antworten zu hören.'**
  String dialogue_team_note(String name, String topics);

  /// No description provided for @dialogue_new_clue.
  ///
  /// In de, this message translates to:
  /// **'Neuer Hinweis: {clue}'**
  String dialogue_new_clue(String clue);

  /// No description provided for @dialogue_profile.
  ///
  /// In de, this message translates to:
  /// **'Steckbrief'**
  String get dialogue_profile;

  /// No description provided for @dialogue_presented.
  ///
  /// In de, this message translates to:
  /// **'Du legst vor: {clue}'**
  String dialogue_presented(String clue);

  /// No description provided for @council_title.
  ///
  /// In de, this message translates to:
  /// **'Beratung'**
  String get council_title;

  /// No description provided for @council_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Welcher Spur folgt ihr als Nächstes?'**
  String get council_subtitle;

  /// No description provided for @council_vote.
  ///
  /// In de, this message translates to:
  /// **'Dafür stimmen'**
  String get council_vote;

  /// No description provided for @council_your_vote.
  ///
  /// In de, this message translates to:
  /// **'Deine Stimme'**
  String get council_your_vote;

  /// No description provided for @council_no_leads.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Spuren – die Nacht kommt trotzdem.'**
  String get council_no_leads;

  /// No description provided for @council_chosen.
  ///
  /// In de, this message translates to:
  /// **'Bisher verfolgt'**
  String get council_chosen;

  /// No description provided for @council_from_combo.
  ///
  /// In de, this message translates to:
  /// **'Aus einer Schlussfolgerung'**
  String get council_from_combo;

  /// No description provided for @night_title.
  ///
  /// In de, this message translates to:
  /// **'Die Nacht bricht herein'**
  String get night_title;

  /// No description provided for @night_hint.
  ///
  /// In de, this message translates to:
  /// **'Bleibt zusammen. Licht schützt.'**
  String get night_hint;

  /// No description provided for @downed_title.
  ///
  /// In de, this message translates to:
  /// **'Niedergeschlagen'**
  String get downed_title;

  /// No description provided for @downed_text.
  ///
  /// In de, this message translates to:
  /// **'Ein Teammitglied muss dich wiederbeleben – bevor die Zeit abläuft.'**
  String get downed_text;

  /// No description provided for @downed_help.
  ///
  /// In de, this message translates to:
  /// **'Hilfe rufen'**
  String get downed_help;

  /// No description provided for @downed_seconds.
  ///
  /// In de, this message translates to:
  /// **'{s} s'**
  String downed_seconds(int s);

  /// No description provided for @ghost_title.
  ///
  /// In de, this message translates to:
  /// **'Du bist ein Geist'**
  String get ghost_title;

  /// No description provided for @ghost_text.
  ///
  /// In de, this message translates to:
  /// **'Finde Echo-Spuren – nur du kannst sie sehen. Du hast einen Spuk-Ping.'**
  String get ghost_text;

  /// No description provided for @accuse_title.
  ///
  /// In de, this message translates to:
  /// **'Die Anklage'**
  String get accuse_title;

  /// No description provided for @accuse_subtitle.
  ///
  /// In de, this message translates to:
  /// **'Wer war es, warum und womit?'**
  String get accuse_subtitle;

  /// No description provided for @accuse_who.
  ///
  /// In de, this message translates to:
  /// **'Täter'**
  String get accuse_who;

  /// No description provided for @accuse_why.
  ///
  /// In de, this message translates to:
  /// **'Motiv'**
  String get accuse_why;

  /// No description provided for @accuse_how.
  ///
  /// In de, this message translates to:
  /// **'Tatwaffe'**
  String get accuse_how;

  /// No description provided for @accuse_optional.
  ///
  /// In de, this message translates to:
  /// **'optional – stärkt das Urteil'**
  String get accuse_optional;

  /// No description provided for @accuse_submit.
  ///
  /// In de, this message translates to:
  /// **'Anklage erheben'**
  String get accuse_submit;

  /// No description provided for @accuse_update.
  ///
  /// In de, this message translates to:
  /// **'Anklage ändern'**
  String get accuse_update;

  /// No description provided for @accuse_submitted.
  ///
  /// In de, this message translates to:
  /// **'Deine Anklage liegt vor. Ihr könnt sie bis zum Ende ändern.'**
  String get accuse_submitted;

  /// No description provided for @accuse_pick_culprit.
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst einen Täter.'**
  String get accuse_pick_culprit;

  /// No description provided for @accuse_open_notebook.
  ///
  /// In de, this message translates to:
  /// **'Beweise ansehen'**
  String get accuse_open_notebook;

  /// No description provided for @accuse_dead.
  ///
  /// In de, this message translates to:
  /// **'tot'**
  String get accuse_dead;

  /// No description provided for @ending_case_closed.
  ///
  /// In de, this message translates to:
  /// **'Akte geschlossen'**
  String get ending_case_closed;

  /// No description provided for @ending_truth.
  ///
  /// In de, this message translates to:
  /// **'Die Wahrheit'**
  String get ending_truth;

  /// No description provided for @ending_accusation.
  ///
  /// In de, this message translates to:
  /// **'Eure Anklage'**
  String get ending_accusation;

  /// No description provided for @ending_resolution.
  ///
  /// In de, this message translates to:
  /// **'Auflösung'**
  String get ending_resolution;

  /// No description provided for @ending_culprit.
  ///
  /// In de, this message translates to:
  /// **'Täter'**
  String get ending_culprit;

  /// No description provided for @ending_motive.
  ///
  /// In de, this message translates to:
  /// **'Motiv'**
  String get ending_motive;

  /// No description provided for @ending_weapon.
  ///
  /// In de, this message translates to:
  /// **'Waffe'**
  String get ending_weapon;

  /// No description provided for @ending_none.
  ///
  /// In de, this message translates to:
  /// **'—'**
  String get ending_none;

  /// No description provided for @ending_strength.
  ///
  /// In de, this message translates to:
  /// **'Beweisstärke'**
  String get ending_strength;

  /// No description provided for @ending_team.
  ///
  /// In de, this message translates to:
  /// **'Das Team'**
  String get ending_team;

  /// No description provided for @ending_epilogue.
  ///
  /// In de, this message translates to:
  /// **'Epilog'**
  String get ending_epilogue;

  /// No description provided for @ending_secret.
  ///
  /// In de, this message translates to:
  /// **'Geheimes Ende'**
  String get ending_secret;

  /// No description provided for @ending_awards.
  ///
  /// In de, this message translates to:
  /// **'Auszeichnungen'**
  String get ending_awards;

  /// No description provided for @ending_no_awards.
  ///
  /// In de, this message translates to:
  /// **'Diesmal keine Auszeichnungen.'**
  String get ending_no_awards;

  /// No description provided for @ending_xp.
  ///
  /// In de, this message translates to:
  /// **'Erfahrung'**
  String get ending_xp;

  /// No description provided for @ending_rank_up.
  ///
  /// In de, this message translates to:
  /// **'Beförderung: {rank}!'**
  String ending_rank_up(String rank);

  /// No description provided for @ending_unlocked.
  ///
  /// In de, this message translates to:
  /// **'Freigeschaltet'**
  String get ending_unlocked;

  /// No description provided for @ending_achievement.
  ///
  /// In de, this message translates to:
  /// **'Erfolg errungen'**
  String get ending_achievement;

  /// No description provided for @ending_new_ending.
  ///
  /// In de, this message translates to:
  /// **'Neues Ende entdeckt!'**
  String get ending_new_ending;

  /// No description provided for @ending_known_ending.
  ///
  /// In de, this message translates to:
  /// **'Dieses Ende kennst du bereits.'**
  String get ending_known_ending;

  /// No description provided for @ending_collection_count.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Ende in deiner Sammlung} other{{count} Enden in deiner Sammlung}}'**
  String ending_collection_count(int count);

  /// No description provided for @ending_new_case.
  ///
  /// In de, this message translates to:
  /// **'Neuer Fall'**
  String get ending_new_case;

  /// No description provided for @ending_hub.
  ///
  /// In de, this message translates to:
  /// **'Zum Hub'**
  String get ending_hub;

  /// No description provided for @ending_rematch.
  ///
  /// In de, this message translates to:
  /// **'Neuer Fall in diesem Raum'**
  String get ending_rematch;

  /// No description provided for @ending_rematch_title.
  ///
  /// In de, this message translates to:
  /// **'Welcher Fall als Nächstes?'**
  String get ending_rematch_title;

  /// No description provided for @ending_rematch_text.
  ///
  /// In de, this message translates to:
  /// **'Alle im Raum ermitteln gemeinsam weiter.'**
  String get ending_rematch_text;

  /// No description provided for @ending_wait_host.
  ///
  /// In de, this message translates to:
  /// **'Der Gastgeber kann einen neuen Fall in diesem Raum starten.'**
  String get ending_wait_host;

  /// No description provided for @ending_survivors.
  ///
  /// In de, this message translates to:
  /// **'Überlebende: {names}'**
  String ending_survivors(String names);

  /// No description provided for @ending_daily_bonus.
  ///
  /// In de, this message translates to:
  /// **'Fall des Tages'**
  String get ending_daily_bonus;

  /// No description provided for @ending_streak.
  ///
  /// In de, this message translates to:
  /// **'Serie'**
  String get ending_streak;

  /// No description provided for @verdict_stamp_perfect.
  ///
  /// In de, this message translates to:
  /// **'Lückenlos'**
  String get verdict_stamp_perfect;

  /// No description provided for @verdict_stamp_solid.
  ///
  /// In de, this message translates to:
  /// **'Gelöst'**
  String get verdict_stamp_solid;

  /// No description provided for @verdict_stamp_partial.
  ///
  /// In de, this message translates to:
  /// **'Knapp'**
  String get verdict_stamp_partial;

  /// No description provided for @verdict_stamp_wrong.
  ///
  /// In de, this message translates to:
  /// **'Fehlurteil'**
  String get verdict_stamp_wrong;

  /// No description provided for @verdict_stamp_unsolved.
  ///
  /// In de, this message translates to:
  /// **'Ungelöst'**
  String get verdict_stamp_unsolved;

  /// No description provided for @team_all.
  ///
  /// In de, this message translates to:
  /// **'Alle überlebt'**
  String get team_all;

  /// No description provided for @team_some.
  ///
  /// In de, this message translates to:
  /// **'Mit Verlusten'**
  String get team_some;

  /// No description provided for @team_lone.
  ///
  /// In de, this message translates to:
  /// **'Einer blieb'**
  String get team_lone;

  /// No description provided for @team_none.
  ///
  /// In de, this message translates to:
  /// **'Keiner überlebte'**
  String get team_none;

  /// No description provided for @collection_title.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get collection_title;

  /// No description provided for @collection_endings.
  ///
  /// In de, this message translates to:
  /// **'Enden'**
  String get collection_endings;

  /// No description provided for @collection_achievements.
  ///
  /// In de, this message translates to:
  /// **'Erfolge'**
  String get collection_achievements;

  /// No description provided for @collection_discovered.
  ///
  /// In de, this message translates to:
  /// **'{count} entdeckt'**
  String collection_discovered(int count);

  /// No description provided for @collection_no_endings.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Ende entdeckt. Löse diese Akte!'**
  String get collection_no_endings;

  /// No description provided for @collection_grid.
  ///
  /// In de, this message translates to:
  /// **'Urteil × Team'**
  String get collection_grid;

  /// No description provided for @collection_secret.
  ///
  /// In de, this message translates to:
  /// **'Geheimnis'**
  String get collection_secret;

  /// No description provided for @collection_achievements_count.
  ///
  /// In de, this message translates to:
  /// **'{done} von {total} errungen'**
  String collection_achievements_count(int done, int total);

  /// No description provided for @profile_title.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profile_title;

  /// No description provided for @profile_record.
  ///
  /// In de, this message translates to:
  /// **'Dienstakte'**
  String get profile_record;

  /// No description provided for @profile_classes.
  ///
  /// In de, this message translates to:
  /// **'Klassen'**
  String get profile_classes;

  /// No description provided for @profile_hats.
  ///
  /// In de, this message translates to:
  /// **'Hüte'**
  String get profile_hats;

  /// No description provided for @profile_coats.
  ///
  /// In de, this message translates to:
  /// **'Mäntel'**
  String get profile_coats;

  /// No description provided for @profile_next_rank.
  ///
  /// In de, this message translates to:
  /// **'Nächster Rang: {rank}'**
  String profile_next_rank(String rank);

  /// No description provided for @stat_cases.
  ///
  /// In de, this message translates to:
  /// **'Fälle'**
  String get stat_cases;

  /// No description provided for @stat_solved.
  ///
  /// In de, this message translates to:
  /// **'Gelöst'**
  String get stat_solved;

  /// No description provided for @stat_perfect.
  ///
  /// In de, this message translates to:
  /// **'Lückenlos'**
  String get stat_perfect;

  /// No description provided for @stat_revives.
  ///
  /// In de, this message translates to:
  /// **'Rettungen'**
  String get stat_revives;

  /// No description provided for @stat_combos.
  ///
  /// In de, this message translates to:
  /// **'Kombinationen'**
  String get stat_combos;

  /// No description provided for @stat_best_streak.
  ///
  /// In de, this message translates to:
  /// **'Beste Serie'**
  String get stat_best_streak;

  /// No description provided for @ach_first_case.
  ///
  /// In de, this message translates to:
  /// **'Erste Akte'**
  String get ach_first_case;

  /// No description provided for @ach_first_case_desc.
  ///
  /// In de, this message translates to:
  /// **'Schließe deinen ersten Fall ab.'**
  String get ach_first_case_desc;

  /// No description provided for @ach_perfect.
  ///
  /// In de, this message translates to:
  /// **'Lückenlos'**
  String get ach_perfect;

  /// No description provided for @ach_perfect_desc.
  ///
  /// In de, this message translates to:
  /// **'Erreiche ein perfektes Urteil.'**
  String get ach_perfect_desc;

  /// No description provided for @ach_all_survived.
  ///
  /// In de, this message translates to:
  /// **'Keiner bleibt zurück'**
  String get ach_all_survived;

  /// No description provided for @ach_all_survived_desc.
  ///
  /// In de, this message translates to:
  /// **'Alle Ermittler überleben einen Fall.'**
  String get ach_all_survived_desc;

  /// No description provided for @ach_revive3.
  ///
  /// In de, this message translates to:
  /// **'Schutzengel'**
  String get ach_revive3;

  /// No description provided for @ach_revive3_desc.
  ///
  /// In de, this message translates to:
  /// **'Belebe insgesamt drei Kollegen wieder.'**
  String get ach_revive3_desc;

  /// No description provided for @ach_secret.
  ///
  /// In de, this message translates to:
  /// **'Das Geheimnis'**
  String get ach_secret;

  /// No description provided for @ach_secret_desc.
  ///
  /// In de, this message translates to:
  /// **'Entdecke ein geheimes Ende.'**
  String get ach_secret_desc;

  /// No description provided for @ach_all_scenarios.
  ///
  /// In de, this message translates to:
  /// **'Alle Akten geschlossen'**
  String get ach_all_scenarios;

  /// No description provided for @ach_all_scenarios_desc.
  ///
  /// In de, this message translates to:
  /// **'Löse jedes Szenario mindestens einmal.'**
  String get ach_all_scenarios_desc;

  /// No description provided for @ach_streak5.
  ///
  /// In de, this message translates to:
  /// **'Stammgast im Präsidium'**
  String get ach_streak5;

  /// No description provided for @ach_streak5_desc.
  ///
  /// In de, this message translates to:
  /// **'Ermittle fünf Tage in Folge.'**
  String get ach_streak5_desc;

  /// No description provided for @ach_ghost_helper.
  ///
  /// In de, this message translates to:
  /// **'Stimme aus dem Jenseits'**
  String get ach_ghost_helper;

  /// No description provided for @ach_ghost_helper_desc.
  ///
  /// In de, this message translates to:
  /// **'Hilf deinem Team als Geist.'**
  String get ach_ghost_helper_desc;

  /// No description provided for @ach_online.
  ///
  /// In de, this message translates to:
  /// **'Im Team'**
  String get ach_online;

  /// No description provided for @ach_online_desc.
  ///
  /// In de, this message translates to:
  /// **'Spiele einen Fall online.'**
  String get ach_online_desc;

  /// No description provided for @ach_combos10.
  ///
  /// In de, this message translates to:
  /// **'Meisterkombinierer'**
  String get ach_combos10;

  /// No description provided for @ach_combos10_desc.
  ///
  /// In de, this message translates to:
  /// **'Ziehe insgesamt zehn Schlussfolgerungen.'**
  String get ach_combos10_desc;

  /// No description provided for @error_unknown_scenario.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte ist unbekannt.'**
  String get error_unknown_scenario;

  /// No description provided for @error_nothing_to_analyze.
  ///
  /// In de, this message translates to:
  /// **'Nichts zu analysieren – bring ungeklärte Hinweise mit.'**
  String get error_nothing_to_analyze;

  /// No description provided for @error_nothing_to_scare.
  ///
  /// In de, this message translates to:
  /// **'Hier ist nichts, das man verscheuchen könnte.'**
  String get error_nothing_to_scare;

  /// No description provided for @error_nothing_left.
  ///
  /// In de, this message translates to:
  /// **'Hier ist nichts mehr zu holen.'**
  String get error_nothing_left;

  /// No description provided for @error_nothing_to_heal.
  ///
  /// In de, this message translates to:
  /// **'Niemand in der Nähe braucht Hilfe.'**
  String get error_nothing_to_heal;

  /// No description provided for @error_not_needed.
  ///
  /// In de, this message translates to:
  /// **'Das brauchst du gerade nicht.'**
  String get error_not_needed;

  /// No description provided for @error_no_pings.
  ///
  /// In de, this message translates to:
  /// **'Keine Markierung mehr in diesem Kapitel.'**
  String get error_no_pings;

  /// No description provided for @error_not_on_board.
  ///
  /// In de, this message translates to:
  /// **'Dieser Hinweis hängt nicht an der Beweiswand.'**
  String get error_not_on_board;

  /// No description provided for @item_trace.
  ///
  /// In de, this message translates to:
  /// **'Schattenspur'**
  String get item_trace;

  /// No description provided for @item_trace_desc.
  ///
  /// In de, this message translates to:
  /// **'Hier war der Schatten. Vielleicht hat er etwas verloren.'**
  String get item_trace_desc;

  /// No description provided for @toast_trace_search.
  ///
  /// In de, this message translates to:
  /// **'Du untersuchst die Spur des Schattens …'**
  String get toast_trace_search;

  /// No description provided for @toast_trace_nothing.
  ///
  /// In de, this message translates to:
  /// **'Nur Schlamm und Asche.'**
  String get toast_trace_nothing;

  /// No description provided for @toast_revived_dawn_me.
  ///
  /// In de, this message translates to:
  /// **'Im Morgengrauen findet man dich.'**
  String get toast_revived_dawn_me;

  /// No description provided for @toast_revived_dawn.
  ///
  /// In de, this message translates to:
  /// **'Im Morgengrauen wird {player} gefunden.'**
  String toast_revived_dawn(String player);

  /// No description provided for @dialogue_not_questioned.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht befragt'**
  String get dialogue_not_questioned;

  /// No description provided for @dialogue_traits_hint.
  ///
  /// In de, this message translates to:
  /// **'Merkmale – vergleiche sie mit deinen Hinweisen.'**
  String get dialogue_traits_hint;

  /// No description provided for @error_server_error.
  ///
  /// In de, this message translates to:
  /// **'Der Server hat ein Problem. Versuch es gleich noch einmal.'**
  String get error_server_error;

  /// No description provided for @error_server_full.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist gerade voll. Versuch es später erneut.'**
  String get error_server_full;

  /// No description provided for @error_timeout.
  ///
  /// In de, this message translates to:
  /// **'Der Server antwortet nicht.'**
  String get error_timeout;

  /// No description provided for @error_unreachable.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist nicht erreichbar. Prüfe deine Verbindung.'**
  String get error_unreachable;

  /// No description provided for @error_replaced.
  ///
  /// In de, this message translates to:
  /// **'Du hast diesen Raum auf einem anderen Gerät betreten.'**
  String get error_replaced;

  /// No description provided for @error_bad_message.
  ///
  /// In de, this message translates to:
  /// **'Verbindungsfehler (ungültige Nachricht).'**
  String get error_bad_message;

  /// No description provided for @error_not_in_room.
  ///
  /// In de, this message translates to:
  /// **'Du bist nicht mehr in diesem Raum.'**
  String get error_not_in_room;

  /// No description provided for @error_protocol.
  ///
  /// In de, this message translates to:
  /// **'Diese App-Version passt nicht zum Server.'**
  String get error_protocol;

  /// No description provided for @error_room_lost.
  ///
  /// In de, this message translates to:
  /// **'Der Raum ist verloren gegangen.'**
  String get error_room_lost;

  /// No description provided for @party_zug_auftakt.
  ///
  /// In de, this message translates to:
  /// **'Die Lupe bereitlegen'**
  String get party_zug_auftakt;

  /// No description provided for @party_zug_auftakt_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Eine kleine Probe, bevor die Ermittlung beginnt. Kein Hinweis, keine Wertung, keine Nachtminuten.'**
  String get party_zug_auftakt_hinweis;

  /// No description provided for @party_zug_auftakt_fertig.
  ///
  /// In de, this message translates to:
  /// **'Bereit für die Ermittlung'**
  String get party_zug_auftakt_fertig;

  /// No description provided for @party_zug_auftakt_weiter.
  ///
  /// In de, this message translates to:
  /// **'Zur ersten Entscheidung'**
  String get party_zug_auftakt_weiter;

  /// No description provided for @party_zug_weg.
  ///
  /// In de, this message translates to:
  /// **'Unterwegs zum gewählten Ziel'**
  String get party_zug_weg;

  /// No description provided for @party_zug_suchen.
  ///
  /// In de, this message translates to:
  /// **'Die gewählte Stelle untersuchen'**
  String get party_zug_suchen;

  /// No description provided for @party_zug_befragen.
  ///
  /// In de, this message translates to:
  /// **'Das Gespräch führen'**
  String get party_zug_befragen;

  /// No description provided for @party_zug_umweg.
  ///
  /// In de, this message translates to:
  /// **'Ein anderer Zugang zur selben Quelle'**
  String get party_zug_umweg;

  /// No description provided for @party_zug_kurz.
  ///
  /// In de, this message translates to:
  /// **'Szene abkürzen'**
  String get party_zug_kurz;

  /// No description provided for @party_zug_blockiert.
  ///
  /// In de, this message translates to:
  /// **'Der Weg ist nicht erreichbar. Die Untersuchung bleibt offen.'**
  String get party_zug_blockiert;

  /// No description provided for @party_zug_nachtzeit.
  ///
  /// In de, this message translates to:
  /// **'{min} Nachtminuten übrig'**
  String party_zug_nachtzeit(String min);

  /// No description provided for @party_zug_marken.
  ///
  /// In de, this message translates to:
  /// **'Marken: {zahl}'**
  String party_zug_marken(String zahl);

  /// No description provided for @party_zug_gruendlich.
  ///
  /// In de, this message translates to:
  /// **'Gründlich suchen · +2 auf den Wurf · 2 Nachtminuten mehr'**
  String get party_zug_gruendlich;

  /// No description provided for @party_zug_wuerfel.
  ///
  /// In de, this message translates to:
  /// **'Der Würfel'**
  String get party_zug_wuerfel;

  /// No description provided for @party_zug_pate.
  ///
  /// In de, this message translates to:
  /// **'Gib das Gerät an {name} – jetzt wird gewürfelt!'**
  String party_zug_pate(String name);

  /// No description provided for @party_zug_werfen.
  ///
  /// In de, this message translates to:
  /// **'Würfeln'**
  String get party_zug_werfen;

  /// No description provided for @party_zug_marke_einsetzen.
  ///
  /// In de, this message translates to:
  /// **'Eine Marke einsetzen · +1'**
  String get party_zug_marke_einsetzen;

  /// No description provided for @party_zug_marke_deckel.
  ///
  /// In de, this message translates to:
  /// **'Der Bonus liegt bereits bei +2. Keine Marke wird verbraucht.'**
  String get party_zug_marke_deckel;

  /// No description provided for @party_zug_chancen.
  ///
  /// In de, this message translates to:
  /// **'Vor dem Wurf · Bonus +{mod}'**
  String party_zug_chancen(String mod);

  /// No description provided for @party_zug_garantie.
  ///
  /// In de, this message translates to:
  /// **'Pech-Garantie: Dieser Anlauf gelingt mindestens teilweise.'**
  String get party_zug_garantie;

  /// No description provided for @party_zug_garantie_kurz.
  ///
  /// In de, this message translates to:
  /// **'Garantie'**
  String get party_zug_garantie_kurz;

  /// No description provided for @party_zug_erfolg.
  ///
  /// In de, this message translates to:
  /// **'Erfolg'**
  String get party_zug_erfolg;

  /// No description provided for @party_zug_teilerfolg.
  ///
  /// In de, this message translates to:
  /// **'Teilerfolg'**
  String get party_zug_teilerfolg;

  /// No description provided for @party_zug_pech.
  ///
  /// In de, this message translates to:
  /// **'Pech'**
  String get party_zug_pech;

  /// No description provided for @party_zug_erfolg_folge.
  ///
  /// In de, this message translates to:
  /// **'Der Fund wird frei. Du gewinnst 7 Nachtminuten.'**
  String get party_zug_erfolg_folge;

  /// No description provided for @party_zug_teilerfolg_folge.
  ///
  /// In de, this message translates to:
  /// **'Der Fund wird frei. Die Auswahl bleibt unverändert.'**
  String get party_zug_teilerfolg_folge;

  /// No description provided for @party_zug_pech_folge.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Fund. Eine Marke dazu; danach Nochmal oder Umweg.'**
  String get party_zug_pech_folge;

  /// No description provided for @party_zug_auftakt_folge.
  ///
  /// In de, this message translates to:
  /// **'Probewurf ohne Fund oder Zeitkosten. Pech schenkt eine Marke.'**
  String get party_zug_auftakt_folge;

  /// No description provided for @party_zug_rechnung.
  ///
  /// In de, this message translates to:
  /// **'2W6: {a} + {b} + {mod} = {summe} · Anlauf {anlauf}'**
  String party_zug_rechnung(
    String a,
    String b,
    String mod,
    String summe,
    String anlauf,
  );

  /// No description provided for @party_zug_tischruf.
  ///
  /// In de, this message translates to:
  /// **'Tischruf: Wie geht es weiter?'**
  String get party_zug_tischruf;

  /// No description provided for @party_zug_pech_szene.
  ///
  /// In de, this message translates to:
  /// **'Die Spur verläuft sich kurz. Die Quelle bleibt dieselbe. Glück im Unglück: eine Marke!'**
  String get party_zug_pech_szene;

  /// No description provided for @party_zug_nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal · 3 Nachtminuten'**
  String get party_zug_nochmal;

  /// No description provided for @party_zug_umweg_knopf.
  ///
  /// In de, this message translates to:
  /// **'Umweg · 3 Nachtminuten'**
  String get party_zug_umweg_knopf;

  /// No description provided for @party_zug_fund_zeigen.
  ///
  /// In de, this message translates to:
  /// **'Fund ansehen'**
  String get party_zug_fund_zeigen;

  /// No description provided for @party_zug_protokoll.
  ///
  /// In de, this message translates to:
  /// **'Würfelprotokoll'**
  String get party_zug_protokoll;

  /// No description provided for @party_zug_kein_wurf.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Wurf. Befragungen bleiben würfelfrei.'**
  String get party_zug_kein_wurf;

  /// No description provided for @party_zug_wahl_bindung.
  ///
  /// In de, this message translates to:
  /// **'Die Auswahl bleibt endgültig. Nochmal und Umweg wiederholen nur die Untersuchung, nicht die Entscheidung.'**
  String get party_zug_wahl_bindung;

  /// No description provided for @logo_stamp.
  ///
  /// In de, this message translates to:
  /// **'Ungelöst'**
  String get logo_stamp;

  /// No description provided for @lobby_bot_slot.
  ///
  /// In de, this message translates to:
  /// **'KI-Partner {n}'**
  String lobby_bot_slot(int n);

  /// No description provided for @hub_streak_label.
  ///
  /// In de, this message translates to:
  /// **'{days, plural, =0{Keine Serie} =1{Tag in Folge} other{Tage in Folge}}'**
  String hub_streak_label(int days);

  /// No description provided for @detektei_neuer_abend.
  ///
  /// In de, this message translates to:
  /// **'Neuer Abend'**
  String get detektei_neuer_abend;

  /// No description provided for @detektei_beitreten.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get detektei_beitreten;

  /// No description provided for @detektei_beitreten_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Mit Raumcode oder QR-Code einem Abend beitreten.'**
  String get detektei_beitreten_hinweis;

  /// No description provided for @detektei_bald.
  ///
  /// In de, this message translates to:
  /// **'bald'**
  String get detektei_bald;

  /// No description provided for @detektei_kampagne.
  ///
  /// In de, this message translates to:
  /// **'Kampagne'**
  String get detektei_kampagne;

  /// No description provided for @detektei_kampagne_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Die Akten der Reihe nach'**
  String get detektei_kampagne_hinweis;

  /// No description provided for @detektei_personen.
  ///
  /// In de, this message translates to:
  /// **'{min} bis {max} Personen'**
  String detektei_personen(int min, int max);

  /// No description provided for @detektei_ton_spuk.
  ///
  /// In de, this message translates to:
  /// **'Spuk'**
  String get detektei_ton_spuk;

  /// No description provided for @detektei_ton_noir.
  ///
  /// In de, this message translates to:
  /// **'Noir'**
  String get detektei_ton_noir;

  /// No description provided for @detektei_sammlung.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get detektei_sammlung;

  /// No description provided for @detektei_sammlung_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Die Karten der Figuren'**
  String get detektei_sammlung_hinweis;

  /// No description provided for @detektei_profil.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get detektei_profil;

  /// No description provided for @detektei_profil_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Rang, Name und Ausrüstung'**
  String get detektei_profil_hinweis;

  /// No description provided for @detektei_akten_fehler.
  ///
  /// In de, this message translates to:
  /// **'Die Akten konnten nicht geladen werden.'**
  String get detektei_akten_fehler;

  /// No description provided for @detektei_nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal versuchen'**
  String get detektei_nochmal;

  /// No description provided for @detektei_akte_spielen.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte spielen'**
  String get detektei_akte_spielen;

  /// No description provided for @detektei_akte_druckmappe.
  ///
  /// In de, this message translates to:
  /// **'Druckmappe'**
  String get detektei_akte_druckmappe;

  /// No description provided for @detektei_akte_unbekannt.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte gibt es nicht.'**
  String get detektei_akte_unbekannt;

  /// No description provided for @detektei_druck_titel.
  ///
  /// In de, this message translates to:
  /// **'Druckmappe'**
  String get detektei_druck_titel;

  /// No description provided for @detektei_druck_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Stelle den Abend ein. Danach erstellst du die Dateien zum Ausdrucken, auch die Erzählerakte für die Person, die erzählt.'**
  String get detektei_druck_hinweis;

  /// No description provided for @detektei_druck_vorbereiten.
  ///
  /// In de, this message translates to:
  /// **'Druckmappe vorbereiten'**
  String get detektei_druck_vorbereiten;

  /// Akte und Startseite: Knopf zur Druckmappe einer Akte mit Druckfassung
  ///
  /// In de, this message translates to:
  /// **'PDFs zum Ausdrucken'**
  String get detektei_druck_pdfs;

  /// No description provided for @abend_schritt.
  ///
  /// In de, this message translates to:
  /// **'Schritt {n} von {gesamt}'**
  String abend_schritt(int n, int gesamt);

  /// No description provided for @abend_schritt_akte.
  ///
  /// In de, this message translates to:
  /// **'Akte'**
  String get abend_schritt_akte;

  /// No description provided for @abend_schritt_spielweise.
  ///
  /// In de, this message translates to:
  /// **'Spielweise'**
  String get abend_schritt_spielweise;

  /// No description provided for @abend_schritt_einstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get abend_schritt_einstellungen;

  /// No description provided for @abend_schritt_start.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get abend_schritt_start;

  /// No description provided for @abend_akte_titel.
  ///
  /// In de, this message translates to:
  /// **'Welche Akte spielt ihr?'**
  String get abend_akte_titel;

  /// No description provided for @abend_akte_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Jede Akte ist ein eigener Fall mit eigenen Figuren.'**
  String get abend_akte_hinweis;

  /// No description provided for @abend_spielweise_titel.
  ///
  /// In de, this message translates to:
  /// **'Wie spielt ihr?'**
  String get abend_spielweise_titel;

  /// No description provided for @abend_spielweise_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst die Spielweise. Sie bestimmt, wie der Abend abläuft.'**
  String get abend_spielweise_hinweis;

  /// No description provided for @abend_spielweise_solo.
  ///
  /// In de, this message translates to:
  /// **'Solo mit Bots'**
  String get abend_spielweise_solo;

  /// No description provided for @abend_spielweise_solo_text.
  ///
  /// In de, this message translates to:
  /// **'Du ermittelst allein. Bots übernehmen die Gäste.'**
  String get abend_spielweise_solo_text;

  /// No description provided for @abend_spielweise_reihum.
  ///
  /// In de, this message translates to:
  /// **'Ein Gerät reihum'**
  String get abend_spielweise_reihum;

  /// No description provided for @abend_spielweise_reihum_text.
  ///
  /// In de, this message translates to:
  /// **'Ein Gerät geht am Tisch von Hand zu Hand. Jede Person liest ihre Rolle verdeckt.'**
  String get abend_spielweise_reihum_text;

  /// No description provided for @abend_spielweise_eigene.
  ///
  /// In de, this message translates to:
  /// **'Jeder am eigenen Gerät'**
  String get abend_spielweise_eigene;

  /// No description provided for @abend_spielweise_eigene_text.
  ///
  /// In de, this message translates to:
  /// **'Jede Person spielt mit ihrem eigenen Handy. Ihr verbindet euch über einen Raumcode.'**
  String get abend_spielweise_eigene_text;

  /// No description provided for @abend_spielweise_eigene_bald.
  ///
  /// In de, this message translates to:
  /// **'Kommt bald: Online-Abende mit Raumcode.'**
  String get abend_spielweise_eigene_bald;

  /// No description provided for @abend_einstellungen_titel.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen für den Abend'**
  String get abend_einstellungen_titel;

  /// No description provided for @abend_laedt.
  ///
  /// In de, this message translates to:
  /// **'Die Akte wird vorbereitet …'**
  String get abend_laedt;

  /// No description provided for @abend_fehler.
  ///
  /// In de, this message translates to:
  /// **'Die Akte konnte nicht geladen werden.'**
  String get abend_fehler;

  /// No description provided for @abend_nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal versuchen'**
  String get abend_nochmal;

  /// No description provided for @abend_weiter.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get abend_weiter;

  /// No description provided for @abend_start_titel.
  ///
  /// In de, this message translates to:
  /// **'Bereit?'**
  String get abend_start_titel;

  /// No description provided for @abend_start_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Mit dem Start beginnt die Rollenverteilung.'**
  String get abend_start_hinweis;

  /// No description provided for @abend_start_akte.
  ///
  /// In de, this message translates to:
  /// **'Akte'**
  String get abend_start_akte;

  /// No description provided for @abend_start_spielweise.
  ///
  /// In de, this message translates to:
  /// **'Spielweise'**
  String get abend_start_spielweise;

  /// No description provided for @abend_start_personen.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get abend_start_personen;

  /// No description provided for @abend_start_dauer.
  ///
  /// In de, this message translates to:
  /// **'Rundendauer'**
  String get abend_start_dauer;

  /// No description provided for @abend_start.
  ///
  /// In de, this message translates to:
  /// **'Abend beginnen'**
  String get abend_start;

  /// No description provided for @abend_abbrechen.
  ///
  /// In de, this message translates to:
  /// **'Abend abbrechen'**
  String get abend_abbrechen;

  /// No description provided for @abend_abbrechen_titel.
  ///
  /// In de, this message translates to:
  /// **'Abend abbrechen?'**
  String get abend_abbrechen_titel;

  /// No description provided for @abend_abbrechen_text.
  ///
  /// In de, this message translates to:
  /// **'Der Abend endet hier, es gibt keine Belohnung. Er lässt sich danach nicht fortsetzen.'**
  String get abend_abbrechen_text;

  /// No description provided for @abend_abbrechen_ja.
  ///
  /// In de, this message translates to:
  /// **'Abend abbrechen'**
  String get abend_abbrechen_ja;

  /// No description provided for @abend_abbrechen_nein.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen'**
  String get abend_abbrechen_nein;

  /// No description provided for @abend_klasse_titel.
  ///
  /// In de, this message translates to:
  /// **'Deine Ermittlerklasse'**
  String get abend_klasse_titel;

  /// No description provided for @abend_klasse_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Dein Abend bringt dir immer eine Sammelkarte deiner Klasse.'**
  String get abend_klasse_hinweis;

  /// No description provided for @abend_klasse_gesperrt.
  ///
  /// In de, this message translates to:
  /// **'{klasse}, gesperrt, {rang}'**
  String abend_klasse_gesperrt(String klasse, String rang);

  /// No description provided for @abend_klasse_forensic_faehigkeit_name.
  ///
  /// In de, this message translates to:
  /// **'Spurenblick'**
  String get abend_klasse_forensic_faehigkeit_name;

  /// No description provided for @abend_klasse_forensic_faehigkeit.
  ///
  /// In de, this message translates to:
  /// **'Suchstellen und Erkundungsorte leuchten schon von weitem.'**
  String get abend_klasse_forensic_faehigkeit;

  /// No description provided for @abend_klasse_profiler_faehigkeit_name.
  ///
  /// In de, this message translates to:
  /// **'Menschenkenner'**
  String get abend_klasse_profiler_faehigkeit_name;

  /// No description provided for @abend_klasse_profiler_faehigkeit.
  ///
  /// In de, this message translates to:
  /// **'Du siehst Gesprächspartner und ihre Stimmung sofort.'**
  String get abend_klasse_profiler_faehigkeit;

  /// No description provided for @abend_klasse_excop_faehigkeit_name.
  ///
  /// In de, this message translates to:
  /// **'Ortskundig'**
  String get abend_klasse_excop_faehigkeit_name;

  /// No description provided for @abend_klasse_excop_faehigkeit.
  ///
  /// In de, this message translates to:
  /// **'Türen, verschlossene Türen und Treppen sind umrandet.'**
  String get abend_klasse_excop_faehigkeit;

  /// No description provided for @abend_klasse_journalist_faehigkeit_name.
  ///
  /// In de, this message translates to:
  /// **'Gerüchte'**
  String get abend_klasse_journalist_faehigkeit_name;

  /// No description provided for @abend_klasse_journalist_faehigkeit.
  ///
  /// In de, this message translates to:
  /// **'Im Vorbeigehen schnappst du Gerüchte auf.'**
  String get abend_klasse_journalist_faehigkeit;

  /// No description provided for @abend_klasse_medic_faehigkeit_name.
  ///
  /// In de, this message translates to:
  /// **'Laufschritt'**
  String get abend_klasse_medic_faehigkeit_name;

  /// No description provided for @abend_klasse_medic_faehigkeit.
  ///
  /// In de, this message translates to:
  /// **'Du läufst auf der Karte schneller.'**
  String get abend_klasse_medic_faehigkeit;

  /// No description provided for @abend_klasse_fair.
  ///
  /// In de, this message translates to:
  /// **'Diese Fähigkeit ändert nie Fakten, Punkte oder Würfel.'**
  String get abend_klasse_fair;

  /// No description provided for @abend_klasse_karte_titel.
  ///
  /// In de, this message translates to:
  /// **'Auf der Karte'**
  String get abend_klasse_karte_titel;

  /// No description provided for @abend_klasse_karten_titel.
  ///
  /// In de, this message translates to:
  /// **'Sammelkarten dieser Klasse'**
  String get abend_klasse_karten_titel;

  /// No description provided for @abend_klasse_karte_besessen.
  ///
  /// In de, this message translates to:
  /// **'in deiner Sammlung'**
  String get abend_klasse_karte_besessen;

  /// No description provided for @detektiv_karte_titel.
  ///
  /// In de, this message translates to:
  /// **'Deine Detektivkarte'**
  String get detektiv_karte_titel;

  /// No description provided for @detektiv_karte_oeffnen.
  ///
  /// In de, this message translates to:
  /// **'Detektivkarte'**
  String get detektiv_karte_oeffnen;

  /// No description provided for @detektiv_karte_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Wer ermittelt, liest hier Auftrag und Regeln.'**
  String get detektiv_karte_hinweis;

  /// No description provided for @detektiv_karte_auftrag.
  ///
  /// In de, this message translates to:
  /// **'Dein Auftrag'**
  String get detektiv_karte_auftrag;

  /// No description provided for @detektiv_karte_auftrag_1.
  ///
  /// In de, this message translates to:
  /// **'Finde heraus, wer es war.'**
  String get detektiv_karte_auftrag_1;

  /// No description provided for @detektiv_karte_auftrag_2.
  ///
  /// In de, this message translates to:
  /// **'{runden} Runden, {entscheidungen} Entscheidungen, dann die Anklage.'**
  String detektiv_karte_auftrag_2(int runden, int entscheidungen);

  /// No description provided for @detektiv_karte_auftrag_3.
  ///
  /// In de, this message translates to:
  /// **'Anklage und Punkte bestimmen zusammen das Ende.'**
  String get detektiv_karte_auftrag_3;

  /// No description provided for @detektiv_karte_regeln.
  ///
  /// In de, this message translates to:
  /// **'Deine Regeln'**
  String get detektiv_karte_regeln;

  /// No description provided for @detektiv_karte_regel_1.
  ///
  /// In de, this message translates to:
  /// **'Je Entscheidung wählst du genau eine Möglichkeit.'**
  String get detektiv_karte_regel_1;

  /// No description provided for @detektiv_karte_regel_2.
  ///
  /// In de, this message translates to:
  /// **'Gute Entscheidungen geben Punkte, sichtbar erst am Ende.'**
  String get detektiv_karte_regel_2;

  /// No description provided for @detektiv_karte_regel_3.
  ///
  /// In de, this message translates to:
  /// **'Was dir zugeflüstert wird, prüfst du selbst.'**
  String get detektiv_karte_regel_3;

  /// No description provided for @detektiv_karte_klasse.
  ///
  /// In de, this message translates to:
  /// **'Deine Klasse'**
  String get detektiv_karte_klasse;

  /// No description provided for @detektiv_karte_belohnung.
  ///
  /// In de, this message translates to:
  /// **'Jeder Abend bringt eine Sammelkarte deiner Klasse.'**
  String get detektiv_karte_belohnung;

  /// No description provided for @detektiv_karte_befragungen.
  ///
  /// In de, this message translates to:
  /// **'So laufen Befragungen'**
  String get detektiv_karte_befragungen;

  /// No description provided for @detektiv_karte_befragung_1.
  ///
  /// In de, this message translates to:
  /// **'Frag gezielt: Wer war wann wo?'**
  String get detektiv_karte_befragung_1;

  /// No description provided for @detektiv_karte_befragung_2.
  ///
  /// In de, this message translates to:
  /// **'Du fragst nach und hörst genau zu.'**
  String get detektiv_karte_befragung_2;

  /// No description provided for @detektiv_karte_befragung_3.
  ///
  /// In de, this message translates to:
  /// **'Schreib auf, was nicht zusammenpasst.'**
  String get detektiv_karte_befragung_3;

  /// No description provided for @abend_feste_loesung_titel.
  ///
  /// In de, this message translates to:
  /// **'Feste Lösung'**
  String get abend_feste_loesung_titel;

  /// No description provided for @abend_feste_loesung_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte hat eine feste Lösung. Wer sie schon kennt, spielt am besten eine Rolle statt der Ermittlung.'**
  String get abend_feste_loesung_hinweis;

  /// No description provided for @abend_feste_loesung_solo.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte hat eine feste Lösung. Wer sie schon kennt, wählt besser eine andere Akte.'**
  String get abend_feste_loesung_solo;

  /// No description provided for @abend_feste_loesung_online.
  ///
  /// In de, this message translates to:
  /// **'Diese Akte hat eine feste Lösung. Wer sie schon kennt, spielt am besten eine Rolle statt der Ermittlung. Dann öffnet besser jemand anderes den Raum.'**
  String get abend_feste_loesung_online;

  /// Assistent, Spielart „Zum Drucken“: Hinweis auf die Druckmappe der Akte (nur Text, kein Sprung)
  ///
  /// In de, this message translates to:
  /// **'Nur die PDFs, ohne Abend? Die gibt es bei der Akte unter PDFs zum Ausdrucken.'**
  String get abend_druck_nur_pdfs;

  /// No description provided for @profil_klasse_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf eine Klasse, um sie zu wählen. Dein Abend bringt dir eine Sammelkarte dieser Klasse.'**
  String get profil_klasse_hinweis;

  /// No description provided for @profil_klasse_akten.
  ///
  /// In de, this message translates to:
  /// **'Wirkt nur in diesen Akten: {akten}.'**
  String profil_klasse_akten(String akten);

  /// No description provided for @profil_klasse_akten_allgemein.
  ///
  /// In de, this message translates to:
  /// **'Die Fähigkeiten wirken nicht in jeder Akte.'**
  String get profil_klasse_akten_allgemein;

  /// No description provided for @profil_klasse_gewaehlt.
  ///
  /// In de, this message translates to:
  /// **'Gewählt'**
  String get profil_klasse_gewaehlt;

  /// No description provided for @karten_sammlung_titel.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get karten_sammlung_titel;

  /// No description provided for @karten_sammlung_text.
  ///
  /// In de, this message translates to:
  /// **'Die Karten der Figuren und Detektivklassen. Tippe eine Karte an, um sie groß zu sehen.'**
  String get karten_sammlung_text;

  /// No description provided for @karten_seltenheit_zinn.
  ///
  /// In de, this message translates to:
  /// **'Zinn'**
  String get karten_seltenheit_zinn;

  /// No description provided for @karten_seltenheit_messing.
  ///
  /// In de, this message translates to:
  /// **'Messing'**
  String get karten_seltenheit_messing;

  /// No description provided for @karten_seltenheit_blutgold.
  ///
  /// In de, this message translates to:
  /// **'Blutgold'**
  String get karten_seltenheit_blutgold;

  /// No description provided for @karten_rueckseite.
  ///
  /// In de, this message translates to:
  /// **'Kartenrückseite'**
  String get karten_rueckseite;

  /// No description provided for @profil_chip_semantik.
  ///
  /// In de, this message translates to:
  /// **'Profil von {name}, {rang}, {xp} Erfahrungspunkte'**
  String profil_chip_semantik(String name, String rang, int xp);

  /// No description provided for @karten_sammlung_fortschritt.
  ///
  /// In de, this message translates to:
  /// **'{x} von {y} Karten'**
  String karten_sammlung_fortschritt(int x, int y);

  /// No description provided for @karten_figur_fortschritt.
  ///
  /// In de, this message translates to:
  /// **'{x} von {y}'**
  String karten_figur_fortschritt(int x, int y);

  /// No description provided for @karten_tab_klassen.
  ///
  /// In de, this message translates to:
  /// **'Detektivklassen'**
  String get karten_tab_klassen;

  /// No description provided for @karten_sammlung_leer.
  ///
  /// In de, this message translates to:
  /// **'Für diese Akte gibt es noch keine Karten.'**
  String get karten_sammlung_leer;

  /// No description provided for @karten_laedt.
  ///
  /// In de, this message translates to:
  /// **'Die Karten werden geladen …'**
  String get karten_laedt;

  /// No description provided for @karten_fehler.
  ///
  /// In de, this message translates to:
  /// **'Die Karten konnten nicht geladen werden.'**
  String get karten_fehler;

  /// No description provided for @karten_unbekannt.
  ///
  /// In de, this message translates to:
  /// **'Unbekannte Karte'**
  String get karten_unbekannt;

  /// No description provided for @karten_unbekannt_semantik.
  ///
  /// In de, this message translates to:
  /// **'{figur}: noch nicht gefunden'**
  String karten_unbekannt_semantik(String figur);

  /// No description provided for @karten_noch_nicht.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht gefunden'**
  String get karten_noch_nicht;

  /// No description provided for @karten_neu.
  ///
  /// In de, this message translates to:
  /// **'NEU'**
  String get karten_neu;

  /// No description provided for @karten_anzahl.
  ///
  /// In de, this message translates to:
  /// **'{n}×'**
  String karten_anzahl(int n);

  /// No description provided for @karten_besitz.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =1{Du besitzt 1 Exemplar.} other{Du besitzt {n} Exemplare.}}'**
  String karten_besitz(int n);

  /// No description provided for @karten_ladungen.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =1{1 Ladung} other{{n} Ladungen}}'**
  String karten_ladungen(int n);

  /// No description provided for @karten_seltenheit_gewoehnlich.
  ///
  /// In de, this message translates to:
  /// **'Gewöhnlich'**
  String get karten_seltenheit_gewoehnlich;

  /// No description provided for @karten_seltenheit_selten.
  ///
  /// In de, this message translates to:
  /// **'Selten'**
  String get karten_seltenheit_selten;

  /// No description provided for @karten_seltenheit_legendaer.
  ///
  /// In de, this message translates to:
  /// **'Legendär'**
  String get karten_seltenheit_legendaer;

  /// No description provided for @karten_art_werkzeug.
  ///
  /// In de, this message translates to:
  /// **'Werkzeug'**
  String get karten_art_werkzeug;

  /// No description provided for @karten_art_marke.
  ///
  /// In de, this message translates to:
  /// **'Marke'**
  String get karten_art_marke;

  /// No description provided for @karten_art_zeit.
  ///
  /// In de, this message translates to:
  /// **'Zeit'**
  String get karten_art_zeit;

  /// No description provided for @karten_art_gruendlich.
  ///
  /// In de, this message translates to:
  /// **'Gründlich'**
  String get karten_art_gruendlich;

  /// No description provided for @karten_art_nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get karten_art_nochmal;

  /// No description provided for @karten_art_umweg.
  ///
  /// In de, this message translates to:
  /// **'Umweg'**
  String get karten_art_umweg;

  /// No description provided for @karten_art_abstecher.
  ///
  /// In de, this message translates to:
  /// **'Abstecher'**
  String get karten_art_abstecher;

  /// No description provided for @karten_art_erinnerung.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get karten_art_erinnerung;

  /// No description provided for @karten_art_kosmetik.
  ///
  /// In de, this message translates to:
  /// **'Aussehen'**
  String get karten_art_kosmetik;

  /// No description provided for @karten_quelle_titel.
  ///
  /// In de, this message translates to:
  /// **'So bekommst du sie'**
  String get karten_quelle_titel;

  /// No description provided for @karten_quelle_rolle.
  ///
  /// In de, this message translates to:
  /// **'Spiele diese Rolle oder Klasse zu Ende, oder habe die Figur an deinem Tisch.'**
  String get karten_quelle_rolle;

  /// No description provided for @karten_quelle_taeter.
  ///
  /// In de, this message translates to:
  /// **'Überführe diese Figur mit einer richtigen Anklage.'**
  String get karten_quelle_taeter;

  /// No description provided for @karten_quelle_meister.
  ///
  /// In de, this message translates to:
  /// **'Erreiche das Meister-Ende der Akte.'**
  String get karten_quelle_meister;

  /// No description provided for @karten_quelle_abstecher.
  ///
  /// In de, this message translates to:
  /// **'Erkunde einen Ort der Akte erfolgreich.'**
  String get karten_quelle_abstecher;

  /// No description provided for @karten_quelle_start.
  ///
  /// In de, this message translates to:
  /// **'Gehört zum Startset.'**
  String get karten_quelle_start;

  /// No description provided for @karten_deck_bearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Deck bearbeiten'**
  String get karten_deck_bearbeiten;

  /// No description provided for @karten_deck_titel.
  ///
  /// In de, this message translates to:
  /// **'Dein Deck'**
  String get karten_deck_titel;

  /// No description provided for @karten_deck_text.
  ///
  /// In de, this message translates to:
  /// **'Höchstens drei Karten, je Art eine. Am Abend liegen sie als gemeinsame Hilfe auf dem Tisch. Eine Karte gleicher Art ersetzt die bisherige.'**
  String get karten_deck_text;

  /// No description provided for @karten_deck_platz.
  ///
  /// In de, this message translates to:
  /// **'Platz {n}'**
  String karten_deck_platz(int n);

  /// No description provided for @karten_deck_leer.
  ///
  /// In de, this message translates to:
  /// **'Leer'**
  String get karten_deck_leer;

  /// No description provided for @karten_deck_ladungen.
  ///
  /// In de, this message translates to:
  /// **'Ladungen {x} von {y}'**
  String karten_deck_ladungen(int x, int y);

  /// No description provided for @karten_deck_voll.
  ///
  /// In de, this message translates to:
  /// **'Das Deck ist voll. Nimm zuerst eine Karte heraus.'**
  String get karten_deck_voll;

  /// No description provided for @karten_deck_zuviel.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Ladungen für das Deck.'**
  String get karten_deck_zuviel;

  /// No description provided for @karten_deck_deine.
  ///
  /// In de, this message translates to:
  /// **'Deine spielbaren Karten'**
  String get karten_deck_deine;

  /// No description provided for @karten_deck_keine.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch keine spielbare Karte. Spiele Abende, um Karten zu finden.'**
  String get karten_deck_keine;

  /// No description provided for @karten_deck_einsetzen.
  ///
  /// In de, this message translates to:
  /// **'{titel} ins Deck legen'**
  String karten_deck_einsetzen(String titel);

  /// No description provided for @karten_deck_entfernen.
  ///
  /// In de, this message translates to:
  /// **'{titel} aus dem Deck nehmen'**
  String karten_deck_entfernen(String titel);

  /// No description provided for @karten_deck_drin.
  ///
  /// In de, this message translates to:
  /// **'Im Deck'**
  String get karten_deck_drin;

  /// No description provided for @karten_deck_fertig.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get karten_deck_fertig;

  /// No description provided for @karten_deck_abend_titel.
  ///
  /// In de, this message translates to:
  /// **'Deck für diesen Abend'**
  String get karten_deck_abend_titel;

  /// No description provided for @karten_deck_abend_leer.
  ///
  /// In de, this message translates to:
  /// **'Kein Deck gelegt. Der Abend läuft auch ohne Karten.'**
  String get karten_deck_abend_leer;

  /// No description provided for @karten_deck_aendern.
  ///
  /// In de, this message translates to:
  /// **'Deck ändern'**
  String get karten_deck_aendern;

  /// No description provided for @karten_detektei_neueste.
  ///
  /// In de, this message translates to:
  /// **'Neueste Karte: {titel}'**
  String karten_detektei_neueste(String titel);

  /// No description provided for @karten_hand_titel.
  ///
  /// In de, this message translates to:
  /// **'Deine Karten'**
  String get karten_hand_titel;

  /// No description provided for @karten_hand_karte.
  ///
  /// In de, this message translates to:
  /// **'{titel}, noch {rest} von {max} Ladungen'**
  String karten_hand_karte(String titel, int rest, int max);

  /// No description provided for @karten_hand_spielbar.
  ///
  /// In de, this message translates to:
  /// **'Jetzt spielbar'**
  String get karten_hand_spielbar;

  /// No description provided for @karten_hand_gesperrt.
  ///
  /// In de, this message translates to:
  /// **'Jetzt nicht spielbar'**
  String get karten_hand_gesperrt;

  /// No description provided for @karten_hand_gewaehlt.
  ///
  /// In de, this message translates to:
  /// **'Eingesetzt'**
  String get karten_hand_gewaehlt;

  /// No description provided for @karten_hand_leer.
  ///
  /// In de, this message translates to:
  /// **'Aufgebraucht'**
  String get karten_hand_leer;

  /// No description provided for @karten_hand_spielen.
  ///
  /// In de, this message translates to:
  /// **'Spielen'**
  String get karten_hand_spielen;

  /// No description provided for @karten_hand_schliessen.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get karten_hand_schliessen;

  /// No description provided for @karten_hand_wuerfel.
  ///
  /// In de, this message translates to:
  /// **'Tippe die Werkzeug-Karte: +1 auf diesen Wurf.'**
  String get karten_hand_wuerfel;

  /// No description provided for @karten_hand_tischruf.
  ///
  /// In de, this message translates to:
  /// **'Tippe die passende Karte: Nochmal oder Umweg ohne Nachtminuten.'**
  String get karten_hand_tischruf;

  /// No description provided for @karten_hand_gruendlich.
  ///
  /// In de, this message translates to:
  /// **'Tippe die Gründlich-Karte: gründlich ohne Nachtminuten.'**
  String get karten_hand_gruendlich;

  /// No description provided for @karten_hand_karte_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Zeit-, Marken- und Erinnerungskarten spielst du zwischen den Zügen.'**
  String get karten_hand_karte_hinweis;

  /// No description provided for @karten_hand_im_zug.
  ///
  /// In de, this message translates to:
  /// **'Diese Karte wirkt im passenden Moment eines Zuges: beim Würfeln, nach Pech oder bei der Wahl.'**
  String get karten_hand_im_zug;

  /// No description provided for @karten_erkunden.
  ///
  /// In de, this message translates to:
  /// **'Erkunden: {name}'**
  String karten_erkunden(String name);

  /// No description provided for @karten_erkunden_marke.
  ///
  /// In de, this message translates to:
  /// **'Abstecher'**
  String get karten_erkunden_marke;

  /// No description provided for @karten_erkunden_text.
  ///
  /// In de, this message translates to:
  /// **'Freiwillig: ein kurzer Blick in eine Ecke. Das bringt Stimmung und vielleicht eine Karte, aber nie einen Hinweis zum Fall.'**
  String get karten_erkunden_text;

  /// No description provided for @karten_erkunden_kosten.
  ///
  /// In de, this message translates to:
  /// **'Kostet {min} Nachtminuten. Bei Pech kommen {pech} dazu.'**
  String karten_erkunden_kosten(int min, int pech);

  /// No description provided for @karten_erkunden_los.
  ///
  /// In de, this message translates to:
  /// **'Erkunden'**
  String get karten_erkunden_los;

  /// No description provided for @karten_erkunden_nein.
  ///
  /// In de, this message translates to:
  /// **'Nicht jetzt'**
  String get karten_erkunden_nein;

  /// No description provided for @karten_erkunden_karte.
  ///
  /// In de, this message translates to:
  /// **'Abstecher-Karte einsetzen: {titel} (ohne Nachtminuten)'**
  String karten_erkunden_karte(String titel);

  /// No description provided for @karten_erkunden_wuerfel.
  ///
  /// In de, this message translates to:
  /// **'Pech zeigt hier nur ein Missgeschick. Einen Tischruf gibt es nicht.'**
  String get karten_erkunden_wuerfel;

  /// No description provided for @karten_erkunden_fund.
  ///
  /// In de, this message translates to:
  /// **'Nebenfund'**
  String get karten_erkunden_fund;

  /// No description provided for @karten_erkunden_liste.
  ///
  /// In de, this message translates to:
  /// **'Freiwillig erkunden'**
  String get karten_erkunden_liste;

  /// No description provided for @karten_gruendlich_karte.
  ///
  /// In de, this message translates to:
  /// **'Gründlich-Karte einsetzen: {titel} (ohne Nachtminuten)'**
  String karten_gruendlich_karte(String titel);

  /// No description provided for @abend_belohnung_marke.
  ///
  /// In de, this message translates to:
  /// **'Belohnung'**
  String get abend_belohnung_marke;

  /// No description provided for @abend_belohnung_titel.
  ///
  /// In de, this message translates to:
  /// **'Abend abgeschlossen'**
  String get abend_belohnung_titel;

  /// No description provided for @abend_belohnung_karten.
  ///
  /// In de, this message translates to:
  /// **'Neue Karten'**
  String get abend_belohnung_karten;

  /// No description provided for @abend_belohnung_tipp.
  ///
  /// In de, this message translates to:
  /// **'Tippe eine Karte, um sie umzudrehen.'**
  String get abend_belohnung_tipp;

  /// No description provided for @abend_belohnung_alle.
  ///
  /// In de, this message translates to:
  /// **'Alle umdrehen'**
  String get abend_belohnung_alle;

  /// No description provided for @abend_belohnung_keine.
  ///
  /// In de, this message translates to:
  /// **'Diesmal gibt es keine Karte.'**
  String get abend_belohnung_keine;

  /// No description provided for @abend_belohnung_doppelt.
  ///
  /// In de, this message translates to:
  /// **'Doppelt'**
  String get abend_belohnung_doppelt;

  /// No description provided for @abend_belohnung_verdeckt.
  ///
  /// In de, this message translates to:
  /// **'Karte {nr} von {gesamt}, verdeckt. Tippen zum Umdrehen.'**
  String abend_belohnung_verdeckt(int nr, int gesamt);

  /// No description provided for @abend_belohnung_xp.
  ///
  /// In de, this message translates to:
  /// **'+{xp} Erfahrungspunkte'**
  String abend_belohnung_xp(int xp);

  /// No description provided for @abend_belohnung_xp_titel.
  ///
  /// In de, this message translates to:
  /// **'Erfahrung'**
  String get abend_belohnung_xp_titel;

  /// No description provided for @abend_belohnung_rang_stempel.
  ///
  /// In de, this message translates to:
  /// **'BEFÖRDERT: {rang}'**
  String abend_belohnung_rang_stempel(String rang);

  /// No description provided for @abend_belohnung_rang_semantik.
  ///
  /// In de, this message translates to:
  /// **'Neuer Rang: {rang}'**
  String abend_belohnung_rang_semantik(String rang);

  /// No description provided for @abend_belohnung_bereits.
  ///
  /// In de, this message translates to:
  /// **'Dieser Abend ist schon verbucht.'**
  String get abend_belohnung_bereits;

  /// No description provided for @abend_belohnung_laedt.
  ///
  /// In de, this message translates to:
  /// **'Die Belohnung wird gezählt …'**
  String get abend_belohnung_laedt;

  /// No description provided for @abend_belohnung_fehler.
  ///
  /// In de, this message translates to:
  /// **'Die Belohnung konnte nicht verbucht werden.'**
  String get abend_belohnung_fehler;

  /// No description provided for @abend_belohnung_detektei.
  ///
  /// In de, this message translates to:
  /// **'Zur Detektei'**
  String get abend_belohnung_detektei;

  /// No description provided for @karten_erkunden_erfolg_folge.
  ///
  /// In de, this message translates to:
  /// **'Ein Fund für die Sammlung. Du gewinnst {min} Nachtminuten.'**
  String karten_erkunden_erfolg_folge(int min);

  /// No description provided for @karten_erkunden_teilerfolg_folge.
  ///
  /// In de, this message translates to:
  /// **'Ein kleiner Fund für die Sammlung. Die Nachtzeit bleibt, wie sie ist.'**
  String get karten_erkunden_teilerfolg_folge;

  /// No description provided for @karten_erkunden_pech_folge.
  ///
  /// In de, this message translates to:
  /// **'Nur ein Missgeschick. Das kostet {min} Nachtminuten, dafür gibt es eine Marke.'**
  String karten_erkunden_pech_folge(int min);

  /// No description provided for @abend_belohnung_ansehen.
  ///
  /// In de, this message translates to:
  /// **'Belohnung ansehen'**
  String get abend_belohnung_ansehen;

  /// No description provided for @online_einstellungen_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Rollen es gibt, legst du gleich in der Lobby fest. Freie Rollen übernehmen Bots.'**
  String get online_einstellungen_hinweis;

  /// No description provided for @online_raum_oeffnen.
  ///
  /// In de, this message translates to:
  /// **'Raum öffnen'**
  String get online_raum_oeffnen;

  /// No description provided for @online_start_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Beim Öffnen verbindet sich dein Gerät mit dem Relais. Danach treten die anderen mit dem Raumcode bei.'**
  String get online_start_hinweis;

  /// No description provided for @online_oeffnen_fehler.
  ///
  /// In de, this message translates to:
  /// **'Der Raum konnte nicht angelegt werden.'**
  String get online_oeffnen_fehler;

  /// No description provided for @online_lobby_marke.
  ///
  /// In de, this message translates to:
  /// **'Jeder am eigenen Gerät'**
  String get online_lobby_marke;

  /// No description provided for @online_lobby_titel.
  ///
  /// In de, this message translates to:
  /// **'Lobby'**
  String get online_lobby_titel;

  /// No description provided for @online_lobby_untertitel.
  ///
  /// In de, this message translates to:
  /// **'Die anderen treten mit dem Raumcode bei. Sind alle bereit, startest du den Abend.'**
  String get online_lobby_untertitel;

  /// No description provided for @online_lobby_verbinde.
  ///
  /// In de, this message translates to:
  /// **'Raum wird geöffnet …'**
  String get online_lobby_verbinde;

  /// No description provided for @online_lobby_fehler.
  ///
  /// In de, this message translates to:
  /// **'Das Relais ist nicht erreichbar. Prüfe die Internetverbindung und versuche es noch einmal.'**
  String get online_lobby_fehler;

  /// No description provided for @online_abend_starten.
  ///
  /// In de, this message translates to:
  /// **'Abend starten'**
  String get online_abend_starten;

  /// No description provided for @online_code_titel.
  ///
  /// In de, this message translates to:
  /// **'Raumcode'**
  String get online_code_titel;

  /// No description provided for @online_code_semantik.
  ///
  /// In de, this message translates to:
  /// **'Raumcode {code}'**
  String online_code_semantik(String code);

  /// No description provided for @online_code_kopieren.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get online_code_kopieren;

  /// No description provided for @online_link_kopieren.
  ///
  /// In de, this message translates to:
  /// **'Link kopieren'**
  String get online_link_kopieren;

  /// No description provided for @online_kopiert.
  ///
  /// In de, this message translates to:
  /// **'Kopiert'**
  String get online_kopiert;

  /// No description provided for @online_qr_semantik.
  ///
  /// In de, this message translates to:
  /// **'QR-Code zum Beitreten'**
  String get online_qr_semantik;

  /// No description provided for @online_qr_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Scannen oder in der Detektei auf „Beitreten“ tippen und den Code eingeben.'**
  String get online_qr_hinweis;

  /// No description provided for @online_tisch_titel.
  ///
  /// In de, this message translates to:
  /// **'Am Tisch'**
  String get online_tisch_titel;

  /// No description provided for @online_tisch_leer.
  ///
  /// In de, this message translates to:
  /// **'Noch ist niemand beigetreten.'**
  String get online_tisch_leer;

  /// No description provided for @online_spielleitung.
  ///
  /// In de, this message translates to:
  /// **'Gastgeber'**
  String get online_spielleitung;

  /// No description provided for @online_bereit.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get online_bereit;

  /// No description provided for @online_nicht_bereit.
  ///
  /// In de, this message translates to:
  /// **'Nicht bereit'**
  String get online_nicht_bereit;

  /// No description provided for @online_getrennt.
  ///
  /// In de, this message translates to:
  /// **'Getrennt'**
  String get online_getrennt;

  /// No description provided for @online_verbunden.
  ///
  /// In de, this message translates to:
  /// **'Verbunden'**
  String get online_verbunden;

  /// No description provided for @online_assistenz.
  ///
  /// In de, this message translates to:
  /// **'Assistenz'**
  String get online_assistenz;

  /// No description provided for @online_alle_bereit.
  ///
  /// In de, this message translates to:
  /// **'Alle sind bereit.'**
  String get online_alle_bereit;

  /// No description provided for @online_warten_bereit.
  ///
  /// In de, this message translates to:
  /// **'Warten, bis alle bereit sind.'**
  String get online_warten_bereit;

  /// No description provided for @online_rollen_titel.
  ///
  /// In de, this message translates to:
  /// **'Rollen'**
  String get online_rollen_titel;

  /// No description provided for @online_rollen_anzahl.
  ///
  /// In de, this message translates to:
  /// **'{n} Rollen'**
  String online_rollen_anzahl(int n);

  /// No description provided for @online_rollen_weniger.
  ///
  /// In de, this message translates to:
  /// **'Weniger Rollen'**
  String get online_rollen_weniger;

  /// No description provided for @online_rollen_mehr.
  ///
  /// In de, this message translates to:
  /// **'Mehr Rollen'**
  String get online_rollen_mehr;

  /// No description provided for @online_rollen_bots.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =0{Alle Rollen sind mit Gästen besetzt.} =1{Ein Bot übernimmt die freie Rolle.} other{{n} Bots übernehmen die freien Rollen.}}'**
  String online_rollen_bots(int n);

  /// No description provided for @online_rollen_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Mindestens so viele Rollen wie Gäste, höchstens so viele, wie die Akte kennt.'**
  String get online_rollen_hinweis;

  /// No description provided for @online_schliessen_titel.
  ///
  /// In de, this message translates to:
  /// **'Raum schließen?'**
  String get online_schliessen_titel;

  /// No description provided for @online_schliessen_text.
  ///
  /// In de, this message translates to:
  /// **'Alle, die schon beigetreten sind, werden getrennt.'**
  String get online_schliessen_text;

  /// No description provided for @online_schliessen_ja.
  ///
  /// In de, this message translates to:
  /// **'Raum schließen'**
  String get online_schliessen_ja;

  /// No description provided for @online_schliessen_nein.
  ///
  /// In de, this message translates to:
  /// **'Weiter warten'**
  String get online_schliessen_nein;

  /// No description provided for @online_leiste_raum.
  ///
  /// In de, this message translates to:
  /// **'Raum {code}'**
  String online_leiste_raum(String code);

  /// No description provided for @online_leiste_online.
  ///
  /// In de, this message translates to:
  /// **'{n} von {gesamt} Gästen online'**
  String online_leiste_online(int n, int gesamt);

  /// No description provided for @online_menue.
  ///
  /// In de, this message translates to:
  /// **'Raum und Gäste'**
  String get online_menue;

  /// No description provided for @online_beenden.
  ///
  /// In de, this message translates to:
  /// **'Abend beenden'**
  String get online_beenden;

  /// No description provided for @online_beenden_titel.
  ///
  /// In de, this message translates to:
  /// **'Abend für alle beenden?'**
  String get online_beenden_titel;

  /// No description provided for @online_beenden_text.
  ///
  /// In de, this message translates to:
  /// **'Alle Gäste werden getrennt. Der Abend lässt sich danach nicht fortsetzen.'**
  String get online_beenden_text;

  /// No description provided for @online_beenden_ja.
  ///
  /// In de, this message translates to:
  /// **'Abend beenden'**
  String get online_beenden_ja;

  /// No description provided for @online_beenden_nein.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen'**
  String get online_beenden_nein;

  /// No description provided for @online_rollen_erklaerung.
  ///
  /// In de, this message translates to:
  /// **'Jede Person liest ihre Rolle auf dem eigenen Gerät. Du hast keine Rolle zu lesen.'**
  String get online_rollen_erklaerung;

  /// No description provided for @online_rollen_warten.
  ///
  /// In de, this message translates to:
  /// **'Warten auf die Gäste: {x} von {y} haben ihre Rolle gelesen'**
  String online_rollen_warten(int x, int y);

  /// No description provided for @online_rollen_alle.
  ///
  /// In de, this message translates to:
  /// **'Alle Gäste haben ihre Rolle gelesen.'**
  String get online_rollen_alle;

  /// No description provided for @online_rollen_ohne_gaeste.
  ///
  /// In de, this message translates to:
  /// **'Alle Rollen spielen Bots. Es kann weitergehen.'**
  String get online_rollen_ohne_gaeste;

  /// No description provided for @online_rollen_gelesen.
  ///
  /// In de, this message translates to:
  /// **'Gelesen'**
  String get online_rollen_gelesen;

  /// No description provided for @online_rollen_liest.
  ///
  /// In de, this message translates to:
  /// **'Liest noch'**
  String get online_rollen_liest;

  /// No description provided for @online_wahl_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Die Gäste wählen auf ihren Geräten. Die Bots stimmen von selbst ab.'**
  String get online_wahl_hinweis;

  /// No description provided for @online_wahl_fortschritt.
  ///
  /// In de, this message translates to:
  /// **'{x} von {y} Gästen haben abgestimmt'**
  String online_wahl_fortschritt(int x, int y);

  /// No description provided for @online_wahl_nur_bots.
  ///
  /// In de, this message translates to:
  /// **'Alle Rollen spielen Bots, sie haben von selbst abgestimmt.'**
  String get online_wahl_nur_bots;

  /// No description provided for @online_wahl_abgegeben_kurz.
  ///
  /// In de, this message translates to:
  /// **'Abgestimmt'**
  String get online_wahl_abgegeben_kurz;

  /// No description provided for @online_wahl_waehlt.
  ///
  /// In de, this message translates to:
  /// **'Wählt noch'**
  String get online_wahl_waehlt;

  /// No description provided for @online_wuerfelt.
  ///
  /// In de, this message translates to:
  /// **'{name} würfelt …'**
  String online_wuerfelt(String name);

  /// No description provided for @online_fehler_nicht_bereit.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht alle sind bereit.'**
  String get online_fehler_nicht_bereit;

  /// No description provided for @online_fehler_nicht_dran.
  ///
  /// In de, this message translates to:
  /// **'Du bist gerade nicht mit Würfeln dran.'**
  String get online_fehler_nicht_dran;

  /// No description provided for @online_fehler_phase.
  ///
  /// In de, this message translates to:
  /// **'Das geht in diesem Abschnitt gerade nicht.'**
  String get online_fehler_phase;

  /// No description provided for @online_fehler_schon_gewaehlt.
  ///
  /// In de, this message translates to:
  /// **'Du hast schon gewählt.'**
  String get online_fehler_schon_gewaehlt;

  /// No description provided for @online_fehler_keine_antwort.
  ///
  /// In de, this message translates to:
  /// **'Keine Antwort vom Gastgeber. Versuche es noch einmal.'**
  String get online_fehler_keine_antwort;

  /// No description provided for @online_fehler_allgemein.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt. Versuche es noch einmal.'**
  String get online_fehler_allgemein;

  /// No description provided for @online_fehler_code.
  ///
  /// In de, this message translates to:
  /// **'Der Raumcode ist nicht gültig. Er hat sechs Zeichen.'**
  String get online_fehler_code;

  /// No description provided for @online_fehler_relay.
  ///
  /// In de, this message translates to:
  /// **'Das Relais ist nicht erreichbar. Prüfe deine Internetverbindung.'**
  String get online_fehler_relay;

  /// No description provided for @online_fehler_kein_raum.
  ///
  /// In de, this message translates to:
  /// **'Es gibt keinen Raum mit diesem Code, oder der Gastgeber ist nicht online.'**
  String get online_fehler_kein_raum;

  /// No description provided for @online_fehler_zeit.
  ///
  /// In de, this message translates to:
  /// **'Keine Antwort in der Zeit. Versuche es noch einmal.'**
  String get online_fehler_zeit;

  /// No description provided for @online_fehler_voll.
  ///
  /// In de, this message translates to:
  /// **'Der Raum ist voll.'**
  String get online_fehler_voll;

  /// No description provided for @online_fehler_gestartet.
  ///
  /// In de, this message translates to:
  /// **'Der Abend hat schon begonnen.'**
  String get online_fehler_gestartet;

  /// No description provided for @online_fehler_proto.
  ///
  /// In de, this message translates to:
  /// **'Diese App-Version passt nicht zum Raum. Aktualisiere die App.'**
  String get online_fehler_proto;

  /// No description provided for @online_fehler_inhalt.
  ///
  /// In de, this message translates to:
  /// **'Die Fassungen der Akten passen nicht zusammen. Aktualisiere die App auf beiden Geräten.'**
  String get online_fehler_inhalt;

  /// No description provided for @online_fehler_name.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein.'**
  String get online_fehler_name;

  /// No description provided for @online_beitreten_marke.
  ///
  /// In de, this message translates to:
  /// **'Online-Abend'**
  String get online_beitreten_marke;

  /// No description provided for @online_beitreten_titel.
  ///
  /// In de, this message translates to:
  /// **'Einem Abend beitreten'**
  String get online_beitreten_titel;

  /// No description provided for @online_beitreten_untertitel.
  ///
  /// In de, this message translates to:
  /// **'Gib den Raumcode ein, den der Gastgeber zeigt.'**
  String get online_beitreten_untertitel;

  /// No description provided for @online_code_feld.
  ///
  /// In de, this message translates to:
  /// **'Raumcode'**
  String get online_code_feld;

  /// No description provided for @online_code_platzhalter.
  ///
  /// In de, this message translates to:
  /// **'ABC-DEF'**
  String get online_code_platzhalter;

  /// No description provided for @online_name_feld.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get online_name_feld;

  /// No description provided for @online_name_platzhalter.
  ///
  /// In de, this message translates to:
  /// **'So heißt du am Tisch'**
  String get online_name_platzhalter;

  /// No description provided for @online_beitreten_los.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get online_beitreten_los;

  /// No description provided for @online_beitreten_laeuft.
  ///
  /// In de, this message translates to:
  /// **'Verbinde …'**
  String get online_beitreten_laeuft;

  /// No description provided for @online_zurueck_in_raum.
  ///
  /// In de, this message translates to:
  /// **'Zurück in Raum {code}'**
  String online_zurueck_in_raum(String code);

  /// No description provided for @online_zurueck_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch einen Platz in diesem Abend.'**
  String get online_zurueck_hinweis;

  /// No description provided for @online_vergessen.
  ///
  /// In de, this message translates to:
  /// **'Vergessen'**
  String get online_vergessen;

  /// No description provided for @online_zurueck_zum_abend.
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Abend {code}'**
  String online_zurueck_zum_abend(String code);

  /// No description provided for @online_zurueck_gastgeber_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Du führst diesen Abend. Er ist auf diesem Gerät gespeichert.'**
  String get online_zurueck_gastgeber_hinweis;

  /// No description provided for @online_verwerfen.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get online_verwerfen;

  /// No description provided for @online_rueckkehr_fehler.
  ///
  /// In de, this message translates to:
  /// **'Die Rückkehr hat nicht geklappt.'**
  String get online_rueckkehr_fehler;

  /// No description provided for @online_status_verbinde.
  ///
  /// In de, this message translates to:
  /// **'Verbinde …'**
  String get online_status_verbinde;

  /// No description provided for @online_status_pausiert.
  ///
  /// In de, this message translates to:
  /// **'Gastgeber getrennt – Abend pausiert'**
  String get online_status_pausiert;

  /// No description provided for @online_status_geschlossen.
  ///
  /// In de, this message translates to:
  /// **'Der Abend wurde beendet.'**
  String get online_status_geschlossen;

  /// No description provided for @online_status_getrennt.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung – prüfe dein Internet. Dein Platz bleibt reserviert.'**
  String get online_status_getrennt;

  /// No description provided for @online_lobby_getrennt.
  ///
  /// In de, this message translates to:
  /// **'Die Verbindung zum Relais ist weg. Gäste können gerade nicht beitreten, und der Abend lässt sich nicht starten. Dein Gerät verbindet sich von selbst neu.'**
  String get online_lobby_getrennt;

  /// No description provided for @online_leiste_getrennt.
  ///
  /// In de, this message translates to:
  /// **'Relais getrennt – Gäste erfahren gerade nichts'**
  String get online_leiste_getrennt;

  /// No description provided for @online_zur_detektei.
  ///
  /// In de, this message translates to:
  /// **'Zur Detektei'**
  String get online_zur_detektei;

  /// No description provided for @online_gast_marke.
  ///
  /// In de, this message translates to:
  /// **'Raum {code}'**
  String online_gast_marke(String code);

  /// No description provided for @online_gast_lobby_titel.
  ///
  /// In de, this message translates to:
  /// **'Warten auf den Start'**
  String get online_gast_lobby_titel;

  /// No description provided for @online_gast_lobby_hinweis.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf „Bereit“. Sind alle bereit, startet der Gastgeber den Abend.'**
  String get online_gast_lobby_hinweis;

  /// No description provided for @online_bereit_knopf.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get online_bereit_knopf;

  /// No description provided for @online_bereit_zurueck.
  ///
  /// In de, this message translates to:
  /// **'Doch nicht bereit'**
  String get online_bereit_zurueck;

  /// No description provided for @online_rolle_marke.
  ///
  /// In de, this message translates to:
  /// **'Deine Rolle'**
  String get online_rolle_marke;

  /// No description provided for @online_dossier_wer.
  ///
  /// In de, this message translates to:
  /// **'Wer ich bin'**
  String get online_dossier_wer;

  /// No description provided for @online_dossier_ziel.
  ///
  /// In de, this message translates to:
  /// **'Mein Ziel'**
  String get online_dossier_ziel;

  /// No description provided for @online_dossier_weiss.
  ///
  /// In de, this message translates to:
  /// **'Was ich weiß'**
  String get online_dossier_weiss;

  /// No description provided for @online_dossier_verbirgt.
  ///
  /// In de, this message translates to:
  /// **'Was ich verberge'**
  String get online_dossier_verbirgt;

  /// No description provided for @online_dossier_tarnung.
  ///
  /// In de, this message translates to:
  /// **'Meine Tarngeschichte'**
  String get online_dossier_tarnung;

  /// No description provided for @online_dossier_tatwissen.
  ///
  /// In de, this message translates to:
  /// **'Was wirklich geschah'**
  String get online_dossier_tatwissen;

  /// No description provided for @online_dossier_besetzung.
  ///
  /// In de, this message translates to:
  /// **'Besetzung'**
  String get online_dossier_besetzung;

  /// No description provided for @online_dossier_stempel.
  ///
  /// In de, this message translates to:
  /// **'Geheim'**
  String get online_dossier_stempel;

  /// No description provided for @online_gelesen_knopf.
  ///
  /// In de, this message translates to:
  /// **'Gelesen'**
  String get online_gelesen_knopf;

  /// No description provided for @online_gelesen_warten.
  ///
  /// In de, this message translates to:
  /// **'Du hast deine Rolle gelesen. Es geht weiter, sobald alle gelesen haben.'**
  String get online_gelesen_warten;

  /// No description provided for @online_assistenz_text.
  ///
  /// In de, this message translates to:
  /// **'Du hast keine eigene Rolle und verfolgst den öffentlichen Verlauf des Abends mit.'**
  String get online_assistenz_text;

  /// No description provided for @online_meine_rolle.
  ///
  /// In de, this message translates to:
  /// **'Meine Rolle: {name}'**
  String online_meine_rolle(String name);

  /// No description provided for @online_warten_spielleitung.
  ///
  /// In de, this message translates to:
  /// **'Gleich geht es weiter …'**
  String get online_warten_spielleitung;

  /// No description provided for @online_runde.
  ///
  /// In de, this message translates to:
  /// **'Runde {n}'**
  String online_runde(int n);

  /// No description provided for @online_erzaehler_titel.
  ///
  /// In de, this message translates to:
  /// **'Erzähler'**
  String get online_erzaehler_titel;

  /// No description provided for @online_phase_rollen.
  ///
  /// In de, this message translates to:
  /// **'Die Rollen werden gelesen'**
  String get online_phase_rollen;

  /// No description provided for @online_phase_intro.
  ///
  /// In de, this message translates to:
  /// **'Die Nacht beginnt'**
  String get online_phase_intro;

  /// No description provided for @online_phase_gespraeche.
  ///
  /// In de, this message translates to:
  /// **'Gespräche'**
  String get online_phase_gespraeche;

  /// No description provided for @online_phase_entscheidungen.
  ///
  /// In de, this message translates to:
  /// **'Ermittlung'**
  String get online_phase_entscheidungen;

  /// No description provided for @online_phase_gruppenwahl.
  ///
  /// In de, this message translates to:
  /// **'Gruppenwahl'**
  String get online_phase_gruppenwahl;

  /// No description provided for @online_phase_bonus.
  ///
  /// In de, this message translates to:
  /// **'Ein Hinweis'**
  String get online_phase_bonus;

  /// No description provided for @online_phase_resuemee.
  ///
  /// In de, this message translates to:
  /// **'Zwischenresümee'**
  String get online_phase_resuemee;

  /// No description provided for @online_phase_anklage.
  ///
  /// In de, this message translates to:
  /// **'Anklage'**
  String get online_phase_anklage;

  /// No description provided for @online_phase_finale.
  ///
  /// In de, this message translates to:
  /// **'Finale'**
  String get online_phase_finale;

  /// No description provided for @online_phase_aufloesung.
  ///
  /// In de, this message translates to:
  /// **'Auflösung'**
  String get online_phase_aufloesung;

  /// No description provided for @online_phase_ende.
  ///
  /// In de, this message translates to:
  /// **'Ende des Abends'**
  String get online_phase_ende;

  /// No description provided for @online_phase_unbekannt.
  ///
  /// In de, this message translates to:
  /// **'Der Abend läuft'**
  String get online_phase_unbekannt;

  /// No description provided for @online_gespraeche_titel.
  ///
  /// In de, this message translates to:
  /// **'Deine Gespräche in dieser Runde'**
  String get online_gespraeche_titel;

  /// No description provided for @online_gespraeche_keine.
  ///
  /// In de, this message translates to:
  /// **'In dieser Runde hast du kein Pflichtgespräch.'**
  String get online_gespraeche_keine;

  /// No description provided for @online_gespraech_mit.
  ///
  /// In de, this message translates to:
  /// **'Gespräch mit {name}'**
  String online_gespraech_mit(String name);

  /// No description provided for @online_gespraech_thema.
  ///
  /// In de, this message translates to:
  /// **'Thema'**
  String get online_gespraech_thema;

  /// No description provided for @online_gespraech_ziel.
  ///
  /// In de, this message translates to:
  /// **'Dein Ziel'**
  String get online_gespraech_ziel;

  /// No description provided for @online_gespraech_eroeffnung.
  ///
  /// In de, this message translates to:
  /// **'Eröffnung'**
  String get online_gespraech_eroeffnung;

  /// No description provided for @online_bots_titel.
  ///
  /// In de, this message translates to:
  /// **'Was am Tisch zu hören ist'**
  String get online_bots_titel;

  /// No description provided for @online_bot_spricht.
  ///
  /// In de, this message translates to:
  /// **'{sprecher} spricht mit {partner}'**
  String online_bot_spricht(String sprecher, String partner);

  /// No description provided for @online_preisgabe.
  ///
  /// In de, this message translates to:
  /// **'Verrät'**
  String get online_preisgabe;

  /// No description provided for @online_frage_titel.
  ///
  /// In de, this message translates to:
  /// **'Die Frage'**
  String get online_frage_titel;

  /// No description provided for @online_gewaehlt_titel.
  ///
  /// In de, this message translates to:
  /// **'Gewählt'**
  String get online_gewaehlt_titel;

  /// No description provided for @online_optionen_titel.
  ///
  /// In de, this message translates to:
  /// **'Zur Wahl stehen'**
  String get online_optionen_titel;

  /// No description provided for @online_ermittlung_wartet.
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv wählt gerade …'**
  String get online_ermittlung_wartet;

  /// No description provided for @online_ermittlung_fertig.
  ///
  /// In de, this message translates to:
  /// **'Die Ermittlung dieser Runde ist abgeschlossen. Gleich geht es zur Gruppenwahl.'**
  String get online_ermittlung_fertig;

  /// Dein Moment (Finale §3.1): Nach der Ermittlung kommt das Flüstern statt der Gruppenwahl
  ///
  /// In de, this message translates to:
  /// **'Die Ermittlung dieser Runde ist abgeschlossen. Gleich zeigt sich, ob die Runde dem Detektiv etwas zuflüstert.'**
  String get online_ermittlung_fertig_moment;

  /// No description provided for @online_nachtzeit.
  ///
  /// In de, this message translates to:
  /// **'Nachtzeit: {min} Min.'**
  String online_nachtzeit(int min);

  /// No description provided for @online_marken.
  ///
  /// In de, this message translates to:
  /// **'Marken: {n}'**
  String online_marken(int n);

  /// No description provided for @online_auftakt.
  ///
  /// In de, this message translates to:
  /// **'Der erste Wurf: Die Gruppe sucht nach Spuren.'**
  String get online_auftakt;

  /// No description provided for @online_abstecher.
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv erkundet einen Ort.'**
  String get online_abstecher;

  /// No description provided for @online_zug_aktion.
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv ist unterwegs …'**
  String get online_zug_aktion;

  /// No description provided for @online_wuerfel_titel.
  ///
  /// In de, this message translates to:
  /// **'Würfel'**
  String get online_wuerfel_titel;

  /// No description provided for @online_wuerfel_du.
  ///
  /// In de, this message translates to:
  /// **'Du würfelst für die Gruppe.'**
  String get online_wuerfel_du;

  /// No description provided for @online_chancen.
  ///
  /// In de, this message translates to:
  /// **'Chancen (Modifikator {mod})'**
  String online_chancen(int mod);

  /// No description provided for @online_stufe_erfolg.
  ///
  /// In de, this message translates to:
  /// **'Erfolg'**
  String get online_stufe_erfolg;

  /// No description provided for @online_stufe_teilerfolg.
  ///
  /// In de, this message translates to:
  /// **'Teilerfolg'**
  String get online_stufe_teilerfolg;

  /// No description provided for @online_stufe_pech.
  ///
  /// In de, this message translates to:
  /// **'Pech'**
  String get online_stufe_pech;

  /// No description provided for @online_marke_einsetzen.
  ///
  /// In de, this message translates to:
  /// **'Marke einsetzen'**
  String get online_marke_einsetzen;

  /// No description provided for @online_werkzeug_einsetzen.
  ///
  /// In de, this message translates to:
  /// **'Werkzeug-Karte einsetzen: {titel} (+1)'**
  String online_werkzeug_einsetzen(String titel);

  /// No description provided for @online_wuerfeln_knopf.
  ///
  /// In de, this message translates to:
  /// **'Würfeln'**
  String get online_wuerfeln_knopf;

  /// No description provided for @online_wurf_titel.
  ///
  /// In de, this message translates to:
  /// **'Wurf'**
  String get online_wurf_titel;

  /// No description provided for @online_wurf_rechnung.
  ///
  /// In de, this message translates to:
  /// **'{a} + {b} + {mod} = {summe}'**
  String online_wurf_rechnung(int a, int b, int mod, int summe);

  /// No description provided for @online_wurf_garantie.
  ///
  /// In de, this message translates to:
  /// **'Pech-Garantie: Pech zählt als Teilerfolg.'**
  String get online_wurf_garantie;

  /// No description provided for @online_wurf_zeile.
  ///
  /// In de, this message translates to:
  /// **'{stufe}: {a} + {b} + {mod} = {summe}'**
  String online_wurf_zeile(String stufe, int a, int b, int mod, int summe);

  /// No description provided for @online_wuerfe_titel.
  ///
  /// In de, this message translates to:
  /// **'Würfelprotokoll'**
  String get online_wuerfe_titel;

  /// No description provided for @online_tischruf_wartet.
  ///
  /// In de, this message translates to:
  /// **'Pech. Der Detektiv entscheidet, wie es weitergeht.'**
  String get online_tischruf_wartet;

  /// No description provided for @online_fund_titel.
  ///
  /// In de, this message translates to:
  /// **'Fund'**
  String get online_fund_titel;

  /// No description provided for @online_fund_wartet.
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv liest den Fund.'**
  String get online_fund_wartet;

  /// No description provided for @online_notizbuch_titel.
  ///
  /// In de, this message translates to:
  /// **'Notizbuch'**
  String get online_notizbuch_titel;

  /// No description provided for @online_wahl_titel.
  ///
  /// In de, this message translates to:
  /// **'Deine Wahl in dieser Runde'**
  String get online_wahl_titel;

  /// No description provided for @online_wahl_geheim.
  ///
  /// In de, this message translates to:
  /// **'Niemand sieht, was du wählst. Tippe eine Karte an und gib deine Wahl ab.'**
  String get online_wahl_geheim;

  /// No description provided for @online_wahl_abgeben.
  ///
  /// In de, this message translates to:
  /// **'Wahl abgeben'**
  String get online_wahl_abgeben;

  /// No description provided for @online_wahl_abgegeben.
  ///
  /// In de, this message translates to:
  /// **'Deine Stimme ist abgegeben. Warten auf die anderen …'**
  String get online_wahl_abgegeben;

  /// No description provided for @online_wahl_assistenz.
  ///
  /// In de, this message translates to:
  /// **'Die Gruppenwahl läuft. Du hast keine Stimme, weil du keine Rolle hast.'**
  String get online_wahl_assistenz;

  /// No description provided for @online_verdaechtige_titel.
  ///
  /// In de, this message translates to:
  /// **'Verdächtige'**
  String get online_verdaechtige_titel;

  /// No description provided for @online_anklage_wartet.
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv erhebt die Anklage gegen eine dieser Personen.'**
  String get online_anklage_wartet;

  /// No description provided for @online_aufloesung_titel.
  ///
  /// In de, this message translates to:
  /// **'Die Auflösung'**
  String get online_aufloesung_titel;

  /// No description provided for @online_aufloesung_taeter.
  ///
  /// In de, this message translates to:
  /// **'Täter oder Täterin'**
  String get online_aufloesung_taeter;

  /// No description provided for @online_aufloesung_punkte.
  ///
  /// In de, this message translates to:
  /// **'Richtige Entscheidungen'**
  String get online_aufloesung_punkte;

  /// No description provided for @online_aufloesung_ende.
  ///
  /// In de, this message translates to:
  /// **'Ende'**
  String get online_aufloesung_ende;

  /// No description provided for @online_aufloesung_code.
  ///
  /// In de, this message translates to:
  /// **'Fall-Code'**
  String get online_aufloesung_code;

  /// No description provided for @online_verlassen.
  ///
  /// In de, this message translates to:
  /// **'Abend verlassen'**
  String get online_verlassen;

  /// No description provided for @online_verlassen_titel.
  ///
  /// In de, this message translates to:
  /// **'Abend verlassen?'**
  String get online_verlassen_titel;

  /// No description provided for @online_verlassen_text.
  ///
  /// In de, this message translates to:
  /// **'Du verlierst deinen Platz und deine Rolle in diesem Abend.'**
  String get online_verlassen_text;

  /// No description provided for @online_verlassen_ja.
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get online_verlassen_ja;

  /// No description provided for @online_verlassen_nein.
  ///
  /// In de, this message translates to:
  /// **'Bleiben'**
  String get online_verlassen_nein;

  /// No description provided for @abend2_auftrag.
  ///
  /// In de, this message translates to:
  /// **'Ermittlungsauftrag'**
  String get abend2_auftrag;

  /// No description provided for @abend2_beweisstueck.
  ///
  /// In de, this message translates to:
  /// **'Beweisstück Nr. {nr}'**
  String abend2_beweisstueck(String nr);

  /// No description provided for @abend2_angeklagt.
  ///
  /// In de, this message translates to:
  /// **'Angeklagt'**
  String get abend2_angeklagt;

  /// No description provided for @online_bot_stempel.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get online_bot_stempel;

  /// No description provided for @detektei_dienstausweis.
  ///
  /// In de, this message translates to:
  /// **'Dienstausweis'**
  String get detektei_dienstausweis;

  /// No description provided for @detektei_dienstgrad.
  ///
  /// In de, this message translates to:
  /// **'Dienstgrad'**
  String get detektei_dienstgrad;

  /// No description provided for @detektei_akte_lage.
  ///
  /// In de, this message translates to:
  /// **'Die Lage'**
  String get detektei_akte_lage;

  /// No description provided for @detektei_akte_schauplatz.
  ///
  /// In de, this message translates to:
  /// **'Schauplatz'**
  String get detektei_akte_schauplatz;

  /// No description provided for @detektei_akte_anlass.
  ///
  /// In de, this message translates to:
  /// **'Anlass'**
  String get detektei_akte_anlass;

  /// No description provided for @detektei_akte_zeitpunkt.
  ///
  /// In de, this message translates to:
  /// **'Zeitpunkt'**
  String get detektei_akte_zeitpunkt;

  /// Tonschalter: Zustand an (Bildschirmleser, Tooltip)
  ///
  /// In de, this message translates to:
  /// **'Ton an'**
  String get ton_an;

  /// Tonschalter: Zustand aus (Bildschirmleser, Tooltip)
  ///
  /// In de, this message translates to:
  /// **'Ton aus'**
  String get ton_aus;

  /// Karte: Aktion an einem Zeugen für ein Randgespräch
  ///
  /// In de, this message translates to:
  /// **'Ansprechen'**
  String get gespraech_ansprechen;

  /// Kopf des Gesprächsprotokolls
  ///
  /// In de, this message translates to:
  /// **'Vernehmung am Rande'**
  String get gespraech_marke;

  /// Knopf am Ende eines Randgesprächs
  ///
  /// In de, this message translates to:
  /// **'Gespräch beenden'**
  String get gespraech_beenden;

  /// Kennzeichnung der eigenen Sätze im Protokoll (passt zu du und Sie)
  ///
  /// In de, this message translates to:
  /// **'Ich'**
  String get gespraech_ich;

  /// Gesprächshaltung
  ///
  /// In de, this message translates to:
  /// **'Freundlich'**
  String get gespraech_haltung_freundlich;

  /// Gesprächshaltung
  ///
  /// In de, this message translates to:
  /// **'Drängen'**
  String get gespraech_haltung_draengen;

  /// Gesprächshaltung
  ///
  /// In de, this message translates to:
  /// **'Bluffen'**
  String get gespraech_haltung_bluffen;

  /// Gesprächshaltung: einen Fund vorlegen
  ///
  /// In de, this message translates to:
  /// **'Vorlegen'**
  String get gespraech_haltung_vorlegen;

  /// Überschrift der Epiloge nach der Auflösung
  ///
  /// In de, this message translates to:
  /// **'Nachspiel'**
  String get nachspiel_titel;

  /// Unterzeile des Nachspiels
  ///
  /// In de, this message translates to:
  /// **'Was aus den Zeugen wurde'**
  String get nachspiel_hinweis;

  /// Detektei: Formularkopf der Schnellstart-Akte für neue Spielende
  ///
  /// In de, this message translates to:
  /// **'Dein erster Fall'**
  String get erster_fall_marke;

  /// Detektei: Text der Schnellstart-Akte
  ///
  /// In de, this message translates to:
  /// **'Ein Fest im Schlosskeller, ein Knall, dann ist es dunkel. Du ermittelst allein, Bots spielen die Gäste.'**
  String get erster_fall_text;

  /// Detektei: Knopf der Schnellstart-Akte
  ///
  /// In de, this message translates to:
  /// **'Sofort ermitteln'**
  String get erster_fall_los;

  /// Detektei: Hinweis unter dem Schnellstart
  ///
  /// In de, this message translates to:
  /// **'Alles Weitere zeigt dir der Abend unterwegs.'**
  String get erster_fall_hinweis;

  /// Detektei: Knopf für den abgelegten Abend
  ///
  /// In de, this message translates to:
  /// **'Abend fortsetzen'**
  String get abend_fortsetzen;

  /// Detektei: Hinweis unter „Abend fortsetzen“ vor der ersten Runde
  ///
  /// In de, this message translates to:
  /// **'{akte}. Es geht genau dort weiter, wo der Abend stand.'**
  String abend_fortsetzen_hinweis(String akte);

  /// Detektei: Hinweis unter „Abend fortsetzen“ mit Runde
  ///
  /// In de, this message translates to:
  /// **'{akte}, Runde {runde}. Es geht genau dort weiter, wo der Abend stand.'**
  String abend_fortsetzen_runde(String akte, int runde);

  /// Detektei: den abgelegten Abend löschen
  ///
  /// In de, this message translates to:
  /// **'Abend verwerfen'**
  String get abend_fortsetzen_verwerfen;

  /// Detektei: Laden des abgelegten Abends gescheitert; der Stand bleibt
  ///
  /// In de, this message translates to:
  /// **'Der Abend lässt sich gerade nicht öffnen. Versuch es gleich noch einmal.'**
  String get abend_fortsetzen_fehler;

  /// Assistent: Rückfrage, wenn ein abgelegter Abend durch einen neuen ersetzt würde
  ///
  /// In de, this message translates to:
  /// **'Abend ersetzen?'**
  String get abend_ersetzen_titel;

  /// Assistent: Text der Rückfrage
  ///
  /// In de, this message translates to:
  /// **'Ein unterbrochener Abend wartet noch in der Detektei. Ein neuer Abend ersetzt ihn.'**
  String get abend_ersetzen_text;

  /// Assistent: den abgelegten Abend ersetzen
  ///
  /// In de, this message translates to:
  /// **'Neuen Abend beginnen'**
  String get abend_ersetzen_ja;

  /// Assistent: nicht ersetzen
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get abend_ersetzen_nein;

  /// Ende des Abends: Knopf zum Teilen der Teilkarte
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get teilen_knopf;

  /// Teilkarte: Formularkopf
  ///
  /// In de, this message translates to:
  /// **'Abschlussbericht'**
  String get teilen_marke;

  /// Teilkarte: Handschrift unten, wenn es keinen Fall-Code gibt
  ///
  /// In de, this message translates to:
  /// **'Schafft ihr es auch?'**
  String get teilen_aufruf;

  /// Teilkarte: Handschrift über dem Fall-Code
  ///
  /// In de, this message translates to:
  /// **'Spielt denselben Fall:'**
  String get teilen_code_aufruf;

  /// Teilkarte: Fußzeile
  ///
  /// In de, this message translates to:
  /// **'Kostenlos, ohne Werbung, ohne Anmeldung'**
  String get teilen_fuss;

  /// Betreff beim Teilen (E-Mail)
  ///
  /// In de, this message translates to:
  /// **'Mordakte: {akte}'**
  String teilen_betreff(String akte);

  /// Text beim Teilen ohne Fall-Code; nennt nie den Täter
  ///
  /// In de, this message translates to:
  /// **'Fall geschlossen: „{akte}“. {ende}, {punkte} Punkten. Schafft ihr es auch? Mordakte, kostenlos und ohne Werbung.'**
  String teilen_text(String akte, String ende, String punkte);

  /// Text beim Teilen mit Fall-Code; nennt nie den Täter
  ///
  /// In de, this message translates to:
  /// **'Fall geschlossen: „{akte}“. {ende}, {punkte} Punkten. Spielt denselben Fall mit dem Code {code}. Schafft ihr es auch? Mordakte, kostenlos und ohne Werbung.'**
  String teilen_text_code(String akte, String ende, String punkte, String code);

  /// Profil: Abschnitt mit Tonschalter und Lautstärkereglern
  ///
  /// In de, this message translates to:
  /// **'Ton'**
  String get ton_titel;

  /// Profil: Regler für Klänge (Knöpfe, Stempel, Würfel, Schritte)
  ///
  /// In de, this message translates to:
  /// **'Geräusche'**
  String get ton_effekte;

  /// Profil: Regler für Regen, Wind und Zug im Hintergrund
  ///
  /// In de, this message translates to:
  /// **'Atmosphäre'**
  String get ton_atmosphaere;

  /// Einrichtung: Abschnitt Erzähltiefe
  ///
  /// In de, this message translates to:
  /// **'Gespräche mit Zeugen'**
  String get erzaehltiefe_titel;

  /// Erzähltiefe: keine Randgespräche
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get erzaehltiefe_aus;

  /// Erzähltiefe: eine Wahl je Gespräch
  ///
  /// In de, this message translates to:
  /// **'Kurz'**
  String get erzaehltiefe_kurz;

  /// Erzähltiefe: ganze Gespräche und Folgen
  ///
  /// In de, this message translates to:
  /// **'Ausführlich'**
  String get erzaehltiefe_voll;

  /// Einrichtung: Hinweis unter der Erzähltiefe
  ///
  /// In de, this message translates to:
  /// **'Zeugen auf der Karte ansprechen. Kostet keine Zeit und zählt nicht in die Wertung.'**
  String get erzaehltiefe_hinweis;

  /// Befragungen des Detektivs: Überschrift (Solo und am Tisch)
  ///
  /// In de, this message translates to:
  /// **'Deine Befragungen'**
  String get party_befragung_titel;

  /// Solo: Hinweis unter der Überschrift der Befragungen
  ///
  /// In de, this message translates to:
  /// **'Tippe eine Frage an, dann hörst du die Antwort. Behauptungen können falsch sein.'**
  String get party_befragung_hinweis;

  /// Am Tisch: Hinweis über den Befragungskarten des Detektivs
  ///
  /// In de, this message translates to:
  /// **'Tippe die Frage an, die du am Tisch stellst. Die Antwort kennt nur die befragte Person.'**
  String get party_befragung_hinweis_tisch;

  /// Druckspiel: Hinweis über den Befragungskarten des Detektivs (nur zum Lesen)
  ///
  /// In de, this message translates to:
  /// **'Deine Befragungen stehen auch auf deinem Bogen. Stelle am Tisch eine der Fragen.'**
  String get party_befragung_hinweis_druck;

  /// Marke einer festen Befragung
  ///
  /// In de, this message translates to:
  /// **'Pflicht'**
  String get party_befragung_pflicht;

  /// Überschrift der frei wählbaren Befragungen
  ///
  /// In de, this message translates to:
  /// **'Frei wählbar'**
  String get party_befragung_frei_titel;

  /// Freie Wahl: eine offen
  ///
  /// In de, this message translates to:
  /// **'Wähle noch eine Befragung frei.'**
  String get party_befragung_frei_eine;

  /// Freie Wahl: zwei offen
  ///
  /// In de, this message translates to:
  /// **'Wähle noch zwei Befragungen frei.'**
  String get party_befragung_frei_zwei;

  /// Freie Wahl: alle getroffen
  ///
  /// In de, this message translates to:
  /// **'Deine freien Wahlen sind getroffen.'**
  String get party_befragung_frei_fertig;

  /// Gesperrte freie Befragung
  ///
  /// In de, this message translates to:
  /// **'Keine freie Wahl mehr'**
  String get party_befragung_vergeben;

  /// Feld Thema einer Befragung
  ///
  /// In de, this message translates to:
  /// **'Thema'**
  String get party_befragung_thema;

  /// Feld Fragen einer Befragung
  ///
  /// In de, this message translates to:
  /// **'Deine Fragen'**
  String get party_befragung_fragen;

  /// Feld Antwort einer Befragung (nur App-Rollen)
  ///
  /// In de, this message translates to:
  /// **'Antwort'**
  String get party_befragung_antwort;

  /// Antwort ohne Preisgabe
  ///
  /// In de, this message translates to:
  /// **'Nichts Neues. Mehr weiß diese Person nicht.'**
  String get party_befragung_nichts;

  /// Stempel einer erledigten Befragung
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get party_befragung_erledigt;

  /// Knopf: Die Person hat am Tisch geantwortet
  ///
  /// In de, this message translates to:
  /// **'Beantwortet'**
  String get party_befragung_beantwortet;

  /// Knopf: Gerät an die befragte Person geben
  ///
  /// In de, this message translates to:
  /// **'Antwort zeigen'**
  String get party_befragung_antwort_zeigen;

  /// Verdeckter Hinweis bei einer Befragung am Tisch
  ///
  /// In de, this message translates to:
  /// **'Gib das Gerät kurz an {name}.'**
  String party_befragung_geraet(String name);

  /// Solo: höchstens drei Paarungen ohne Antwort
  ///
  /// In de, this message translates to:
  /// **'Am Tisch aufgeschnappt'**
  String get party_befragung_aufgeschnappt;

  /// Am Tisch: Paarungen der Tischgespräche
  ///
  /// In de, this message translates to:
  /// **'Am Tisch in dieser Runde'**
  String get party_befragung_tisch_titel;

  /// Am Tisch: Hinweis zu den Paarungen
  ///
  /// In de, this message translates to:
  /// **'Jede Person führt ein Gespräch. Was sie sagt, steht auf ihrem Spickzettel.'**
  String get party_befragung_tisch_hinweis;

  /// Solo: alle Befragungen erledigt
  ///
  /// In de, this message translates to:
  /// **'Alle Befragungen geführt. Jetzt ermittelst du auf der Karte.'**
  String get party_befragung_fertig;

  /// Weiter ist gesperrt, bis die Befragungen erledigt sind
  ///
  /// In de, this message translates to:
  /// **'Erst die Befragungen, dann geht es weiter.'**
  String get party_befragung_offen;

  /// Notizbuch: Antworten der Befragungen
  ///
  /// In de, this message translates to:
  /// **'Antworten aus deinen Befragungen'**
  String get party_befragung_notizen;

  /// Notizbuch: Wissen unbesetzter Gäste, das der Erzähler zum Rundenstart sprach (E-044)
  ///
  /// In de, this message translates to:
  /// **'Vom Erzähler gehört'**
  String get party_befragung_erzaehler_notizen;

  /// Verdeckter Zettel je Person für die laufende Runde
  ///
  /// In de, this message translates to:
  /// **'Mein Spickzettel'**
  String get party_befragung_spickzettel;

  /// Am Tisch: Hinweis zu den Spickzetteln
  ///
  /// In de, this message translates to:
  /// **'Tippe deinen Namen an. Nur du siehst deinen Zettel für diese Runde.'**
  String get party_befragung_spickzettel_hinweis;

  /// Spickzettel: eigenes Tischgespräch
  ///
  /// In de, this message translates to:
  /// **'Dein Tischgespräch'**
  String get party_befragung_tisch_eigen;

  /// Spickzettel: Stichpunkte des Tischgesprächs
  ///
  /// In de, this message translates to:
  /// **'Stichpunkte'**
  String get party_befragung_stichpunkte;

  /// Spickzettel: wer die Rolle anspricht
  ///
  /// In de, this message translates to:
  /// **'Wer dich anspricht'**
  String get party_befragung_anspricht;

  /// Spickzettel: niemand spricht die Rolle an
  ///
  /// In de, this message translates to:
  /// **'In dieser Runde spricht dich niemand an.'**
  String get party_befragung_niemand;

  /// Spickzettel: eigene Befragung
  ///
  /// In de, this message translates to:
  /// **'Wenn der Detektiv dich befragt'**
  String get party_befragung_dich;

  /// Spickzettel: Antwort-Stichpunkte
  ///
  /// In de, this message translates to:
  /// **'Das sagst du'**
  String get party_befragung_sagen;

  /// Spickzettel: Behauptung einer Lüge
  ///
  /// In de, this message translates to:
  /// **'Behaupte: {text}'**
  String party_befragung_behaupte(String text);

  /// Spickzettel: feste Befragung
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv befragt dich in dieser Runde.'**
  String get party_befragung_sicher;

  /// Spickzettel: freie Befragung
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv kann dich in dieser Runde frei wählen.'**
  String get party_befragung_vielleicht;

  /// Spickzettel: freie Wahl ist vergeben
  ///
  /// In de, this message translates to:
  /// **'In dieser Runde befragt dich der Detektiv nicht.'**
  String get party_befragung_entfaellt;

  /// Spickzettel: die gestellte Frage
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv fragt dich: {frage}'**
  String party_befragung_fragt(String frage);

  /// Rollenübergabe: nur die Notizen der ersten Runde
  ///
  /// In de, this message translates to:
  /// **'Das ist dein Zettel für die erste Runde. Die nächsten Zettel siehst du in der Runde selbst.'**
  String get party_befragung_runde_eins;

  /// Online: öffentliche Liste der Befragungen
  ///
  /// In de, this message translates to:
  /// **'Wen der Detektiv befragt'**
  String get party_befragung_oeffentlich;

  /// Detektei: alter Abendstand wurde verworfen
  ///
  /// In de, this message translates to:
  /// **'Dieser Abend stammt aus einer älteren Fassung der Akte. Er lässt sich nicht fortsetzen.'**
  String get abend_fortsetzen_veraltet;

  /// Einrichtung: Abschnitt mit Erzähler (reihum) bzw. eigenem Platz (online)
  ///
  /// In de, this message translates to:
  /// **'Rollen am Tisch'**
  String get abend_rollen_titel;

  /// Einrichtung reihum: Feld für den Erzähler
  ///
  /// In de, this message translates to:
  /// **'Name des Erzählers (optional)'**
  String get abend_erzaehler_feld;

  /// Einrichtung reihum: was der Erzähler tut
  ///
  /// In de, this message translates to:
  /// **'Der Erzähler liest vor und führt weiter. Er ermittelt nicht.'**
  String get abend_erzaehler_hinweis;

  /// Einrichtung reihum: ohne Erzähler
  ///
  /// In de, this message translates to:
  /// **'Ohne Namen liest, wer gerade das Gerät hält.'**
  String get abend_erzaehler_leer;

  /// Einrichtung online: Sitz des Gastgebers
  ///
  /// In de, this message translates to:
  /// **'Dein Platz'**
  String get abend_platz_titel;

  /// Sitz: Detektiv
  ///
  /// In de, this message translates to:
  /// **'Detektiv'**
  String get abend_platz_detektiv;

  /// Sitz: Erzähler
  ///
  /// In de, this message translates to:
  /// **'Erzähler'**
  String get abend_platz_erzaehler;

  /// Einrichtung online: Gastgeber ermittelt
  ///
  /// In de, this message translates to:
  /// **'Du ermittelst. Ein Gast kann vorlesen.'**
  String get abend_platz_hinweis_detektiv;

  /// Einrichtung online: Gastgeber liest vor
  ///
  /// In de, this message translates to:
  /// **'Du liest vor und führst weiter. Ein Gast ermittelt.'**
  String get abend_platz_hinweis_erzaehler;

  /// Startübersicht: Name des Erzählers
  ///
  /// In de, this message translates to:
  /// **'Erzähler'**
  String get abend_start_erzaehler;

  /// Startübersicht online: Sitz des Gastgebers
  ///
  /// In de, this message translates to:
  /// **'Dein Platz'**
  String get abend_start_platz;

  /// Startübersicht: kein Erzähler
  ///
  /// In de, this message translates to:
  /// **'keiner'**
  String get abend_start_ohne;

  /// Reihum: verdeckte Erzähltexte
  ///
  /// In de, this message translates to:
  /// **'Erzählerpult'**
  String get erzaehlerpult_titel;

  /// Reihum: Übergabe an den Erzähler
  ///
  /// In de, this message translates to:
  /// **'Gib das Gerät an {name}.'**
  String erzaehlerpult_geben(String name);

  /// Reihum: nur der Erzähler sieht die Texte
  ///
  /// In de, this message translates to:
  /// **'Nur {name} schaut hin und liest vor.'**
  String erzaehlerpult_nur(String name);

  /// Reihum: wie viele Texte warten
  ///
  /// In de, this message translates to:
  /// **'Texte in diesem Abschnitt: {anzahl}'**
  String erzaehlerpult_texte(int anzahl);

  /// Reihum: Pult öffnen
  ///
  /// In de, this message translates to:
  /// **'Ich bin {name}, zeig her'**
  String erzaehlerpult_zeigen(String name);

  /// Reihum: Pult schließen
  ///
  /// In de, this message translates to:
  /// **'Gelesen, zudecken'**
  String get erzaehlerpult_zudecken;

  /// Karte: ein anderes Gerät liest vor
  ///
  /// In de, this message translates to:
  /// **'Vorlesen'**
  String get vorleser_titel;

  /// Karte: wer vorliest
  ///
  /// In de, this message translates to:
  /// **'{name} liest vor.'**
  String vorleser_liest(String name);

  /// Karte: zuhören
  ///
  /// In de, this message translates to:
  /// **'Hört zu. Der Text steht nur dort.'**
  String get vorleser_zuhoeren;

  /// Name, wenn der Erzähler keinen Namen hat
  ///
  /// In de, this message translates to:
  /// **'Der Erzähler'**
  String get vorleser_erzaehler;

  /// Gastgeber: der Erzähler ist weg, die Übernahme kommt
  ///
  /// In de, this message translates to:
  /// **'{name} ist getrennt. Gleich liest du.'**
  String vorleser_frist(String name);

  /// Gastgeber: der Erzähler drückt Weiter
  ///
  /// In de, this message translates to:
  /// **'{name} führt weiter.'**
  String vorleser_fuehrt(String name);

  /// Einrichtung reihum: Namen per Porträt tauschen
  ///
  /// In de, this message translates to:
  /// **'Zwei Porträts antippen tauscht die Namen.'**
  String get abend_tausch_hinweis;

  /// Einrichtung reihum: Bildschirmleser-Beschriftung des Porträts
  ///
  /// In de, this message translates to:
  /// **'Porträt {figur}: Namen tauschen'**
  String abend_tausch_portraet(String figur);

  /// Einrichtung online: Akte ohne Erzähler-Sitz
  ///
  /// In de, this message translates to:
  /// **'Du führst den Abend als Detektiv.'**
  String get abend_platz_hinweis_allein;

  /// Lobby: Sitz eines Geräts
  ///
  /// In de, this message translates to:
  /// **'Platz'**
  String get online_lobby_platz;

  /// Lobby: Figur eines Geräts
  ///
  /// In de, this message translates to:
  /// **'Figur'**
  String get online_lobby_figur;

  /// Lobby: Gerät ohne Sitz
  ///
  /// In de, this message translates to:
  /// **'Figur spielen'**
  String get online_lobby_figur_spielen;

  /// Lobby: Figur lost der Start
  ///
  /// In de, this message translates to:
  /// **'Zufall'**
  String get online_lobby_zufall;

  /// Lobby: gewünschte Figur bzw. wer sie sich wünscht
  ///
  /// In de, this message translates to:
  /// **'Wunsch: {name}'**
  String online_lobby_wunsch(String name);

  /// Lobby: Figur ist schon zugeteilt
  ///
  /// In de, this message translates to:
  /// **'hat {name}'**
  String online_lobby_vergeben(String name);

  /// Lobby: Gerät, das den Raum hält
  ///
  /// In de, this message translates to:
  /// **'Gastgeber'**
  String get online_lobby_gastgeber;

  /// Lobby: Karte zum Zuteilen
  ///
  /// In de, this message translates to:
  /// **'Platz und Figur: {name}'**
  String online_lobby_wahl_titel(String name);

  /// Lobby: Bildschirmleser-Hinweis eines Platzes
  ///
  /// In de, this message translates to:
  /// **'Platz und Figur wählen'**
  String get online_lobby_wahl_hinweis;

  /// Lobby: ohne Detektiv startet der Abend nicht
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst, wer ermittelt. Tippe dazu auf einen Platz.'**
  String get online_lobby_detektiv_fehlt;

  /// Lobby: Zuteilung aus der Gästeliste übernehmen
  ///
  /// In de, this message translates to:
  /// **'Figuren aus der Gästeliste'**
  String get online_lobby_gaesteliste;

  /// Gast-Lobby: eigener Sitz
  ///
  /// In de, this message translates to:
  /// **'Dein Platz'**
  String get online_gast_platz_titel;

  /// Gast-Lobby: zugeteilte Figur
  ///
  /// In de, this message translates to:
  /// **'Deine Figur'**
  String get online_gast_figur_titel;

  /// Gast-Lobby: Detektiv-Sitz
  ///
  /// In de, this message translates to:
  /// **'Du ermittelst heute und spielst keine Figur.'**
  String get online_gast_detektiv_text;

  /// Gast-Lobby: Erzähler-Sitz
  ///
  /// In de, this message translates to:
  /// **'Du liest vor und führst durch den Abend.'**
  String get online_gast_erzaehler_text;

  /// Gast-Lobby: noch keine Figur zugeteilt
  ///
  /// In de, this message translates to:
  /// **'Deine Figur lost der Start.'**
  String get online_gast_zufall_text;

  /// Gast-Lobby: Wunschfigur
  ///
  /// In de, this message translates to:
  /// **'Dein Wunsch'**
  String get online_gast_wunsch_titel;

  /// Gast-Lobby: der Wunsch ist nur ein Hinweis
  ///
  /// In de, this message translates to:
  /// **'Wer zuteilt, sieht deinen Wunsch.'**
  String get online_gast_wunsch_hinweis;

  /// Gast-Lobby: kein Wunsch
  ///
  /// In de, this message translates to:
  /// **'Egal'**
  String get online_gast_kein_wunsch;

  /// Gast-Lobby: Detektiv oder Erzähler teilt zu
  ///
  /// In de, this message translates to:
  /// **'Figuren verteilen'**
  String get online_gast_verteilen_titel;

  /// Raum lehnt den Start ab: Sitze unvollständig
  ///
  /// In de, this message translates to:
  /// **'Es fehlt noch der Detektiv.'**
  String get online_fehler_sitze;

  /// Raum lehnt ab: nur der Detektiv-Sitz
  ///
  /// In de, this message translates to:
  /// **'Das darf nur der Detektiv.'**
  String get online_fehler_nur_detektiv;

  /// Raum lehnt ab: nur wer leitet
  ///
  /// In de, this message translates to:
  /// **'Das darf nur, wer den Abend leitet.'**
  String get online_fehler_nicht_leitung;

  /// Gast: wer leitet, führt weiter
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get online_weiter;

  /// Gast auf dem Erzähler-Sitz: Untertitel
  ///
  /// In de, this message translates to:
  /// **'Du liest vor und drückst „Weiter“.'**
  String get online_erzaehler_hinweis;

  /// Rollenphase für Detektiv und Erzähler
  ///
  /// In de, this message translates to:
  /// **'Alle lesen ihre Rolle. Danach geht es weiter.'**
  String get online_sitz_rollen;

  /// Gruppenwahl für Detektiv und Erzähler
  ///
  /// In de, this message translates to:
  /// **'Die Gäste wählen geheim. Du wählst nicht mit.'**
  String get online_wahl_sitz;

  /// Erzähler: was er zur Runde wissen darf
  ///
  /// In de, this message translates to:
  /// **'Dein Erzählerpaket'**
  String get erzaehler_paket_titel;

  /// Erzählerpaket: Tischgespräche
  ///
  /// In de, this message translates to:
  /// **'Am Tisch'**
  String get erzaehler_paket_tisch;

  /// Erzählerpaket: Befragungen des Detektivs
  ///
  /// In de, this message translates to:
  /// **'Befragungen'**
  String get erzaehler_paket_befragungen;

  /// Erzählerpaket: Wissen der Figuren ohne Spieler
  ///
  /// In de, this message translates to:
  /// **'Ungespielte Gäste'**
  String get erzaehler_paket_npc;

  /// Erzählerpaket: wer mit wem spricht
  ///
  /// In de, this message translates to:
  /// **'{sprecher} mit {partner}'**
  String erzaehler_paket_mit(String sprecher, String partner);

  /// Erzählerpaket: feste Befragung
  ///
  /// In de, this message translates to:
  /// **'fest'**
  String get erzaehler_paket_pflicht;

  /// Erzählerpaket: Zahl der freien Befragungen
  ///
  /// In de, this message translates to:
  /// **'Freie Wahlen in dieser Runde: {n}'**
  String erzaehler_paket_frei(int n);

  /// Erzählerpaket: Fragen einer Befragung
  ///
  /// In de, this message translates to:
  /// **'Fragen'**
  String get erzaehler_paket_fragen;

  /// Erzählerpaket: Antwort in Stichpunkten
  ///
  /// In de, this message translates to:
  /// **'Antwort'**
  String get erzaehler_paket_antwort;

  /// Gastgeber als Erzähler: Marke des Pults
  ///
  /// In de, this message translates to:
  /// **'Erzählerpult'**
  String get erzaehler_pult_marke;

  /// Gastgeber als Erzähler: Zuschauerkarte
  ///
  /// In de, this message translates to:
  /// **'Was der Detektiv tut'**
  String get erzaehler_zuschauer_titel;

  /// Erzähler: der Detektiv entscheidet
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv wählt gerade.'**
  String get erzaehler_detektiv_waehlt;

  /// Erzähler: alle Entscheidungen getroffen
  ///
  /// In de, this message translates to:
  /// **'Die Runde ist ermittelt. Du führst weiter.'**
  String get erzaehler_detektiv_fertig;

  /// Erzähler: Gespräche laufen
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv befragt den Tisch.'**
  String get erzaehler_befragt;

  /// Erzähler: Anklage steht aus
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv erhebt gleich die Anklage.'**
  String get erzaehler_anklage_wartet;

  /// Erzähler: wen der Detektiv angeklagt hat
  ///
  /// In de, this message translates to:
  /// **'Angeklagt: {name}'**
  String erzaehler_angeklagt(String name);

  /// Gast-Detektiv: Optionen der Entscheidung
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Spur. Die Karte zeigt das Ziel.'**
  String get detektiv_gast_optionen;

  /// Gast-Detektiv: Sofortkarte ausspielen
  ///
  /// In de, this message translates to:
  /// **'Spielen: {titel}'**
  String detektiv_gast_karte_spielen(String titel);

  /// Gast-Detektiv: Karte für gründlich
  ///
  /// In de, this message translates to:
  /// **'Gründlich mit Karte: {titel}'**
  String detektiv_gast_karte_gruendlich(String titel);

  /// Gast-Detektiv: Karte beim Tischruf
  ///
  /// In de, this message translates to:
  /// **'Mit Karte: {titel}'**
  String detektiv_gast_karte_ruf(String titel);

  /// Gast-Detektiv: der sichtbare Weg läuft
  ///
  /// In de, this message translates to:
  /// **'Du bist unterwegs.'**
  String get detektiv_gast_unterwegs;

  /// Gast-Detektiv: Anklage wählen
  ///
  /// In de, this message translates to:
  /// **'Wen klagst du an?'**
  String get detektiv_gast_anklage;

  /// Gast-Detektiv: Funde und Antworten
  ///
  /// In de, this message translates to:
  /// **'Dein Notizbuch'**
  String get detektiv_gast_notizen;

  /// Übersicht der Sitze und ihrer Aufgaben je Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Wer macht was'**
  String get rollen_uebersicht_titel;

  /// Knopf zur Übersicht der Sitze
  ///
  /// In de, this message translates to:
  /// **'Wer macht was?'**
  String get rollen_uebersicht_oeffnen;

  /// Übersicht: Untertitel
  ///
  /// In de, this message translates to:
  /// **'Je Abschnitt eine Aufgabe für jeden Platz.'**
  String get rollen_uebersicht_hinweis;

  /// Übersicht: Spielweise Solo
  ///
  /// In de, this message translates to:
  /// **'Allein'**
  String get uebersicht_weise_solo;

  /// Übersicht: Spielweise reihum
  ///
  /// In de, this message translates to:
  /// **'Ein Gerät'**
  String get uebersicht_weise_reihum;

  /// Übersicht: Spielweise online
  ///
  /// In de, this message translates to:
  /// **'Eigene Geräte'**
  String get uebersicht_weise_online;

  /// Übersicht: Sitz
  ///
  /// In de, this message translates to:
  /// **'Detektiv'**
  String get uebersicht_sitz_detektiv;

  /// Übersicht: Sitz
  ///
  /// In de, this message translates to:
  /// **'Erzähler'**
  String get uebersicht_sitz_erzaehler;

  /// Übersicht: Sitz
  ///
  /// In de, this message translates to:
  /// **'Rolle'**
  String get uebersicht_sitz_rolle;

  /// Übersicht: Sitz
  ///
  /// In de, this message translates to:
  /// **'Assistenz'**
  String get uebersicht_sitz_assistenz;

  /// Übersicht: was der Detektiv tut
  ///
  /// In de, this message translates to:
  /// **'Ermittelt und klagt an.'**
  String get uebersicht_sitz_detektiv_kurz;

  /// Übersicht: was der Erzähler tut
  ///
  /// In de, this message translates to:
  /// **'Liest vor und führt weiter.'**
  String get uebersicht_sitz_erzaehler_kurz;

  /// Übersicht: was eine Rolle tut
  ///
  /// In de, this message translates to:
  /// **'Spielt eine Figur mit Geheimnis.'**
  String get uebersicht_sitz_rolle_kurz;

  /// Übersicht: was die Assistenz tut
  ///
  /// In de, this message translates to:
  /// **'Verfolgt den Abend und würfelt mit.'**
  String get uebersicht_sitz_assistenz_kurz;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Rollen'**
  String get uebersicht_phase_rollen;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Auftakt'**
  String get uebersicht_phase_intro;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Gespräche'**
  String get uebersicht_phase_gespraeche;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Ermittlung'**
  String get uebersicht_phase_entscheidungen;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Gruppenwahl'**
  String get uebersicht_phase_gruppenwahl;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Hinweis und Resümee'**
  String get uebersicht_phase_resuemee;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Anklage'**
  String get uebersicht_phase_anklage;

  /// Übersicht: Abschnitt
  ///
  /// In de, this message translates to:
  /// **'Finale und Auflösung'**
  String get uebersicht_phase_finale;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Detektivkarte lesen'**
  String get aufgabe_detektiv_rollen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zuhören, erste Notizen machen'**
  String get aufgabe_detektiv_intro;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Drei bis fünf Personen befragen'**
  String get aufgabe_detektiv_gespraeche;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Spuren auf der Karte wählen'**
  String get aufgabe_detektiv_entscheidungen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Notizen ordnen, die Gruppe wählt'**
  String get aufgabe_detektiv_gruppenwahl;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Hinweis prüfen, Verdacht schärfen'**
  String get aufgabe_detektiv_resuemee;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Eine Person anklagen'**
  String get aufgabe_detektiv_anklage;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Auflösung lesen, Belohnung holen'**
  String get aufgabe_detektiv_finale;

  /// Aufgabe Solo
  ///
  /// In de, this message translates to:
  /// **'Auftakt lesen'**
  String get aufgabe_detektiv_solo_intro;

  /// Aufgabe Solo
  ///
  /// In de, this message translates to:
  /// **'Bots befragen, Antworten notieren'**
  String get aufgabe_detektiv_solo_gespraeche;

  /// Aufgabe Solo
  ///
  /// In de, this message translates to:
  /// **'Hinweis und Resümee lesen'**
  String get aufgabe_detektiv_solo_resuemee;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Warten, bis alle gelesen haben'**
  String get aufgabe_erzaehler_rollen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Den Auftakt vorlesen'**
  String get aufgabe_erzaehler_intro;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Rundenstart vorlesen, Gespräche anleiten'**
  String get aufgabe_erzaehler_gespraeche;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Den Weg des Detektivs begleiten'**
  String get aufgabe_erzaehler_entscheidungen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zur geheimen Wahl aufrufen'**
  String get aufgabe_erzaehler_gruppenwahl;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Hinweis und Resümee vorlesen'**
  String get aufgabe_erzaehler_resuemee;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zur Anklage aufrufen'**
  String get aufgabe_erzaehler_anklage;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Finale und Auflösung vorlesen'**
  String get aufgabe_erzaehler_finale;

  /// Aufgabe reihum (Lesen am Pult)
  ///
  /// In de, this message translates to:
  /// **'Pult öffnen, vorlesen, zudecken'**
  String get aufgabe_erzaehler_reihum;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Eigene Rolle verdeckt lesen'**
  String get aufgabe_rolle_rollen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zuhören, in die Figur finden'**
  String get aufgabe_rolle_intro;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Tischgespräch führen, Befragung beantworten'**
  String get aufgabe_rolle_gespraeche;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Mitraten, würfeln, wenn du dran bist'**
  String get aufgabe_rolle_entscheidungen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Geheim A oder B wählen'**
  String get aufgabe_rolle_gruppenwahl;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zuhören, eigene Spur schützen'**
  String get aufgabe_rolle_resuemee;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Verteidigen oder verdächtigen'**
  String get aufgabe_rolle_anklage;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Auflösung hören, Belohnung holen'**
  String get aufgabe_rolle_finale;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Den Tisch kennenlernen'**
  String get aufgabe_assistenz_rollen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zuhören und mitfiebern'**
  String get aufgabe_assistenz_intro;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Verfolgen, wer mit wem spricht'**
  String get aufgabe_assistenz_gespraeche;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Würfeln, wenn du dran bist'**
  String get aufgabe_assistenz_entscheidungen;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Den Stand der Wahl verfolgen'**
  String get aufgabe_assistenz_gruppenwahl;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Zuhören, mitraten'**
  String get aufgabe_assistenz_resuemee;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Mitraten, wer es war'**
  String get aufgabe_assistenz_anklage;

  /// Aufgabe
  ///
  /// In de, this message translates to:
  /// **'Auflösung lesen, Belohnung holen'**
  String get aufgabe_assistenz_finale;

  /// Erzählerpult: Erzähler-Begleiter öffnen
  ///
  /// In de, this message translates to:
  /// **'Am eigenen Handy lesen'**
  String get erzaehlerpult_handy;

  /// Erzähler-Begleiter: Titel der Karte
  ///
  /// In de, this message translates to:
  /// **'Erzähler am eigenen Handy'**
  String get begleiter_titel;

  /// Erzähler-Begleiter: wie der Erzähler beitritt
  ///
  /// In de, this message translates to:
  /// **'{name} öffnet Mordakte, tippt in der Detektei auf „Beitreten“ und gibt diesen Code ein.'**
  String begleiter_anleitung(String name);

  /// Erzähler-Begleiter: was sich am Tisch-Gerät ändert
  ///
  /// In de, this message translates to:
  /// **'Danach stehen die Texte nur auf dem Handy. Dieses Gerät zeigt, wer vorliest.'**
  String get begleiter_hinweis;

  /// Erzähler-Begleiter: verbunden
  ///
  /// In de, this message translates to:
  /// **'{name} liest jetzt am eigenen Handy.'**
  String begleiter_liest(String name);

  /// Erzähler-Begleiter: Raum ließ sich nicht öffnen
  ///
  /// In de, this message translates to:
  /// **'Dieses Gerät erreicht das Relais nicht. Lest am Pult weiter oder versucht es noch einmal.'**
  String get begleiter_fehler;

  /// Erzähler-Begleiter: erneut öffnen
  ///
  /// In de, this message translates to:
  /// **'Noch einmal versuchen'**
  String get begleiter_nochmal;

  /// Erzähler-Begleiter: Karte schließen, Raum bleibt offen
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Abend'**
  String get begleiter_zurueck;

  /// Erzähler-Begleiter: Raum schließen
  ///
  /// In de, this message translates to:
  /// **'Wieder am Pult lesen'**
  String get begleiter_beenden;

  /// Vorleser-Karte am Tisch-Gerät, während der Erzähler am Handy liest
  ///
  /// In de, this message translates to:
  /// **'Der Text steht auf dem Handy von {name}.'**
  String begleiter_handy_hinweis(String name);

  /// Lobby: Der Detektiv steht, aber der Gastgeber hat keinen Sitz (Detektiv oder Erzähler)
  ///
  /// In de, this message translates to:
  /// **'Du brauchst selbst einen Platz. Tippe dazu auf deine Karte.'**
  String get online_lobby_gastgeber_platz;

  /// Druck: Die Datei entsteht beim ersten Tipp
  ///
  /// In de, this message translates to:
  /// **'Die Datei wird erstellt …'**
  String get druck_datei_laedt;

  /// Druck im Browser: Der zweite Tipp teilt die fertige Datei
  ///
  /// In de, this message translates to:
  /// **'Teilen: {datei}'**
  String druck_datei_teilen(String datei);

  /// Druck im Browser: Der zweite Tipp lädt die fertige Datei herunter
  ///
  /// In de, this message translates to:
  /// **'Herunterladen: {datei}'**
  String druck_datei_laden(String datei);

  /// Druck: Erstellen oder Teilen der Datei ist gescheitert
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt. Versuch es bitte noch einmal.'**
  String get druck_datei_fehler;

  /// Druckfassung: Überschrift der Rollenhefte je Person
  ///
  /// In de, this message translates to:
  /// **'Rollenhefte einzeln senden'**
  String get druck_je_person;

  /// Druckfassung: Hinweis zu den Rollenheften je Person
  ///
  /// In de, this message translates to:
  /// **'Jede Person bekommt nur ihr eigenes Heft. Die Hefte gelten nur mit diesem Fall-Code.'**
  String get druck_je_person_hinweis;

  /// Druckfassung: Rollenheft einer Person teilen
  ///
  /// In de, this message translates to:
  /// **'Senden an {name}'**
  String druck_senden_an(String name);

  /// Rollenvergabe reihum: Erzählerheft ohne Druckspiel
  ///
  /// In de, this message translates to:
  /// **'Für den Erzähler: alle Texte zum Vorlesen, der Tisch und die Antworten der Befragungen. Der Detektiv liest es nicht.'**
  String get druck_erzaehlerheft_hinweis;

  /// Druckmappe: Hinweis zur Erzählerakte (A-063), nur für die Person, die erzählt
  ///
  /// In de, this message translates to:
  /// **'Nur für die Person, die erzählt: Hintergründe und Netz aller Figuren. Die Akte nennt nie den Täter. Gib sie nicht weiter.'**
  String get druck_erzaehlerakte_hinweis;

  /// Akte: Knopf zu Steckbriefen und Charakterübersicht
  ///
  /// In de, this message translates to:
  /// **'Steckbriefe & Übersicht'**
  String get detektei_akte_steckbriefe;

  /// Steckbrief-Seite: Titel
  ///
  /// In de, this message translates to:
  /// **'Steckbriefe & Übersicht'**
  String get steckbrief_titel;

  /// Steckbrief-Seite: Hinweis unter dem Titel
  ///
  /// In de, this message translates to:
  /// **'Für die Wochen vor dem Abend: ohne Geheimnisse und ohne Fall-Code. Ihr dürft alles verschicken.'**
  String get steckbrief_hinweis;

  /// Steckbrief-Seite: Personenzahl
  ///
  /// In de, this message translates to:
  /// **'Wie viele seid ihr?'**
  String get steckbrief_personen;

  /// Steckbrief-Seite: Personenzahl noch offen
  ///
  /// In de, this message translates to:
  /// **'Wissen wir noch nicht'**
  String get steckbrief_personen_offen;

  /// Steckbrief-Seite: Personenzahl steht fest
  ///
  /// In de, this message translates to:
  /// **'Steht fest'**
  String get steckbrief_personen_fest;

  /// Steckbrief-Seite: gewählte Personenzahl
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Personen am Tisch, dazu der Detektiv'**
  String steckbrief_personen_wert(String anzahl);

  /// Steckbrief-Seite: Dateien
  ///
  /// In de, this message translates to:
  /// **'Zum Verschicken'**
  String get steckbrief_dateien;

  /// Steckbrief-Seite: Gästeliste
  ///
  /// In de, this message translates to:
  /// **'Gästeliste'**
  String get steckbrief_gaeste;

  /// Steckbrief-Seite: Hinweis zur Gästeliste
  ///
  /// In de, this message translates to:
  /// **'Tragt ein, wer welche Figur spielt. Am Abend stehen die Namen schon in der Einrichtung.'**
  String get steckbrief_gaeste_hinweis;

  /// Steckbrief-Seite: neuer Gast
  ///
  /// In de, this message translates to:
  /// **'Gast eintragen'**
  String get steckbrief_gast_neu;

  /// Steckbrief-Seite: Name eines Gastes
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get steckbrief_gast_name;

  /// Steckbrief-Seite: Gast ohne Figur
  ///
  /// In de, this message translates to:
  /// **'Noch keine Figur'**
  String get steckbrief_gast_ohne;

  /// Steckbrief-Seite: gewählte Figur fällt bei dieser Personenzahl weg
  ///
  /// In de, this message translates to:
  /// **'Bei {anzahl} Personen nicht dabei'**
  String steckbrief_gast_nicht_dabei(String anzahl);

  /// Steckbrief-Seite: Gast löschen
  ///
  /// In de, this message translates to:
  /// **'Gast entfernen'**
  String get steckbrief_gast_entfernen;

  /// Steckbrief-Seite: Steckbrief eines Gastes teilen
  ///
  /// In de, this message translates to:
  /// **'Steckbrief senden'**
  String get steckbrief_senden;

  /// Lobby des Gastgebers: Figuren der Gästeliste, die bei dieser Rollenzahl wegfallen (Figur und Gast)
  ///
  /// In de, this message translates to:
  /// **'Bei {anzahl} Rollen nicht dabei: {figuren}.'**
  String online_lobby_gaesteliste_weg(int anzahl, String figuren);

  /// Gast, Akte ohne Erzähler-Sitz (Altakte): Der Gastgeber wählt eine Option (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung wählt gerade …'**
  String get online_ermittlung_wartet_leitung;

  /// Gast, Altakte: Abstecher läuft (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung erkundet einen Ort.'**
  String get online_abstecher_leitung;

  /// Gast, Altakte: Weg auf der Karte läuft (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung ist unterwegs …'**
  String get online_zug_aktion_leitung;

  /// Gast, Altakte: Tischruf nach Pech (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Pech. Die Spielleitung entscheidet, wie es weitergeht.'**
  String get online_tischruf_wartet_leitung;

  /// Gast, Altakte: Fund wird gelesen (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung liest den Fund.'**
  String get online_fund_wartet_leitung;

  /// Gast, Altakte: Anklage (Wortlaut wie vor M3)
  ///
  /// In de, this message translates to:
  /// **'Die Spielleitung erhebt die Anklage gegen eine dieser Personen.'**
  String get online_anklage_wartet_leitung;

  /// Mitten im Abend wechselt der Platz dieses Geräts: jetzt Detektiv-Sitz
  ///
  /// In de, this message translates to:
  /// **'Du ermittelst jetzt.'**
  String get online_platz_neu_detektiv;

  /// Mitten im Abend wechselt der Platz dieses Geräts: jetzt Erzähler-Sitz
  ///
  /// In de, this message translates to:
  /// **'Du liest jetzt vor.'**
  String get online_platz_neu_erzaehler;

  /// Mitten im Abend wechselt der Platz dieses Geräts: jetzt eine Figur
  ///
  /// In de, this message translates to:
  /// **'Du spielst jetzt {figur}.'**
  String online_platz_neu_rolle(String figur);

  /// Mitten im Abend wechselt der Platz dieses Geräts: jetzt ohne Figur
  ///
  /// In de, this message translates to:
  /// **'Du schaust jetzt zu.'**
  String get online_platz_neu_assistenz;

  /// Gastgeber: Der Gast auf dem Detektiv-Sitz ist getrennt
  ///
  /// In de, this message translates to:
  /// **'{name} ermittelt und ist getrennt. Kommt {name} nicht zurück, gib den Detektiv-Sitz weiter.'**
  String online_detektiv_weg(String name);

  /// Gastgeber: Knopf, der den Detektiv-Sitz neu vergibt
  ///
  /// In de, this message translates to:
  /// **'Detektiv-Sitz weitergeben'**
  String get online_detektiv_weitergeben;

  /// Gastgeber: Karteikarte zur Wahl des neuen Detektivs
  ///
  /// In de, this message translates to:
  /// **'Wer ermittelt weiter?'**
  String get online_detektiv_wer;

  /// Gastgeber: Wer den Sitz übernimmt, bekommt dessen Platz nicht mehr
  ///
  /// In de, this message translates to:
  /// **'Wer übernimmt, tauscht den Platz mit {name}.'**
  String online_detektiv_wer_hinweis(String name);

  /// Gastgeber: übernimmt den Detektiv-Sitz selbst
  ///
  /// In de, this message translates to:
  /// **'Ich ermittle selbst'**
  String get online_detektiv_ich;

  /// Gastgeber: Meldung nach dem Wechsel des Detektiv-Sitzes
  ///
  /// In de, this message translates to:
  /// **'{name} ermittelt jetzt.'**
  String online_detektiv_neu(String name);

  /// Rundenuhr: Knopf, gibt fünf Minuten dazu
  ///
  /// In de, this message translates to:
  /// **'Fünf Minuten dazu'**
  String get party_runde_plus;

  /// Rundenuhr: Knopf nach einer Pause
  ///
  /// In de, this message translates to:
  /// **'Uhr weiterlaufen lassen'**
  String get party_runde_weiterlaufen;

  /// Rundenuhr: Marke, wenn die Uhr steht
  ///
  /// In de, this message translates to:
  /// **'Angehalten'**
  String get party_runde_angehalten;

  /// Rundenuhr: wer sie stellt, auf Geräten ohne Knöpfe
  ///
  /// In de, this message translates to:
  /// **'Die Uhr stellt {name}.'**
  String party_runde_stellt(String name);

  /// Diashow der Einleitung: zum nächsten Bild
  ///
  /// In de, this message translates to:
  /// **'Nächstes Bild'**
  String get party_intro_naechstes;

  /// Diashow der Einleitung: Zähler und Beschriftung für den Bildschirmleser
  ///
  /// In de, this message translates to:
  /// **'Bild {nr} von {anzahl}'**
  String party_intro_bild(String nr, String anzahl);

  /// Langer Abend (M7b): Marke des Rundgangs vor dem Abend (Unterzustand der Einleitung)
  ///
  /// In de, this message translates to:
  /// **'Vorspiel'**
  String get rundgang_vorspiel;

  /// Langer Abend (M7b): Marke des Rundgangs nach der Auflösung (Unterzustand des Endes)
  ///
  /// In de, this message translates to:
  /// **'Der Morgen'**
  String get rundgang_morgen;

  /// Langer Abend (M7b): Marke über der Station, Rundgang und Uhrzeit der Station
  ///
  /// In de, this message translates to:
  /// **'{teil} · {uhrzeit}'**
  String rundgang_marke(String teil, String uhrzeit);

  /// Langer Abend (M7b): Zähler der Stationen eines Rundgangs
  ///
  /// In de, this message translates to:
  /// **'Station {nr} von {anzahl}'**
  String rundgang_station(String nr, String anzahl);

  /// Langer Abend (M7b): zur nächsten Station des Rundgangs
  ///
  /// In de, this message translates to:
  /// **'Nächste Station'**
  String get rundgang_weiter;

  /// Langer Abend (M7b): letzte Station des Vorspiels, danach Diashow und Einleitung
  ///
  /// In de, this message translates to:
  /// **'Weiter zur Einleitung'**
  String get rundgang_zur_einleitung;

  /// Langer Abend (M7b): letzte Station des Morgens, danach die geschlossene Akte
  ///
  /// In de, this message translates to:
  /// **'Weiter zum Schluss'**
  String get rundgang_zum_schluss;

  /// Langer Abend (M7b): den Rest von Vorspiel oder Morgen überspringen
  ///
  /// In de, this message translates to:
  /// **'Rundgang überspringen'**
  String get rundgang_ueberspringen;

  /// Langer Abend (M7b): Fuß des Rundgangs auf Geräten, die nicht weiterschalten
  ///
  /// In de, this message translates to:
  /// **'{name} führt durch den Rundgang.'**
  String rundgang_fuehrt(String name);

  /// Langer Abend (M7b): Gast sieht, dass der Rundgang vor dem Abend läuft
  ///
  /// In de, this message translates to:
  /// **'Das Vorspiel läuft.'**
  String get rundgang_laeuft_vorspiel;

  /// Langer Abend (M7b): Gast sieht, dass der Rundgang am Morgen läuft
  ///
  /// In de, this message translates to:
  /// **'Der Morgen läuft.'**
  String get rundgang_laeuft_morgen;

  /// Langer Abend (M7b): Beschriftung der Karte für den Bildschirmleser
  ///
  /// In de, this message translates to:
  /// **'Karte des Rundgangs. Der Detektiv geht zur Station.'**
  String get rundgang_karte_semantik;

  /// Einstimmung (A-063): Name des ersten Teils im Kapitelzähler
  ///
  /// In de, this message translates to:
  /// **'Vorgeschichte'**
  String get einstimmung_vorgeschichte;

  /// Einstimmung (A-063): Name des zweiten Teils im Kapitelzähler
  ///
  /// In de, this message translates to:
  /// **'Vorstellung'**
  String get einstimmung_vorstellung;

  /// Einstimmung (A-063): Kapitelzähler über dem Titel, etwa „Vorgeschichte · 3 von 7“
  ///
  /// In de, this message translates to:
  /// **'{teil} · {nr} von {von}'**
  String einstimmung_zaehler(String teil, String nr, String von);

  /// Einstimmung (A-063): zum nächsten Schritt
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get einstimmung_weiter;

  /// Einstimmung (A-063): letzter Schritt im langen Abend, danach das Vorspiel
  ///
  /// In de, this message translates to:
  /// **'Weiter zum Vorspiel'**
  String get einstimmung_zum_vorspiel;

  /// Einstimmung (A-063): den Rest der Vorgeschichte überspringen
  ///
  /// In de, this message translates to:
  /// **'Vorgeschichte überspringen'**
  String get einstimmung_ueberspringen_vorgeschichte;

  /// Einstimmung (A-063): den Rest der Vorstellung überspringen
  ///
  /// In de, this message translates to:
  /// **'Vorstellung überspringen'**
  String get einstimmung_ueberspringen_vorstellung;

  /// Einstimmung (A-063): unter der Vorstellungskarte, wer die Figur am Tisch spielt (nie im Vorlesetext)
  ///
  /// In de, this message translates to:
  /// **'gespielt von {name}'**
  String einstimmung_gespielt_von(String name);

  /// Einstimmung (A-063): unter der Vorstellungskarte im Solo oder bei einer Rolle ohne Gerät
  ///
  /// In de, this message translates to:
  /// **'Die App spielt {name}'**
  String einstimmung_app_spielt(String name);

  /// Einstimmung (A-063): Gast, dessen Figur gerade vorgestellt wird
  ///
  /// In de, this message translates to:
  /// **'Du bist dran'**
  String get einstimmung_du_bist_dran;

  /// Einstimmung (A-063): Fuß auf Geräten, die nicht weiterschalten
  ///
  /// In de, this message translates to:
  /// **'{name} führt durch die Einstimmung.'**
  String einstimmung_fuehrt(String name);

  /// Einstimmung (A-063): Gast sieht, dass Vorgeschichte oder Vorstellung läuft
  ///
  /// In de, this message translates to:
  /// **'Die Einstimmung läuft.'**
  String get einstimmung_laeuft;

  /// Assistent (A-063): Überschrift des Schalters für Vorgeschichte und Vorstellung
  ///
  /// In de, this message translates to:
  /// **'Einstimmung'**
  String get abend_einstimmung_titel;

  /// Assistent (A-063): Schalter für die Einstimmung vor dem Auftakt
  ///
  /// In de, this message translates to:
  /// **'Vorgeschichte und Vorstellung'**
  String get abend_einstimmung_schalter;

  /// Assistent (A-063): Erklärung unter dem Schalter
  ///
  /// In de, this message translates to:
  /// **'Vor dem Auftakt: erst die Vorgeschichte, dann wird jede Figur vorgestellt.'**
  String get abend_einstimmung_hinweis;

  /// Assistent (A-063): Dauer der Einstimmung bei der gewählten Personenzahl
  ///
  /// In de, this message translates to:
  /// **'Dauert etwa {minuten} Minuten.'**
  String abend_einstimmung_dauer(int minuten);

  /// Assistent (A-063): Zeile der Startübersicht
  ///
  /// In de, this message translates to:
  /// **'Einstimmung'**
  String get abend_start_einstimmung;

  /// Assistent (A-063): Startübersicht, Einstimmung eingeschaltet
  ///
  /// In de, this message translates to:
  /// **'Vorgeschichte und Vorstellung'**
  String get abend_einstimmung_an;

  /// Assistent (A-063): Startübersicht, ohne Einstimmung
  ///
  /// In de, this message translates to:
  /// **'Direkt zum Auftakt'**
  String get abend_einstimmung_aus;

  /// Wer macht was (A-063): Abschnitt Vorgeschichte und Vorstellung
  ///
  /// In de, this message translates to:
  /// **'Einstimmung'**
  String get uebersicht_phase_einstimmung;

  /// Wer macht was (A-063): Detektiv in der Einstimmung
  ///
  /// In de, this message translates to:
  /// **'Zuhören, die Gäste kennenlernen'**
  String get aufgabe_detektiv_einstimmung;

  /// Wer macht was (A-063): Erzähler in der Einstimmung
  ///
  /// In de, this message translates to:
  /// **'Vorgeschichte lesen, Figuren vorstellen'**
  String get aufgabe_erzaehler_einstimmung;

  /// Wer macht was (A-063): Rolle in der Einstimmung
  ///
  /// In de, this message translates to:
  /// **'Zuhören, die anderen Figuren kennenlernen'**
  String get aufgabe_rolle_einstimmung;

  /// Wer macht was (A-063): Assistenz in der Einstimmung
  ///
  /// In de, this message translates to:
  /// **'Zuhören und die Runde kennenlernen'**
  String get aufgabe_assistenz_einstimmung;

  /// Erzählerakte (A-063): Knopf und Titel, nur auf dem Erzähler-Platz
  ///
  /// In de, this message translates to:
  /// **'Erzählerakte'**
  String get erzaehlerakte_titel;

  /// Erzählerakte (A-063): Zeile unter dem Eintrag in der Rollenphase
  ///
  /// In de, this message translates to:
  /// **'Hintergründe und Netz aller Figuren'**
  String get erzaehlerakte_eintrag;

  /// Erzählerakte (A-063): Eintrag in der Rollenphase, für wen sie ist
  ///
  /// In de, this message translates to:
  /// **'Für {name}'**
  String erzaehlerakte_fuer(String name);

  /// Erzählerakte (A-063): Reiter mit allen Figuren
  ///
  /// In de, this message translates to:
  /// **'Figuren'**
  String get erzaehlerakte_reiter_figuren;

  /// Erzählerakte (A-063): Reiter mit dem Beziehungsnetz
  ///
  /// In de, this message translates to:
  /// **'Netz'**
  String get erzaehlerakte_reiter_netz;

  /// Erzählerakte (A-063): Hinweis unter dem Netz
  ///
  /// In de, this message translates to:
  /// **'Tipp auf eine Figur zeigt ihre Bindungen.'**
  String get erzaehlerakte_netz_tipp;

  /// Erzählerakte (A-063): Auswahl im Netz aufheben
  ///
  /// In de, this message translates to:
  /// **'Alle Bindungen'**
  String get erzaehlerakte_netz_alle;

  /// Erzählerakte (A-063): die Akte des Abends als PDF, nur auf dem Erzähler-Platz
  ///
  /// In de, this message translates to:
  /// **'Als PDF'**
  String get erzaehlerakte_pdf;

  /// Erzählerakte (A-063): Bildschirmleser für eine Figur im Netz
  ///
  /// In de, this message translates to:
  /// **'{name}, {anzahl} Bindungen'**
  String erzaehlerakte_figur_semantik(String name, int anzahl);

  /// Gast: Überschrift der gemeinsamen Rundenuhr
  ///
  /// In de, this message translates to:
  /// **'Zeit für diese Runde'**
  String get online_uhr_titel;

  /// Gast, der leitet: Knopf der Rundenuhr
  ///
  /// In de, this message translates to:
  /// **'Uhr starten'**
  String get online_uhr_start;

  /// Gast, der leitet: Knopf der Rundenuhr
  ///
  /// In de, this message translates to:
  /// **'Uhr anhalten'**
  String get online_uhr_pause;

  /// Gast: Stempel, wenn die Rundenzeit um ist
  ///
  /// In de, this message translates to:
  /// **'Die Zeit ist um.'**
  String get online_uhr_um;

  /// Gastgeber: Den Detektiv-Sitz übernimmt nur der Gastgeber oder ein Gerät ohne Figur (A-062)
  ///
  /// In de, this message translates to:
  /// **'Wer eine Figur spielt, behält sie. Übernehmen kannst du selbst oder ein Platz ohne Figur.'**
  String get online_detektiv_wer_figuren;

  /// Einrichtung (M7b): Überschrift der Wahl kurzer oder langer Abend, nur Akten mit Langfassung
  ///
  /// In de, this message translates to:
  /// **'Länge des Abends'**
  String get abend_fassung_titel;

  /// Einrichtung und Startübersicht (M7b): der kurze Abend
  ///
  /// In de, this message translates to:
  /// **'Kurzer Abend'**
  String get abend_fassung_kurz;

  /// Einrichtung und Startübersicht (M7b): der lange Abend mit Streifzug
  ///
  /// In de, this message translates to:
  /// **'Langer Abend'**
  String get abend_fassung_lang;

  /// Einrichtung (M7b): Wahl der Fassung mit geschätzter Abendlänge bei der Vorgabe ihrer Rundendauer
  ///
  /// In de, this message translates to:
  /// **'{fassung} · ca. {minuten} Min.'**
  String abend_fassung_mit_dauer(String fassung, int minuten);

  /// Einrichtung (M7b): Hinweis unter der Wahl, kurzer Abend gewählt
  ///
  /// In de, this message translates to:
  /// **'Der gewohnte Abend am Tisch.'**
  String get abend_fassung_hinweis_kurz;

  /// Einrichtung (M7b): Hinweis unter der Wahl, langer Abend gewählt
  ///
  /// In de, this message translates to:
  /// **'Streifzug durch Schloss, Hof und Garten.'**
  String get abend_fassung_hinweis_lang;

  /// Einrichtung (M7b): geschätzte Länge des ganzen Abends unter der Rundendauer (K-18)
  ///
  /// In de, this message translates to:
  /// **'Ganzer Abend: ca. {minuten} Min.'**
  String abend_dauer_ca(int minuten);

  /// Einrichtung (M7b): Im langen Abend deckt die Rundenuhr Gespräche und Entscheidungen ab
  ///
  /// In de, this message translates to:
  /// **'Die Uhr läuft über den ganzen Streifzug.'**
  String get abend_dauer_lang_hinweis;

  /// Startübersicht (M7b): geschätzte Länge des Abends
  ///
  /// In de, this message translates to:
  /// **'ca. {minuten} Min.'**
  String abend_ca_minuten(int minuten);

  /// Startübersicht (M7b): kurzer oder langer Abend
  ///
  /// In de, this message translates to:
  /// **'Abend'**
  String get abend_start_fassung;

  /// Dein Moment (Finale §3): Assistent: Überschrift des Schalters
  ///
  /// In de, this message translates to:
  /// **'Dein Moment'**
  String get abend_moment_titel;

  /// Dein Moment (Finale §3): Assistent: Beschriftung des Schalters
  ///
  /// In de, this message translates to:
  /// **'Heimliche Züge in jeder Runde'**
  String get abend_moment_schalter;

  /// Dein Moment (Finale §3): Assistent: Hinweis unter dem Schalter
  ///
  /// In de, this message translates to:
  /// **'Jede Rolle zieht geheim und formt Würfel, Zeit und Gerüchte. Aus: Gruppenwahl wie bisher.'**
  String get abend_moment_hinweis;

  /// Dein Moment (Finale §3): Startübersicht: Feldname
  ///
  /// In de, this message translates to:
  /// **'Dein Moment'**
  String get abend_start_moment;

  /// Dein Moment (Finale §3): Startübersicht: Wert an
  ///
  /// In de, this message translates to:
  /// **'an'**
  String get abend_moment_an;

  /// Dein Moment (Finale §3): Startübersicht: Wert aus
  ///
  /// In de, this message translates to:
  /// **'aus'**
  String get abend_moment_aus;

  /// Dein Moment (Finale §3): Wer macht was: Rolle in den Gesprächen mit Schicht (höchstens acht Wörter)
  ///
  /// In de, this message translates to:
  /// **'Gespräch führen, geheim deinen Moment ziehen'**
  String get aufgabe_rolle_moment;

  /// Dein Moment (Finale §3): Wer macht was: Detektiv in der Ermittlung mit Schicht
  ///
  /// In de, this message translates to:
  /// **'Tischwerte lesen, nach Pech gemeinsam rufen'**
  String get aufgabe_detektiv_tischwerte;

  /// Dein Moment (Finale §3): Wer macht was: Erzähler in der Ermittlung mit Schicht
  ///
  /// In de, this message translates to:
  /// **'Zu Beginn der Ermittlung die Folgen vorlesen'**
  String get aufgabe_erzaehler_folgen;

  /// Dein Moment (Finale §3): Überschrift der Liste und der verdeckten Ansicht
  ///
  /// In de, this message translates to:
  /// **'Dein Moment'**
  String get moment_titel;

  /// Dein Moment (Finale §3): Hinweis über der Liste am Tisch
  ///
  /// In de, this message translates to:
  /// **'Reihum zieht jede Person geheim einen Zug. Erst dann geht es weiter.'**
  String get moment_hinweis;

  /// Dein Moment (Finale §3): Zeile je Person in der Liste
  ///
  /// In de, this message translates to:
  /// **'Dein Moment: {zustand}'**
  String moment_zeile(String zustand);

  /// Dein Moment (Finale §3): Zustand: noch nicht gezogen
  ///
  /// In de, this message translates to:
  /// **'offen'**
  String get moment_offen;

  /// Dein Moment (Finale §3): Zustand: gezogen
  ///
  /// In de, this message translates to:
  /// **'fertig'**
  String get moment_fertig;

  /// Dein Moment (Finale §3): Liste: alle fertig
  ///
  /// In de, this message translates to:
  /// **'Alle haben ihren Moment gezogen.'**
  String get moment_alle;

  /// Dein Moment (Finale §3): Solo: Hinweis statt Liste
  ///
  /// In de, this message translates to:
  /// **'Die Rollen der App ziehen ihren Moment selbst.'**
  String get moment_solo;

  /// Dein Moment (Finale §3): Zwischenstufe: Gerät weitergeben
  ///
  /// In de, this message translates to:
  /// **'Gib das Gerät an {name}.'**
  String moment_weitergeben(String name);

  /// Dein Moment (Finale §3): Zwischenstufe: Knopf
  ///
  /// In de, this message translates to:
  /// **'Ich bin {name}, zeig her'**
  String moment_zeig_her(String name);

  /// Dein Moment (Finale §3): Zwischenstufe: Abbruch
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get moment_zurueck;

  /// Dein Moment (Finale §3): Abschnitt mit den privaten Nachrichten der Vorrunde
  ///
  /// In de, this message translates to:
  /// **'Was du erfahren hast'**
  String get moment_erfahren;

  /// Dein Moment (Finale §3): Keine privaten Nachrichten
  ///
  /// In de, this message translates to:
  /// **'Diesmal hast du nichts erfahren.'**
  String get moment_nichts;

  /// Dein Moment (Finale §3): Abschnitt mit den zwei Sternen
  ///
  /// In de, this message translates to:
  /// **'Deine Ziele'**
  String get moment_ziele;

  /// Dein Moment (Finale §3): Kopf einer Sternkarte
  ///
  /// In de, this message translates to:
  /// **'Stern {nr}'**
  String moment_stern(int nr);

  /// Dein Moment (Finale §3): Stand eines Sterns
  ///
  /// In de, this message translates to:
  /// **'offen'**
  String get moment_stand_offen;

  /// Dein Moment (Finale §3): Stand eines Sterns
  ///
  /// In de, this message translates to:
  /// **'erreicht'**
  String get moment_stand_erreicht;

  /// Dein Moment (Finale §3): Stand eines Sterns
  ///
  /// In de, this message translates to:
  /// **'verloren'**
  String get moment_stand_verloren;

  /// Dein Moment (Finale §3): Abschnitt mit dem Raster der Züge
  ///
  /// In de, this message translates to:
  /// **'Dein Zug'**
  String get moment_zug_waehlen;

  /// Dein Moment (Finale §3): Ausgegraute Kachel eines Einmal-Zugs
  ///
  /// In de, this message translates to:
  /// **'Schon gespielt'**
  String get moment_einmal;

  /// Dein Moment (Finale §3): Ausgegraute Kachel ohne erlaubtes Ziel
  ///
  /// In de, this message translates to:
  /// **'Gerade nicht möglich'**
  String get moment_gesperrt;

  /// Dein Moment (Finale §3): Zielwahl beim Decken: sich selbst
  ///
  /// In de, this message translates to:
  /// **'Ich selbst'**
  String get moment_ich_selbst;

  /// Dein Moment (Finale §3): Tipp: niemand
  ///
  /// In de, this message translates to:
  /// **'Keine Ahnung'**
  String get moment_keine_ahnung;

  /// Dein Moment (Finale §3): Knopf: Zug bestätigen und zudecken
  ///
  /// In de, this message translates to:
  /// **'Das ist mein Zug'**
  String get moment_bestaetigen;

  /// Dein Moment (Finale §3): Kachel: denselben Zug wie in der Runde davor
  ///
  /// In de, this message translates to:
  /// **'Wie letzte Runde'**
  String get moment_wie_letzte;

  /// Dein Moment (Finale §3): Kurzform eines Zugs mit Ziel
  ///
  /// In de, this message translates to:
  /// **'{zug} auf {name}'**
  String moment_zug_auf(String zug, String name);

  /// Dein Moment (Finale §3): Zug steht schon, lässt sich bis zu den Folgen ändern
  ///
  /// In de, this message translates to:
  /// **'Gezogen: {zug}'**
  String moment_dein_zug(String zug);

  /// Dein Moment (Finale §3): Protokoll: kein Zug
  ///
  /// In de, this message translates to:
  /// **'abgewartet'**
  String get moment_abgewartet;

  /// Dein Moment (Finale §3): Dossier: erster Stichpunkt (R17)
  ///
  /// In de, this message translates to:
  /// **'Jede Runde ziehst du geheim einen Zug'**
  String get moment_erklaerung_1;

  /// Dein Moment (Finale §3): Dossier: zweiter Stichpunkt (R17)
  ///
  /// In de, this message translates to:
  /// **'Er formt Würfel, Zeit und Gerüchte'**
  String get moment_erklaerung_2;

  /// Dein Moment (Finale §3): Dossier: dritter Stichpunkt (R17)
  ///
  /// In de, this message translates to:
  /// **'Zwei Sterne sind deine geheimen Ziele'**
  String get moment_erklaerung_3;

  /// Dein Moment (Finale §3): Gast: nach dem Senden
  ///
  /// In de, this message translates to:
  /// **'Dein Zug steht. Bis zu den Folgen kannst du ihn ändern.'**
  String get moment_gezogen_online;

  /// Dein Moment (Finale §3): Wer leitet: Knopf, wenn noch nicht alle gezogen haben
  ///
  /// In de, this message translates to:
  /// **'Letzter Aufruf'**
  String get moment_aufruf_knopf;

  /// Dein Moment (Finale §3): Wer leitet: Hinweis über dem Knopf
  ///
  /// In de, this message translates to:
  /// **'Noch nicht alle haben ihren Moment gezogen.'**
  String get moment_aufruf_hinweis;

  /// Dein Moment (Finale §3): Countdown nach dem letzten Aufruf
  ///
  /// In de, this message translates to:
  /// **'Letzter Aufruf: noch {sekunden} Sekunden'**
  String moment_aufruf_laeuft(int sekunden);

  /// Dein Moment (Finale §3): Nach dem Countdown
  ///
  /// In de, this message translates to:
  /// **'Wer jetzt nicht gezogen hat, wartet diese Runde ab.'**
  String get moment_aufruf_vorbei;

  /// Dein Moment (Finale §3): Hinweis für Sitze ohne Figur
  ///
  /// In de, this message translates to:
  /// **'Alle ziehen gerade ihren Moment.'**
  String get moment_warten;

  /// Dein Moment (Finale §3): Zu Beginn der Ermittlung
  ///
  /// In de, this message translates to:
  /// **'Die Folgen eures Moments'**
  String get einfluss_folgen_titel;

  /// Dein Moment (Finale §3): Knopf nach den Folgen
  ///
  /// In de, this message translates to:
  /// **'Zur Ermittlung'**
  String get einfluss_folgen_weiter;

  /// Dein Moment (Finale §3): Solo: Reaktionen der Rollen der App
  ///
  /// In de, this message translates to:
  /// **'Am Tisch geraunt'**
  String get einfluss_blasen_titel;

  /// Dein Moment (Finale §3): Chancenvorschau: Zeile Tischwert
  ///
  /// In de, this message translates to:
  /// **'Tisch'**
  String get einfluss_tisch;

  /// Dein Moment (Finale §3): Chancenvorschau: Bonus nach einem Umweg
  ///
  /// In de, this message translates to:
  /// **'Umweg'**
  String get einfluss_umweg;

  /// Dein Moment (Finale §3): Fundkarte und Notizbuch: Kopf einer Randnotiz
  ///
  /// In de, this message translates to:
  /// **'Randnotiz'**
  String get einfluss_randnotiz;

  /// Dein Moment (Finale §3.6): Notizbuch: Kopf eines ausgepackten Fakts, mit dem Namen am Tisch
  ///
  /// In de, this message translates to:
  /// **'Ausgepackt: {name}'**
  String einfluss_ausgepackt(String name);

  /// Dein Moment (Finale §3): Leisten Zusammenhalt und Spuk
  ///
  /// In de, this message translates to:
  /// **'Stimmung am Tisch'**
  String get einfluss_leisten_titel;

  /// Dein Moment (Finale §3): Name der Leiste
  ///
  /// In de, this message translates to:
  /// **'Zusammenhalt'**
  String get einfluss_zusammenhalt;

  /// Dein Moment (Finale §3): Name der Leiste
  ///
  /// In de, this message translates to:
  /// **'Spuk'**
  String get einfluss_spuk;

  /// Dein Moment (Finale §3): Stand einer Leiste
  ///
  /// In de, this message translates to:
  /// **'{wert} von {max}'**
  String einfluss_leiste_stand(int wert, int max);

  /// Dein Moment (Finale §3): Resümee: Ereignisse
  ///
  /// In de, this message translates to:
  /// **'Was in dieser Runde geschah'**
  String get einfluss_ereignisse_titel;

  /// Dein Moment (Finale §3): Resümee: Funde, die bis jetzt warteten
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichtbar'**
  String get einfluss_nachgereicht_titel;

  /// Dein Moment (Finale §3): Anklage: Zahl der Nachfragen
  ///
  /// In de, this message translates to:
  /// **'Offene Nachfragen: {n}'**
  String einfluss_nachfrage_offen(int n);

  /// Dein Moment (Finale §3): Anklage: Auswahl der Option
  ///
  /// In de, this message translates to:
  /// **'Zu welcher Wahl fragst du nach?'**
  String get einfluss_nachfrage_waehlen;

  /// Dein Moment (Finale §3): Anklage: Knopf
  ///
  /// In de, this message translates to:
  /// **'Nachfragen'**
  String get einfluss_nachfrage_knopf;

  /// Dein Moment (Finale §3): Auflösung: alle Züge
  ///
  /// In de, this message translates to:
  /// **'Protokoll der Nacht'**
  String get einfluss_protokoll_titel;

  /// Dein Moment (Finale §3): Auflösung: Kopf einer Runde
  ///
  /// In de, this message translates to:
  /// **'Runde {nr}'**
  String einfluss_runde(int nr);

  /// Dein Moment (Finale §3): Auflösung: Zug der App für eine Rolle ohne Mensch
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get einfluss_bot;

  /// Dein Moment (Finale §3): Auflösung: Sterne je Figur
  ///
  /// In de, this message translates to:
  /// **'Sterne der Nacht'**
  String get einfluss_sterne_titel;

  /// Dein Moment (Finale §3): Auflösung: Tipps aus Runde drei
  ///
  /// In de, this message translates to:
  /// **'Geheime Tipps'**
  String get einfluss_tipps_titel;

  /// Dein Moment (Finale §3): Auflösung: Feldname
  ///
  /// In de, this message translates to:
  /// **'Punkte'**
  String get einfluss_punkte;

  /// Dein Moment (Finale §3): Auflösung: Feldname
  ///
  /// In de, this message translates to:
  /// **'Tischbonus'**
  String get einfluss_tischbonus;

  /// Dein Moment (Finale §3): Auflösung: Feldname
  ///
  /// In de, this message translates to:
  /// **'Endwert'**
  String get einfluss_endwert;

  /// Dein Moment (Finale §3): Erzähler: Zug-Tafel
  ///
  /// In de, this message translates to:
  /// **'Züge dieser Runde'**
  String get einfluss_tafel_titel;

  /// Dein Moment (Finale §3): Erzähler: Hinweis zur Zug-Tafel
  ///
  /// In de, this message translates to:
  /// **'Nur für dich. Nie vorlesen.'**
  String get einfluss_tafel_hinweis;

  /// Dein Moment (Finale §3): Erzähler: Zug-Tafel ohne Züge
  ///
  /// In de, this message translates to:
  /// **'Noch hat niemand gezogen.'**
  String get einfluss_tafel_leer;

  /// Dein Moment (Finale §3): Fundkarte nach einem Umweg, die Fakten warten
  ///
  /// In de, this message translates to:
  /// **'Die Fakten kommen im Zwischenresümee.'**
  String get einfluss_verzoegert;

  /// Startübersicht (M7b): geschätzte Länge des Abends
  ///
  /// In de, this message translates to:
  /// **'Länge'**
  String get abend_start_laenge;

  /// Streifzug (M7b): Überschrift des Streifzugs durchs Schloss im langen Abend
  ///
  /// In de, this message translates to:
  /// **'Streifzug'**
  String get streifzug_titel;

  /// Streifzug (M7b): Handlung an einer Figur am Treffpunkt
  ///
  /// In de, this message translates to:
  /// **'Ansprechen'**
  String get streifzug_ansprechen;

  /// Streifzug (M7b): Restzeit der Rundenuhr in der Kopfzeile
  ///
  /// In de, this message translates to:
  /// **'Noch {zeit}'**
  String streifzug_uhr_rest(String zeit);

  /// Streifzug (M7b): Weg zurück in den Keller sofort beenden
  ///
  /// In de, this message translates to:
  /// **'Abkürzen'**
  String get streifzug_abkuerzen;

  /// Streifzug (M7b): Knopf: zurück in den Keller, dann die nächste Entscheidung
  ///
  /// In de, this message translates to:
  /// **'Zur Entscheidung'**
  String get streifzug_zur_entscheidung;

  /// Streifzug (M7b): Rundenstart schließen und losgehen
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get streifzug_los;

  /// Streifzug (M7b): Offene Karte schließen
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Karte'**
  String get streifzug_zur_karte;

  /// Streifzug (M7b): Erkundungskarte schließen
  ///
  /// In de, this message translates to:
  /// **'Weiter erkunden'**
  String get streifzug_weiter_erkunden;

  /// Streifzug (M7b): Hinweis: der Detektiv geht vor der Entscheidung zurück
  ///
  /// In de, this message translates to:
  /// **'Zurück in den Keller …'**
  String get streifzug_rueckweg;

  /// Streifzug (M7b): Hinweis: der Detektiv geht gerade zu einem Ziel
  ///
  /// In de, this message translates to:
  /// **'Unterwegs …'**
  String get streifzug_unterwegs;

  /// Streifzug (M7b): Hinweis, wenn kein Treffpunkt mehr offen ist
  ///
  /// In de, this message translates to:
  /// **'Alle Befragungen dieser Runde sind geführt.'**
  String get streifzug_befragungen_fertig;

  /// Streifzug (M7b): Karte eines Treffpunkts, etwa „Triff Ahmet am Brunnen“
  ///
  /// In de, this message translates to:
  /// **'Triff {name} {ort}'**
  String streifzug_triff(String name, String ort);

  /// Streifzug (M7b): Befragung gestellt, am Tisch noch nicht beantwortet
  ///
  /// In de, this message translates to:
  /// **'Antwort steht noch aus'**
  String get streifzug_antwort_offen;

  /// Streifzug (M7b): Befragung, die der Detektiv frei wählen kann
  ///
  /// In de, this message translates to:
  /// **'Freie Wahl'**
  String get streifzug_frei;

  /// Streifzug (M7b): Hinweis in den Entscheidungen
  ///
  /// In de, this message translates to:
  /// **'Die nächste Entscheidung wartet im Keller.'**
  String get streifzug_entscheidung_wartet;

  /// Streifzug (M7b): Reihum nach dem Deckel der freien Erkundung: Überschrift
  ///
  /// In de, this message translates to:
  /// **'Zeit für den Tisch'**
  String get streifzug_deckel_titel;

  /// Streifzug (M7b): Reihum nach dem Deckel: Stichpunkt eins
  ///
  /// In de, this message translates to:
  /// **'Genug erkundet in dieser Runde.'**
  String get streifzug_deckel_1;

  /// Streifzug (M7b): Reihum nach dem Deckel: Stichpunkt zwei
  ///
  /// In de, this message translates to:
  /// **'Jetzt zählen Gruppe und Tisch.'**
  String get streifzug_deckel_2;

  /// Streifzug (M7b): Reihum nach dem Deckel: Stichpunkt drei
  ///
  /// In de, this message translates to:
  /// **'Befragungen gehen weiter.'**
  String get streifzug_deckel_3;

  /// Streifzug (M7b): Karte eines Erkundungsorts
  ///
  /// In de, this message translates to:
  /// **'Erkunde: {ort}'**
  String streifzug_erkunde(String ort);

  /// Streifzug (M7b): Reihum: Tischgespräche und Spickzettel
  ///
  /// In de, this message translates to:
  /// **'Am Tisch'**
  String get streifzug_tisch;

  /// Streifzug (M7b): Reihum: Zeile unter „Am Tisch“
  ///
  /// In de, this message translates to:
  /// **'Gespräche und Spickzettel'**
  String get streifzug_tisch_unter;

  /// Streifzug (M7b): Karte mit Erzähltext und Uhr der Runde
  ///
  /// In de, this message translates to:
  /// **'Rundenstart'**
  String get streifzug_rundenstart;

  /// Streifzug (M7b): Zeile unter „Rundenstart“
  ///
  /// In de, this message translates to:
  /// **'Erzähler und Uhr'**
  String get streifzug_rundenstart_unter;

  /// Streifzug (M7b): Impulskarte bei einer Befragung: worüber die Figur am Tisch spricht
  ///
  /// In de, this message translates to:
  /// **'Am Tisch jetzt'**
  String get streifzug_impuls_titel;

  /// Streifzug (M7b): Impulskarte ohne Tischgespräch der Figur
  ///
  /// In de, this message translates to:
  /// **'Gerade spricht niemand mit ihr am Tisch.'**
  String get streifzug_impuls_leer;

  /// Streifzug (M7b): Statuskarte der übrigen Gäste
  ///
  /// In de, this message translates to:
  /// **'Streifzug läuft'**
  String get streifzug_laeuft_titel;

  /// Streifzug (M7b): Statuskarte der übrigen Gäste: Stichpunkt
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv streift durchs Schloss.'**
  String get streifzug_laeuft_text;

  /// Streifzug (M7b): Gast, der gerade befragt wird: wo der Detektiv ihn trifft
  ///
  /// In de, this message translates to:
  /// **'Der Detektiv trifft dich {ort}.'**
  String streifzug_trifft_dich(String ort);

  /// Streifzug (M7b): Erzähler und Gäste: wen der Detektiv gerade trifft
  ///
  /// In de, this message translates to:
  /// **'Trifft {name} {ort}.'**
  String streifzug_trifft(String name, String ort);

  /// Streifzug (M7b): Erzähler und Gäste: wo der Detektiv gerade ist
  ///
  /// In de, this message translates to:
  /// **'Gerade: {ort}'**
  String streifzug_ist(String ort);

  /// Streifzug (M7b): Erzähler und Gäste: der Detektiv ist im Keller
  ///
  /// In de, this message translates to:
  /// **'Im Keller'**
  String get streifzug_im_keller;

  /// Streifzug (M7b): Erzähler: Überschrift der Zuschauerkarte im langen Abend
  ///
  /// In de, this message translates to:
  /// **'Streifzug des Detektivs'**
  String get streifzug_zuschauer_titel;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return LDe();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
