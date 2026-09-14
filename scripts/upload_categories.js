const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// The data to upload
const categoriesData = [
  {
    name: 'Programming & Development',
    iconName: 'code',
    subcategories: ['Flutter', 'React', 'React Native', 'Next.js', 'Node.js', 'Python', 'Java', 'JavaScript', 'TypeScript', 'C++', 'C#', 'SQL', 'MongoDB', 'Firebase', 'API Development', 'Bug Fixing', 'Code Review', 'System Design', 'DevOps', 'Git & GitHub']
  },
  {
    name: 'AI & Prompt Engineering',
    iconName: 'bot',
    subcategories: ['ChatGPT', 'Gemini', 'Claude', 'DeepSeek', 'Perplexity', 'Cursor AI', 'GitHub Copilot', 'Prompt Engineering']
  },
  {
    name: 'Image Generation',
    iconName: 'image',
    subcategories: ['Midjourney', 'DALL·E', 'Flux AI', 'Leonardo AI', 'Stable Diffusion', 'Runway ML', 'Sora Video Prompts', 'Image Generation']
  },
  {
    name: 'Content Creation',
    iconName: 'pen-tool',
    subcategories: ['YouTube Scripts', 'YouTube Titles', 'YouTube Descriptions', 'Instagram Captions', 'Instagram Reels', 'TikTok Ideas', 'Facebook Posts', 'LinkedIn Posts', 'X (Twitter) Threads', 'Pinterest Pins', 'Podcast Scripts', 'Blog Writing', 'Newsletter Writing', 'Storytelling']
  },
  {
    name: 'Digital Marketing',
    iconName: 'trending-up',
    subcategories: ['SEO Articles', 'Google Ads', 'Facebook Ads', 'Instagram Ads', 'Email Marketing', 'Sales Funnels', 'Copywriting', 'Product Descriptions', 'Landing Pages', 'Marketing Strategy', 'Brand Positioning', 'Keyword Research']
  },
  {
    name: 'Business & Startup',
    iconName: 'briefcase',
    subcategories: ['Business Plans', 'Startup Ideas', 'Pitch Decks', 'Investor Pitch', 'SWOT Analysis', 'Market Research', 'Customer Persona', 'Business Emails', 'Business Proposal', 'Pricing Strategy']
  },
  {
    name: 'Freelancing',
    iconName: 'globe',
    subcategories: ['Upwork Proposals', 'Fiverr Gig Descriptions', 'Client Emails', 'Project Estimates', 'Invoice Messages', 'Portfolio Writing', 'Client Follow-ups']
  },
  {
    name: 'Career',
    iconName: 'briefcase',
    subcategories: ['Resume Writing', 'ATS Resume', 'Cover Letter', 'LinkedIn Profile', 'Interview Questions', 'HR Interview', 'Technical Interview', 'Salary Negotiation', 'Career Advice']
  },
  {
    name: 'Education',
    iconName: 'book-open',
    subcategories: ['Homework Help', 'Assignment Writing', 'Essay Writing', 'Research Paper', 'Quiz Generator', 'Study Notes', 'Flashcards', 'Exam Preparation', 'Lesson Plans']
  },
  {
    name: 'E-commerce',
    iconName: 'shopping-cart',
    subcategories: ['Amazon Listings', 'Shopify Store', 'Etsy Product Titles', 'Product Descriptions', 'Customer Support Replies', 'Review Responses', 'Product SEO']
  },
  {
    name: 'Design',
    iconName: 'pen-tool',
    subcategories: ['UI/UX Design', 'Logo Design', 'Brand Identity', 'Poster Design', 'Thumbnail Ideas', 'Interior Design', 'Architecture', 'Color Palette', 'Wireframes']
  },
  {
    name: 'Professional Writing',
    iconName: 'file-text',
    subcategories: ['Emails', 'Cold Emails', 'Follow-up Emails', 'Meeting Notes', 'Proposals', 'Contracts', 'Reports', 'Documentation']
  },
  {
    name: 'Lifestyle',
    iconName: 'heart',
    subcategories: ['Fitness Plans', 'Meal Plans', 'Yoga', 'Meditation', 'Habit Tracker', 'Productivity', 'Time Management', 'Goal Planning']
  },
  {
    name: 'Travel',
    iconName: 'map',
    subcategories: ['Trip Planner', 'Travel Itinerary', 'Budget Travel', 'Hotel Reviews', 'Packing Lists', 'Local Guides']
  },
  {
    name: 'Writing',
    iconName: 'edit-3',
    subcategories: ['Story Writing', 'Book Writing', 'Poetry', 'Screenplay', 'Novel Ideas', 'Character Development', 'Dialogue Writing']
  },
  {
    name: 'Professional',
    iconName: 'briefcase',
    subcategories: ['Legal Drafts', 'HR Documents', 'SOP Writing', 'Policies', 'Meeting Agendas', 'Project Documentation']
  }
];

async function uploadData() {
  const collectionRef = db.collection('categories');

  for (const category of categoriesData) {
    try {
      // Create a document with auto-generated ID or use the name as ID (slugified)
      const docRef = collectionRef.doc();
      
      await docRef.set({
        id: docRef.id,
        name: category.name,
        iconName: category.iconName,
        subcategories: category.subcategories,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`Successfully added: ${category.name}`);
    } catch (error) {
      console.error(`Error adding category ${category.name}: `, error);
    }
  }
  
  console.log("All data uploaded successfully!");
}

uploadData();
