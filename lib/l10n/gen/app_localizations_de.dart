// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mordakte';

  @override
  String get appSubtitle => 'Ein kooperativer Krimi';

  @override
  String get appLoading => 'Akten werden geladen …';

  @override
  String get common_back => 'Zurück';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_ok => 'OK';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_locked => 'Gesperrt';

  @override
  String get common_you => 'Du';

  @override
  String common_unlock_at(String rank) {
    return 'ab $rank';
  }

  @override
  String common_minutes(int n) {
    return '$n Min.';
  }

  @override
  String common_xp(int xp) {
    return '$xp XP';
  }

  @override
  String common_xp_gain(int xp) {
    return '+$xp XP';
  }

  @override
  String hub_welcome(String name) {
    return 'Willkommen zurück, $name.';
  }

  @override
  String get hub_cases => 'Fallakten';

  @override
  String get hub_cases_sub => 'Solo mit KI-Partnern';

  @override
  String get hub_online => 'Online spielen';

  @override
  String get hub_online_sub => 'Mit bis zu fünf Freunden';

  @override
  String get hub_party => 'Partyabend: Spuk im Schlosskeller';

  @override
  String get hub_party_sub =>
      'Ein Krimi für 4 bis 20 Gäste, einen Detektiv und auf Wunsch einen Erzähler';

  @override
  String get hub_section_party => 'Partyabende';

  @override
  String get party_menu => 'Andere Abende & Fälle';

  @override
  String get party_solo_spielweise => 'Wie möchtest du spielen?';

  @override
  String get party_solo_party => 'Party am Gerät';

  @override
  String get party_solo_solo => 'Solo mit Bots';

  @override
  String get party_solo_einrichtung =>
      'Du ermittelst allein. Die Gäste sprechen und wählen als Bots; ihre geheimen Rollenkarten bleiben zu.';

  @override
  String get party_solo_rollen => 'Gäste mit Stimmrecht';

  @override
  String party_solo_rollen_anzahl(Object anzahl) {
    return '$anzahl Bot-Rollen';
  }

  @override
  String get party_solo_rollen_hinweis =>
      'Diese Gäste übernehmen die Rollen und wählen verdeckt. Weitere Gäste melden sich mit ihrem öffentlichen Wissen, wenn es gebraucht wird.';

  @override
  String get party_solo_name => 'Dein Name als Detektiv';

  @override
  String get party_solo_name_feld => 'Name (freiwillig)';

  @override
  String get party_solo_rollen_start =>
      'Du bist der Detektiv. Die folgenden Rollen werden vom Spiel übernommen. Ihre Dossiers kannst du nicht öffnen; alle nötigen Aussagen hörst du in den Runden.';

  @override
  String get party_solo_gespraeche => 'Gespräche mit den Gästen';

  @override
  String get party_solo_gespraeche_hinweis =>
      'Höre die öffentlichen Aussagen an, bevor du ermittelst. Behauptungen können falsch sein. Die Sprechblasen bleiben danach im Notizbuch.';

  @override
  String party_solo_fortschritt(Object gesamt, Object nr) {
    return 'Gespräch $nr von $gesamt';
  }

  @override
  String get party_solo_gehoert => 'Gehört – nächstes Gespräch';

  @override
  String get party_solo_vorheriges => 'Vorheriges Gespräch';

  @override
  String get party_solo_fertig =>
      'Alle Aussagen gehört. Jetzt entscheidest du auf der Karte.';

  @override
  String get party_solo_gruppenwahl =>
      'Die Bots haben verdeckt gewählt. Sie kooperieren mit 70 % Wahrscheinlichkeit. Nur die Täterrolle kann mit ihrer Wahl sabotieren; Stimmen und Hinweisqualität bleiben geheim.';

  @override
  String get party_solo_gast => 'Diese Figur wird vom Spiel übernommen.';

  @override
  String get party_solo_npc => 'Gast ohne Stimmrolle';

  @override
  String get party_solo_notizen => 'Gehörte Gespräche';

  @override
  String get hub_section_classic => 'Klassische Fälle';

  @override
  String get hub_section_meta => 'Sammlung und Profil';

  @override
  String get hub_party_keller => 'Spuk im Schlosskeller';

  @override
  String get hub_party_keller_sub => 'Party am Gerät oder Solo mit Bots';

  @override
  String get hub_party_gewoelbe => 'Spuk im Gewölbe';

  @override
  String get hub_party_gewoelbe_sub =>
      'Krimidinner auf Burg Schartenfels · Besetzung, Steckbriefe, Mappen';

  @override
  String hub_online_rejoin(String code) {
    return 'Zurück zu Raum $code';
  }

  @override
  String hud_room(String code) {
    return 'RAUM $code';
  }

  @override
  String toast_combo_known(String combo) {
    return '„$combo“ habt ihr schon kombiniert.';
  }

  @override
  String get hub_collection => 'Sammlung';

  @override
  String get hub_profile => 'Profil';

  @override
  String hub_streak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage in Folge',
      one: '1 Tag in Folge',
      zero: 'Keine Serie',
    );
    return '$_temp0';
  }

  @override
  String get hub_daily_title => 'Fall des Tages';

  @override
  String get hub_daily_play => 'Ermitteln';

  @override
  String get hub_daily_done => 'Heute gelöst';

  @override
  String hub_daily_bonus(int xp) {
    return '+$xp XP Bonus';
  }

  @override
  String hub_rank_progress(int xp, int next) {
    return '$xp / $next XP';
  }

  @override
  String get hub_rank_max => 'Höchster Rang erreicht';

  @override
  String get hub_motto =>
      'Niemand verlässt das Haus, bevor der Fall gelöst ist.';

  @override
  String get name_prompt_title => 'Wie lautet Ihr Name, Detektiv?';

  @override
  String get name_prompt_text => 'Er steht ab sofort auf Ihrer Dienstmarke.';

  @override
  String get name_prompt_hint => 'Name';

  @override
  String get name_prompt_title_du => 'Wie heißt du, Detektiv?';

  @override
  String get name_prompt_text_du =>
      'Dein Name steht ab sofort auf deiner Dienstmarke.';

  @override
  String get name_prompt_confirm => 'Dienstmarke ausstellen';

  @override
  String get name_edit => 'Name ändern';

  @override
  String get name_default => 'Detektiv';

  @override
  String get cases_title => 'Fallakten';

  @override
  String get cases_subtitle =>
      'Wähle eine Akte. Deine KI-Partner warten schon.';

  @override
  String case_file_no(String n) {
    return 'Akte Nr. $n';
  }

  @override
  String get case_difficulty => 'Schwierigkeit';

  @override
  String case_endings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Enden entdeckt',
      one: '1 Ende entdeckt',
      zero: 'Noch kein Ende entdeckt',
    );
    return '$_temp0';
  }

  @override
  String get case_story_solved => 'Story gelöst';

  @override
  String get case_daily_badge => 'Heute';

  @override
  String get case_start => 'Akte öffnen';

  @override
  String get case_starting => 'Akte wird geöffnet …';

  @override
  String get mode_story => 'Story';

  @override
  String get mode_story_desc =>
      'Der Originalfall – ideal für den ersten Durchlauf.';

  @override
  String get mode_random => 'Zufallsfall';

  @override
  String get mode_random_desc => 'Neuer Täter, neues Motiv, neue Waffe.';

  @override
  String get mode_daily => 'Fall des Tages';

  @override
  String get mode_daily_desc => 'Für alle gleich. Heute mit Bonus-XP.';

  @override
  String get mode_daily_other => 'Heute ist eine andere Akte dran.';

  @override
  String get online_title => 'Online spielen';

  @override
  String get online_create => 'Raum erstellen';

  @override
  String get online_create_sub => 'Du bist Gastgeber und wählst den Fall.';

  @override
  String get online_join => 'Raum beitreten';

  @override
  String get online_join_sub =>
      'Gib den vierstelligen Code deines Gastgebers ein.';

  @override
  String get online_join_button => 'Beitreten';

  @override
  String get online_advanced => 'Erweitert';

  @override
  String get online_server => 'Server-Adresse';

  @override
  String get online_server_reset => 'Standard';

  @override
  String get online_connecting => 'Verbinde …';

  @override
  String online_playing_as(String name) {
    return 'Du spielst als $name';
  }

  @override
  String get error_room_not_found =>
      'Diesen Raum gibt es nicht. Prüfe den Code.';

  @override
  String get error_room_full => 'Der Raum ist voll.';

  @override
  String get error_game_running => 'In diesem Raum läuft bereits ein Fall.';

  @override
  String get error_not_host => 'Das darf nur der Gastgeber.';

  @override
  String get error_too_far => 'Zu weit entfernt.';

  @override
  String get error_inventory_full => 'Deine Taschen sind voll.';

  @override
  String get error_cooldown => 'Noch nicht wieder bereit.';

  @override
  String get error_not_in_phase => 'Das geht gerade nicht.';

  @override
  String get error_no_charges => 'Keine Ladungen mehr in dieser Nacht.';

  @override
  String get error_invalid => 'Ungültige Eingabe.';

  @override
  String get error_connection => 'Keine Verbindung zum Server.';

  @override
  String get error_server_missing =>
      'Der öffentliche Spielserver ist noch nicht eingerichtet. Trage unter Erweitert die freigegebene Server-Adresse ein. Offline kannst du sofort spielen.';

  @override
  String get error_server_invalid =>
      'Bitte eine öffentliche wss-Adresse mit dem Pfad /ws eingeben. Lokale Adressen und Zugangsdaten in der URL sind nicht erlaubt.';

  @override
  String get error_unavailable => 'Der Online-Modus ist noch nicht verfügbar.';

  @override
  String get error_unknown => 'Etwas ist schiefgelaufen.';

  @override
  String get lobby_title => 'Lagebesprechung';

  @override
  String get lobby_room_code => 'Raumcode';

  @override
  String get lobby_copied => 'Code kopiert';

  @override
  String lobby_players(int count) {
    return 'Ermittler ($count/6)';
  }

  @override
  String get lobby_bot => 'KI';

  @override
  String get lobby_host => 'Gastgeber';

  @override
  String get lobby_ready => 'Bereit';

  @override
  String get lobby_waiting => 'Wartet';

  @override
  String get lobby_offline => 'Getrennt';

  @override
  String get lobby_loadout => 'Deine Ausrüstung';

  @override
  String get lobby_class => 'Klasse';

  @override
  String get lobby_coat => 'Mantel';

  @override
  String get lobby_hat => 'Hut';

  @override
  String get lobby_ability => 'Fähigkeit';

  @override
  String get lobby_passive => 'Passiv';

  @override
  String get lobby_case => 'Der Fall';

  @override
  String get lobby_scenario => 'Akte';

  @override
  String get lobby_mode => 'Modus';

  @override
  String get lobby_bots => 'KI-Partner';

  @override
  String get lobby_start => 'Ermittlung beginnen';

  @override
  String get lobby_set_ready => 'Ich bin bereit';

  @override
  String get lobby_unready => 'Doch nicht bereit';

  @override
  String get lobby_wait_host => 'Warte auf den Gastgeber …';

  @override
  String get lobby_pick_case => 'Akte wählen …';

  @override
  String get lobby_need_case =>
      'Wähle zuerst eine Akte – dann kann die Ermittlung beginnen.';

  @override
  String get lobby_leave => 'Lobby verlassen';

  @override
  String get lobby_empty_slot => 'Freier Platz';

  @override
  String get class_forensic_name => 'Forensikerin';

  @override
  String get class_forensic_ability =>
      'Adlerauge: 15 s lang verborgene Spuren sehen und schneller suchen.';

  @override
  String get class_forensic_passive =>
      'Laboranalysen gehen doppelt so schnell.';

  @override
  String get class_profiler_name => 'Profiler';

  @override
  String get class_profiler_ability =>
      'Ruhe bewahren: Fokus für alle in der Nähe, heilt Panik.';

  @override
  String get class_profiler_passive => 'Erkennt Lügen im Verhör.';

  @override
  String get class_excop_name => 'Ex-Polizist';

  @override
  String get class_excop_ability =>
      'Verscheuchen: Der Schatten in deiner Nähe flieht. 1× pro Nacht.';

  @override
  String get class_excop_passive => 'Vier statt drei Herzen.';

  @override
  String get class_journalist_name => 'Journalistin';

  @override
  String get class_journalist_ability =>
      'Quellen: Markiert den Ort eines ungefundenen Hinweises.';

  @override
  String get class_journalist_passive =>
      'Kann Verdächtige nach Gerüchten fragen.';

  @override
  String get class_medic_name => 'Sanitäter';

  @override
  String get class_medic_ability =>
      'Erste Hilfe: +1 Herz, heilt Verletzung und Gift beim nächsten Detektiv.';

  @override
  String get class_medic_passive => 'Wiederbelebt doppelt so schnell.';

  @override
  String get ability_scan => 'Adlerauge';

  @override
  String get ability_calm => 'Ruhe bewahren';

  @override
  String get ability_scare => 'Verscheuchen';

  @override
  String get ability_sources => 'Quellen';

  @override
  String get ability_firstaid => 'Erste Hilfe';

  @override
  String get hat_fedora => 'Fedora';

  @override
  String get hat_bowler => 'Melone';

  @override
  String get hat_cap => 'Schiebermütze';

  @override
  String get hat_beret => 'Baskenmütze';

  @override
  String get hat_cloche => 'Glockenhut';

  @override
  String get hat_top => 'Zylinder';

  @override
  String get hat_none => 'Ohne Hut';

  @override
  String coat_name(int n) {
    return 'Mantel $n';
  }

  @override
  String get effect_caffeine => 'Koffein';

  @override
  String get effect_caffeine_desc => 'Du läufst und suchst schneller.';

  @override
  String get effect_teamgeist => 'Teamgeist';

  @override
  String get effect_teamgeist_desc =>
      'In der Gruppe: schneller suchen, ruhige Nerven, Schutz vor dem Schatten.';

  @override
  String get effect_adrenaline => 'Adrenalin';

  @override
  String get effect_adrenaline_desc => 'Ein kurzer Sprint – nichts wie weg!';

  @override
  String get effect_eagle_eye => 'Adlerauge';

  @override
  String get effect_eagle_eye_desc =>
      'Du siehst verborgene Spuren und suchst schneller.';

  @override
  String get effect_focused => 'Fokussiert';

  @override
  String get effect_focused_desc =>
      'Deine Nerven erholen sich rasch, du suchst schneller.';

  @override
  String get effect_bright => 'Helle Lampe';

  @override
  String get effect_bright_desc => 'Deine Lampe leuchtet weiter.';

  @override
  String get effect_hidden => 'Versteckt';

  @override
  String get effect_hidden_desc =>
      'Unsichtbar für den Schatten – aber du kannst dich nicht bewegen.';

  @override
  String get effect_injured => 'Verletzt';

  @override
  String get effect_injured_desc => 'Du bist langsamer.';

  @override
  String get effect_panic => 'Panik';

  @override
  String get effect_panic_desc =>
      'Weniger Licht, langsameres Suchen. Bleib bei den anderen!';

  @override
  String get effect_poisoned => 'Vergiftet';

  @override
  String get effect_poisoned_desc =>
      'Du verlierst jede Minute ein Herz. Ein Gegengift hilft.';

  @override
  String get effect_blinded => 'Geblendet';

  @override
  String get effect_blinded_desc => 'Du siehst kaum etwas.';

  @override
  String get effect_suspicious => 'Verdächtig';

  @override
  String get effect_suspicious_desc =>
      'Verdächtige verweigern das Gespräch mit dir.';

  @override
  String get effect_buff => 'Vorteil';

  @override
  String get effect_debuff => 'Nachteil';

  @override
  String get item_coffee => 'Kaffee';

  @override
  String get item_coffee_desc => 'Koffein: schneller laufen und suchen.';

  @override
  String get item_battery => 'Batterie';

  @override
  String get item_battery_desc => 'Deine Lampe leuchtet weiter.';

  @override
  String get item_salts => 'Riechsalz';

  @override
  String get item_salts_desc => 'Fokus: Nerven beruhigen, Panik vertreiben.';

  @override
  String get item_antidote => 'Gegengift';

  @override
  String get item_antidote_desc => 'Heilt Vergiftung.';

  @override
  String get item_medkit => 'Verbandskasten';

  @override
  String get item_medkit_desc => '+1 Herz, heilt Verletzungen.';

  @override
  String get item_flare => 'Leuchtfackel';

  @override
  String get item_flare_desc => 'Vertreibt den Schatten in deiner Nähe.';

  @override
  String get quick_come_here => 'Komm her!';

  @override
  String get quick_found_clue => 'Ich habe was gefunden!';

  @override
  String get quick_help => 'Hilfe!';

  @override
  String get quick_stay_together => 'Bleibt zusammen!';

  @override
  String get quick_split_up => 'Wir teilen uns auf.';

  @override
  String get quick_suspect => 'Ich habe einen Verdacht.';

  @override
  String get quick_danger => 'Vorsicht, Gefahr!';

  @override
  String get quick_thanks => 'Danke!';

  @override
  String get emote_wave => 'Winken';

  @override
  String get emote_shock => 'Schock';

  @override
  String get emote_think => 'Grübeln';

  @override
  String get emote_laugh => 'Lachen';

  @override
  String get emote_scared => 'Angst';

  @override
  String get emote_thumbs => 'Daumen hoch';

  @override
  String get award_spurensucher => 'Spurensucher';

  @override
  String get award_spurensucher_desc => 'Die meisten Hinweise gefunden.';

  @override
  String get award_lebensretter => 'Lebensretter';

  @override
  String get award_lebensretter_desc => 'Die meisten Kollegen wiederbelebt.';

  @override
  String get award_kombinierer => 'Kombinierer';

  @override
  String get award_kombinierer_desc =>
      'Die meisten Schlussfolgerungen gezogen.';

  @override
  String get award_ueberlebender => 'Überlebender';

  @override
  String get award_ueberlebender_desc => 'Nie zu Boden gegangen.';

  @override
  String get award_geist => 'Rastloser Geist';

  @override
  String get award_geist_desc => 'Auch als Geist weiterermittelt.';

  @override
  String get award_teamplayer => 'Teamplayer';

  @override
  String get award_teamplayer_desc => 'Die meisten Hinweise geteilt.';

  @override
  String get rank_0 => 'Anwärter';

  @override
  String get rank_1 => 'Ermittler';

  @override
  String get rank_2 => 'Inspektor';

  @override
  String get rank_3 => 'Kommissar';

  @override
  String get rank_4 => 'Hauptkommissar';

  @override
  String get rank_5 => 'Legende';

  @override
  String get phase_lobby => 'Lobby';

  @override
  String get phase_intro => 'Einleitung';

  @override
  String get phase_investigation => 'Ermittlung';

  @override
  String get phase_council => 'Beratung';

  @override
  String get phase_night => 'Nacht';

  @override
  String get phase_accusation => 'Anklage';

  @override
  String get phase_ending => 'Abschluss';

  @override
  String hud_chapter(int n) {
    return 'Kapitel $n/3';
  }

  @override
  String get hud_notebook => 'Notizbuch';

  @override
  String get hud_signals => 'Signale';

  @override
  String get hud_map => 'Karte';

  @override
  String hud_map_ping(int left) {
    return 'Tippe auf die Karte, um einen Ort zu markieren ($left übrig).';
  }

  @override
  String get hud_map_no_ping => 'Keine Markierung mehr in diesem Kapitel.';

  @override
  String get hud_emotes => 'Gesten';

  @override
  String get hud_quick_chat => 'Schnellchat';

  @override
  String get hud_nerves => 'Nerven';

  @override
  String get hud_ability_ready => 'Bereit';

  @override
  String get hud_menu => 'Menü';

  @override
  String get hud_leave_title => 'Fall verlassen?';

  @override
  String get hud_leave_text => 'Dein Fortschritt in diesem Fall geht verloren.';

  @override
  String get hud_leave_confirm => 'Verlassen';

  @override
  String get hud_disconnected => 'Verbindung unterbrochen – verbinde neu …';

  @override
  String get hud_inventory_empty => 'Leerer Slot';

  @override
  String toast_clue_found(String clue) {
    return 'Hinweis gefunden: $clue';
  }

  @override
  String toast_hotspot_empty(String player) {
    return '$player war schneller – hier ist nichts mehr.';
  }

  @override
  String toast_nothing_found(String place) {
    return 'Nichts gefunden: $place';
  }

  @override
  String toast_clue_shared_me(String clue) {
    return 'An die Beweiswand gepinnt: $clue';
  }

  @override
  String toast_clue_shared(String player, String clue) {
    return '$player hat einen Hinweis geteilt: $clue';
  }

  @override
  String toast_clue_evolved(String clue) {
    return 'Neue Erkenntnis: $clue';
  }

  @override
  String toast_clue_lost(String clue) {
    return 'Der Schatten hat Notizen zerstört: $clue';
  }

  @override
  String toast_clue_lost_damaged(String clue) {
    return 'Der Schatten hat $clue beschädigt – erneut ins Labor bringen.';
  }

  @override
  String toast_clue_lost_stolen(String clue) {
    return 'Der Schatten hat $clue gestohlen – die Spur ist noch an ihrer Quelle.';
  }

  @override
  String toast_clues_faded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spuren sind verblasst.',
      one: 'Eine Spur ist verblasst.',
    );
    return '$_temp0';
  }

  @override
  String toast_combo(String combo) {
    return 'Schlussfolgerung: $combo';
  }

  @override
  String get toast_combo_fail => 'Das passt nicht zusammen.';

  @override
  String toast_refused_silenced(String npc) {
    return '$npc will nicht mit dir reden.';
  }

  @override
  String toast_refused_dead(String npc) {
    return '$npc wird nie wieder sprechen.';
  }

  @override
  String toast_refused_busy(String npc) {
    return '$npc spricht gerade mit jemand anderem.';
  }

  @override
  String get accuse_contradicted => 'Widerspruch aufgedeckt';

  @override
  String toast_contradiction(String npc) {
    return 'Widerspruch! $npc hat gelogen. Beweisstärke +1';
  }

  @override
  String toast_effect_on(String effect, String desc) {
    return '$effect: $desc';
  }

  @override
  String toast_effect_off(String effect) {
    return '$effect lässt nach.';
  }

  @override
  String get toast_attacked_me => 'Du wurdest angegriffen!';

  @override
  String toast_attacked(String player) {
    return '$player wurde angegriffen!';
  }

  @override
  String get toast_downed_me => 'Du bist niedergeschlagen!';

  @override
  String toast_downed(String player) {
    return '$player liegt am Boden – hilf!';
  }

  @override
  String toast_revived(String by, String player) {
    return '$by hat $player wiederbelebt.';
  }

  @override
  String toast_revived_me(String by) {
    return '$by hat dich gerettet!';
  }

  @override
  String toast_died(String player) {
    return 'Der Schatten hat $player getötet.';
  }

  @override
  String get toast_died_me => 'Du bist gestorben … aber noch nicht fort.';

  @override
  String toast_npc_killed(String npc) {
    return 'Der Schatten hat $npc getötet.';
  }

  @override
  String get toast_repelled_group =>
      'Gemeinsam habt ihr den Schatten vertrieben!';

  @override
  String toast_repelled_scare(String player) {
    return '$player hat den Schatten verscheucht!';
  }

  @override
  String get toast_repelled_flare => 'Leuchtfackel! Der Schatten flieht.';

  @override
  String get toast_shadow_near => 'Etwas ist ganz nah …';

  @override
  String toast_lead_chosen(String lead) {
    return 'Spur gewählt: $lead';
  }

  @override
  String toast_ping(String player) {
    return '$player hat einen Ort markiert.';
  }

  @override
  String toast_signal(String player, String text) {
    return '$player: $text';
  }

  @override
  String toast_item_picked(String item) {
    return 'Eingesteckt: $item';
  }

  @override
  String toast_item_used_me(String item) {
    return '$item benutzt.';
  }

  @override
  String toast_item_used(String player, String item) {
    return '$player benutzt: $item';
  }

  @override
  String toast_ability_me(String ability) {
    return '$ability aktiviert.';
  }

  @override
  String toast_ability(String player, String ability) {
    return '$player nutzt $ability.';
  }

  @override
  String toast_sources(String place) {
    return 'Quelle markiert: $place';
  }

  @override
  String toast_lab_done(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Labor: $count Hinweise analysiert.',
      one: 'Labor: ein Hinweis analysiert.',
      zero: 'Labor: nichts zu analysieren.',
    );
    return '$_temp0';
  }

  @override
  String get toast_hidden => 'Du versteckst dich.';

  @override
  String get toast_unhidden => 'Du verlässt das Versteck.';

  @override
  String toast_phase(String phase, int chapter) {
    return '$phase · Kapitel $chapter';
  }

  @override
  String get intro_ready => 'Bereit';

  @override
  String get intro_waiting => 'Warte auf die anderen …';

  @override
  String get intro_victim => 'Das Opfer';

  @override
  String get intro_tap_to_skip => 'Tippen, um den Text sofort zu zeigen';

  @override
  String get notebook_title => 'Notizbuch';

  @override
  String get notebook_mine => 'Meine Hinweise';

  @override
  String get notebook_board => 'Beweiswand';

  @override
  String get notebook_empty_mine =>
      'Noch keine Hinweise. Durchsuche Orte und befrage Verdächtige.';

  @override
  String get notebook_empty_board =>
      'Die Wand ist leer. Teile Hinweise, damit das ganze Team sie sieht.';

  @override
  String get notebook_share => 'Teilen';

  @override
  String get notebook_share_hint => 'Ungeteilte Notizen sind nachts in Gefahr.';

  @override
  String get notebook_combine => 'Kombinieren';

  @override
  String get notebook_combine_hint =>
      'Wähle zwei Hinweise, die zusammenpassen.';

  @override
  String get notebook_combine_hint_second => 'Und jetzt den zweiten Hinweis.';

  @override
  String get notebook_deductions => 'Schlussfolgerungen';

  @override
  String get notebook_strength => 'Beweisstärke';

  @override
  String notebook_strength_hint(int solid, int perfect) {
    return 'Überführt ab $solid, lückenlos ab $perfect.';
  }

  @override
  String notebook_contradictions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Widersprüche',
      one: '1 Widerspruch',
      zero: 'Keine Widersprüche',
    );
    return '$_temp0';
  }

  @override
  String get clue_kind_trait => 'Merkmal';

  @override
  String get clue_kind_motive => 'Motiv';

  @override
  String get clue_kind_weapon => 'Tatwaffe';

  @override
  String get clue_kind_alibi => 'Alibi';

  @override
  String get clue_kind_story => 'Notiz';

  @override
  String get clue_kind_sighting => 'Sichtung';

  @override
  String get clue_kind_other => 'Hinweis';

  @override
  String get clue_pending_lab => 'Im Labor analysieren';

  @override
  String clue_pending_time(int chapter) {
    return 'Ergebnis in Kapitel $chapter';
  }

  @override
  String get clue_sighting_title => 'Sichtung';

  @override
  String clue_sighting(String trait, String value) {
    return 'Sichtung: $trait – $value';
  }

  @override
  String clue_found_by(String player) {
    return 'gefunden von $player';
  }

  @override
  String clue_shared_by(String player) {
    return 'geteilt von $player';
  }

  @override
  String get clue_unknown => 'Ein unleserlicher Zettel.';

  @override
  String get dialogue_topics => 'Befragen';

  @override
  String get topic_alibi => 'Wo waren Sie zur Tatzeit?';

  @override
  String get topic_victim => 'Was wissen Sie über das Opfer?';

  @override
  String get topic_observation => 'Ist Ihnen etwas aufgefallen?';

  @override
  String get topic_rumor => 'Was erzählt man sich?';

  @override
  String get topic_alibi_short => 'Alibi';

  @override
  String get topic_victim_short => 'Opfer';

  @override
  String get topic_observation_short => 'Beobachtung';

  @override
  String get topic_rumor_short => 'Gerüchte';

  @override
  String get dialogue_lie => 'Lüge erkannt';

  @override
  String get dialogue_present => 'Beweis vorlegen';

  @override
  String get dialogue_present_title => 'Welchen Beweis legst du vor?';

  @override
  String get dialogue_present_empty => 'Du hast noch nichts in der Hand.';

  @override
  String get dialogue_reaction_nervous => 'wirkt nervös';

  @override
  String get dialogue_reaction_annoyed => 'reagiert gereizt';

  @override
  String get dialogue_reaction_neutral => 'zeigt keine Regung.';

  @override
  String get dialogue_heard => 'schon gehört';

  @override
  String get dialogue_heard_team => 'Team hat gefragt';

  @override
  String dialogue_team_note(String name, String topics) {
    return 'Dein Team hat $name schon befragt ($topics). Frag selbst nach, um die Antworten zu hören.';
  }

  @override
  String dialogue_new_clue(String clue) {
    return 'Neuer Hinweis: $clue';
  }

  @override
  String get dialogue_profile => 'Steckbrief';

  @override
  String dialogue_presented(String clue) {
    return 'Du legst vor: $clue';
  }

  @override
  String get council_title => 'Beratung';

  @override
  String get council_subtitle => 'Welcher Spur folgt ihr als Nächstes?';

  @override
  String get council_vote => 'Dafür stimmen';

  @override
  String get council_your_vote => 'Deine Stimme';

  @override
  String get council_no_leads =>
      'Keine offenen Spuren – die Nacht kommt trotzdem.';

  @override
  String get council_chosen => 'Bisher verfolgt';

  @override
  String get council_from_combo => 'Aus einer Schlussfolgerung';

  @override
  String get night_title => 'Die Nacht bricht herein';

  @override
  String get night_hint => 'Bleibt zusammen. Licht schützt.';

  @override
  String get downed_title => 'Niedergeschlagen';

  @override
  String get downed_text =>
      'Ein Teammitglied muss dich wiederbeleben – bevor die Zeit abläuft.';

  @override
  String get downed_help => 'Hilfe rufen';

  @override
  String downed_seconds(int s) {
    return '$s s';
  }

  @override
  String get ghost_title => 'Du bist ein Geist';

  @override
  String get ghost_text =>
      'Finde Echo-Spuren – nur du kannst sie sehen. Du hast einen Spuk-Ping.';

  @override
  String get accuse_title => 'Die Anklage';

  @override
  String get accuse_subtitle => 'Wer war es, warum und womit?';

  @override
  String get accuse_who => 'Täter';

  @override
  String get accuse_why => 'Motiv';

  @override
  String get accuse_how => 'Tatwaffe';

  @override
  String get accuse_optional => 'optional – stärkt das Urteil';

  @override
  String get accuse_submit => 'Anklage erheben';

  @override
  String get accuse_update => 'Anklage ändern';

  @override
  String get accuse_submitted =>
      'Deine Anklage liegt vor. Ihr könnt sie bis zum Ende ändern.';

  @override
  String get accuse_pick_culprit => 'Wähle zuerst einen Täter.';

  @override
  String get accuse_open_notebook => 'Beweise ansehen';

  @override
  String get accuse_dead => 'tot';

  @override
  String get ending_case_closed => 'Akte geschlossen';

  @override
  String get ending_truth => 'Die Wahrheit';

  @override
  String get ending_accusation => 'Eure Anklage';

  @override
  String get ending_resolution => 'Auflösung';

  @override
  String get ending_culprit => 'Täter';

  @override
  String get ending_motive => 'Motiv';

  @override
  String get ending_weapon => 'Waffe';

  @override
  String get ending_none => '—';

  @override
  String get ending_strength => 'Beweisstärke';

  @override
  String get ending_team => 'Das Team';

  @override
  String get ending_epilogue => 'Epilog';

  @override
  String get ending_secret => 'Geheimes Ende';

  @override
  String get ending_awards => 'Auszeichnungen';

  @override
  String get ending_no_awards => 'Diesmal keine Auszeichnungen.';

  @override
  String get ending_xp => 'Erfahrung';

  @override
  String ending_rank_up(String rank) {
    return 'Beförderung: $rank!';
  }

  @override
  String get ending_unlocked => 'Freigeschaltet';

  @override
  String get ending_achievement => 'Erfolg errungen';

  @override
  String get ending_new_ending => 'Neues Ende entdeckt!';

  @override
  String get ending_known_ending => 'Dieses Ende kennst du bereits.';

  @override
  String ending_collection_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Enden in deiner Sammlung',
      one: '1 Ende in deiner Sammlung',
    );
    return '$_temp0';
  }

  @override
  String get ending_new_case => 'Neuer Fall';

  @override
  String get ending_hub => 'Zum Hub';

  @override
  String get ending_rematch => 'Neuer Fall in diesem Raum';

  @override
  String get ending_rematch_title => 'Welcher Fall als Nächstes?';

  @override
  String get ending_rematch_text => 'Alle im Raum ermitteln gemeinsam weiter.';

  @override
  String get ending_wait_host =>
      'Der Gastgeber kann einen neuen Fall in diesem Raum starten.';

  @override
  String ending_survivors(String names) {
    return 'Überlebende: $names';
  }

  @override
  String get ending_daily_bonus => 'Fall des Tages';

  @override
  String get ending_streak => 'Serie';

  @override
  String get verdict_stamp_perfect => 'Lückenlos';

  @override
  String get verdict_stamp_solid => 'Gelöst';

  @override
  String get verdict_stamp_partial => 'Knapp';

  @override
  String get verdict_stamp_wrong => 'Fehlurteil';

  @override
  String get verdict_stamp_unsolved => 'Ungelöst';

  @override
  String get team_all => 'Alle überlebt';

  @override
  String get team_some => 'Mit Verlusten';

  @override
  String get team_lone => 'Einer blieb';

  @override
  String get team_none => 'Keiner überlebte';

  @override
  String get collection_title => 'Sammlung';

  @override
  String get collection_endings => 'Enden';

  @override
  String get collection_achievements => 'Erfolge';

  @override
  String collection_discovered(int count) {
    return '$count entdeckt';
  }

  @override
  String get collection_no_endings =>
      'Noch kein Ende entdeckt. Löse diese Akte!';

  @override
  String get collection_grid => 'Urteil × Team';

  @override
  String get collection_secret => 'Geheimnis';

  @override
  String collection_achievements_count(int done, int total) {
    return '$done von $total errungen';
  }

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_record => 'Dienstakte';

  @override
  String get profile_classes => 'Klassen';

  @override
  String get profile_hats => 'Hüte';

  @override
  String get profile_coats => 'Mäntel';

  @override
  String profile_next_rank(String rank) {
    return 'Nächster Rang: $rank';
  }

  @override
  String get stat_cases => 'Fälle';

  @override
  String get stat_solved => 'Gelöst';

  @override
  String get stat_perfect => 'Lückenlos';

  @override
  String get stat_revives => 'Rettungen';

  @override
  String get stat_combos => 'Kombinationen';

  @override
  String get stat_best_streak => 'Beste Serie';

  @override
  String get ach_first_case => 'Erste Akte';

  @override
  String get ach_first_case_desc => 'Schließe deinen ersten Fall ab.';

  @override
  String get ach_perfect => 'Lückenlos';

  @override
  String get ach_perfect_desc => 'Erreiche ein perfektes Urteil.';

  @override
  String get ach_all_survived => 'Keiner bleibt zurück';

  @override
  String get ach_all_survived_desc => 'Alle Ermittler überleben einen Fall.';

  @override
  String get ach_revive3 => 'Schutzengel';

  @override
  String get ach_revive3_desc => 'Belebe insgesamt drei Kollegen wieder.';

  @override
  String get ach_secret => 'Das Geheimnis';

  @override
  String get ach_secret_desc => 'Entdecke ein geheimes Ende.';

  @override
  String get ach_all_scenarios => 'Alle Akten geschlossen';

  @override
  String get ach_all_scenarios_desc => 'Löse jedes Szenario mindestens einmal.';

  @override
  String get ach_streak5 => 'Stammgast im Präsidium';

  @override
  String get ach_streak5_desc => 'Ermittle fünf Tage in Folge.';

  @override
  String get ach_ghost_helper => 'Stimme aus dem Jenseits';

  @override
  String get ach_ghost_helper_desc => 'Hilf deinem Team als Geist.';

  @override
  String get ach_online => 'Im Team';

  @override
  String get ach_online_desc => 'Spiele einen Fall online.';

  @override
  String get ach_combos10 => 'Meisterkombinierer';

  @override
  String get ach_combos10_desc => 'Ziehe insgesamt zehn Schlussfolgerungen.';

  @override
  String get error_unknown_scenario => 'Diese Akte ist unbekannt.';

  @override
  String get error_nothing_to_analyze =>
      'Nichts zu analysieren – bring ungeklärte Hinweise mit.';

  @override
  String get error_nothing_to_scare =>
      'Hier ist nichts, das man verscheuchen könnte.';

  @override
  String get error_nothing_left => 'Hier ist nichts mehr zu holen.';

  @override
  String get error_nothing_to_heal => 'Niemand in der Nähe braucht Hilfe.';

  @override
  String get error_not_needed => 'Das brauchst du gerade nicht.';

  @override
  String get error_no_pings => 'Keine Markierung mehr in diesem Kapitel.';

  @override
  String get error_not_on_board =>
      'Dieser Hinweis hängt nicht an der Beweiswand.';

  @override
  String get item_trace => 'Schattenspur';

  @override
  String get item_trace_desc =>
      'Hier war der Schatten. Vielleicht hat er etwas verloren.';

  @override
  String get toast_trace_search => 'Du untersuchst die Spur des Schattens …';

  @override
  String get toast_trace_nothing => 'Nur Schlamm und Asche.';

  @override
  String get toast_revived_dawn_me => 'Im Morgengrauen findet man dich.';

  @override
  String toast_revived_dawn(String player) {
    return 'Im Morgengrauen wird $player gefunden.';
  }

  @override
  String get dialogue_not_questioned => 'Noch nicht befragt';

  @override
  String get dialogue_traits_hint =>
      'Merkmale – vergleiche sie mit deinen Hinweisen.';

  @override
  String get error_server_error =>
      'Der Server hat ein Problem. Versuch es gleich noch einmal.';

  @override
  String get error_server_full =>
      'Der Server ist gerade voll. Versuch es später erneut.';

  @override
  String get error_timeout => 'Der Server antwortet nicht.';

  @override
  String get error_unreachable =>
      'Der Server ist nicht erreichbar. Prüfe deine Verbindung.';

  @override
  String get error_replaced =>
      'Du hast diesen Raum auf einem anderen Gerät betreten.';

  @override
  String get error_bad_message => 'Verbindungsfehler (ungültige Nachricht).';

  @override
  String get error_not_in_room => 'Du bist nicht mehr in diesem Raum.';

  @override
  String get error_protocol => 'Diese App-Version passt nicht zum Server.';

  @override
  String get error_room_lost => 'Der Raum ist verloren gegangen.';

  @override
  String get party_zug_auftakt => 'Die Lupe bereitlegen';

  @override
  String get party_zug_auftakt_hinweis =>
      'Eine kleine Probe, bevor die Ermittlung beginnt. Kein Hinweis, keine Wertung, keine Nachtminuten.';

  @override
  String get party_zug_auftakt_fertig => 'Bereit für die Ermittlung';

  @override
  String get party_zug_auftakt_weiter => 'Zur ersten Entscheidung';

  @override
  String get party_zug_weg => 'Unterwegs zum gewählten Ziel';

  @override
  String get party_zug_suchen => 'Die gewählte Stelle untersuchen';

  @override
  String get party_zug_befragen => 'Das Gespräch führen';

  @override
  String get party_zug_umweg => 'Ein anderer Zugang zur selben Quelle';

  @override
  String get party_zug_kurz => 'Szene abkürzen';

  @override
  String get party_zug_blockiert =>
      'Der Weg ist nicht erreichbar. Die Untersuchung bleibt offen.';

  @override
  String party_zug_nachtzeit(String min) {
    return '$min Nachtminuten übrig';
  }

  @override
  String party_zug_marken(String zahl) {
    return 'Marken: $zahl';
  }

  @override
  String get party_zug_gruendlich =>
      'Gründlich suchen · +2 auf den Wurf · 2 Nachtminuten mehr';

  @override
  String get party_zug_wuerfel => 'Der Würfel';

  @override
  String party_zug_pate(String name) {
    return 'Gib das Gerät an $name – jetzt wird gewürfelt!';
  }

  @override
  String get party_zug_werfen => 'Würfeln';

  @override
  String get party_zug_marke_einsetzen => 'Eine Marke einsetzen · +1';

  @override
  String get party_zug_marke_deckel =>
      'Der Bonus liegt bereits bei +2. Keine Marke wird verbraucht.';

  @override
  String party_zug_chancen(String mod) {
    return 'Vor dem Wurf · Bonus +$mod';
  }

  @override
  String get party_zug_garantie =>
      'Pech-Garantie: Dieser Anlauf gelingt mindestens teilweise.';

  @override
  String get party_zug_garantie_kurz => 'Garantie';

  @override
  String get party_zug_erfolg => 'Erfolg';

  @override
  String get party_zug_teilerfolg => 'Teilerfolg';

  @override
  String get party_zug_pech => 'Pech';

  @override
  String get party_zug_erfolg_folge =>
      'Der Fund wird frei. Du gewinnst 7 Nachtminuten.';

  @override
  String get party_zug_teilerfolg_folge =>
      'Der Fund wird frei. Die Auswahl bleibt unverändert.';

  @override
  String get party_zug_pech_folge =>
      'Noch kein Fund. Eine Marke dazu; danach Nochmal oder Umweg.';

  @override
  String get party_zug_auftakt_folge =>
      'Probewurf ohne Fund oder Zeitkosten. Pech schenkt eine Marke.';

  @override
  String party_zug_rechnung(
    String a,
    String b,
    String mod,
    String summe,
    String anlauf,
  ) {
    return '2W6: $a + $b + $mod = $summe · Anlauf $anlauf';
  }

  @override
  String get party_zug_tischruf => 'Tischruf: Wie geht es weiter?';

  @override
  String get party_zug_pech_szene =>
      'Die Spur verläuft sich kurz. Die Quelle bleibt dieselbe. Glück im Unglück: eine Marke!';

  @override
  String get party_zug_nochmal => 'Nochmal · 3 Nachtminuten';

  @override
  String get party_zug_umweg_knopf => 'Umweg · 3 Nachtminuten';

  @override
  String get party_zug_fund_zeigen => 'Fund ansehen';

  @override
  String get party_zug_protokoll => 'Würfelprotokoll';

  @override
  String get party_zug_kein_wurf =>
      'Noch kein Wurf. Befragungen bleiben würfelfrei.';

  @override
  String get party_zug_wahl_bindung =>
      'Die Auswahl bleibt endgültig. Nochmal und Umweg wiederholen nur die Untersuchung, nicht die Entscheidung.';

  @override
  String get logo_stamp => 'Ungelöst';

  @override
  String lobby_bot_slot(int n) {
    return 'KI-Partner $n';
  }

  @override
  String hub_streak_label(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tage in Folge',
      one: 'Tag in Folge',
      zero: 'Keine Serie',
    );
    return '$_temp0';
  }

  @override
  String get detektei_neuer_abend => 'Neuer Abend';

  @override
  String get detektei_beitreten => 'Beitreten';

  @override
  String get detektei_beitreten_hinweis =>
      'Mit Raumcode oder QR-Code einem Abend beitreten.';

  @override
  String get detektei_bald => 'bald';

  @override
  String get detektei_kampagne => 'Kampagne';

  @override
  String get detektei_kampagne_hinweis => 'Die Akten der Reihe nach';

  @override
  String detektei_personen(int min, int max) {
    return '$min bis $max Personen';
  }

  @override
  String get detektei_ton_spuk => 'Spuk';

  @override
  String get detektei_ton_noir => 'Noir';

  @override
  String get detektei_sammlung => 'Sammlung';

  @override
  String get detektei_sammlung_hinweis => 'Die Karten der Figuren';

  @override
  String get detektei_profil => 'Profil';

  @override
  String get detektei_profil_hinweis => 'Rang, Name und Ausrüstung';

  @override
  String get detektei_akten_fehler => 'Die Akten konnten nicht geladen werden.';

  @override
  String get detektei_nochmal => 'Nochmal versuchen';

  @override
  String get detektei_akte_spielen => 'Diese Akte spielen';

  @override
  String get detektei_akte_druckmappe => 'Druckmappe';

  @override
  String get detektei_akte_unbekannt => 'Diese Akte gibt es nicht.';

  @override
  String get detektei_druck_titel => 'Druckmappe';

  @override
  String get detektei_druck_hinweis =>
      'Stelle den Abend ein. Danach erstellst du die Dateien zum Ausdrucken.';

  @override
  String get detektei_druck_vorbereiten => 'Druckmappe vorbereiten';

  @override
  String abend_schritt(int n, int gesamt) {
    return 'Schritt $n von $gesamt';
  }

  @override
  String get abend_schritt_akte => 'Akte';

  @override
  String get abend_schritt_spielweise => 'Spielweise';

  @override
  String get abend_schritt_einstellungen => 'Einstellungen';

  @override
  String get abend_schritt_start => 'Start';

  @override
  String get abend_akte_titel => 'Welche Akte spielt ihr?';

  @override
  String get abend_akte_hinweis =>
      'Jede Akte ist ein eigener Fall mit eigenen Figuren.';

  @override
  String get abend_spielweise_titel => 'Wie spielt ihr?';

  @override
  String get abend_spielweise_hinweis =>
      'Wähle zuerst die Spielweise. Sie bestimmt, wie der Abend abläuft.';

  @override
  String get abend_spielweise_solo => 'Solo mit Bots';

  @override
  String get abend_spielweise_solo_text =>
      'Du ermittelst allein. Bots übernehmen die Gäste.';

  @override
  String get abend_spielweise_reihum => 'Ein Gerät reihum';

  @override
  String get abend_spielweise_reihum_text =>
      'Ein Gerät geht am Tisch von Hand zu Hand. Jede Person liest ihre Rolle verdeckt.';

  @override
  String get abend_spielweise_eigene => 'Jeder am eigenen Gerät';

  @override
  String get abend_spielweise_eigene_text =>
      'Jede Person spielt mit ihrem eigenen Handy. Ihr verbindet euch über einen Raumcode.';

  @override
  String get abend_spielweise_eigene_bald =>
      'Kommt bald: Online-Abende mit Raumcode.';

  @override
  String get abend_einstellungen_titel => 'Einstellungen für den Abend';

  @override
  String get abend_laedt => 'Die Akte wird vorbereitet …';

  @override
  String get abend_fehler => 'Die Akte konnte nicht geladen werden.';

  @override
  String get abend_nochmal => 'Nochmal versuchen';

  @override
  String get abend_weiter => 'Weiter';

  @override
  String get abend_start_titel => 'Bereit?';

  @override
  String get abend_start_hinweis =>
      'Mit dem Start beginnt die Rollenverteilung.';

  @override
  String get abend_start_akte => 'Akte';

  @override
  String get abend_start_spielweise => 'Spielweise';

  @override
  String get abend_start_personen => 'Personen';

  @override
  String get abend_start_dauer => 'Rundendauer';

  @override
  String get abend_start => 'Abend beginnen';

  @override
  String get abend_abbrechen => 'Abend abbrechen';

  @override
  String get abend_abbrechen_titel => 'Abend abbrechen?';

  @override
  String get abend_abbrechen_text =>
      'Der Abend endet hier, es gibt keine Belohnung. Er lässt sich danach nicht fortsetzen.';

  @override
  String get abend_abbrechen_ja => 'Abend abbrechen';

  @override
  String get abend_abbrechen_nein => 'Weiterspielen';

  @override
  String get abend_klasse_titel => 'Deine Ermittlerklasse';

  @override
  String get abend_klasse_hinweis =>
      'Dein Abend bringt dir immer eine Sammelkarte deiner Klasse.';

  @override
  String abend_klasse_gesperrt(String klasse, String rang) {
    return '$klasse, gesperrt, $rang';
  }

  @override
  String get abend_klasse_forensic_faehigkeit_name => 'Spurenblick';

  @override
  String get abend_klasse_forensic_faehigkeit =>
      'Suchstellen und Erkundungsorte leuchten schon von weitem.';

  @override
  String get abend_klasse_profiler_faehigkeit_name => 'Menschenkenner';

  @override
  String get abend_klasse_profiler_faehigkeit =>
      'Du siehst Gesprächspartner und ihre Stimmung sofort.';

  @override
  String get abend_klasse_excop_faehigkeit_name => 'Ortskundig';

  @override
  String get abend_klasse_excop_faehigkeit =>
      'Türen, verschlossene Türen und Treppen sind umrandet.';

  @override
  String get abend_klasse_journalist_faehigkeit_name => 'Gerüchte';

  @override
  String get abend_klasse_journalist_faehigkeit =>
      'Im Vorbeigehen schnappst du Gerüchte auf.';

  @override
  String get abend_klasse_medic_faehigkeit_name => 'Laufschritt';

  @override
  String get abend_klasse_medic_faehigkeit =>
      'Du läufst auf der Karte schneller.';

  @override
  String get abend_klasse_fair =>
      'Diese Fähigkeit ändert nie Fakten, Punkte oder Würfel.';

  @override
  String get abend_klasse_karte_titel => 'Auf der Karte';

  @override
  String get abend_klasse_karten_titel => 'Sammelkarten dieser Klasse';

  @override
  String get abend_klasse_karte_besessen => 'in deiner Sammlung';

  @override
  String get detektiv_karte_titel => 'Deine Detektivkarte';

  @override
  String get detektiv_karte_oeffnen => 'Detektivkarte';

  @override
  String get detektiv_karte_hinweis =>
      'Wer ermittelt, liest hier Auftrag und Regeln.';

  @override
  String get detektiv_karte_auftrag => 'Dein Auftrag';

  @override
  String get detektiv_karte_auftrag_1 => 'Finde heraus, wer es war.';

  @override
  String detektiv_karte_auftrag_2(int runden, int entscheidungen) {
    return '$runden Runden, $entscheidungen Entscheidungen, dann die Anklage.';
  }

  @override
  String get detektiv_karte_auftrag_3 =>
      'Anklage und Punkte bestimmen zusammen das Ende.';

  @override
  String get detektiv_karte_regeln => 'Deine Regeln';

  @override
  String get detektiv_karte_regel_1 =>
      'Je Entscheidung wählst du genau eine Möglichkeit.';

  @override
  String get detektiv_karte_regel_2 =>
      'Gute Entscheidungen geben Punkte, sichtbar erst am Ende.';

  @override
  String get detektiv_karte_regel_3 =>
      'Was dir zugeflüstert wird, prüfst du selbst.';

  @override
  String get detektiv_karte_klasse => 'Deine Klasse';

  @override
  String get detektiv_karte_belohnung =>
      'Jeder Abend bringt eine Sammelkarte deiner Klasse.';

  @override
  String get detektiv_karte_befragungen => 'So laufen Befragungen';

  @override
  String get detektiv_karte_befragung_1 => 'Frag gezielt: Wer war wann wo?';

  @override
  String get detektiv_karte_befragung_2 => 'Du fragst nach und hörst genau zu.';

  @override
  String get detektiv_karte_befragung_3 =>
      'Schreib auf, was nicht zusammenpasst.';

  @override
  String get abend_feste_loesung_titel => 'Feste Lösung';

  @override
  String get abend_feste_loesung_hinweis =>
      'Diese Akte hat eine feste Lösung. Wer sie schon kennt, spielt am besten eine Rolle statt der Ermittlung.';

  @override
  String get abend_feste_loesung_solo =>
      'Diese Akte hat eine feste Lösung. Wer sie schon kennt, wählt besser eine andere Akte.';

  @override
  String get abend_feste_loesung_online =>
      'Diese Akte hat eine feste Lösung. Wer sie schon kennt, spielt am besten eine Rolle statt der Ermittlung. Dann öffnet besser jemand anderes den Raum.';

  @override
  String get profil_klasse_hinweis =>
      'Tippe auf eine Klasse, um sie zu wählen. Dein Abend bringt dir eine Sammelkarte dieser Klasse.';

  @override
  String profil_klasse_akten(String akten) {
    return 'Wirkt nur in diesen Akten: $akten.';
  }

  @override
  String get profil_klasse_akten_allgemein =>
      'Die Fähigkeiten wirken nicht in jeder Akte.';

  @override
  String get profil_klasse_gewaehlt => 'Gewählt';

  @override
  String get karten_sammlung_titel => 'Sammlung';

  @override
  String get karten_sammlung_text =>
      'Die Karten der Figuren und Detektivklassen. Tippe eine Karte an, um sie groß zu sehen.';

  @override
  String get karten_seltenheit_zinn => 'Zinn';

  @override
  String get karten_seltenheit_messing => 'Messing';

  @override
  String get karten_seltenheit_blutgold => 'Blutgold';

  @override
  String get karten_rueckseite => 'Kartenrückseite';

  @override
  String profil_chip_semantik(String name, String rang, int xp) {
    return 'Profil von $name, $rang, $xp Erfahrungspunkte';
  }

  @override
  String karten_sammlung_fortschritt(int x, int y) {
    return '$x von $y Karten';
  }

  @override
  String karten_figur_fortschritt(int x, int y) {
    return '$x von $y';
  }

  @override
  String get karten_tab_klassen => 'Detektivklassen';

  @override
  String get karten_sammlung_leer =>
      'Für diese Akte gibt es noch keine Karten.';

  @override
  String get karten_laedt => 'Die Karten werden geladen …';

  @override
  String get karten_fehler => 'Die Karten konnten nicht geladen werden.';

  @override
  String get karten_unbekannt => 'Unbekannte Karte';

  @override
  String karten_unbekannt_semantik(String figur) {
    return '$figur: noch nicht gefunden';
  }

  @override
  String get karten_noch_nicht => 'Noch nicht gefunden';

  @override
  String get karten_neu => 'NEU';

  @override
  String karten_anzahl(int n) {
    return '$n×';
  }

  @override
  String karten_besitz(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Du besitzt $n Exemplare.',
      one: 'Du besitzt 1 Exemplar.',
    );
    return '$_temp0';
  }

  @override
  String karten_ladungen(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Ladungen',
      one: '1 Ladung',
    );
    return '$_temp0';
  }

  @override
  String get karten_seltenheit_gewoehnlich => 'Gewöhnlich';

  @override
  String get karten_seltenheit_selten => 'Selten';

  @override
  String get karten_seltenheit_legendaer => 'Legendär';

  @override
  String get karten_art_werkzeug => 'Werkzeug';

  @override
  String get karten_art_marke => 'Marke';

  @override
  String get karten_art_zeit => 'Zeit';

  @override
  String get karten_art_gruendlich => 'Gründlich';

  @override
  String get karten_art_nochmal => 'Nochmal';

  @override
  String get karten_art_umweg => 'Umweg';

  @override
  String get karten_art_abstecher => 'Abstecher';

  @override
  String get karten_art_erinnerung => 'Erinnerung';

  @override
  String get karten_art_kosmetik => 'Aussehen';

  @override
  String get karten_quelle_titel => 'So bekommst du sie';

  @override
  String get karten_quelle_rolle =>
      'Spiele diese Rolle oder Klasse zu Ende, oder habe die Figur an deinem Tisch.';

  @override
  String get karten_quelle_taeter =>
      'Überführe diese Figur mit einer richtigen Anklage.';

  @override
  String get karten_quelle_meister => 'Erreiche das Meister-Ende der Akte.';

  @override
  String get karten_quelle_abstecher =>
      'Erkunde einen Ort der Akte erfolgreich.';

  @override
  String get karten_quelle_start => 'Gehört zum Startset.';

  @override
  String get karten_deck_bearbeiten => 'Deck bearbeiten';

  @override
  String get karten_deck_titel => 'Dein Deck';

  @override
  String get karten_deck_text =>
      'Höchstens drei Karten, je Art eine. Am Abend liegen sie als gemeinsame Hilfe auf dem Tisch. Eine Karte gleicher Art ersetzt die bisherige.';

  @override
  String karten_deck_platz(int n) {
    return 'Platz $n';
  }

  @override
  String get karten_deck_leer => 'Leer';

  @override
  String karten_deck_ladungen(int x, int y) {
    return 'Ladungen $x von $y';
  }

  @override
  String get karten_deck_voll =>
      'Das Deck ist voll. Nimm zuerst eine Karte heraus.';

  @override
  String get karten_deck_zuviel => 'Zu viele Ladungen für das Deck.';

  @override
  String get karten_deck_deine => 'Deine spielbaren Karten';

  @override
  String get karten_deck_keine =>
      'Du hast noch keine spielbare Karte. Spiele Abende, um Karten zu finden.';

  @override
  String karten_deck_einsetzen(String titel) {
    return '$titel ins Deck legen';
  }

  @override
  String karten_deck_entfernen(String titel) {
    return '$titel aus dem Deck nehmen';
  }

  @override
  String get karten_deck_drin => 'Im Deck';

  @override
  String get karten_deck_fertig => 'Fertig';

  @override
  String get karten_deck_abend_titel => 'Deck für diesen Abend';

  @override
  String get karten_deck_abend_leer =>
      'Kein Deck gelegt. Der Abend läuft auch ohne Karten.';

  @override
  String get karten_deck_aendern => 'Deck ändern';

  @override
  String karten_detektei_neueste(String titel) {
    return 'Neueste Karte: $titel';
  }

  @override
  String get karten_hand_titel => 'Deine Karten';

  @override
  String karten_hand_karte(String titel, int rest, int max) {
    return '$titel, noch $rest von $max Ladungen';
  }

  @override
  String get karten_hand_spielbar => 'Jetzt spielbar';

  @override
  String get karten_hand_gesperrt => 'Jetzt nicht spielbar';

  @override
  String get karten_hand_gewaehlt => 'Eingesetzt';

  @override
  String get karten_hand_leer => 'Aufgebraucht';

  @override
  String get karten_hand_spielen => 'Spielen';

  @override
  String get karten_hand_schliessen => 'Schließen';

  @override
  String get karten_hand_wuerfel =>
      'Tippe die Werkzeug-Karte: +1 auf diesen Wurf.';

  @override
  String get karten_hand_tischruf =>
      'Tippe die passende Karte: Nochmal oder Umweg ohne Nachtminuten.';

  @override
  String get karten_hand_gruendlich =>
      'Tippe die Gründlich-Karte: gründlich ohne Nachtminuten.';

  @override
  String get karten_hand_karte_hinweis =>
      'Zeit-, Marken- und Erinnerungskarten spielst du zwischen den Zügen.';

  @override
  String get karten_hand_im_zug =>
      'Diese Karte wirkt im passenden Moment eines Zuges: beim Würfeln, nach Pech oder bei der Wahl.';

  @override
  String karten_erkunden(String name) {
    return 'Erkunden: $name';
  }

  @override
  String get karten_erkunden_marke => 'Abstecher';

  @override
  String get karten_erkunden_text =>
      'Freiwillig: ein kurzer Blick in eine Ecke. Das bringt Stimmung und vielleicht eine Karte, aber nie einen Hinweis zum Fall.';

  @override
  String karten_erkunden_kosten(int min, int pech) {
    return 'Kostet $min Nachtminuten. Bei Pech kommen $pech dazu.';
  }

  @override
  String get karten_erkunden_los => 'Erkunden';

  @override
  String get karten_erkunden_nein => 'Nicht jetzt';

  @override
  String karten_erkunden_karte(String titel) {
    return 'Abstecher-Karte einsetzen: $titel (ohne Nachtminuten)';
  }

  @override
  String get karten_erkunden_wuerfel =>
      'Pech zeigt hier nur ein Missgeschick. Einen Tischruf gibt es nicht.';

  @override
  String get karten_erkunden_fund => 'Nebenfund';

  @override
  String get karten_erkunden_liste => 'Freiwillig erkunden';

  @override
  String karten_gruendlich_karte(String titel) {
    return 'Gründlich-Karte einsetzen: $titel (ohne Nachtminuten)';
  }

  @override
  String get abend_belohnung_marke => 'Belohnung';

  @override
  String get abend_belohnung_titel => 'Abend abgeschlossen';

  @override
  String get abend_belohnung_karten => 'Neue Karten';

  @override
  String get abend_belohnung_tipp => 'Tippe eine Karte, um sie umzudrehen.';

  @override
  String get abend_belohnung_alle => 'Alle umdrehen';

  @override
  String get abend_belohnung_keine => 'Diesmal gibt es keine Karte.';

  @override
  String get abend_belohnung_doppelt => 'Doppelt';

  @override
  String abend_belohnung_verdeckt(int nr, int gesamt) {
    return 'Karte $nr von $gesamt, verdeckt. Tippen zum Umdrehen.';
  }

  @override
  String abend_belohnung_xp(int xp) {
    return '+$xp Erfahrungspunkte';
  }

  @override
  String get abend_belohnung_xp_titel => 'Erfahrung';

  @override
  String abend_belohnung_rang_stempel(String rang) {
    return 'BEFÖRDERT: $rang';
  }

  @override
  String abend_belohnung_rang_semantik(String rang) {
    return 'Neuer Rang: $rang';
  }

  @override
  String get abend_belohnung_bereits => 'Dieser Abend ist schon verbucht.';

  @override
  String get abend_belohnung_laedt => 'Die Belohnung wird gezählt …';

  @override
  String get abend_belohnung_fehler =>
      'Die Belohnung konnte nicht verbucht werden.';

  @override
  String get abend_belohnung_detektei => 'Zur Detektei';

  @override
  String karten_erkunden_erfolg_folge(int min) {
    return 'Ein Fund für die Sammlung. Du gewinnst $min Nachtminuten.';
  }

  @override
  String get karten_erkunden_teilerfolg_folge =>
      'Ein kleiner Fund für die Sammlung. Die Nachtzeit bleibt, wie sie ist.';

  @override
  String karten_erkunden_pech_folge(int min) {
    return 'Nur ein Missgeschick. Das kostet $min Nachtminuten, dafür gibt es eine Marke.';
  }

  @override
  String get abend_belohnung_ansehen => 'Belohnung ansehen';

  @override
  String get online_einstellungen_hinweis =>
      'Wie viele Rollen es gibt, legst du gleich in der Lobby fest. Freie Rollen übernehmen Bots.';

  @override
  String get online_raum_oeffnen => 'Raum öffnen';

  @override
  String get online_start_hinweis =>
      'Beim Öffnen verbindet sich dein Gerät mit dem Relais. Danach treten die anderen mit dem Raumcode bei.';

  @override
  String get online_oeffnen_fehler => 'Der Raum konnte nicht angelegt werden.';

  @override
  String get online_lobby_marke => 'Jeder am eigenen Gerät';

  @override
  String get online_lobby_titel => 'Lobby';

  @override
  String get online_lobby_untertitel =>
      'Die anderen treten mit dem Raumcode bei. Sind alle bereit, startest du den Abend.';

  @override
  String get online_lobby_verbinde => 'Raum wird geöffnet …';

  @override
  String get online_lobby_fehler =>
      'Das Relais ist nicht erreichbar. Prüfe die Internetverbindung und versuche es noch einmal.';

  @override
  String get online_abend_starten => 'Abend starten';

  @override
  String get online_code_titel => 'Raumcode';

  @override
  String online_code_semantik(String code) {
    return 'Raumcode $code';
  }

  @override
  String get online_code_kopieren => 'Code kopieren';

  @override
  String get online_link_kopieren => 'Link kopieren';

  @override
  String get online_kopiert => 'Kopiert';

  @override
  String get online_qr_semantik => 'QR-Code zum Beitreten';

  @override
  String get online_qr_hinweis =>
      'Scannen oder in der Detektei auf „Beitreten“ tippen und den Code eingeben.';

  @override
  String get online_tisch_titel => 'Am Tisch';

  @override
  String get online_tisch_leer => 'Noch ist niemand beigetreten.';

  @override
  String get online_spielleitung => 'Gastgeber';

  @override
  String get online_bereit => 'Bereit';

  @override
  String get online_nicht_bereit => 'Nicht bereit';

  @override
  String get online_getrennt => 'Getrennt';

  @override
  String get online_verbunden => 'Verbunden';

  @override
  String get online_assistenz => 'Assistenz';

  @override
  String get online_alle_bereit => 'Alle sind bereit.';

  @override
  String get online_warten_bereit => 'Warten, bis alle bereit sind.';

  @override
  String get online_rollen_titel => 'Rollen';

  @override
  String online_rollen_anzahl(int n) {
    return '$n Rollen';
  }

  @override
  String get online_rollen_weniger => 'Weniger Rollen';

  @override
  String get online_rollen_mehr => 'Mehr Rollen';

  @override
  String online_rollen_bots(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Bots übernehmen die freien Rollen.',
      one: 'Ein Bot übernimmt die freie Rolle.',
      zero: 'Alle Rollen sind mit Gästen besetzt.',
    );
    return '$_temp0';
  }

  @override
  String get online_rollen_hinweis =>
      'Mindestens so viele Rollen wie Gäste, höchstens so viele, wie die Akte kennt.';

  @override
  String get online_schliessen_titel => 'Raum schließen?';

  @override
  String get online_schliessen_text =>
      'Alle, die schon beigetreten sind, werden getrennt.';

  @override
  String get online_schliessen_ja => 'Raum schließen';

  @override
  String get online_schliessen_nein => 'Weiter warten';

  @override
  String online_leiste_raum(String code) {
    return 'Raum $code';
  }

  @override
  String online_leiste_online(int n, int gesamt) {
    return '$n von $gesamt Gästen online';
  }

  @override
  String get online_menue => 'Raum und Gäste';

  @override
  String get online_beenden => 'Abend beenden';

  @override
  String get online_beenden_titel => 'Abend für alle beenden?';

  @override
  String get online_beenden_text =>
      'Alle Gäste werden getrennt. Der Abend lässt sich danach nicht fortsetzen.';

  @override
  String get online_beenden_ja => 'Abend beenden';

  @override
  String get online_beenden_nein => 'Weiterspielen';

  @override
  String get online_rollen_erklaerung =>
      'Jede Person liest ihre Rolle auf dem eigenen Gerät. Du hast keine Rolle zu lesen.';

  @override
  String online_rollen_warten(int x, int y) {
    return 'Warten auf die Gäste: $x von $y haben ihre Rolle gelesen';
  }

  @override
  String get online_rollen_alle => 'Alle Gäste haben ihre Rolle gelesen.';

  @override
  String get online_rollen_ohne_gaeste =>
      'Alle Rollen spielen Bots. Es kann weitergehen.';

  @override
  String get online_rollen_gelesen => 'Gelesen';

  @override
  String get online_rollen_liest => 'Liest noch';

  @override
  String get online_wahl_hinweis =>
      'Die Gäste wählen auf ihren Geräten. Die Bots stimmen von selbst ab.';

  @override
  String online_wahl_fortschritt(int x, int y) {
    return '$x von $y Gästen haben abgestimmt';
  }

  @override
  String get online_wahl_nur_bots =>
      'Alle Rollen spielen Bots, sie haben von selbst abgestimmt.';

  @override
  String get online_wahl_abgegeben_kurz => 'Abgestimmt';

  @override
  String get online_wahl_waehlt => 'Wählt noch';

  @override
  String online_wuerfelt(String name) {
    return '$name würfelt …';
  }

  @override
  String get online_fehler_nicht_bereit => 'Noch nicht alle sind bereit.';

  @override
  String get online_fehler_nicht_dran =>
      'Du bist gerade nicht mit Würfeln dran.';

  @override
  String get online_fehler_phase =>
      'Das geht in diesem Abschnitt gerade nicht.';

  @override
  String get online_fehler_schon_gewaehlt => 'Du hast schon gewählt.';

  @override
  String get online_fehler_keine_antwort =>
      'Keine Antwort vom Gastgeber. Versuche es noch einmal.';

  @override
  String get online_fehler_allgemein =>
      'Das hat nicht geklappt. Versuche es noch einmal.';

  @override
  String get online_fehler_code =>
      'Der Raumcode ist nicht gültig. Er hat sechs Zeichen.';

  @override
  String get online_fehler_relay =>
      'Das Relais ist nicht erreichbar. Prüfe deine Internetverbindung.';

  @override
  String get online_fehler_kein_raum =>
      'Es gibt keinen Raum mit diesem Code, oder der Gastgeber ist nicht online.';

  @override
  String get online_fehler_zeit =>
      'Keine Antwort in der Zeit. Versuche es noch einmal.';

  @override
  String get online_fehler_voll => 'Der Raum ist voll.';

  @override
  String get online_fehler_gestartet => 'Der Abend hat schon begonnen.';

  @override
  String get online_fehler_proto =>
      'Diese App-Version passt nicht zum Raum. Aktualisiere die App.';

  @override
  String get online_fehler_inhalt =>
      'Die Fassungen der Akten passen nicht zusammen. Aktualisiere die App auf beiden Geräten.';

  @override
  String get online_fehler_name => 'Bitte gib einen Namen ein.';

  @override
  String get online_beitreten_marke => 'Online-Abend';

  @override
  String get online_beitreten_titel => 'Einem Abend beitreten';

  @override
  String get online_beitreten_untertitel =>
      'Gib den Raumcode ein, den der Gastgeber zeigt.';

  @override
  String get online_code_feld => 'Raumcode';

  @override
  String get online_code_platzhalter => 'ABC-DEF';

  @override
  String get online_name_feld => 'Dein Name';

  @override
  String get online_name_platzhalter => 'So heißt du am Tisch';

  @override
  String get online_beitreten_los => 'Beitreten';

  @override
  String get online_beitreten_laeuft => 'Verbinde …';

  @override
  String online_zurueck_in_raum(String code) {
    return 'Zurück in Raum $code';
  }

  @override
  String get online_zurueck_hinweis =>
      'Du hast noch einen Platz in diesem Abend.';

  @override
  String get online_vergessen => 'Vergessen';

  @override
  String online_zurueck_zum_abend(String code) {
    return 'Zurück zum Abend $code';
  }

  @override
  String get online_zurueck_gastgeber_hinweis =>
      'Du führst diesen Abend. Er ist auf diesem Gerät gespeichert.';

  @override
  String get online_verwerfen => 'Verwerfen';

  @override
  String get online_rueckkehr_fehler => 'Die Rückkehr hat nicht geklappt.';

  @override
  String get online_status_verbinde => 'Verbinde …';

  @override
  String get online_status_pausiert => 'Gastgeber getrennt – Abend pausiert';

  @override
  String get online_status_geschlossen => 'Der Abend wurde beendet.';

  @override
  String get online_status_getrennt =>
      'Keine Verbindung – prüfe dein Internet. Dein Platz bleibt reserviert.';

  @override
  String get online_lobby_getrennt =>
      'Die Verbindung zum Relais ist weg. Gäste können gerade nicht beitreten, und der Abend lässt sich nicht starten. Dein Gerät verbindet sich von selbst neu.';

  @override
  String get online_leiste_getrennt =>
      'Relais getrennt – Gäste erfahren gerade nichts';

  @override
  String get online_zur_detektei => 'Zur Detektei';

  @override
  String online_gast_marke(String code) {
    return 'Raum $code';
  }

  @override
  String get online_gast_lobby_titel => 'Warten auf den Start';

  @override
  String get online_gast_lobby_hinweis =>
      'Tippe auf „Bereit“. Sind alle bereit, startet der Gastgeber den Abend.';

  @override
  String get online_bereit_knopf => 'Bereit';

  @override
  String get online_bereit_zurueck => 'Doch nicht bereit';

  @override
  String get online_rolle_marke => 'Deine Rolle';

  @override
  String get online_dossier_wer => 'Wer ich bin';

  @override
  String get online_dossier_ziel => 'Mein Ziel';

  @override
  String get online_dossier_weiss => 'Was ich weiß';

  @override
  String get online_dossier_verbirgt => 'Was ich verberge';

  @override
  String get online_dossier_tarnung => 'Meine Tarngeschichte';

  @override
  String get online_dossier_tatwissen => 'Was wirklich geschah';

  @override
  String get online_dossier_besetzung => 'Besetzung';

  @override
  String get online_dossier_stempel => 'Geheim';

  @override
  String get online_gelesen_knopf => 'Gelesen';

  @override
  String get online_gelesen_warten =>
      'Du hast deine Rolle gelesen. Es geht weiter, sobald alle gelesen haben.';

  @override
  String get online_assistenz_text =>
      'Du hast keine eigene Rolle und verfolgst den öffentlichen Verlauf des Abends mit.';

  @override
  String online_meine_rolle(String name) {
    return 'Meine Rolle: $name';
  }

  @override
  String get online_warten_spielleitung => 'Gleich geht es weiter …';

  @override
  String online_runde(int n) {
    return 'Runde $n';
  }

  @override
  String get online_erzaehler_titel => 'Erzähler';

  @override
  String get online_phase_rollen => 'Die Rollen werden gelesen';

  @override
  String get online_phase_intro => 'Die Nacht beginnt';

  @override
  String get online_phase_gespraeche => 'Gespräche';

  @override
  String get online_phase_entscheidungen => 'Ermittlung';

  @override
  String get online_phase_gruppenwahl => 'Gruppenwahl';

  @override
  String get online_phase_bonus => 'Ein Hinweis';

  @override
  String get online_phase_resuemee => 'Zwischenresümee';

  @override
  String get online_phase_anklage => 'Anklage';

  @override
  String get online_phase_finale => 'Finale';

  @override
  String get online_phase_aufloesung => 'Auflösung';

  @override
  String get online_phase_ende => 'Ende des Abends';

  @override
  String get online_phase_unbekannt => 'Der Abend läuft';

  @override
  String get online_gespraeche_titel => 'Deine Gespräche in dieser Runde';

  @override
  String get online_gespraeche_keine =>
      'In dieser Runde hast du kein Pflichtgespräch.';

  @override
  String online_gespraech_mit(String name) {
    return 'Gespräch mit $name';
  }

  @override
  String get online_gespraech_thema => 'Thema';

  @override
  String get online_gespraech_ziel => 'Dein Ziel';

  @override
  String get online_gespraech_eroeffnung => 'Eröffnung';

  @override
  String get online_bots_titel => 'Was am Tisch zu hören ist';

  @override
  String online_bot_spricht(String sprecher, String partner) {
    return '$sprecher spricht mit $partner';
  }

  @override
  String get online_preisgabe => 'Verrät';

  @override
  String get online_frage_titel => 'Die Frage';

  @override
  String get online_gewaehlt_titel => 'Gewählt';

  @override
  String get online_optionen_titel => 'Zur Wahl stehen';

  @override
  String get online_ermittlung_wartet => 'Der Detektiv wählt gerade …';

  @override
  String get online_ermittlung_fertig =>
      'Die Ermittlung dieser Runde ist abgeschlossen. Gleich geht es zur Gruppenwahl.';

  @override
  String online_nachtzeit(int min) {
    return 'Nachtzeit: $min Min.';
  }

  @override
  String online_marken(int n) {
    return 'Marken: $n';
  }

  @override
  String get online_auftakt => 'Der erste Wurf: Die Gruppe sucht nach Spuren.';

  @override
  String get online_abstecher => 'Der Detektiv erkundet einen Ort.';

  @override
  String get online_zug_aktion => 'Der Detektiv ist unterwegs …';

  @override
  String get online_wuerfel_titel => 'Würfel';

  @override
  String get online_wuerfel_du => 'Du würfelst für die Gruppe.';

  @override
  String online_chancen(int mod) {
    return 'Chancen (Modifikator $mod)';
  }

  @override
  String get online_stufe_erfolg => 'Erfolg';

  @override
  String get online_stufe_teilerfolg => 'Teilerfolg';

  @override
  String get online_stufe_pech => 'Pech';

  @override
  String get online_marke_einsetzen => 'Marke einsetzen';

  @override
  String online_werkzeug_einsetzen(String titel) {
    return 'Werkzeug-Karte einsetzen: $titel (+1)';
  }

  @override
  String get online_wuerfeln_knopf => 'Würfeln';

  @override
  String get online_wurf_titel => 'Wurf';

  @override
  String online_wurf_rechnung(int a, int b, int mod, int summe) {
    return '$a + $b + $mod = $summe';
  }

  @override
  String get online_wurf_garantie =>
      'Pech-Garantie: Pech zählt als Teilerfolg.';

  @override
  String online_wurf_zeile(String stufe, int a, int b, int mod, int summe) {
    return '$stufe: $a + $b + $mod = $summe';
  }

  @override
  String get online_wuerfe_titel => 'Würfelprotokoll';

  @override
  String get online_tischruf_wartet =>
      'Pech. Der Detektiv entscheidet, wie es weitergeht.';

  @override
  String get online_fund_titel => 'Fund';

  @override
  String get online_fund_wartet => 'Der Detektiv liest den Fund.';

  @override
  String get online_notizbuch_titel => 'Notizbuch';

  @override
  String get online_wahl_titel => 'Deine Wahl in dieser Runde';

  @override
  String get online_wahl_geheim =>
      'Niemand sieht, was du wählst. Tippe eine Karte an und gib deine Wahl ab.';

  @override
  String get online_wahl_abgeben => 'Wahl abgeben';

  @override
  String get online_wahl_abgegeben =>
      'Deine Stimme ist abgegeben. Warten auf die anderen …';

  @override
  String get online_wahl_assistenz =>
      'Die Gruppenwahl läuft. Du hast keine Stimme, weil du keine Rolle hast.';

  @override
  String get online_verdaechtige_titel => 'Verdächtige';

  @override
  String get online_anklage_wartet =>
      'Der Detektiv erhebt die Anklage gegen eine dieser Personen.';

  @override
  String get online_aufloesung_titel => 'Die Auflösung';

  @override
  String get online_aufloesung_taeter => 'Täter oder Täterin';

  @override
  String get online_aufloesung_punkte => 'Richtige Entscheidungen';

  @override
  String get online_aufloesung_ende => 'Ende';

  @override
  String get online_aufloesung_code => 'Fall-Code';

  @override
  String get online_verlassen => 'Abend verlassen';

  @override
  String get online_verlassen_titel => 'Abend verlassen?';

  @override
  String get online_verlassen_text =>
      'Du verlierst deinen Platz und deine Rolle in diesem Abend.';

  @override
  String get online_verlassen_ja => 'Verlassen';

  @override
  String get online_verlassen_nein => 'Bleiben';

  @override
  String get abend2_auftrag => 'Ermittlungsauftrag';

  @override
  String abend2_beweisstueck(String nr) {
    return 'Beweisstück Nr. $nr';
  }

  @override
  String get abend2_angeklagt => 'Angeklagt';

  @override
  String get online_bot_stempel => 'Bot';

  @override
  String get detektei_dienstausweis => 'Dienstausweis';

  @override
  String get detektei_dienstgrad => 'Dienstgrad';

  @override
  String get detektei_akte_lage => 'Die Lage';

  @override
  String get detektei_akte_schauplatz => 'Schauplatz';

  @override
  String get detektei_akte_anlass => 'Anlass';

  @override
  String get detektei_akte_zeitpunkt => 'Zeitpunkt';

  @override
  String get ton_an => 'Ton an';

  @override
  String get ton_aus => 'Ton aus';

  @override
  String get gespraech_ansprechen => 'Ansprechen';

  @override
  String get gespraech_marke => 'Vernehmung am Rande';

  @override
  String get gespraech_beenden => 'Gespräch beenden';

  @override
  String get gespraech_ich => 'Ich';

  @override
  String get gespraech_haltung_freundlich => 'Freundlich';

  @override
  String get gespraech_haltung_draengen => 'Drängen';

  @override
  String get gespraech_haltung_bluffen => 'Bluffen';

  @override
  String get gespraech_haltung_vorlegen => 'Vorlegen';

  @override
  String get nachspiel_titel => 'Nachspiel';

  @override
  String get nachspiel_hinweis => 'Was aus den Zeugen wurde';

  @override
  String get erster_fall_marke => 'Dein erster Fall';

  @override
  String get erster_fall_text =>
      'Ein Fest im Schlosskeller, ein Knall, dann ist es dunkel. Du ermittelst allein, Bots spielen die Gäste.';

  @override
  String get erster_fall_los => 'Sofort ermitteln';

  @override
  String get erster_fall_hinweis =>
      'Alles Weitere zeigt dir der Abend unterwegs.';

  @override
  String get abend_fortsetzen => 'Abend fortsetzen';

  @override
  String abend_fortsetzen_hinweis(String akte) {
    return '$akte. Es geht genau dort weiter, wo der Abend stand.';
  }

  @override
  String abend_fortsetzen_runde(String akte, int runde) {
    return '$akte, Runde $runde. Es geht genau dort weiter, wo der Abend stand.';
  }

  @override
  String get abend_fortsetzen_verwerfen => 'Abend verwerfen';

  @override
  String get abend_fortsetzen_fehler =>
      'Der Abend lässt sich gerade nicht öffnen. Versuch es gleich noch einmal.';

  @override
  String get abend_ersetzen_titel => 'Abend ersetzen?';

  @override
  String get abend_ersetzen_text =>
      'Ein unterbrochener Abend wartet noch in der Detektei. Ein neuer Abend ersetzt ihn.';

  @override
  String get abend_ersetzen_ja => 'Neuen Abend beginnen';

  @override
  String get abend_ersetzen_nein => 'Zurück';

  @override
  String get teilen_knopf => 'Teilen';

  @override
  String get teilen_marke => 'Abschlussbericht';

  @override
  String get teilen_aufruf => 'Schafft ihr es auch?';

  @override
  String get teilen_code_aufruf => 'Spielt denselben Fall:';

  @override
  String get teilen_fuss => 'Kostenlos, ohne Werbung, ohne Anmeldung';

  @override
  String teilen_betreff(String akte) {
    return 'Mordakte: $akte';
  }

  @override
  String teilen_text(String akte, String ende, String punkte) {
    return 'Fall geschlossen: „$akte“. $ende, $punkte Punkten. Schafft ihr es auch? Mordakte, kostenlos und ohne Werbung.';
  }

  @override
  String teilen_text_code(
    String akte,
    String ende,
    String punkte,
    String code,
  ) {
    return 'Fall geschlossen: „$akte“. $ende, $punkte Punkten. Spielt denselben Fall mit dem Code $code. Schafft ihr es auch? Mordakte, kostenlos und ohne Werbung.';
  }

  @override
  String get ton_titel => 'Ton';

  @override
  String get ton_effekte => 'Geräusche';

  @override
  String get ton_atmosphaere => 'Atmosphäre';

  @override
  String get erzaehltiefe_titel => 'Gespräche mit Zeugen';

  @override
  String get erzaehltiefe_aus => 'Keine';

  @override
  String get erzaehltiefe_kurz => 'Kurz';

  @override
  String get erzaehltiefe_voll => 'Ausführlich';

  @override
  String get erzaehltiefe_hinweis =>
      'Zeugen auf der Karte ansprechen. Kostet keine Zeit und zählt nicht in die Wertung.';

  @override
  String get party_befragung_titel => 'Deine Befragungen';

  @override
  String get party_befragung_hinweis =>
      'Tippe eine Frage an, dann hörst du die Antwort. Behauptungen können falsch sein.';

  @override
  String get party_befragung_hinweis_tisch =>
      'Tippe die Frage an, die du am Tisch stellst. Die Antwort kennt nur die befragte Person.';

  @override
  String get party_befragung_hinweis_druck =>
      'Deine Befragungen stehen auch auf deinem Bogen. Stelle am Tisch eine der Fragen.';

  @override
  String get party_befragung_pflicht => 'Pflicht';

  @override
  String get party_befragung_frei_titel => 'Frei wählbar';

  @override
  String get party_befragung_frei_eine => 'Wähle noch eine Befragung frei.';

  @override
  String get party_befragung_frei_zwei => 'Wähle noch zwei Befragungen frei.';

  @override
  String get party_befragung_frei_fertig =>
      'Deine freien Wahlen sind getroffen.';

  @override
  String get party_befragung_vergeben => 'Keine freie Wahl mehr';

  @override
  String get party_befragung_thema => 'Thema';

  @override
  String get party_befragung_fragen => 'Deine Fragen';

  @override
  String get party_befragung_antwort => 'Antwort';

  @override
  String get party_befragung_nichts =>
      'Nichts Neues. Mehr weiß diese Person nicht.';

  @override
  String get party_befragung_erledigt => 'Erledigt';

  @override
  String get party_befragung_beantwortet => 'Beantwortet';

  @override
  String get party_befragung_antwort_zeigen => 'Antwort zeigen';

  @override
  String party_befragung_geraet(String name) {
    return 'Gib das Gerät kurz an $name.';
  }

  @override
  String get party_befragung_aufgeschnappt => 'Am Tisch aufgeschnappt';

  @override
  String get party_befragung_tisch_titel => 'Am Tisch in dieser Runde';

  @override
  String get party_befragung_tisch_hinweis =>
      'Jede Person führt ein Gespräch. Was sie sagt, steht auf ihrem Spickzettel.';

  @override
  String get party_befragung_fertig =>
      'Alle Befragungen geführt. Jetzt ermittelst du auf der Karte.';

  @override
  String get party_befragung_offen =>
      'Erst die Befragungen, dann geht es weiter.';

  @override
  String get party_befragung_notizen => 'Antworten aus deinen Befragungen';

  @override
  String get party_befragung_erzaehler_notizen => 'Vom Erzähler gehört';

  @override
  String get party_befragung_spickzettel => 'Mein Spickzettel';

  @override
  String get party_befragung_spickzettel_hinweis =>
      'Tippe deinen Namen an. Nur du siehst deinen Zettel für diese Runde.';

  @override
  String get party_befragung_tisch_eigen => 'Dein Tischgespräch';

  @override
  String get party_befragung_stichpunkte => 'Stichpunkte';

  @override
  String get party_befragung_anspricht => 'Wer dich anspricht';

  @override
  String get party_befragung_niemand =>
      'In dieser Runde spricht dich niemand an.';

  @override
  String get party_befragung_dich => 'Wenn der Detektiv dich befragt';

  @override
  String get party_befragung_sagen => 'Das sagst du';

  @override
  String party_befragung_behaupte(String text) {
    return 'Behaupte: $text';
  }

  @override
  String get party_befragung_sicher =>
      'Der Detektiv befragt dich in dieser Runde.';

  @override
  String get party_befragung_vielleicht =>
      'Der Detektiv kann dich in dieser Runde frei wählen.';

  @override
  String get party_befragung_entfaellt =>
      'In dieser Runde befragt dich der Detektiv nicht.';

  @override
  String party_befragung_fragt(String frage) {
    return 'Der Detektiv fragt dich: $frage';
  }

  @override
  String get party_befragung_runde_eins =>
      'Das ist dein Zettel für die erste Runde. Die nächsten Zettel siehst du in der Runde selbst.';

  @override
  String get party_befragung_oeffentlich => 'Wen der Detektiv befragt';

  @override
  String get abend_fortsetzen_veraltet =>
      'Dieser Abend stammt aus einer älteren Fassung der Akte. Er lässt sich nicht fortsetzen.';

  @override
  String get abend_rollen_titel => 'Rollen am Tisch';

  @override
  String get abend_erzaehler_feld => 'Name des Erzählers (optional)';

  @override
  String get abend_erzaehler_hinweis =>
      'Der Erzähler liest vor und führt weiter. Er ermittelt nicht.';

  @override
  String get abend_erzaehler_leer =>
      'Ohne Namen liest, wer gerade das Gerät hält.';

  @override
  String get abend_platz_titel => 'Dein Platz';

  @override
  String get abend_platz_detektiv => 'Detektiv';

  @override
  String get abend_platz_erzaehler => 'Erzähler';

  @override
  String get abend_platz_hinweis_detektiv =>
      'Du ermittelst. Ein Gast kann vorlesen.';

  @override
  String get abend_platz_hinweis_erzaehler =>
      'Du liest vor und führst weiter. Ein Gast ermittelt.';

  @override
  String get abend_start_erzaehler => 'Erzähler';

  @override
  String get abend_start_platz => 'Dein Platz';

  @override
  String get abend_start_ohne => 'keiner';

  @override
  String get erzaehlerpult_titel => 'Erzählerpult';

  @override
  String erzaehlerpult_geben(String name) {
    return 'Gib das Gerät an $name.';
  }

  @override
  String erzaehlerpult_nur(String name) {
    return 'Nur $name schaut hin und liest vor.';
  }

  @override
  String erzaehlerpult_texte(int anzahl) {
    return 'Texte in diesem Abschnitt: $anzahl';
  }

  @override
  String erzaehlerpult_zeigen(String name) {
    return 'Ich bin $name, zeig her';
  }

  @override
  String get erzaehlerpult_zudecken => 'Gelesen, zudecken';

  @override
  String get vorleser_titel => 'Vorlesen';

  @override
  String vorleser_liest(String name) {
    return '$name liest vor.';
  }

  @override
  String get vorleser_zuhoeren => 'Hört zu. Der Text steht nur dort.';

  @override
  String get vorleser_erzaehler => 'Der Erzähler';

  @override
  String vorleser_frist(String name) {
    return '$name ist getrennt. Gleich liest du.';
  }

  @override
  String vorleser_fuehrt(String name) {
    return '$name führt weiter.';
  }

  @override
  String get abend_tausch_hinweis =>
      'Zwei Porträts antippen tauscht die Namen.';

  @override
  String abend_tausch_portraet(String figur) {
    return 'Porträt $figur: Namen tauschen';
  }

  @override
  String get abend_platz_hinweis_allein => 'Du führst den Abend als Detektiv.';

  @override
  String get online_lobby_platz => 'Platz';

  @override
  String get online_lobby_figur => 'Figur';

  @override
  String get online_lobby_figur_spielen => 'Figur spielen';

  @override
  String get online_lobby_zufall => 'Zufall';

  @override
  String online_lobby_wunsch(String name) {
    return 'Wunsch: $name';
  }

  @override
  String online_lobby_vergeben(String name) {
    return 'hat $name';
  }

  @override
  String get online_lobby_gastgeber => 'Gastgeber';

  @override
  String online_lobby_wahl_titel(String name) {
    return 'Platz und Figur: $name';
  }

  @override
  String get online_lobby_wahl_hinweis => 'Platz und Figur wählen';

  @override
  String get online_lobby_detektiv_fehlt =>
      'Wähle zuerst, wer ermittelt. Tippe dazu auf einen Platz.';

  @override
  String get online_lobby_gaesteliste => 'Figuren aus der Gästeliste';

  @override
  String get online_gast_platz_titel => 'Dein Platz';

  @override
  String get online_gast_figur_titel => 'Deine Figur';

  @override
  String get online_gast_detektiv_text =>
      'Du ermittelst heute und spielst keine Figur.';

  @override
  String get online_gast_erzaehler_text =>
      'Du liest vor und führst durch den Abend.';

  @override
  String get online_gast_zufall_text => 'Deine Figur lost der Start.';

  @override
  String get online_gast_wunsch_titel => 'Dein Wunsch';

  @override
  String get online_gast_wunsch_hinweis => 'Wer zuteilt, sieht deinen Wunsch.';

  @override
  String get online_gast_kein_wunsch => 'Egal';

  @override
  String get online_gast_verteilen_titel => 'Figuren verteilen';

  @override
  String get online_fehler_sitze => 'Es fehlt noch der Detektiv.';

  @override
  String get online_fehler_nur_detektiv => 'Das darf nur der Detektiv.';

  @override
  String get online_fehler_nicht_leitung =>
      'Das darf nur, wer den Abend leitet.';

  @override
  String get online_weiter => 'Weiter';

  @override
  String get online_erzaehler_hinweis => 'Du liest vor und drückst „Weiter“.';

  @override
  String get online_sitz_rollen =>
      'Alle lesen ihre Rolle. Danach geht es weiter.';

  @override
  String get online_wahl_sitz =>
      'Die Gäste wählen geheim. Du wählst nicht mit.';

  @override
  String get erzaehler_paket_titel => 'Dein Erzählerpaket';

  @override
  String get erzaehler_paket_tisch => 'Am Tisch';

  @override
  String get erzaehler_paket_befragungen => 'Befragungen';

  @override
  String get erzaehler_paket_npc => 'Ungespielte Gäste';

  @override
  String erzaehler_paket_mit(String sprecher, String partner) {
    return '$sprecher mit $partner';
  }

  @override
  String get erzaehler_paket_pflicht => 'fest';

  @override
  String erzaehler_paket_frei(int n) {
    return 'Freie Wahlen in dieser Runde: $n';
  }

  @override
  String get erzaehler_paket_fragen => 'Fragen';

  @override
  String get erzaehler_paket_antwort => 'Antwort';

  @override
  String get erzaehler_pult_marke => 'Erzählerpult';

  @override
  String get erzaehler_zuschauer_titel => 'Was der Detektiv tut';

  @override
  String get erzaehler_detektiv_waehlt => 'Der Detektiv wählt gerade.';

  @override
  String get erzaehler_detektiv_fertig =>
      'Die Runde ist ermittelt. Du führst weiter.';

  @override
  String get erzaehler_befragt => 'Der Detektiv befragt den Tisch.';

  @override
  String get erzaehler_anklage_wartet =>
      'Der Detektiv erhebt gleich die Anklage.';

  @override
  String erzaehler_angeklagt(String name) {
    return 'Angeklagt: $name';
  }

  @override
  String get detektiv_gast_optionen =>
      'Wähle eine Spur. Die Karte zeigt das Ziel.';

  @override
  String detektiv_gast_karte_spielen(String titel) {
    return 'Spielen: $titel';
  }

  @override
  String detektiv_gast_karte_gruendlich(String titel) {
    return 'Gründlich mit Karte: $titel';
  }

  @override
  String detektiv_gast_karte_ruf(String titel) {
    return 'Mit Karte: $titel';
  }

  @override
  String get detektiv_gast_unterwegs => 'Du bist unterwegs.';

  @override
  String get detektiv_gast_anklage => 'Wen klagst du an?';

  @override
  String get detektiv_gast_notizen => 'Dein Notizbuch';

  @override
  String get rollen_uebersicht_titel => 'Wer macht was';

  @override
  String get rollen_uebersicht_oeffnen => 'Wer macht was?';

  @override
  String get rollen_uebersicht_hinweis =>
      'Je Abschnitt eine Aufgabe für jeden Platz.';

  @override
  String get uebersicht_weise_solo => 'Allein';

  @override
  String get uebersicht_weise_reihum => 'Ein Gerät';

  @override
  String get uebersicht_weise_online => 'Eigene Geräte';

  @override
  String get uebersicht_sitz_detektiv => 'Detektiv';

  @override
  String get uebersicht_sitz_erzaehler => 'Erzähler';

  @override
  String get uebersicht_sitz_rolle => 'Rolle';

  @override
  String get uebersicht_sitz_assistenz => 'Assistenz';

  @override
  String get uebersicht_sitz_detektiv_kurz => 'Ermittelt und klagt an.';

  @override
  String get uebersicht_sitz_erzaehler_kurz => 'Liest vor und führt weiter.';

  @override
  String get uebersicht_sitz_rolle_kurz => 'Spielt eine Figur mit Geheimnis.';

  @override
  String get uebersicht_sitz_assistenz_kurz =>
      'Verfolgt den Abend und würfelt mit.';

  @override
  String get uebersicht_phase_rollen => 'Rollen';

  @override
  String get uebersicht_phase_intro => 'Auftakt';

  @override
  String get uebersicht_phase_gespraeche => 'Gespräche';

  @override
  String get uebersicht_phase_entscheidungen => 'Ermittlung';

  @override
  String get uebersicht_phase_gruppenwahl => 'Gruppenwahl';

  @override
  String get uebersicht_phase_resuemee => 'Hinweis und Resümee';

  @override
  String get uebersicht_phase_anklage => 'Anklage';

  @override
  String get uebersicht_phase_finale => 'Finale und Auflösung';

  @override
  String get aufgabe_detektiv_rollen => 'Detektivkarte lesen';

  @override
  String get aufgabe_detektiv_intro => 'Zuhören, erste Notizen machen';

  @override
  String get aufgabe_detektiv_gespraeche => 'Drei bis fünf Personen befragen';

  @override
  String get aufgabe_detektiv_entscheidungen => 'Spuren auf der Karte wählen';

  @override
  String get aufgabe_detektiv_gruppenwahl => 'Notizen ordnen, die Gruppe wählt';

  @override
  String get aufgabe_detektiv_resuemee => 'Hinweis prüfen, Verdacht schärfen';

  @override
  String get aufgabe_detektiv_anklage => 'Eine Person anklagen';

  @override
  String get aufgabe_detektiv_finale => 'Auflösung lesen, Belohnung holen';

  @override
  String get aufgabe_detektiv_solo_intro => 'Auftakt lesen';

  @override
  String get aufgabe_detektiv_solo_gespraeche =>
      'Bots befragen, Antworten notieren';

  @override
  String get aufgabe_detektiv_solo_resuemee => 'Hinweis und Resümee lesen';

  @override
  String get aufgabe_erzaehler_rollen => 'Warten, bis alle gelesen haben';

  @override
  String get aufgabe_erzaehler_intro => 'Den Auftakt vorlesen';

  @override
  String get aufgabe_erzaehler_gespraeche =>
      'Rundenstart vorlesen, Gespräche anleiten';

  @override
  String get aufgabe_erzaehler_entscheidungen =>
      'Den Weg des Detektivs begleiten';

  @override
  String get aufgabe_erzaehler_gruppenwahl => 'Zur geheimen Wahl aufrufen';

  @override
  String get aufgabe_erzaehler_resuemee => 'Hinweis und Resümee vorlesen';

  @override
  String get aufgabe_erzaehler_anklage => 'Zur Anklage aufrufen';

  @override
  String get aufgabe_erzaehler_finale => 'Finale und Auflösung vorlesen';

  @override
  String get aufgabe_erzaehler_reihum => 'Pult öffnen, vorlesen, zudecken';

  @override
  String get aufgabe_rolle_rollen => 'Eigene Rolle verdeckt lesen';

  @override
  String get aufgabe_rolle_intro => 'Zuhören, in die Figur finden';

  @override
  String get aufgabe_rolle_gespraeche =>
      'Tischgespräch führen, Befragung beantworten';

  @override
  String get aufgabe_rolle_entscheidungen =>
      'Mitraten, würfeln, wenn du dran bist';

  @override
  String get aufgabe_rolle_gruppenwahl => 'Geheim A oder B wählen';

  @override
  String get aufgabe_rolle_resuemee => 'Zuhören, eigene Spur schützen';

  @override
  String get aufgabe_rolle_anklage => 'Verteidigen oder verdächtigen';

  @override
  String get aufgabe_rolle_finale => 'Auflösung hören, Belohnung holen';

  @override
  String get aufgabe_assistenz_rollen => 'Den Tisch kennenlernen';

  @override
  String get aufgabe_assistenz_intro => 'Zuhören und mitfiebern';

  @override
  String get aufgabe_assistenz_gespraeche => 'Verfolgen, wer mit wem spricht';

  @override
  String get aufgabe_assistenz_entscheidungen => 'Würfeln, wenn du dran bist';

  @override
  String get aufgabe_assistenz_gruppenwahl => 'Den Stand der Wahl verfolgen';

  @override
  String get aufgabe_assistenz_resuemee => 'Zuhören, mitraten';

  @override
  String get aufgabe_assistenz_anklage => 'Mitraten, wer es war';

  @override
  String get aufgabe_assistenz_finale => 'Auflösung lesen, Belohnung holen';

  @override
  String get erzaehlerpult_handy => 'Am eigenen Handy lesen';

  @override
  String get begleiter_titel => 'Erzähler am eigenen Handy';

  @override
  String begleiter_anleitung(String name) {
    return '$name öffnet Mordakte, tippt auf „Abend beitreten“ und gibt diesen Code ein.';
  }

  @override
  String get begleiter_hinweis =>
      'Danach stehen die Texte nur auf dem Handy. Dieses Gerät zeigt, wer vorliest.';

  @override
  String begleiter_liest(String name) {
    return '$name liest jetzt am eigenen Handy.';
  }

  @override
  String get begleiter_fehler =>
      'Das Handy ließ sich nicht verbinden. Lest am Pult weiter oder versucht es noch einmal.';

  @override
  String get begleiter_nochmal => 'Noch einmal versuchen';

  @override
  String get begleiter_zurueck => 'Zurück zum Abend';

  @override
  String get begleiter_beenden => 'Wieder am Pult lesen';

  @override
  String begleiter_handy_hinweis(String name) {
    return 'Der Text steht auf dem Handy von $name.';
  }

  @override
  String get online_lobby_gastgeber_platz =>
      'Du brauchst selbst einen Platz. Tippe dazu auf deine Karte.';

  @override
  String get druck_datei_laedt => 'Die Datei wird erstellt …';

  @override
  String druck_datei_teilen(String datei) {
    return 'Teilen: $datei';
  }

  @override
  String druck_datei_laden(String datei) {
    return 'Herunterladen: $datei';
  }

  @override
  String get druck_datei_fehler =>
      'Das hat nicht geklappt. Versuch es bitte noch einmal.';

  @override
  String get druck_je_person => 'Rollenhefte einzeln senden';

  @override
  String get druck_je_person_hinweis =>
      'Jede Person bekommt nur ihr eigenes Heft. Die Hefte gelten nur mit diesem Fall-Code.';

  @override
  String druck_senden_an(String name) {
    return 'Senden an $name';
  }

  @override
  String get druck_erzaehlerheft_hinweis =>
      'Für den Erzähler: alle Texte zum Vorlesen, der Tisch und die Antworten der Befragungen. Der Detektiv liest es nicht.';

  @override
  String get detektei_akte_steckbriefe => 'Steckbriefe & Übersicht';

  @override
  String get steckbrief_titel => 'Steckbriefe & Übersicht';

  @override
  String get steckbrief_hinweis =>
      'Für die Wochen vor dem Abend: ohne Geheimnisse und ohne Fall-Code. Ihr dürft alles verschicken.';

  @override
  String get steckbrief_personen => 'Wie viele seid ihr?';

  @override
  String get steckbrief_personen_offen => 'Wissen wir noch nicht';

  @override
  String get steckbrief_personen_fest => 'Steht fest';

  @override
  String steckbrief_personen_wert(String anzahl) {
    return '$anzahl Personen am Tisch, dazu der Detektiv';
  }

  @override
  String get steckbrief_dateien => 'Zum Verschicken';

  @override
  String get steckbrief_gaeste => 'Gästeliste';

  @override
  String get steckbrief_gaeste_hinweis =>
      'Tragt ein, wer welche Figur spielt. Am Abend stehen die Namen schon in der Einrichtung.';

  @override
  String get steckbrief_gast_neu => 'Gast eintragen';

  @override
  String get steckbrief_gast_name => 'Name';

  @override
  String get steckbrief_gast_ohne => 'Noch keine Figur';

  @override
  String steckbrief_gast_nicht_dabei(String anzahl) {
    return 'Bei $anzahl Personen nicht dabei';
  }

  @override
  String get steckbrief_gast_entfernen => 'Gast entfernen';

  @override
  String get steckbrief_senden => 'Steckbrief senden';

  @override
  String get party_runde_plus => 'Fünf Minuten dazu';

  @override
  String get party_runde_weiterlaufen => 'Uhr weiterlaufen lassen';

  @override
  String get party_runde_angehalten => 'Angehalten';

  @override
  String party_runde_stellt(String name) {
    return 'Die Uhr stellt $name.';
  }

  @override
  String get party_intro_naechstes => 'Nächstes Bild';

  @override
  String party_intro_bild(String nr, String anzahl) {
    return 'Bild $nr von $anzahl';
  }

  @override
  String get online_uhr_titel => 'Zeit für diese Runde';

  @override
  String get online_uhr_start => 'Uhr starten';

  @override
  String get online_uhr_pause => 'Uhr anhalten';

  @override
  String get online_uhr_um => 'Die Zeit ist um.';
}
