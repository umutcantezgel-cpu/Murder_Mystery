import 'package:mordakte_core/mordakte_core.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Texte für IDs aus Regeln/Protokoll (Effekte, Klassen, Items, Signale …).
extension LLookup on L {
  String effectName(String id) => switch (id) {
    'caffeine' => effect_caffeine,
    'teamgeist' => effect_teamgeist,
    'adrenaline' => effect_adrenaline,
    'eagle_eye' => effect_eagle_eye,
    'focused' => effect_focused,
    'bright' => effect_bright,
    'hidden' => effect_hidden,
    'injured' => effect_injured,
    'panic' => effect_panic,
    'poisoned' => effect_poisoned,
    'blinded' => effect_blinded,
    'suspicious' => effect_suspicious,
    _ => id,
  };

  String effectDesc(String id) => switch (id) {
    'caffeine' => effect_caffeine_desc,
    'teamgeist' => effect_teamgeist_desc,
    'adrenaline' => effect_adrenaline_desc,
    'eagle_eye' => effect_eagle_eye_desc,
    'focused' => effect_focused_desc,
    'bright' => effect_bright_desc,
    'hidden' => effect_hidden_desc,
    'injured' => effect_injured_desc,
    'panic' => effect_panic_desc,
    'poisoned' => effect_poisoned_desc,
    'blinded' => effect_blinded_desc,
    'suspicious' => effect_suspicious_desc,
    _ => '',
  };

  String className(String id) => switch (id) {
    'forensic' => class_forensic_name,
    'profiler' => class_profiler_name,
    'excop' => class_excop_name,
    'journalist' => class_journalist_name,
    'medic' => class_medic_name,
    _ => id,
  };

  String classAbility(String id) => switch (id) {
    'forensic' => class_forensic_ability,
    'profiler' => class_profiler_ability,
    'excop' => class_excop_ability,
    'journalist' => class_journalist_ability,
    'medic' => class_medic_ability,
    _ => '',
  };

  String classPassive(String id) => switch (id) {
    'forensic' => class_forensic_passive,
    'profiler' => class_profiler_passive,
    'excop' => class_excop_passive,
    'journalist' => class_journalist_passive,
    'medic' => class_medic_passive,
    _ => '',
  };

  String abilityName(String ability) => switch (ability) {
    'scan' => ability_scan,
    'calm' => ability_calm,
    'scare' => ability_scare,
    'sources' => ability_sources,
    'firstaid' => ability_firstaid,
    _ => ability,
  };

  String hatName(String id) => switch (id) {
    'fedora' => hat_fedora,
    'bowler' => hat_bowler,
    'cap' => hat_cap,
    'beret' => hat_beret,
    'cloche' => hat_cloche,
    'top' => hat_top,
    'none' => hat_none,
    _ => id,
  };

  String itemName(String type) => switch (type) {
    ItemType.coffee => item_coffee,
    ItemType.battery => item_battery,
    ItemType.salts => item_salts,
    ItemType.antidote => item_antidote,
    ItemType.medkit => item_medkit,
    ItemType.flare => item_flare,
    ItemType.trace => item_trace,
    _ => type,
  };

  String itemDesc(String type) => switch (type) {
    ItemType.coffee => item_coffee_desc,
    ItemType.battery => item_battery_desc,
    ItemType.salts => item_salts_desc,
    ItemType.antidote => item_antidote_desc,
    ItemType.medkit => item_medkit_desc,
    ItemType.flare => item_flare_desc,
    ItemType.trace => item_trace_desc,
    _ => '',
  };

  String quickText(String id) => switch (id) {
    'come_here' => quick_come_here,
    'found_clue' => quick_found_clue,
    'help' => quick_help,
    'stay_together' => quick_stay_together,
    'split_up' => quick_split_up,
    'suspect' => quick_suspect,
    'danger' => quick_danger,
    'thanks' => quick_thanks,
    _ => id,
  };

  String emoteLabel(String id) => switch (id) {
    'wave' => emote_wave,
    'shock' => emote_shock,
    'think' => emote_think,
    'laugh' => emote_laugh,
    'scared' => emote_scared,
    'thumbs' => emote_thumbs,
    _ => id,
  };

