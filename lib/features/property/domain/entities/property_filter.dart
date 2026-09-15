import 'package:flutter/material.dart';
import 'package:property_app/core/constants/app_constants.dart';

class PropertyFilter {
  final String? keyword;
  final String? location;
  final PropertyType? type;
  final RangeValues? priceRange;
  final RangeValues? areaRange;
  final PropertyStatus? status;
  final String? configuration; // '1BHK', '2BHK', etc.

  const PropertyFilter({
    this.keyword,
    this.location,
    this.type,
    this.priceRange,
    this.areaRange,
    this.status,
    this.configuration,
  });

  bool get hasActiveFilters {
    return (keyword != null && keyword!.trim().isNotEmpty) ||
        (location != null && location!.trim().isNotEmpty) ||
        type != null ||
        priceRange != null ||
        areaRange != null ||
        status != null ||
        (configuration != null && configuration!.trim().isNotEmpty);
  }

  int get activeFilterCount {
    int count = 0;
    if (keyword != null && keyword!.trim().isNotEmpty) count++;
    if (location != null && location!.trim().isNotEmpty) count++;
    if (type != null) count++;
    if (priceRange != null) count++;
    if (areaRange != null) count++;
    if (status != null) count++;
    if (configuration != null && configuration!.trim().isNotEmpty) count++;
    return count;
  }

  PropertyFilter copyWith({
    String? keyword,
    String? location,
    PropertyType? type,
    RangeValues? priceRange,
    RangeValues? areaRange,
    PropertyStatus? status,
    String? configuration,
    bool clearKeyword = false,
    bool clearLocation = false,
    bool clearType = false,
    bool clearPriceRange = false,
    bool clearAreaRange = false,
    bool clearStatus = false,
    bool clearConfiguration = false,
  }) {
    return PropertyFilter(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      location: clearLocation ? null : (location ?? this.location),
      type: clearType ? null : (type ?? this.type),
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      areaRange: clearAreaRange ? null : (areaRange ?? this.areaRange),
      status: clearStatus ? null : (status ?? this.status),
      configuration:
          clearConfiguration ? null : (configuration ?? this.configuration),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyFilter &&
          runtimeType == other.runtimeType &&
          keyword == other.keyword &&
          location == other.location &&
          type == other.type &&
          priceRange == other.priceRange &&
          areaRange == other.areaRange &&
          status == other.status &&
          configuration == other.configuration;

  @override
  int get hashCode => Object.hash(
        keyword,
        location,
        type,
        priceRange,
        areaRange,
        status,
        configuration,
      );
}
