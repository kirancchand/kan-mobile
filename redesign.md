Redesign the UI of this app with a clean, modern, premium look. Change only
the visual layer. Do not change any app logic, features, navigation, data
handling or APIs,i had applied seperate design for services dont apply this change to any of the services.

DESIGN SYSTEM

Colors
- Background: #F5F6F8
- Surface (cards, inputs): #FFFFFF
- Primary text: #0F172A
- Secondary text: #5B6475
- Accent (links, active states, highlights): #4F46E5
- Accent soft background (icon chips, tags): #EEF0FF
- Borders/dividers: #E5E7EB (1px)
- Hero/featured card: background #0F172A, text #FFFFFF,
  label text #A5B4FC
- Primary button on dark surfaces: background #A5B4FC, text #0F172A
- Primary button on light surfaces: background #4F46E5, text #FFFFFF

Typography
- Font: Inter only (weights 400, 500, 600)
- Screen title: 30px, weight 600
- Section heading: 20px, weight 600
- Body: 14-15px, weight 400
- Small labels: 12px, uppercase, letter-spacing 0.14em, accent color
- Secondary text: 13px, color #5B6475

Shape and spacing
- Use an 8px spacing scale (8, 16, 24, 32)
- Screen horizontal padding: 24px
- Corner radius: 16px for cards and buttons, fully round for avatars
- Soft shadows only: very light, low opacity (or none, relying on borders)
- Minimum touch target: 44px

Components
- Cards: white, 1px border, 16px radius, 14-16px padding
- Buttons: 44px high, 16px radius, weight 600, no default system styling
- Bottom navigation: white, top border, 4 items, active item in accent
  color with weight 600, inactive in secondary text color
- Icons: one outlined icon set only (Lucide or Phosphor). Never mix
  filled and outlined icons.
- Animations: subtle only, 200-300ms fades/slides, press feedback on buttons
- Loading: skeleton placeholders instead of spinners

PROCESS
1. Scan the project and list all screens and shared components.
2. Create one central theme file (colors, typography, spacing, radii)
   and use it everywhere. No hardcoded colors or font sizes in screens.
3. Redesign the HOME screen first, then stop and show me what changed.
4. After I approve, apply the same system to all remaining screens.
5. Make empty, loading and error states match the new design too.

RULES
- Keep all existing text and functionality.
- Don't add new libraries unless needed for the font or icons, and tell me
  which ones you add.
- Commit or summarize changes per screen so I can review and revert.