  /// Fehlertext zu einem Fehler-Schlüssel der Runtime/des Servers.
  String errorText(String key) => switch (key) {
    'room_not_found' => error_room_not_found,
    'room_full' => error_room_full,
    'game_running' => error_game_running,
    'not_host' => error_not_host,
    'too_far' => error_too_far,
    'inventory_full' => error_inventory_full,
    'cooldown' => error_cooldown,
    'not_in_phase' => error_not_in_phase,
    'no_charges' => error_no_charges,
    'invalid' => error_invalid,
    'connection' => error_connection,
    'server_missing' => error_server_missing,
    'server_invalid' => error_server_invalid,
    'unavailable' => error_unavailable,
    'unknown_scenario' => error_unknown_scenario,
    'nothing_to_analyze' => error_nothing_to_analyze,
    'nothing_to_scare' => error_nothing_to_scare,
    'nothing_left' => error_nothing_left,
    'nothing_to_heal' => error_nothing_to_heal,
    'not_needed' => error_not_needed,
    'no_pings' => error_no_pings,
    'not_on_board' => error_not_on_board,
    'server_error' => error_server_error,
    'server_full' => error_server_full,
    'timeout' => error_timeout,
    'unreachable' => error_unreachable,
    'replaced' => error_replaced,
    'bad_message' => error_bad_message,
    'not_in_room' => error_not_in_room,
    'protocol' => error_protocol,
    _ => error_unknown,
  };

  String awardName(String id) => switch (id) {
    'spurensucher' => award_spurensucher,
    'lebensretter' => award_lebensretter,
    'kombinierer' => award_kombinierer,
    'ueberlebender' => award_ueberlebender,
    'geist' => award_geist,
    'teamplayer' => award_teamplayer,
    _ => id,
  };

  String awardDesc(String id) => switch (id) {
    'spurensucher' => award_spurensucher_desc,
    'lebensretter' => award_lebensretter_desc,
    'kombinierer' => award_kombinierer_desc,
    'ueberlebender' => award_ueberlebender_desc,
    'geist' => award_geist_desc,
    'teamplayer' => award_teamplayer_desc,
    _ => '',
  };

  String rankName(int index) => switch (index) {
    <= 0 => rank_0,
    1 => rank_1,
    2 => rank_2,
    3 => rank_3,
    4 => rank_4,
    _ => rank_5,
  };

  String phaseName(Phase p) => switch (p) {
    Phase.lobby => phase_lobby,
    Phase.intro => phase_intro,
    Phase.investigation => phase_investigation,
    Phase.council => phase_council,
    Phase.night => phase_night,
    Phase.accusation => phase_accusation,
    Phase.ending => phase_ending,
  };

  String clueKind(String kind) => switch (kind) {
    ClueKind.trait => clue_kind_trait,
    ClueKind.motive => clue_kind_motive,
    ClueKind.weapon => clue_kind_weapon,
    ClueKind.alibi => clue_kind_alibi,
    ClueKind.story => clue_kind_story,
    'sighting' => clue_kind_sighting,
    _ => clue_kind_other,
  };

  String topicQuestion(String topic) => switch (topic) {
    Topic.alibi => topic_alibi,
    Topic.victim => topic_victim,
    Topic.observation => topic_observation,
    Topic.rumor => topic_rumor,
    _ => topic,
  };

  String topicShort(String topic) => switch (topic) {
    Topic.alibi => topic_alibi_short,
    Topic.victim => topic_victim_short,
    Topic.observation => topic_observation_short,
    Topic.rumor => topic_rumor_short,
    _ => topic,
  };

  String modeName(String mode) => switch (mode) {
    'random' => mode_random,
    'daily' => mode_daily,
    _ => mode_story,
  };

  String modeDesc(String mode) => switch (mode) {
    'random' => mode_random_desc,
    'daily' => mode_daily_desc,
    _ => mode_story_desc,
  };

  String verdictStamp(String verdict) => switch (verdict) {
    'perfect' => verdict_stamp_perfect,
    'solid' => verdict_stamp_solid,
    'partial' => verdict_stamp_partial,
    'wrong' => verdict_stamp_wrong,
    _ => verdict_stamp_unsolved,
  };

  String teamLabel(String team) => switch (team) {
    'all' => team_all,
    'some' => team_some,
    'lone' => team_lone,
    _ => team_none,
  };

  String achievementName(String id) => switch (id) {
    'first_case' => ach_first_case,
    'perfect' => ach_perfect,
    'all_survived' => ach_all_survived,
    'revive3' => ach_revive3,
    'secret' => ach_secret,
    'all_scenarios' => ach_all_scenarios,
    'streak5' => ach_streak5,
    'ghost_helper' => ach_ghost_helper,
    'online' => ach_online,
    'combos10' => ach_combos10,
    _ => id,
  };

  String achievementDesc(String id) => switch (id) {
    'first_case' => ach_first_case_desc,
    'perfect' => ach_perfect_desc,
    'all_survived' => ach_all_survived_desc,
    'revive3' => ach_revive3_desc,
    'secret' => ach_secret_desc,
    'all_scenarios' => ach_all_scenarios_desc,
    'streak5' => ach_streak5_desc,
    'ghost_helper' => ach_ghost_helper_desc,
    'online' => ach_online_desc,
    'combos10' => ach_combos10_desc,
    _ => '',
  };
}
