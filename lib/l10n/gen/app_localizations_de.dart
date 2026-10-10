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
      'Ein Krimi für den Geburtstag, für 4 bis 20 Personen und ein Geburtstagskind';

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
    return 'Seifenblasen-Marken: $zahl';
  }

  @override
  String get party_zug_gruendlich =>
      'Gründlich suchen · +2 auf den Wurf · 2 Nachtminuten mehr';

  @override
  String get party_zug_wuerfel => 'Der Kellerwürfel';

  @override
  String party_zug_pate(String name) {
    return 'Gib das Gerät an $name – jetzt wird gewürfelt!';
  }

  @override
  String get party_zug_werfen => 'Würfeln';

  @override
  String get party_zug_marke_einsetzen =>
      'Eine Seifenblasen-Marke einsetzen · +1';

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
  String get party_zug_erfolg => 'Erfolg · Lupe';

  @override
  String get party_zug_teilerfolg => 'Teilerfolg · Handy';

  @override
  String get party_zug_pech => 'Pech · Gespenst';

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
      'Das Handy-Licht wandert kurz über die Decke. Die Quelle bleibt dieselbe. Glück im Unglück: eine Seifenblasen-Marke!';

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
}
