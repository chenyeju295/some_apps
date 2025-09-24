import 'package:flutter/foundation.dart';
import '../models/diving_content.dart';

class ContentProvider extends ChangeNotifier {
  List<DivingContent> _allContent = [];
  List<DivingContent> _filteredContent = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _searchQuery = '';

  List<DivingContent> get allContent => _allContent;
  List<DivingContent> get filteredContent => _filteredContent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;

  List<String> get categories => [
        'All',
        ...DivingCategory.values.map((c) => c.displayName),
      ];

  List<String> get difficultyLevels => [
        'All',
        ...DifficultyLevel.values.map((d) => d.displayName),
      ];

  Future<void> loadContent() async {
    _setLoading(true);
    try {
      // In a real app, this would load from an API or local database
      // For now, we'll use hardcoded content
      _allContent = _generateSampleContent();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to load content: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
      notifyListeners();
    }
  }

  void setDifficulty(String difficulty) {
    if (_selectedDifficulty != difficulty) {
      _selectedDifficulty = difficulty;
      _applyFilters();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _selectedDifficulty = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  DivingContent? getContentById(String id) {
    try {
      return _allContent.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DivingContent> getContentByCategory(String category) {
    if (category == 'All') return _allContent;
    return _allContent
        .where((content) => content.category == category)
        .toList();
  }

  List<DivingContent> getContentByIds(List<String> ids) {
    return _allContent.where((content) => ids.contains(content.id)).toList();
  }

  void _applyFilters() {
    List<DivingContent> filtered = List.from(_allContent);

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((content) => content.category == _selectedCategory)
          .toList();
    }

    // Apply difficulty filter
    if (_selectedDifficulty != 'All') {
      filtered = filtered
          .where((content) => content.difficulty == _selectedDifficulty)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      filtered = filtered.where((content) {
        return content.title.toLowerCase().contains(query) ||
            content.content.toLowerCase().contains(query) ||
            content.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    _filteredContent = filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<DivingContent> _generateSampleContent() {
    return [
      // Essential Safety Content
      DivingContent(
        id: 'safety_001',
        title: 'Basic Diving Safety Rules',
        content: '''# Basic Diving Safety Rules

## Never Hold Your Breath
The most important rule in scuba diving is to never hold your breath. As you ascend, the air in your lungs expands due to decreasing pressure.

## Plan Your Dive and Dive Your Plan
Always plan your dive before entering the water:
- Maximum depth and bottom time
- Air consumption rate
- Emergency procedures

## Check Your Equipment
Before every dive, perform equipment checks:
- BCD and regulator function
- Gauge readings and mask fit

## Use the Buddy System
Never dive alone. Stay within sight of your buddy and know emergency procedures.

## Monitor Your Air Supply
Check your air gauge frequently and start ascent with adequate air remaining.''',
        category: 'Safety',
        difficulty: 'Beginner',
        tags: ['safety', 'rules', 'basic'],
        imageUrl: 'assets/images/coral_welcome_generated.png',
        readTimeMinutes: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      DivingContent(
        id: 'safety_002',
        title: 'Emergency Procedures',
        content: '''# Emergency Procedures

## Out of Air Emergency
Signal your buddy, share air source, and ascend slowly together.

## Lost Buddy Procedure
Look around for 1 minute, then surface slowly and meet at predetermined location.

## Mask Flooding
Stay calm, tilt head back, press mask top, and exhale through nose.

## Equipment Problems
Signal buddy immediately for any equipment malfunction and prepare for ascent.''',
        category: 'Safety',
        difficulty: 'Intermediate',
        tags: ['emergency', 'procedures', 'safety'],
        imageUrl: 'assets/images/diving_hero_generated.png',
        readTimeMinutes: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // Equipment Content
      DivingContent(
        id: 'equipment_001',
        title: 'Essential Diving Equipment',
        content: '''# Essential Diving Equipment

## Core Equipment
**Mask**: Low volume with tempered glass for clear vision
**Fins**: Choose open heel or full foot based on conditions
**Wetsuit**: 3mm-7mm thickness depending on water temperature

## Life Support
**Regulator**: First and second stage with backup octopus
**BCD**: Buoyancy control device with weight integration
**Dive Computer**: Tracks depth, time, and decompression limits

## Safety Accessories
**Dive Light**: Primary and backup lights for visibility
**Safety Whistle**: Surface signaling device
**Dive Knife**: Emergency cutting tool''',
        category: 'Equipment',
        difficulty: 'Beginner',
        tags: ['equipment', 'gear', 'basic'],
        imageUrl: 'assets/images/diver_turtle_generated.png',
        readTimeMinutes: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // Marine Life Content
      DivingContent(
        id: 'marine_001',
        title: 'Coral Reef Ecosystems',
        content: '''# Coral Reef Ecosystems

## What Are Coral Reefs?
Coral reefs are diverse underwater ecosystems built by coral polyps over thousands of years.

## Types of Reefs
**Fringing Reefs**: Grow directly from shore in shallow waters
**Barrier Reefs**: Separated from shore by lagoons
**Atolls**: Ring-shaped reefs around lagoons

## Marine Life
**Fish**: Angelfish, parrotfish, clownfish, and wrasse
**Other Animals**: Sea turtles, rays, octopus, and sea slugs

## Conservation
- Don't touch corals or marine life
- Maintain proper buoyancy
- Use reef-safe sunscreen
- Practice responsible diving''',
        category: 'Marine Life',
        difficulty: 'Beginner',
        tags: ['coral', 'reef', 'marine life', 'conservation'],
        imageUrl: 'assets/images/coral_welcome_generated.png',
        readTimeMinutes: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      // Techniques Content
      DivingContent(
        id: 'techniques_001',
        title: 'Buoyancy Control Basics',
        content: '''# Buoyancy Control Basics

## Three States of Buoyancy
**Positive**: You float upward
**Negative**: You sink downward
**Neutral**: You neither sink nor float

## Achieving Neutral Buoyancy
1. Do proper weight check at surface
2. Add small amounts of air to BCD when sinking
3. Release air when floating up
4. Use breathing to fine-tune

## Common Problems
**Over-weighted**: Remove 1-2 lbs of weight
**Under-weighted**: Add weight gradually
**Poor control**: Make small BCD adjustments only

## Practice Tips
- Perfect buoyancy in shallow water first
- Use breathing for minor adjustments
- Practice hovering motionless''',
        category: 'Techniques',
        difficulty: 'Intermediate',
        tags: ['buoyancy', 'control', 'techniques'],
        imageUrl: 'assets/images/diving_hero_generated.png',
        readTimeMinutes: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // Certification Content
      DivingContent(
        id: 'cert_001',
        title: 'Open Water Certification',
        content: '''# Open Water Certification

## Prerequisites
- Age 15+ (10+ for Junior Open Water)
- Swim 200m and tread water 10 minutes
- Medical clearance if required

## Course Structure
**Knowledge Development**: 5 theory sections
**Confined Water**: 5 skill sessions in pool
**Open Water**: 4 certification dives

## What You'll Learn
- Pressure effects and equalization
- Equipment use and maintenance
- Safety procedures and emergency response
- Underwater navigation and buoyancy control

## After Certification
- Dive to 18m/60ft with certified buddy
- Continue with Advanced Open Water
- Join dive clubs and trips''',
        category: 'Certification',
        difficulty: 'Beginner',
        tags: ['certification', 'open water', 'training'],
        imageUrl: 'assets/images/diver_turtle_generated.png',
        readTimeMinutes: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),

      // Destinations Content
      DivingContent(
        id: 'dest_001',
        title: 'Top Diving Destinations',
        content: '''# Top Diving Destinations

## Tropical Waters
**Great Barrier Reef, Australia**: World's largest reef system with diverse marine life
**Maldives**: Manta rays and whale sharks in crystal clear waters
**Red Sea, Egypt**: Dramatic walls and abundant coral coverage

## Advanced Destinations
**Galápagos Islands**: Hammerhead schools and unique endemic species
**Socorro Island, Mexico**: Giant manta rays and whale shark encounters

## Unique Experiences
**Silfra Fissure, Iceland**: Diving between tectonic plates with 100m visibility
**Cenotes, Mexico**: Freshwater cavern diving with spectacular formations

## Planning Tips
- Check certification requirements for each destination
- Research best seasons for marine life encounters
- Book with reputable operators with good safety records''',
        category: 'Destinations',
        difficulty: 'Beginner',
        tags: ['destinations', 'travel', 'diving spots'],
        imageUrl: 'assets/images/coral_welcome_generated.png',
        readTimeMinutes: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
