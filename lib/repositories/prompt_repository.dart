import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/prompt_model.dart';
import 'dart:async';
import 'dart:math';
import '../data/mock_categories.dart';

abstract class PromptRepository {
  Future<List<PromptModel>> getFeaturedPrompts();
  Future<List<PromptModel>> getTrendingPrompts();
  Future<List<PromptModel>> getRecentPrompts();
  Future<PromptModel> getDailyPrompt();
  Future<List<PromptModel>> searchPrompts(String query);
  Future<List<PromptModel>> getPromptsByCategory(String category);
  Future<PromptModel?> getPromptById(String id);
  Future<List<PromptModel>> getTrendingPhotos();
}

class HybridPromptRepository implements PromptRepository {
  List<PromptModel> _dummyPrompts = [];
  bool _isInitialized = false;

  HybridPromptRepository();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    // Load generated dummy prompts
    _dummyPrompts = _generateHighQualityPrompts();
    
    // Load image generation prompts from JSON
    try {
      final jsonString = await rootBundle.loadString('assets/data/image_generation_prompts.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      for (var jsonItem in jsonList) {
        _dummyPrompts.add(PromptModel(
          id: jsonItem['id'],
          title: jsonItem['title'],
          description: 'A premium image generation prompt.',
          content: jsonItem['content'],
          category: jsonItem['category'],
          aiTool: 'Midjourney', // Mock tool for all since it's image generation
        ));
      }
    } catch (e) {
      debugPrint('Error loading image generation prompts: $e');
    }
    
    // Load prompts from Supabase
    try {
      final response = await Supabase.instance.client.from('prompts').select('''
        id, title, description, command, copy_count, category_id, image_url,
        categories ( title )
      ''');
      final data = response as List<dynamic>;
      for (var item in data) {
        _dummyPrompts.add(PromptModel(
          id: item['id'].toString(),
          title: item['title']?.toString() ?? 'Untitled',
          description: item['description']?.toString() ?? '',
          content: item['command']?.toString() ?? '',
          aiTool: 'ChatGPT', // default
          category: item['categories']?['title']?.toString() ?? 'General',
          copyCount: (item['copy_count'] as num?)?.toInt() ?? 0,
          imageUrl: item['image_url']?.toString(), // Parse image_url if exists
        ));
      }
    } catch (e) {
      debugPrint('Error fetching prompts from Supabase: $e');
    }

    // Add some dummy trending photos for demonstration
    _dummyPrompts.addAll([
      PromptModel(
        id: 'photo_1',
        title: 'Cyberpunk Cityscape',
        description: 'A futuristic city with neon lights.',
        content: 'A highly detailed cyberpunk cityscape at night, raining, neon signs, reflections on wet pavement, flying cars, 8k resolution, unreal engine 5 render, cinematic lighting.',
        aiTool: 'Midjourney',
        category: 'Image Generation',
        imageUrl: 'https://images.unsplash.com/photo-1601042879364-f3947d3f9c16?q=80&w=600&auto=format&fit=crop',
        copyCount: 1205,
      ),
      PromptModel(
        id: 'photo_2',
        title: 'Minimalist Workspace',
        description: 'Clean and modern desk setup.',
        content: 'A clean minimalist workspace, wooden desk, modern monitor, mechanical keyboard, small potted plant, natural sunlight from a window, soft shadows, photorealistic.',
        aiTool: 'DALL-E 3',
        category: 'Image Generation',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=600&auto=format&fit=crop',
        copyCount: 850,
      ),
      PromptModel(
        id: 'photo_3',
        title: 'Enchanted Forest',
        description: 'Magical forest with glowing mushrooms.',
        content: 'An enchanted forest at dusk, giant glowing mushrooms, bioluminescent plants, fairy lights, magical atmosphere, fantasy art style, highly detailed.',
        aiTool: 'Stable Diffusion',
        category: 'Image Generation',
        imageUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969?q=80&w=600&auto=format&fit=crop',
        copyCount: 2340,
      ),
      PromptModel(
        id: 'photo_4',
        title: 'Abstract Fluid Art',
        description: 'Vibrant fluid waves.',
        content: 'Abstract fluid art, swirling colors of gold, deep blue, and magenta, metallic reflections, macro photography style, highly detailed, 8k.',
        aiTool: 'Midjourney',
        category: 'Image Generation',
        imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=600&auto=format&fit=crop',
        copyCount: 432,
      ),
    ]);
    
