import 'dart:ui';

import 'package:citgroupvn_bds/data/model/app_settings_datamodel.dart';
import 'package:citgroupvn_bds/exports/main_export.dart';
import 'package:citgroupvn_bds/utils/AppIcon.dart';
import 'package:citgroupvn_bds/utils/hive_keys.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import '../Ui/Theme/theme.dart';
import '../utils/api.dart';
import '../utils/network_to_localsvg.dart';

AppSettingsDataModel fallbackSettingAppSettings = AppSettingsDataModel(
  appHomeScreen: AppIcons.fallbackHomeLogo,
  splashLogo: AppIcons.fallbackSplashLogo,
  placeholderLogo: AppIcons.fallbackPlaceholderLogo,
  lightPrimary: primaryColor_,
  lightSecondary: secondaryColor_,
  lightTertiary: tertiaryColor_,
  darkPrimary: primaryColorDark,
  darkSecondary: secondaryColorDark,
  darkTertiary: tertiaryColorDark,
);

///DO not touch this
class LoadAppSettings {
  Future<void> load() async {
    try {
      try {
        Map<String, dynamic> response = await Api.get(url: Api.getAppSettings);

        appSettings = AppSettingsDataModel.fromJson(response['data']);
        HiveUtils.setAppThemeSetting(response['data']);

        ///Set other icons from here which will come from server
        appSettings.splashLogo =
            await loadIconIfChange(appSettings.splashLogo!);
        appSettings.appHomeScreen =
            await loadIconIfChange(appSettings.appHomeScreen!);
        appSettings.placeholderLogo =
            await loadIconIfChange(appSettings.placeholderLogo!);
      } catch (e) {
        appSettings =
            AppSettingsDataModel.fromJson(HiveUtils.getAppThemeSettings());
        appSettings.splashLogo =
            await loadIconIfChange(appSettings.splashLogo!);
        appSettings.appHomeScreen =
            await loadIconIfChange(appSettings.appHomeScreen!);
        appSettings.placeholderLogo =
            await loadIconIfChange(appSettings.placeholderLogo!);
      }
    } catch (ee) {
      print("Issue in load default setting $ee");
    }
  }

  Future<String> loadIconIfChange(String svgURL) async {
    try {
      Box box = Hive.box(HiveKeys.svgBox);
      bool isAvailable = box.containsKey(svgURL);
      if (isAvailable) {
        return box.get(svgURL) as String;
      } else {
        String? localSVG = await NetworkToLocalSvg().convert(svgURL);
        await box.put(svgURL, localSVG);

        return await Future.value(localSVG);
      }
    } catch (e) {
      rethrow;
    }
  }

  SvgPicture svg(
    String svg, {
    Color? color,
    double? width,
    double? height,
  }) {
    if (svg.startsWith("assets/svg/")) {
      return SvgPicture.asset(
        svg,
        color: color,
        width: width,
        height: height,
      );
    } else {
      return SvgPicture.string(
        svg,
        color: color,
        width: width,
        height: height,
      );
    }
  }
}
