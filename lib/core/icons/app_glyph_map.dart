// مولَّد: ربط أيقونات Material بأشكال AppGlyph (أضف الأيقونة هنا لتحصل على شكل مرسوم).
import 'package:flutter/material.dart';

import 'package:barwah_app/core/icons/app_glyph.dart';

/// الشكل المرسوم المقابل لأيقونة Material، أو null إن لم يكن لها شكل.
AppGlyph? glyphFor(IconData? icon) =>
    icon == null ? null : _byCode[icon.codePoint];

final Map<int, AppGlyph> _byCode = _build();

Map<int, AppGlyph> _build() {
  final table = <int, AppGlyph>{};
  void put(AppGlyph glyph, List<IconData> icons) {
    for (final icon in icons) {
      table[icon.codePoint] = glyph;
    }
  }

  put(AppGlyph.person, [
    Icons.account_circle,
    Icons.badge_outlined,
    Icons.groups_2_outlined,
    Icons.groups_outlined,
    Icons.manage_accounts,
    Icons.manage_accounts_outlined,
    Icons.people_outline,
    Icons.person,
    Icons.person_add_alt_1,
    Icons.person_add_alt_1_outlined,
    Icons.person_outline,
    Icons.person_outline_rounded,
    Icons.person_pin_circle_outlined,
    Icons.person_pin_outlined,
    Icons.person_remove_alt_1,
    Icons.supervisor_account_outlined,
  ]);
  put(AppGlyph.verified, [
    Icons.check_circle,
    Icons.check_circle_outline,
    Icons.check_circle_outline_rounded,
    Icons.check_circle_rounded,
    Icons.checklist,
    Icons.checklist_rtl,
    Icons.domain_verification,
    Icons.fact_check_outlined,
    Icons.task_alt,
    Icons.task_alt_outlined,
    Icons.task_alt_rounded,
    Icons.verified,
    Icons.verified_outlined,
  ]);
  put(AppGlyph.wallet, [
    Icons.account_balance_wallet,
    Icons.account_balance_wallet_outlined,
    Icons.add_card_outlined,
    Icons.credit_card,
    Icons.credit_card_outlined,
    Icons.savings_rounded,
    Icons.wallet_outlined,
  ]);
  put(AppGlyph.shield, [
    Icons.admin_panel_settings,
    Icons.admin_panel_settings_outlined,
    Icons.gpp_bad_outlined,
    Icons.gpp_maybe_outlined,
    Icons.privacy_tip_outlined,
    Icons.security,
    Icons.security_outlined,
    Icons.shield,
    Icons.shield_outlined,
    Icons.shield_rounded,
    Icons.verified_user,
    Icons.verified_user_outlined,
    Icons.verified_user_rounded,
  ]);
  put(AppGlyph.store, [
    Icons.local_grocery_store_outlined,
    Icons.restore,
    Icons.restore_outlined,
    Icons.shop_outlined,
    Icons.store,
    Icons.store_mall_directory_outlined,
    Icons.store_outlined,
    Icons.storefront,
    Icons.storefront_outlined,
  ]);
  put(AppGlyph.warning, [
    Icons.error_outline,
    Icons.error_outline_rounded,
    Icons.escalator_warning_outlined,
    Icons.priority_high,
    Icons.priority_high_rounded,
    Icons.report_gmailerrorred_outlined,
    Icons.report_outlined,
    Icons.report_problem_outlined,
    Icons.warning_amber,
    Icons.warning_amber_outlined,
    Icons.warning_amber_rounded,
  ]);
  put(AppGlyph.search, [
    Icons.manage_search,
    Icons.manage_search_outlined,
    Icons.person_search_outlined,
    Icons.search,
    Icons.search_off,
    Icons.search_off_rounded,
    Icons.search_rounded,
  ]);
  put(AppGlyph.receipt, [
    Icons.article_outlined,
    Icons.assignment_ind_outlined,
    Icons.assignment_outlined,
    Icons.assignment_turned_in_outlined,
    Icons.description_outlined,
    Icons.notes_outlined,
    Icons.receipt,
    Icons.receipt_long,
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
    Icons.receipt_outlined,
    Icons.request_quote_outlined,
  ]);
  put(AppGlyph.truck, [
    Icons.directions_car,
    Icons.directions_car_filled,
    Icons.directions_car_filled_outlined,
    Icons.directions_car_outlined,
    Icons.local_shipping,
    Icons.local_shipping_outlined,
    Icons.pedal_bike,
    Icons.pedal_bike_outlined,
    Icons.two_wheeler_outlined,
  ]);
  put(AppGlyph.gavel, [
    Icons.balance_outlined,
    Icons.gavel,
    Icons.gavel_outlined,
    Icons.gavel_rounded,
    Icons.policy_outlined,
  ]);
  put(AppGlyph.megaphone, [
    Icons.campaign,
    Icons.campaign_outlined,
  ]);
  put(AppGlyph.cancel, [
    Icons.cancel,
    Icons.cancel_outlined,
    Icons.highlight_off,
  ]);
  put(AppGlyph.payments, [
    Icons.monetization_on_rounded,
    Icons.payment,
    Icons.payments_outlined,
  ]);
  put(AppGlyph.chat, [
    Icons.add_comment_outlined,
    Icons.chat_bubble_outline,
    Icons.chat_outlined,
    Icons.comment_outlined,
    Icons.forum_outlined,
    Icons.support_agent,
    Icons.support_agent_outlined,
    Icons.support_agent_rounded,
  ]);
  put(AppGlyph.refresh, [
    Icons.refresh,
    Icons.restart_alt,
    Icons.sync,
  ]);
  put(AppGlyph.box, [
    Icons.archive_outlined,
    Icons.category_outlined,
    Icons.inventory_2_outlined,
    Icons.shopping_bag,
    Icons.shopping_bag_outlined,
  ]);
  put(AppGlyph.send, [
    Icons.send,
    Icons.send_outlined,
    Icons.send_rounded,
  ]);
  put(AppGlyph.lock, [
    Icons.keyboard_arrow_down,
    Icons.keyboard_return_outlined,
    Icons.lock_clock_outlined,
    Icons.lock_outline,
    Icons.lock_outline_rounded,
    Icons.lock_person_outlined,
    Icons.lock_reset_rounded,
    Icons.vpn_key_outlined,
  ]);
  put(AppGlyph.clock, [
    Icons.access_time,
    Icons.history,
    Icons.history_outlined,
    Icons.history_rounded,
    Icons.history_toggle_off,
    Icons.hourglass_bottom,
    Icons.hourglass_empty,
    Icons.hourglass_top,
    Icons.hourglass_top_rounded,
    Icons.pending_actions,
    Icons.pending_actions_outlined,
    Icons.schedule,
    Icons.schedule_outlined,
    Icons.timer_off_outlined,
    Icons.timer_outlined,
    Icons.watch,
    Icons.watch_outlined,
  ]);
  put(AppGlyph.eyeOff, [
    Icons.visibility_off_outlined,
  ]);
  put(AppGlyph.tune, [
    Icons.settings_outlined,
    Icons.tune,
    Icons.tune_outlined,
    Icons.tune_rounded,
  ]);
  put(AppGlyph.info, [
    Icons.info,
    Icons.info_outline,
    Icons.info_outline_rounded,
  ]);
  put(AppGlyph.star, [
    Icons.star,
    Icons.star_outline_rounded,
    Icons.star_rounded,
    Icons.stars,
    Icons.stars_rounded,
    Icons.workspace_premium,
    Icons.workspace_premium_outlined,
  ]);
  put(AppGlyph.pin, [
    Icons.location_on,
    Icons.location_on_outlined,
    Icons.map_outlined,
    Icons.my_location_outlined,
    Icons.place_outlined,
  ]);
  put(AppGlyph.bolt, [
    Icons.bolt,
    Icons.bolt_outlined,
    Icons.bolt_rounded,
    Icons.flash_on,
  ]);
  put(AppGlyph.block, [
    Icons.block,
    Icons.block_outlined,
    Icons.block_rounded,
    Icons.do_not_disturb_alt,
  ]);
  put(AppGlyph.bell, [
    Icons.notification_important_outlined,
    Icons.notifications_active_outlined,
    Icons.notifications_none_outlined,
    Icons.notifications_none_rounded,
  ]);
  put(AppGlyph.tools, [
    Icons.build,
    Icons.build_circle,
    Icons.build_circle_outlined,
    Icons.build_outlined,
    Icons.engineering_outlined,
    Icons.handyman_outlined,
    Icons.home_repair_service_outlined,
  ]);
  put(AppGlyph.download, [
    Icons.backup_outlined,
    Icons.cloud_upload_outlined,
    Icons.download_outlined,
    Icons.download_rounded,
    Icons.file_download_outlined,
    Icons.upload_file_outlined,
  ]);
  put(AppGlyph.eye, [
    Icons.remove_red_eye_outlined,
    Icons.visibility,
    Icons.visibility_outlined,
  ]);
  put(AppGlyph.phone, [
    Icons.contact_phone_outlined,
    Icons.phone,
    Icons.phone_android,
    Icons.phone_android_outlined,
    Icons.phone_in_talk_outlined,
    Icons.phone_iphone,
    Icons.phone_iphone_outlined,
    Icons.phone_outlined,
    Icons.smartphone,
  ]);
  return table;
}
