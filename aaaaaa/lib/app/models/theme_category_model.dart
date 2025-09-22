import 'package:flutter/material.dart';

class ThemeCategoryModel {
  final String name;
  final String description;
  final IconData icon;
  final List<String> prompts;
  final Color color;

  const ThemeCategoryModel({
    required this.name,
    required this.description,
    required this.icon,
    required this.prompts,
    required this.color,
  });

  static List<ThemeCategoryModel> get categories => [
        ThemeCategoryModel(
          name: 'Portrait',
          description: 'Beautiful portrait and beauty photography',
          icon: Icons.face,
          color: Colors.pink,
          prompts: [
            'Elegant woman with flowing hair in soft lighting',
            'Professional portrait with dramatic shadows',
            'Beautiful model with natural makeup in golden hour',
            'Artistic portrait with creative lighting',
            'Classic beauty portrait in black and white',
            'Fashion portrait with vibrant colors',
            'Dreamy portrait with soft focus background',
            'Portrait with artistic bokeh effects'
          ],
        ),
        ThemeCategoryModel(
          name: 'Fashion',
          description: 'Fashion photography and style imagery',
          icon: Icons.checkroom,
          color: Colors.deepPurple,
          prompts: [
            'High fashion model on runway with dramatic lighting',
            'Street style fashion photography in urban setting',
            'Elegant evening gown portrait',
            'Modern fashion shoot with minimalist background',
            'Vintage fashion styling with retro vibes',
            'Contemporary fashion with bold colors',
            'Artistic fashion photography with creative angles',
            'Luxury fashion portrait with sophisticated styling'
          ],
        ),
        ThemeCategoryModel(
          name: 'Nature',
          description: 'Beautiful landscapes and natural scenes',
          icon: Icons.nature,
          color: Colors.green,
          prompts: [
            'Serene forest with morning sunlight filtering through trees',
            'Peaceful mountain lake with perfect reflections',
            'Cherry blossom trees in full spring bloom',
            'Tropical paradise beach with crystal clear water',
            'Misty forest waterfall cascading over rocks',
            'Sunset over rolling green hills',
            'Ancient redwood forest with towering trees',
            'Wildflower meadow in golden hour light'
          ],
        ),
        ThemeCategoryModel(
          name: 'City',
          description: 'Urban landscapes and cityscapes',
          icon: Icons.location_city,
          color: Colors.blue,
          prompts: [
            'Modern city skyline at sunset with glass buildings',
            'Neon-lit streets at night with reflections',
            'Futuristic urban architecture with clean lines',
            'Busy intersection with long exposure light trails',
            'Art deco building facades with intricate details',
            'Cyberpunk cityscape with holographic displays',
            'Rooftop view of sprawling metropolis',
            'Urban street photography with dramatic shadows'
          ],
        ),
        ThemeCategoryModel(
          name: 'Space',
          description: 'Cosmic scenes and celestial bodies',
          icon: Icons.rocket_launch,
          color: Colors.purple,
          prompts: [
            'Distant galaxy with swirling colorful nebula',
            'Earth from space with beautiful aurora borealis',
            'Starry night sky over mountain silhouettes',
            'International space station orbiting Earth',
            'Milky Way galaxy stretching across dark sky',
            'Alien planet landscape with multiple moons',
            'Cosmic explosion with vibrant colors',
            'Astronaut floating in deep space'
          ],
        ),
        ThemeCategoryModel(
          name: 'Abstract',
          description: 'Artistic and abstract compositions',
          icon: Icons.palette,
          color: Colors.orange,
          prompts: [
            'Flowing liquid metal patterns with reflections',
            'Geometric shapes with rainbow gradients',
            'Watercolor paint splash with vibrant colors',
            'Digital art with electric neon effects',
            'Minimalist wave patterns in pastel tones',
            'Fractal patterns with mathematical beauty',
            'Marble texture with gold veining',
            'Abstract smoke formations in color'
          ],
        ),
        ThemeCategoryModel(
          name: 'Anime',
          description: 'Anime and manga style artwork',
          icon: Icons.animation,
          color: Colors.red,
          prompts: [
            'Beautiful anime girl with large expressive eyes',
            'Anime character in magical school uniform',
            'Cute anime style portrait with pastel colors',
            'Anime warrior with flowing cape and sword',
            'Kawaii anime character with cherry blossoms',
            'Anime girl in traditional Japanese kimono',
            'Fantasy anime character with magical powers',
            'Anime style cityscape with dramatic sky'
          ],
        ),
        ThemeCategoryModel(
          name: 'Fantasy',
          description: 'Magical and mythical worlds',
          icon: Icons.auto_fix_high,
          color: Colors.teal,
          prompts: [
            'Enchanted forest with glowing magical mushrooms',
            'Majestic dragon soaring over ancient castle',
            'Mystical portal glowing in ancient stone ruins',
            'Floating islands connected by rainbow bridges',
            'Wizard tower surrounded by swirling magic',
            'Fairy tale princess in magical garden',
            'Phoenix rising from flames with golden feathers',
            'Underwater mermaid palace with coral decorations'
          ],
        ),
        ThemeCategoryModel(
          name: 'Gaming',
          description: 'Video game inspired artwork',
          icon: Icons.sports_esports,
          color: Colors.lime,
          prompts: [
            'Epic fantasy RPG character with legendary armor',
            'Cyberpunk hacker in neon-lit virtual reality',
            'Post-apocalyptic warrior in wasteland setting',
            'Steampunk inventor with mechanical gadgets',
            'Space marine in futuristic power armor',
            'Medieval knight with glowing enchanted sword',
            'Ninja assassin in moonlit rooftop scene',
            'Sci-fi spaceship cockpit with holographic displays'
          ],
        ),
        ThemeCategoryModel(
          name: 'Architecture',
          description: 'Buildings and structural designs',
          icon: Icons.architecture,
          color: Colors.indigo,
          prompts: [
            'Gothic cathedral with intricate stained glass windows',
            'Modern glass skyscraper with sky reflections',
            'Ancient Greek temple ruins at golden hour',
            'Traditional Japanese pagoda in zen garden',
            'Art nouveau building with ornate decorative details',
            'Futuristic architecture with impossible geometry',
            'Classical Roman amphitheater in morning light',
            'Contemporary museum with bold geometric design'
          ],
        ),
        ThemeCategoryModel(
          name: 'Vehicles',
          description: 'Cars, motorcycles, and transportation',
          icon: Icons.directions_car,
          color: Colors.grey,
          prompts: [
            'Luxury sports car on winding mountain road',
            'Vintage motorcycle parked in urban alley',
            'Futuristic electric vehicle in cyber city',
            'Classic muscle car at sunset beach',
            'Racing car speeding on professional track',
            'Steampunk airship floating in cloudy sky',
            'Sleek spacecraft in asteroid field',
            'Retro convertible on scenic coastal highway'
          ],
        ),
        ThemeCategoryModel(
          name: 'Animals',
          description: 'Wildlife and domestic animals',
          icon: Icons.pets,
          color: Colors.amber,
          prompts: [
            'Majestic lion with flowing mane in African savanna',
            'Colorful tropical parrot in lush rainforest',
            'Wolf pack hunting in snowy wilderness',
            'Monarch butterfly on vibrant blooming flower',
            'Bald eagle soaring majestically above mountains',
            'Cute panda eating bamboo in natural habitat',
            'Graceful dolphins jumping in ocean waves',
            'Majestic tiger walking through jungle foliage'
          ],
        ),
      ];
}
