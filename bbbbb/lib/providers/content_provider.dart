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
    return _allContent.where((content) => content.category == category).toList();
  }

  List<DivingContent> getContentByIds(List<String> ids) {
    return _allContent.where((content) => ids.contains(content.id)).toList();
  }

  void _applyFilters() {
    List<DivingContent> filtered = List.from(_allContent);

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((content) => content.category == _selectedCategory).toList();
    }

    // Apply difficulty filter
    if (_selectedDifficulty != 'All') {
      filtered = filtered.where((content) => content.difficulty == _selectedDifficulty).toList();
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
      // Safety Content
      DivingContent(
        id: 'safety_001',
        title: 'Basic Diving Safety Rules',
        content: '''# Basic Diving Safety Rules

## Never Hold Your Breath
The most important rule in scuba diving is to never hold your breath. As you ascend, the air in your lungs expands due to decreasing pressure. If you hold your breath, this expansion can cause serious lung injuries.

## Plan Your Dive and Dive Your Plan
Always plan your dive before entering the water:
- Maximum depth
- Bottom time
- Air consumption rate
- Emergency procedures

## Check Your Equipment
Before every dive, perform a thorough equipment check:
- BCD inflation and deflation
- Regulator breathing test
- Gauge readings
- Mask and fins fit

## Use the Buddy System
Never dive alone. Your dive buddy is your safety backup:
- Stay within sight of each other
- Know each other's hand signals
- Practice emergency procedures together

## Monitor Your Air Supply
Check your air gauge frequently:
- Start ascent with 50 bar (700 psi) remaining
- Surface with 30 bar (500 psi) minimum
- Never share air unless it's an emergency

Remember: When in doubt, don't dive. Your safety is more important than any dive.''',
        category: 'Safety',
        difficulty: 'Beginner',
        tags: ['safety', 'rules', 'basic', 'emergency'],
        imageUrl: 'https://example.com/safety_diving.jpg',
        readTimeMinutes: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      DivingContent(
        id: 'safety_002',
        title: 'Emergency Procedures Underwater',
        content: '''# Emergency Procedures Underwater

## Out of Air Emergency
If you or your buddy runs out of air:

### For the Diver Out of Air:
1. Signal "Out of Air" to your buddy
2. Move close to your buddy
3. Take the alternate air source (octopus)
4. Begin controlled ascent together

### For the Assisting Diver:
1. Stay calm and take control
2. Secure your buddy close to you
3. Establish buoyancy for both divers
4. Begin slow ascent (no faster than 18m/60ft per minute)

## Lost Buddy Procedure
If you lose sight of your buddy:
1. Look around for 1 minute maximum
2. Make some noise (tank banging)
3. If not found, surface slowly
4. Meet at the predetermined surface location

## Mask Flooding
1. Remain calm - you can breathe through your regulator
2. Tilt your head back slightly
3. Press top of mask against forehead
4. Exhale through nose to clear water

## Regulator Free-Flow
1. Don't panic - you have plenty of air
2. Turn off the air flow if possible
3. Breathe from the side of your mouth
4. Signal buddy and begin ascent

## Cramp Relief
Leg cramps underwater:
1. Grab your fin tip
2. Pull towards you while straightening leg
3. Massage the cramped muscle
4. Signal buddy if you need assistance

Practice these procedures regularly in controlled conditions.''',
        category: 'Safety',
        difficulty: 'Intermediate',
        tags: ['emergency', 'procedures', 'safety', 'rescue'],
        imageUrl: 'https://example.com/emergency_diving.jpg',
        readTimeMinutes: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // Equipment Content
      DivingContent(
        id: 'equipment_001',
        title: 'Essential Scuba Diving Equipment',
        content: '''# Essential Scuba Diving Equipment

## Core Equipment

### Mask
Your window to the underwater world:
- **Low volume masks** reduce CO2 buildup
- **Tempered glass** for safety
- **Proper fit** is crucial - no gaps at hairline
- **Nose pocket** for equalizing ear pressure

### Snorkel
For surface swimming and conserving tank air:
- **J-shaped or flexible** designs work best
- **Purge valve** helps clear water
- **Comfortable mouthpiece** reduces jaw fatigue

### Fins
Propulsion underwater:
- **Open heel** fins for cold water/thick boots
- **Full foot** fins for warm water
- **Blade stiffness** affects efficiency
- **Proper fit** prevents blisters and cramps

## Life Support Equipment

### Regulator System
Your air delivery system:
- **First stage** reduces tank pressure
- **Second stage** delivers breathing air
- **Octopus** backup air source
- **Low pressure inflator** for BCD

### BCD (Buoyancy Control Device)
Controls your buoyancy:
- **Back inflation** vs **jacket style**
- **Integrated weights** vs weight belt
- **Multiple dump valves** for easy deflation
- **D-rings** for equipment attachment

### Exposure Protection

#### Wetsuits
For moderate water temperatures:
- **3mm** for tropical water (24°C+/75°F+)
- **5mm** for temperate water (18-24°C/65-75°F)
- **7mm** for cold water (10-18°C/50-65°F)

#### Drysuits
For very cold water:
- **Neoprene** vs **trilaminate** materials
- **Undergarments** for insulation
- **Proper training** required for safe use

## Monitoring Equipment

### Depth Gauge
Tracks your depth:
- **Analog** vs **digital** displays
- **Maximum depth indicator**
- **Metric** vs **imperial** units

### Pressure Gauge
Monitors air supply:
- **Color-coded** readings (green/yellow/red)
- **Luminous** dial for low light
- **High pressure** connection to tank

### Dive Computer
Modern diving essential:
- **No-decompression limits**
- **Ascent rate warnings**
- **Safety stop timers**
- **Dive log memory**

## Additional Accessories

### Dive Knife/Tool
For safety and utility:
- **Blunt tip** preferred for safety
- **Serrated edge** for cutting lines
- **Secure attachment** to prevent loss

### Dive Light
Essential for night diving and looking into crevices:
- **Primary light** - powerful and reliable
- **Backup lights** - at least two
- **Lanyard attachment** to prevent dropping

### Surface Marker Buoy (SMB)
For surface visibility:
- **Delayed SMB** deployed during dive
- **Oral inflation** or **low pressure inflator**
- **Bright colors** for visibility

Quality equipment properly maintained is an investment in your safety and diving enjoyment.''',
        category: 'Equipment',
        difficulty: 'Beginner',
        tags: ['equipment', 'gear', 'basic', 'essential'],
        imageUrl: 'https://example.com/diving_equipment.jpg',
        readTimeMinutes: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // Marine Life Content
      DivingContent(
        id: 'marine_001',
        title: 'Coral Reef Ecosystems',
        content: '''# Coral Reef Ecosystems

## What Are Coral Reefs?

Coral reefs are among the most diverse ecosystems on Earth, often called the "rainforests of the sea." These underwater structures are built by tiny animals called coral polyps over thousands of years.

### Types of Coral Reefs

#### Fringing Reefs
- Grow directly from the shore
- Most common type of reef
- Found in shallow, warm waters
- Examples: Great Barrier Reef sections

#### Barrier Reefs
- Separated from shore by lagoon
- Run parallel to coastline
- Deeper waters between reef and shore
- Example: Belize Barrier Reef

#### Atolls
- Ring-shaped reefs around lagoons
- Formed from sunken volcanic islands
- Found in deep ocean waters
- Example: Maldives atolls

## Coral Types

### Hard Corals (Scleractinia)
- Build calcium carbonate skeletons
- Create reef structure
- Examples: Brain coral, staghorn coral, table coral

### Soft Corals
- No hard skeleton
- Flexible and wave-like movement
- Examples: Sea fans, sea whips, leather corals

## Marine Life Inhabitants

### Fish Species

#### Reef Fish
- **Angelfish** - Colorful, laterally compressed
- **Butterflyfish** - Small, bright patterns
- **Parrotfish** - Important for reef health
- **Wrasse** - Cleaners and predators
- **Grouper** - Large predatory fish

#### Smaller Species
- **Clownfish** - Live in anemones
- **Gobies** - Bottom dwellers
- **Damselfish** - Territorial defenders
- **Cardinalfish** - Active at night

### Other Marine Animals

#### Invertebrates
- **Sea turtles** - Ancient mariners
- **Rays** - Graceful swimmers
- **Moray eels** - Crevice dwellers
- **Octopus** - Intelligent cephalopods
- **Sea slugs** - Colorful nudibranchs

## Reef Conservation

### Threats to Reefs
- **Climate change** and ocean warming
- **Ocean acidification**
- **Pollution** from land runoff
- **Overfishing** and destructive fishing
- **Tourism** impact

### How Divers Can Help
1. **Don't touch** corals or marine life
2. **Maintain proper buoyancy** to avoid contact
3. **Don't collect** souvenirs from reefs
4. **Use reef-safe sunscreen**
5. **Support conservation** organizations
6. **Practice responsible** diving techniques

## Diving Coral Reefs Safely

### Best Practices
- **Perfect your buoyancy** before reef diving
- **Swim slowly** to avoid damaging corals
- **Look but don't touch** marine life
- **Stay with your group** and guide
- **Respect marine park** rules and regulations

### What to Look For
- **Cleaning stations** where fish get cleaned
- **Spawning events** during certain seasons
- **Nocturnal creatures** during night dives
- **Camouflaged animals** hiding in plain sight

Coral reefs are fragile ecosystems that take decades to grow but can be damaged in seconds. As divers, we are privileged visitors to this underwater world and must act as its protectors.''',
        category: 'Marine Life',
        difficulty: 'Beginner',
        tags: ['coral', 'reef', 'ecosystem', 'marine life', 'conservation'],
        imageUrl: 'https://example.com/coral_reef.jpg',
        readTimeMinutes: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      // Techniques Content
      DivingContent(
        id: 'techniques_001',
        title: 'Mastering Buoyancy Control',
        content: '''# Mastering Buoyancy Control

Buoyancy control is the most important skill in diving. It affects your air consumption, safety, and enjoyment underwater.

## Understanding Buoyancy

### Three States of Buoyancy
1. **Positive** - You float upward
2. **Negative** - You sink downward  
3. **Neutral** - You neither sink nor float

### Factors Affecting Buoyancy
- **Lung volume** - breathing affects buoyancy
- **Equipment weight** - BCD, weights, tank
- **Wetsuit compression** - decreases with depth
- **Salt vs fresh water** - salt water is denser

## Achieving Perfect Buoyancy

### Initial Weight Check
1. At surface, fully inflate BCD
2. Hold normal breath
3. Float at eye level
4. Deflate BCD completely
5. Should slowly sink

### Fine-Tuning Underwater
- **Add air** to BCD when sinking
- **Release air** when floating up
- **Small adjustments** work best
- **Use breathing** to fine-tune

## Breathing Techniques

### Lung as Buoyancy Control
- **Inhale** - become more buoyant
- **Exhale** - become less buoyant
- **Deep breathing** affects buoyancy more
- **Controlled breathing** maintains stable buoyancy

### Optimal Breathing Pattern
1. **Slow, deep breaths**
2. **Pause briefly** at full inhale
3. **Slow, complete exhale**
4. **Brief pause** before next inhale

## Common Buoyancy Problems

### Over-Weighting
Signs:
- Constantly adding air to BCD
- Rapid descent at start of dive
- Difficulty staying up during safety stop

Solutions:
- Remove 1-2 lbs of weight
- Do proper weight check
- Practice at shallow depth

### Under-Weighting
Signs:
- Can't descend even with empty BCD
- Floating during safety stop
- Struggling to stay down

Solutions:
- Add 1-2 lbs of weight
- Check equipment for trapped air
- Ensure complete BCD deflation

### Poor BCD Control
Signs:
- Yo-yo diving (up and down movement)
- Over-inflating BCD
- Adding large amounts of air

Solutions:
- Make small adjustments only
- Use oral inflator for precision
- Practice in shallow water

## Advanced Buoyancy Skills

### Hovering Motionless
1. Find neutral buoyancy at target depth
2. Relax completely
3. Use only breathing for small adjustments
4. Practice staying motionless for 30 seconds

### Swimming While Neutral
1. Achieve neutral buoyancy
2. Use fins for propulsion only
3. Maintain depth while swimming
4. Adjust for depth changes

### Photography Buoyancy
1. Perfect neutral buoyancy essential
2. Use reef hook in currents
3. Steady breathing for sharp photos
4. Avoid contact with bottom

## Practice Exercises

### Pool Training
1. **Fin pivot** - stay on bottom with fin tips
2. **Hovering** - motionless mid-water
3. **Swimming without hands** - fins only propulsion

### Open Water Practice
1. **Peak performance buoyancy** course
2. **Underwater photography** training
3. **Regular buoyancy** check dives

## Benefits of Good Buoyancy
- **Better air consumption**
- **Reduced marine life disturbance**
- **Improved safety margins**
- **More enjoyable diving**
- **Better underwater photography**
- **Easier wreck penetration**

Master buoyancy control and transform your diving experience. It's the foundation skill that makes everything else possible.''',
        category: 'Techniques',
        difficulty: 'Intermediate',
        tags: ['buoyancy', 'control', 'techniques', 'skills'],
        imageUrl: 'https://example.com/buoyancy_control.jpg',
        readTimeMinutes: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // Certification Content
      DivingContent(
        id: 'cert_001',
        title: 'Open Water Diver Certification Guide',
        content: '''# Open Water Diver Certification Guide

The Open Water Diver certification is your first step into the underwater world. This certification allows you to dive with a certified buddy to a maximum depth of 18 meters (60 feet).

## Course Overview

### Prerequisites
- **Age requirement**: 10 years old (Junior Open Water), 15 years old (Open Water)
- **Swimming ability**: Swim 200 meters, tread water for 10 minutes
- **Medical clearance**: May be required based on health questionnaire

### Course Structure
1. **Knowledge Development** (5 sections)
2. **Confined Water Training** (5 sessions)
3. **Open Water Training** (4 dives)

## Knowledge Development

### Section 1: The Underwater World
- Pressure effects on the body
- Air spaces and equalization
- Breathing compressed air underwater

### Section 2: Equipment
- Selecting and using dive equipment
- Problem prevention and management
- Caring for your equipment

### Section 3: Planning and Procedures
- Dive planning and preparation
- Dive procedures and safety
- Problem management

### Section 4: Dive Environment
- Aquatic life and ecosystems
- Diving conditions and environments
- Conservation and responsible diving

### Section 5: Dive Safety
- Preventing problems
- Emergency procedures
- Continuing education

## Confined Water Skills

### Session 1: Basic Skills
- Equipment setup and use
- Breathing underwater
- Regulator clearing and recovery
- Mask clearing

### Session 2: Buoyancy and Movement
- BCD inflation and deflation
- Underwater swimming
- Basic buoyancy control
- Hand signals review

### Session 3: Problem Prevention
- Alternate air source use
- Controlled emergency swimming ascent
- Weight system removal and replacement
- Cramp removal

### Session 4: Advanced Skills
- Underwater navigation
- Deep water entry
- Night diving signals
- Equipment care and maintenance

### Session 5: Skill Integration
- Complete skill circuit
- Problem-solving scenarios
- Preparation for open water

## Open Water Training Dives

### Dive 1: Foundation Skills
- Pre-dive safety check
- Deep water entry
- Buoyancy control
- Basic navigation

### Dive 2: Navigation and Safety
- Underwater navigation
- Emergency procedures
- Wildlife observation
- Dive planning

### Dive 3: Exploration
- Deeper water diving
- Advanced buoyancy
- Underwater tour
- Problem management

### Dive 4: Independent Diving
- Student-led dive planning
- Autonomous problem solving
- Certification skills demonstration
- Celebration dive!

## After Certification

### Your Privileges
- Dive with certified buddy
- Maximum depth: 18m/60ft
- Rent or purchase equipment
- Join dive trips and groups

### Recommended Next Steps
1. **Advanced Open Water** - Expand skills and depth limits
2. **Specialty Courses** - Focus on specific interests
3. **Rescue Diver** - Learn to help others
4. **Divemaster** - Leadership level training

### Building Experience
- **Log your dives** - Track progress and experiences
- **Join dive clubs** - Meet other divers
- **Take specialty courses** - Expand your skills
- **Practice regularly** - Maintain and improve skills

## Choosing a Dive Center

### What to Look For
- **PADI 5-Star rating** or equivalent
- **Experienced instructors**
- **Good equipment maintenance**
- **Small class sizes**
- **Positive reviews**

### Questions to Ask
- What's included in course price?
- What's the instructor-to-student ratio?
- Can I see the training facility?
- What equipment do I need to purchase?
- What are the local diving conditions?

## Cost Considerations

### Typical Course Costs
- **Course fees**: $300-500
- **Materials**: $50-100
- **Equipment rental**: $50-100
- **Certification card**: $25-50

### Equipment Investment
Start with personal items:
1. **Mask, snorkel, fins**
2. **Exposure suit**
3. **BCD and regulator** (later)
4. **Instruments** (last)

Your Open Water certification is just the beginning of a lifetime of underwater adventures. Take your time to learn properly - the ocean will wait for you to be ready.''',
        category: 'Certification',
        difficulty: 'Beginner',
        tags: ['certification', 'open water', 'training', 'course'],
        imageUrl: 'https://example.com/open_water_cert.jpg',
        readTimeMinutes: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),

      // Destinations Content
      DivingContent(
        id: 'dest_001',
        title: 'World\'s Best Diving Destinations',
        content: '''# World's Best Diving Destinations

Explore the most spectacular underwater locations around the globe, each offering unique marine life and diving experiences.

## Tropical Paradise Destinations

### Great Barrier Reef, Australia
**Best Time**: April-November
**Highlights**:
- World's largest coral reef system
- Over 1,500 fish species
- Diving with Minke whales
- Multiple diving areas from Cairns

**What to Expect**:
- Water temperature: 23-29°C (73-84°F)
- Visibility: 15-40 meters
- Currents: Generally mild
- Difficulty: All levels

### Maldives
**Best Time**: November-April
**Highlights**:
- Manta ray encounters
- Whale shark sightings
- Pristine coral gardens
- Over-water bungalow diving

**What to Expect**:
- Water temperature: 26-30°C (79-86°F)
- Visibility: 20-40 meters
- Currents: Can be strong
- Difficulty: Intermediate to advanced

### Red Sea, Egypt
**Best Time**: March-May, September-November
**Highlights**:
- Dramatic drop-offs and walls
- Abundant coral coverage
- Historic wrecks
- Pelagic species

**What to Expect**:
- Water temperature: 20-28°C (68-82°F)
- Visibility: 20-40 meters
- Currents: Variable
- Difficulty: All levels

## Advanced Diving Destinations

### Galápagos Islands, Ecuador
**Best Time**: June-November (cooler, more marine life)
**Highlights**:
- Hammerhead shark schools
- Marine iguanas underwater
- Unique endemic species
- Darwin and Wolf Islands

**What to Expect**:
- Water temperature: 16-26°C (61-79°F)
- Visibility: 10-25 meters
- Currents: Strong
- Difficulty: Advanced only

### Socorro Island, Mexico
**Best Time**: November-May
**Highlights**:
- Giant Pacific manta rays
- Whale shark encounters
- Dolphin interactions
- Hammerhead schools

**What to Expect**:
- Water temperature: 21-27°C (70-81°F)
- Visibility: 20-40 meters
- Currents: Strong
- Difficulty: Advanced

### Cocos Island, Costa Rica
**Best Time**: December-May
**Highlights**:
- Massive hammerhead schools
- Whale shark encounters
- Unique underwater topography
- Pristine ecosystem

**What to Expect**:
- Water temperature: 24-27°C (75-81°F)
- Visibility: 15-30 meters
- Currents: Strong
- Difficulty: Advanced

## Unique Experiences

### Silfra Fissure, Iceland
**Best Time**: Year-round
**Highlights**:
- Diving between tectonic plates
- Crystal clear glacial water
- Unique geological formations
- 100+ meter visibility

**What to Expect**:
- Water temperature: 2-4°C (36-39°F)
- Visibility: 100+ meters
- Currents: Minimal
- Difficulty: Open Water certified (drysuit)

### Cenotes, Mexico
**Best Time**: Year-round
**Highlights**:
- Freshwater cavern diving
- Spectacular stalactites
- Unique light effects
- Archaeological significance

**What to Expect**:
- Water temperature: 24-26°C (75-79°F)
- Visibility: 50+ meters
- Currents: None
- Difficulty: Open Water to advanced

### Sardine Run, South Africa
**Best Time**: May-July
**Highlights**:
- Massive sardine shoals
- Dolphin super-pods
- Sharks and marine predators
- Spectacular feeding frenzies

**What to Expect**:
- Water temperature: 18-21°C (64-70°F)
- Visibility: 5-15 meters
- Currents: Strong
- Difficulty: Intermediate to advanced

## Planning Your Dive Trip

### Research and Preparation
1. **Check visa requirements**
2. **Get necessary vaccinations**
3. **Verify certification requirements**
4. **Book well in advance**
5. **Consider travel insurance**

### What to Pack
- **Certification cards** and logbook
- **Personal dive gear** (mask, fins, computer)
- **Reef-safe sunscreen**
- **First aid kit**
- **Underwater camera**

### Choosing Dive Operators
Look for:
- **PADI 5-Star or equivalent** rating
- **Good safety record**
- **Local knowledge**
- **Environmental responsibility**
- **Positive reviews**

### Dive Travel Tips
1. **Arrive a day early** to acclimate
2. **Don't fly within 18 hours** of diving
3. **Stay hydrated** throughout trip
4. **Respect local customs** and environment
5. **Log every dive** for memories

Each destination offers its own magic. Choose based on your certification level, interests, and comfort with different diving conditions. The underwater world is vast and waiting to be explored!''',
        category: 'Destinations',
        difficulty: 'Beginner',
        tags: ['destinations', 'travel', 'diving spots', 'locations'],
        imageUrl: 'https://example.com/diving_destinations.jpg',
        readTimeMinutes: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