    _isInitialized = true;
  }

  List<PromptModel> _generateHighQualityPrompts() {
    final List<PromptModel> generated = [];
    final Random random = Random(42);
    final allCategories = AppCategories.getAllCategories();
    int idCounter = 1;

    // These templates feature interactive variables [LIKE THIS] that the PromptDetailScreen will parse into input fields.
    final universalTemplates = [
      {
        'title': 'Masterclass Strategy for [CATEGORY]',
        'content': 'Act as an industry-leading expert in [CATEGORY]. Create a highly detailed, 30-day roadmap designed for a [Experience Level] to achieve [Specific Goal]. Break the plan down into weekly milestones. For each week, provide: \n\n1. Core concepts to master.\n2. Daily actionable tasks.\n3. Common pitfalls and how to avoid them.\n\nEnsure the tone is [Tone] and provide practical examples.'
      },
      {
        'title': '[CATEGORY] Problem Troubleshooting Framework',
        'content': 'You are an elite consultant specializing in [CATEGORY]. I am facing a critical issue regarding [Specific Problem]. First, analyze the root causes of this problem. Then, provide a structured troubleshooting framework containing at least 3 distinct solutions. Compare the pros and cons of each solution, and recommend the best approach for a [Company Size/Type] scenario.'
      },
      {
        'title': 'The Ultimate [CATEGORY] Execution Checklist',
        'content': 'Create an exhaustive, professional-grade execution checklist for a [Project Name] project in the field of [CATEGORY]. Divide the checklist into three chronological phases: \n\n1. Preparation & Setup\n2. Execution & Implementation\n3. Review & Optimization\n\nFor every item, include a brief explanation of WHY it is crucial and WHO should be responsible for it.'
      },
      {
        'title': '[CATEGORY] Innovation & Disruption Brainstorm',
        'content': 'Act as a visionary thought leader in [CATEGORY]. I want to disrupt the current market standard. Brainstorm 5 highly unconventional, cutting-edge ideas related to [Target Audience/Niche]. For each idea, detail the core mechanics, the unique value proposition, and the potential barriers to entry. Keep the formatting clean and use bullet points for readability.'
      },
      {
        'title': 'Ruthless [CATEGORY] Audit & Optimization',
        'content': 'Act as a strict, meticulous auditor for [CATEGORY]. I am working on [Current Project Details]. Critique my approach ruthlessly to identify inefficiencies, logic gaps, or missed opportunities. After your critique, provide a fully optimized, step-by-step revised version of my work that adheres to the absolute highest industry standards.'
      },
      {
        'title': 'Explain [CATEGORY] Concepts Simply',
        'content': 'Act as a world-class educator. Explain the complex concept of [Complex Concept Name] within the field of [CATEGORY]. Structure your explanation using the Feynman Technique. First, explain it so a 10-year-old can understand it using an intuitive analogy. Then, provide a deeper, technical explanation suitable for a college student, highlighting key terminology and real-world applications.'
      },
      {
        'title': '[CATEGORY] Best Practices & Guidelines',
        'content': 'Generate a definitive guide of best practices for [CATEGORY]. Focus specifically on the context of [Context/Environment]. Include the top 5 "Must-Do" rules and the top 5 "Never-Do" mistakes. Provide real-world case studies or hypothetical scenarios to illustrate why these rules are non-negotiable.'
      },
      {
        'title': 'Future Trends Analysis in [CATEGORY]',
        'content': 'Act as a futurist analyzing [CATEGORY]. Provide a detailed forecast of how [Specific Technology/Trend] will impact this field over the next 3 to 5 years. Discuss the implications for [Target Demographic], predict the tools that will become obsolete, and suggest how professionals can prepare for this shift today.'
      }
    ];

    final hardcodedData = {
      'ChatGPT': [
        {'title': 'Act as a Linux Terminal', 'content': 'I want you to act as a linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. do not write explanations. do not type commands unless I instruct you to do so. when I need to tell you something in english, i will do so by putting text inside curly brackets {like this}. my first command is pwd'},
        {'title': 'Act as an English Translator', 'content': 'I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more literary. I want you to only reply the correction, the improvements and nothing else, do not write explanations. My first sentence is "[Text to translate]"'},
        {'title': 'Act as a Job Interviewer', 'content': 'I want you to act as an interviewer. I will be the candidate and you will ask me the interview questions for the position of [Job Title]. I want you to only reply as the interviewer. Do not write all the conservation at once. I want you to only do the interview with me. Ask me the questions and wait for my answers. Do not write explanations. Ask me the questions one by one like an interviewer does and wait for my answers. My first sentence is "Hi"'},
        {'title': 'DALL-E Logo Design', 'content': 'Design a minimalist, modern logo for a company named [Company Name] that specializes in [Industry]. Use a color palette consisting of [Color 1] and [Color 2]. The logo should feature a [Shape or Symbol] and convey a sense of [Brand Emotion].'},
      ],
      'Gemini': [
        {'title': 'Photorealistic Landscape Generation', 'content': 'Create a highly detailed, photorealistic image of a [Landscape Type, e.g., futuristic city, serene mountain lake] at [Time of Day]. The lighting should be [Lighting Style, e.g., cinematic, golden hour]. Include elements like [Specific Elements] to make it unique.'},
        {'title': 'Character Concept Art', 'content': 'Generate concept art for a [Character Type, e.g., cyber-ninja, fantasy mage] in a [Setting] environment. They should be wearing [Clothing Style] and holding a [Prop/Weapon]. Use a [Art Style, e.g., watercolor, 3D render, comic book] style with [Color Palette] colors.'},
      ],
      'DALL·E': [
        {'title': 'Surreal Dreamscape', 'content': 'A surreal landscape where [Object 1] are floating in the sky instead of clouds, and the ground is made of [Material]. The lighting is [Lighting Style], creating a [Mood] atmosphere. High definition, masterpiece, trending on ArtStation.'},
        {'title': 'Product Photography', 'content': 'Commercial product photography of a [Product Name/Type] sitting on a [Surface Type] with [Background Elements] in the background. Studio lighting, sharp focus, 8k resolution, photorealistic.'},
      ],
      'Stable Diffusion': [
        {'title': 'Anime Style Illustration', 'content': 'Masterpiece, best quality, 1girl, solo, [Character Description], standing in a [Setting], wearing [Clothing], [Time of Day] lighting, detailed eyes, detailed hair, vibrant colors, intricate details.'},
      ],
      'SEO Articles': [
        {'title': 'Write a 2000-word Pillar Post', 'content': 'Act as an expert SEO copywriter. Write a comprehensive, 2000-word pillar blog post about [Main Topic]. Include an optimized H1, at least five H2s, and appropriate H3s. Naturally integrate the primary keyword "[Primary Keyword]" and secondary keywords: [Secondary Keywords]. Ensure the tone is authoritative yet engaging, and end with a strong CTA.'},
        {'title': 'Generate SEO Meta Tags', 'content': 'Act as an SEO Specialist. Create 5 variations of high-converting SEO Title Tags (under 60 characters) and Meta Descriptions (under 160 characters) for a page targeting the keyword "[Primary Keyword]". Ensure they are highly clickable and include a call to action.'},
      ],
      'Midjourney': [
        {'title': 'Cinematic Character Portrait', 'content': 'A highly detailed cinematic portrait of a [Character Description] in a [Setting], rain reflecting on the ground, glowing [Color] lighting, incredibly detailed face, photorealistic, shot on 35mm lens, 8k, Unreal Engine 5 render, dramatic lighting --ar 16:9 --v 6.0'},
        {'title': 'Epic Fantasy Landscape', 'content': 'A breathtaking fantasy landscape featuring [Main Subject e.g. floating islands], glowing waterfalls pouring into the clouds below, lush alien vegetation, ancient ruins, epic scale, concept art by Greg Rutkowski, golden hour lighting, masterpiece --ar 21:9 --v 6.0'},
      ],
      'React': [
        {'title': 'Custom Hook for Fetching', 'content': 'Act as a Senior React Developer. Write a production-ready Custom React Hook named `useFetch` using TypeScript. It should handle loading states, error handling, abort controllers (to prevent memory leaks), and caching. Provide a clear example of how to use it in a component that fetches [API Endpoint Data].'},
        {'title': 'Zustand State Setup', 'content': 'Act as a Frontend Engineer. Create a global state management setup using Zustand in a React TypeScript application. The store should handle [State Variables e.g. user authentication state]. Include persistence to local storage and demonstrate how to consume the store in a component.'},
      ],
      'Marketing Strategy': [
        {'title': 'Go-to-Market Strategy', 'content': 'Act as a Chief Marketing Officer (CMO). Develop a comprehensive 90-day Go-to-Market (GTM) strategy for a [Product Type] targeting [Target Audience]. Include phases for Pre-launch, Launch, and Post-launch. Detail the channels, budget allocation, and key KPIs we need to track.'},
      ],
      'YouTube Scripts': [
        {'title': 'Engaging 10-min Video Script', 'content': 'Act as a viral YouTube creator. Write a highly engaging, 10-minute video script about [Video Topic]. Start with an incredible hook in the first 15 seconds to maximize retention. Include visual cues in brackets [like this]. Break the video into 4 distinct acts, and end with a strong call to action to subscribe.'},
      ],
      'Flutter': [
        {'title': 'Riverpod 3.x Architecture', 'content': 'Act as a Senior Flutter Developer. Write a robust architecture example using Riverpod 3.x (Notifier/AsyncNotifier). Create a feature for [Feature Name e.g. Authentication]. It should include a repository pattern, handle loading states safely, and integrate with GoRouter for redirecting users.'},
      ],
      'Image Generation': [
        {'title': 'Photorealistic Portrait', 'content': 'RAW photo of a [Subject e.g. young woman], [Expression], [Lighting], [Background], 8k uhd, dslr, soft lighting, high quality, film grain, Fujifilm XT4 --ar 16:9'},
        {'title': 'Cyberpunk Cityscape', 'content': 'A futuristic cyberpunk city at night, [Weather Conditions e.g. raining neon], [Specific Elements e.g. flying cars], volumetric lighting, cinematic composition, masterpiece, trending on ArtStation --v 6.0'},
        {'title': 'Watercolor Illustration', 'content': 'A beautiful watercolor painting of [Subject e.g. a cozy cottage in the woods], delicate brushstrokes, pastel colors, whimsical atmosphere, highly detailed, Studio Ghibli style'},
        {'title': 'Minimalist Logo Design', 'content': 'A flat vector logo design of [Subject e.g. a fox], minimalist, geometric, negative space, [Color Palette], clean background, professional, corporate identity'},
      ],
    };

    for (var category in allCategories) {
      // 1. Add specific hardcoded prompts if available
      if (hardcodedData.containsKey(category)) {
        for (var data in hardcodedData[category]!) {
          generated.add(
            PromptModel(
              id: idCounter.toString(),
              title: data['title']!,
              description: 'A premium, handcrafted prompt specifically designed for ${category}.',
              content: data['content']!,
              aiTool: ['Midjourney', 'DALL·E', 'Flux AI', 'Leonardo AI', 'Stable Diffusion'].contains(category) ? 'Midjourney' : 'ChatGPT',
              category: category,
              difficulty: ['Beginner', 'Intermediate', 'Advanced'][random.nextInt(3)],
              copyCount: random.nextInt(50000) + 1000,
              isFavorite: false,
            ),
          );
          idCounter++;
        }
      }

      // 2. Add highly dynamic template prompts for every single category
      int numPrompts = 10 + random.nextInt(6); // Generate 10-15 high quality templates per category
      for (int i = 0; i < numPrompts; i++) {
        var template = universalTemplates[i % universalTemplates.length];
        
        String title = template['title']!.replaceAll('[CATEGORY]', category);
        String content = template['content']!.replaceAll('[CATEGORY]', category);

        if (i >= universalTemplates.length) {
          title = '$title (Variant ${i - universalTemplates.length + 1})';
        }

        generated.add(
          PromptModel(
            id: idCounter.toString(),
            title: title,
            description: 'A highly optimized, template-based prompt engineered for ${category} tasks.',
            content: content,
            aiTool: 'ChatGPT',
            category: category,
            difficulty: ['Beginner', 'Intermediate', 'Advanced'][random.nextInt(3)],
            copyCount: random.nextInt(20000) + 500,
            isFavorite: false,
          ),
        );
        idCounter++;
      }
    }
    
    // Shuffle to make feeds look organic
    generated.shuffle(random);
    return generated;
  }

  @override
  Future<List<PromptModel>> getFeaturedPrompts() async {
    await _ensureInitialized();
    return _dummyPrompts.take(15).toList();
  }

  @override
  Future<List<PromptModel>> getTrendingPrompts() async {
    await _ensureInitialized();
    final sorted = List<PromptModel>.from(_dummyPrompts)..sort((a, b) => b.copyCount.compareTo(a.copyCount));
    return sorted.take(20).toList();
  }

  @override
  Future<List<PromptModel>> getRecentPrompts() async {
    await _ensureInitialized();
    return _dummyPrompts.reversed.take(20).toList();
  }

  @override
  Future<PromptModel> getDailyPrompt() async {
    await _ensureInitialized();
    if (_dummyPrompts.isEmpty) throw Exception('No prompts available');
    return _dummyPrompts.first;
  }

  @override
  Future<List<PromptModel>> searchPrompts(String query) async {
    await _ensureInitialized();
    final lowercaseQuery = query.toLowerCase();
    return _dummyPrompts.where((p) => 
      p.title.toLowerCase().contains(lowercaseQuery) || 
      p.content.toLowerCase().contains(lowercaseQuery) ||
      p.category.toLowerCase().contains(lowercaseQuery) // Added category search support
    ).toList();
  }

  @override
  Future<List<PromptModel>> getPromptsByCategory(String category) async {
    await _ensureInitialized();
    return _dummyPrompts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<PromptModel?> getPromptById(String id) async {
    await _ensureInitialized();
    try {
      return _dummyPrompts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PromptModel>> getTrendingPhotos() async {
    await _ensureInitialized();
    // Return prompts that have an image url
    final photos = _dummyPrompts.where((p) => p.imageUrl != null).toList();
    photos.sort((a, b) => b.copyCount.compareTo(a.copyCount));
    return photos;
  }
}

