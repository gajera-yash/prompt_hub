class AppCategories {
  static const Map<String, List<String>> categoryGroups = {
    'Programming & Development': [
      'Flutter', 'React', 'React Native', 'Next.js', 'Node.js', 'Python', 'Java', 'JavaScript', 'TypeScript', 'C++', 'C#', 'SQL', 'MongoDB', 'Firebase', 'API Development', 'Bug Fixing', 'Code Review', 'System Design', 'DevOps', 'Git & GitHub'
    ],
    'AI & Prompt Engineering': [
      'ChatGPT', 'Gemini', 'Claude', 'DeepSeek', 'Perplexity', 'Cursor AI', 'GitHub Copilot', 'Prompt Engineering'
    ],
    'Image Generation': [
      'Midjourney', 'DALL·E', 'Flux AI', 'Leonardo AI', 'Stable Diffusion', 'Runway ML', 'Sora Video Prompts', 'Image Generation'
    ],
    'Content Creation': [
      'YouTube Scripts', 'YouTube Titles', 'YouTube Descriptions', 'Instagram Captions', 'Instagram Reels', 'TikTok Ideas', 'Facebook Posts', 'LinkedIn Posts', 'X (Twitter) Threads', 'Pinterest Pins', 'Podcast Scripts', 'Blog Writing', 'Newsletter Writing', 'Storytelling'
    ],
    'Digital Marketing': [
      'SEO Articles', 'Google Ads', 'Facebook Ads', 'Instagram Ads', 'Email Marketing', 'Sales Funnels', 'Copywriting', 'Product Descriptions', 'Landing Pages', 'Marketing Strategy', 'Brand Positioning', 'Keyword Research'
    ],
    'Business & Startup': [
      'Business Plans', 'Startup Ideas', 'Pitch Decks', 'Investor Pitch', 'SWOT Analysis', 'Market Research', 'Customer Persona', 'Business Emails', 'Business Proposal', 'Pricing Strategy'
    ],
    'Freelancing': [
      'Upwork Proposals', 'Fiverr Gig Descriptions', 'Client Emails', 'Project Estimates', 'Invoice Messages', 'Portfolio Writing', 'Client Follow-ups'
    ],
    'Career': [
      'Resume Writing', 'ATS Resume', 'Cover Letter', 'LinkedIn Profile', 'Interview Questions', 'HR Interview', 'Technical Interview', 'Salary Negotiation', 'Career Advice'
    ],
    'Education': [
      'Homework Help', 'Assignment Writing', 'Essay Writing', 'Research Paper', 'Quiz Generator', 'Study Notes', 'Flashcards', 'Exam Preparation', 'Lesson Plans'
    ],
    'E-commerce': [
      'Amazon Listings', 'Shopify Store', 'Etsy Product Titles', 'Product Descriptions', 'Customer Support Replies', 'Review Responses', 'Product SEO'
    ],
    'Design': [
      'UI/UX Design', 'Logo Design', 'Brand Identity', 'Poster Design', 'Thumbnail Ideas', 'Interior Design', 'Architecture', 'Color Palette', 'Wireframes'
    ],
    'Professional Writing': [
      'Emails', 'Cold Emails', 'Follow-up Emails', 'Meeting Notes', 'Proposals', 'Contracts', 'Reports', 'Documentation'
    ],
    'Lifestyle': [
      'Fitness Plans', 'Meal Plans', 'Yoga', 'Meditation', 'Habit Tracker', 'Productivity', 'Time Management', 'Goal Planning'
    ],
    'Travel': [
      'Trip Planner', 'Travel Itinerary', 'Budget Travel', 'Hotel Reviews', 'Packing Lists', 'Local Guides'
    ],
    'Writing': [
      'Story Writing', 'Book Writing', 'Poetry', 'Screenplay', 'Novel Ideas', 'Character Development', 'Dialogue Writing'
    ],
    'Professional': [
      'Legal Drafts', 'HR Documents', 'SOP Writing', 'Policies', 'Meeting Agendas', 'Project Documentation'
    ],
  };

  static String getIconForGroup(String group) {
    switch (group) {
      case 'Programming & Development':
        return 'code';
      case 'AI & Prompt Engineering':
        return 'bot';
      case 'Content Creation':
        return 'pen-tool';
      case 'Digital Marketing':
        return 'trending-up';
      case 'Business & Startup':
        return 'briefcase';
      case 'Freelancing':
        return 'globe';
      case 'Career':
        return 'briefcase';
      case 'Education':
        return 'book-open';
      case 'E-commerce':
        return 'shopping-cart';
      case 'Design':
        return 'pen-tool';
      case 'Professional Writing':
        return 'file-text';
      case 'Lifestyle':
        return 'heart';
      case 'Travel':
        return 'map';
      case 'Writing':
        return 'edit-3';
      case 'Professional':
        return 'briefcase';
      default:
        return 'grid';
    }
  }

  static List<String> getAllCategories() {
    List<String> all = [];
    categoryGroups.forEach((group, items) {
      all.addAll(items);
    });
    return all;
  }
}

