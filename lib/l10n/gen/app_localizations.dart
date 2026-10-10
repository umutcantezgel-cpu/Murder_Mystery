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
  /// **'Ein Krimi für den Geburtstag, für 4 bis 20 Personen und ein Geburtstagskind'**
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
  /// **'Seifenblasen-Marken: {zahl}'**
  String party_zug_marken(String zahl);

  /// No description provided for @party_zug_gruendlich.
  ///
  /// In de, this message translates to:
  /// **'Gründlich suchen · +2 auf den Wurf · 2 Nachtminuten mehr'**
  String get party_zug_gruendlich;

  /// No description provided for @party_zug_wuerfel.
  ///
  /// In de, this message translates to:
  /// **'Der Kellerwürfel'**
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
  /// **'Eine Seifenblasen-Marke einsetzen · +1'**
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
  /// **'Erfolg · Lupe'**
  String get party_zug_erfolg;

  /// No description provided for @party_zug_teilerfolg.
  ///
  /// In de, this message translates to:
  /// **'Teilerfolg · Handy'**
  String get party_zug_teilerfolg;

  /// No description provided for @party_zug_pech.
  ///
  /// In de, this message translates to:
  /// **'Pech · Gespenst'**
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
  /// **'Das Handy-Licht wandert kurz über die Decke. Die Quelle bleibt dieselbe. Glück im Unglück: eine Seifenblasen-Marke!'**
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
