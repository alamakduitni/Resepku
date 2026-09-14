import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/widgets.dart';

class AppIcons {
  AppIcons._();

  static const IconData home = Symbols.home;
  static const IconData search = Symbols.search;
  static const IconData add = Symbols.add;
  static const IconData favorite = Symbols.favorite;
  static const IconData favoriteBorder = Symbols.favorite;
  static const IconData person = Symbols.person;
  static const IconData back = Symbols.arrow_back;
  static const IconData notifications = Symbols.notifications;
  static const IconData schedule = Symbols.schedule;
  static const IconData star = Symbols.star;
  static const IconData starHalf = Symbols.star_half;
  static const IconData gridView = Symbols.grid_view;
  static const IconData viewList = Symbols.view_list;
  static const IconData chevronLeft = Symbols.chevron_left;
  static const IconData chevronRight = Symbols.chevron_right;
  static const IconData manageSearch = Symbols.manage_search;
  static const IconData ramenDining = Symbols.ramen_dining;
  static const IconData mail = Symbols.mail;
  static const IconData lock = Symbols.lock;
  static const IconData visibilityOff = Symbols.visibility_off;
  static const IconData block = Symbols.block;
  static const IconData cookie = Symbols.cookie;
  static const IconData lunchDining = Symbols.lunch_dining;
  static const IconData setMeal = Symbols.set_meal;
  static const IconData localDrink = Symbols.local_drink;
  static const IconData coffee = Symbols.coffee;
  static const IconData emojiFoodBeverage = Symbols.emoji_food_beverage;
  static const IconData construction = Symbols.construction;
  static const IconData call = Symbols.call;
  static const IconData locationOn = Symbols.location_on;
  static const IconData cake = Symbols.cake;
  static const IconData success = Symbols.check_circle;
  static const IconData error = Symbols.error;
  static const IconData warning = Symbols.warning;
  static const IconData info = Symbols.info;

  static IconData categoryIcon(String key) {
    switch (key) {
      case 'rice_bowl':
        return Symbols.rice_bowl;
      case 'egg':
        return Symbols.egg;
      case 'lunch_dining':
        return Symbols.lunch_dining;
      case 'set_meal':
        return Symbols.set_meal;
      case 'local_cafe':
        return Symbols.local_cafe;
      case 'cookie':
        return Symbols.cookie;
      default:
        return Symbols.restaurant;
    }
  }
}
