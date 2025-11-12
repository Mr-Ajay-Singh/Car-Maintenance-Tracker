# Urine Tracker App - UI Design Documentation

## Design System & Theme

### Seed Colors (from themes.dart)
The app uses Material 3 design with 6 theme seed color options:
- **Purple Theme** (Primary): `#6750A4` / `Color(0xFF6750A4)`
- **Green Theme**: `#006C51` / `Color(0xFF006C51)`
- **Blue Theme**: `#0061A4` / `Color(0xFF0061A4)`
- **Red Theme**: `#B3261E` / `Color(0xFFB3261E)`
- **Teal Theme**: `#006874` / `Color(0xFF006874)`
- **Pink Theme**: `#FFC0CB` / `Color(0xFFFFC0CB)`

### Material 3 Generated Color Scheme (Purple Theme - Light Mode)
When using `ColorScheme.fromSeed(seedColor: Color(0xFF6750A4), brightness: Brightness.light)`, Material 3 generates:

**Primary Colors:**
- `primary`: #6750A4 (Main purple - buttons, active states, icons)
- `onPrimary`: #FFFFFF (Text/icons on primary color)
- `primaryContainer`: #E8DEF8 (Light purple - selected items, chips)
- `onPrimaryContainer`: #21005D (Text on primary container)

**Secondary Colors:**
- `secondary`: #625B71 (Supporting purple-gray)
- `onSecondary`: #FFFFFF
- `secondaryContainer`: #E8DEF8
- `onSecondaryContainer`: #1D192B

**Tertiary Colors:**
- `tertiary`: #7D5260 (Accent pink-purple)
- `onTertiary`: #FFFFFF
- `tertiaryContainer`: #FFD8E4
- `onTertiaryContainer`: #31111D

**Surface Colors:**
- `surface`: #FEF7FF (Main surface background)
- `onSurface`: #1D1B20 (Primary text)
- `surfaceVariant`: #E7E0EC (Alternative surface)
- `onSurfaceVariant`: #49454F (Secondary text)
- `surfaceContainer`: #F3EDF7 (Container backgrounds like bottom nav)
- `surfaceContainerHigh`: #EDE7F1
- `surfaceContainerHighest`: #E6E0E9
- `surfaceContainerLow`: #F9F3FC
- `surfaceContainerLowest`: #FFFFFF

**Background:**
- `background`: #FDFBFF (Screen background)
- `onBackground`: #1D1B20 (Text on background)

**Other Colors:**
- `error`: #BA1A1A
- `onError`: #FFFFFF
- `errorContainer`: #FFDAD6
- `onErrorContainer`: #410002
- `outline`: #79747E (Borders, dividers)
- `outlineVariant`: #CAC4D0 (Subtle borders)
- `scrim`: #000000 (Overlay shadows)
- `shadow`: #000000

**Inverse Colors:**
- `inverseSurface`: #322F35
- `onInverseSurface`: #F5EFF7
- `inversePrimary`: #D0BCFF

### Typography
- **Font Family**: PT Serif (Regular, Bold, Italic, Bold Italic)
- **Font Weights**: 300, 400, 500, 600, 700

### Design Principles
- Material 3 Design Language with `useMaterial3: true`
- Smooth animations (200ms duration)
- Rounded corners (16px border radius)
- Elevated surfaces with subtle shadows
- Support for Light and Dark modes
- ColorScheme.fromSeed() algorithm for consistent theming

---

## 1. Dashboard (Home Screen)

**AI Image Generation Prompt:**

Create a modern mobile app dashboard screen for a Urine Tracker application using Material 3 design.

**Exact Theme Colors** (from ColorScheme.fromSeed with seed #6750A4):
- Primary: #6750A4 (main purple for buttons/icons)
- Primary Container: #E8DEF8 (light purple for selected states)
- On Primary: #FFFFFF (white text on purple)
- Surface: #FEF7FF (main surface background)
- On Surface: #1D1B20 (primary text color)
- On Surface Variant: #49454F (secondary text/gray text)
- Surface Container: #F3EDF7 (card containers)
- Background: #FDFBFF (screen background)
- Outline: #79747E (dividers/borders)

**Layout**:
- App bar at top with:
  - Title "Dashboard" in PT Serif font (24px, bold) in color #1D1B20
  - Settings icon button on right in color #6750A4
  - Background: #FEF7FF
- Below app bar, main summary card with:
  - Background: #FFFFFF
  - Rounded corners (16px)
  - Subtle shadow (elevation 1)
  - Large centered number "8" in primary purple #6750A4 (48px, bold)
  - Subtitle "Today's Entries" below in #49454F (14px)
  - Small secondary stats: "Average: 6-8" and "Last entry: 2h ago" in #49454F (12px)
- Grid of 4 metric cards (2x2 layout), each card with:
  - Icons at top (water drop, clock, chart, calendar) in #6750A4
  - Metric number in #1D1B20 (24px, bold)
  - Label text below in #49454F (12px)
  - Background: #E8DEF8 (primary container)
  - 12px padding, 16px rounded corners
  - Subtle shadow elevation
- Quick actions section at bottom:
  - Horizontal row of 2 action buttons
  - "Add Entry" button: Background #6750A4, text #FFFFFF, elevated with shadow, rounded 16px, plus icon
  - "View History" button: Outlined style with border #6750A4, text #6750A4, background transparent, rounded 16px

**Style**: Clean, minimalist, medical app aesthetic with gentle colors, plenty of white space, PT Serif for headings, Material 3 elevated surfaces

---

## 2. Graph/Analytics Screen

**AI Image Generation Prompt:**

Design a mobile analytics screen for a Urine Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Surface Container: #F3EDF7 | Background: #FDFBFF | Outline: #79747E

**Layout**:
- App bar with:
  - Title "Analytics" in PT Serif font (24px, bold) in #1D1B20
  - Back button on left in #6750A4
  - Background: #FEF7FF
- Time period selector below app bar:
  - Horizontal pill-shaped segmented button group
  - Options: "Day", "Week", "Month", "Year"
  - Active selection: Background #6750A4, text #FFFFFF
  - Inactive: Background #F3EDF7, text #1D1B20
  - 8px between buttons, 12px rounded corners
- Main chart area (40% of screen height):
  - Line chart or bar chart using fl_chart library styling
  - X-axis: Time labels in #49454F (12px)
  - Y-axis: Frequency count (0-12) in #49454F (12px)
  - Chart line/bars: Gradient from #6750A4 to #E8DEF8
  - Grid lines in #CAC4D0 (outline variant)
  - Data points: Small circles in #6750A4
  - Smooth curved lines for line chart
  - Background: #FFFFFF with border #CAC4D0
  - 16px rounded corners
- Statistics cards below chart (3 cards in horizontal scroll):
  - Each card background: #E8DEF8 (primary container)
  - Card 1: "Average Frequency" with large number in #6750A4 and trend arrow
  - Card 2: "Peak Time" with clock icon in #6750A4 and time in #1D1B20
  - Card 3: "Hydration Score" with water drop icon in #6750A4 and percentage
  - 12px padding, 16px rounded corners per card
- Bottom section with insights:
  - "Insights" heading (18px, bold) in #1D1B20
  - 2-3 insight cards with:
    - White background (#FFFFFF)
    - Left border (4px) in #6750A4
    - Icon in #6750A4, text in #1D1B20
    - "Learn more" link in #6750A4
    - 16px padding, 12px rounded corners

**Style**: Data-focused, clean fl_chart graphs, professional medical analytics aesthetic, Material 3 design

---

## 3. Schedule Screen

**AI Image Generation Prompt:**

Create a mobile schedule screen for a Urine Tracker app with Material 3 design and purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Background: #FDFBFF | Outline: #79747E | Error Container: #FFDAD6

**Layout**:
- App bar with:
  - "Schedule" title in PT Serif font (24px, bold) in #1D1B20
  - Menu icon on right in #6750A4
  - Background: #FEF7FF
- Date selector strip below app bar:
  - Horizontal scrollable row of date chips
  - Each chip shows day name and date number
  - Today's date: Background #6750A4, text #FFFFFF, 32px height, 16px rounded
  - Other dates: Background #F3EDF7, text #1D1B20, 32px height, 16px rounded
  - 8px spacing between chips
  - Smooth horizontal scroll
- Timeline view (vertical list with screen background #FDFBFF):
  - Left side: Time labels (8:00 AM, 10:00 AM, etc.) in #49454F (12px)
  - Right side: Schedule entry cards
  - Each entry card contains:
    - Time in bold (16px) in #1D1B20 with AM/PM
    - Status indicator dot:
      - Green #2E7D32 for completed
      - Orange #F57C00 for upcoming
      - Gray #79747E for missed
    - "Bathroom break" text (14px) in #1D1B20
    - Optional notes in #49454F (12px, italic)
    - Right arrow icon in #49454F
    - Card backgrounds:
      - Completed: #E8DEF8 (primary container)
      - Upcoming: #FFFFFF
      - Missed: #FFDAD6 (error container)
    - 16px padding, 12px rounded corners per card
  - Dotted vertical line in #CAC4D0 connecting timeline entries
- Floating action button at bottom right:
  - Circular button (56px diameter)
  - Background: #6750A4 (primary)
  - Plus icon in #FFFFFF
  - Elevated with shadow (elevation 3)
  - 16px margin from edges

**Style**: Calendar-like, organized, time-based layout, Material 3 design, clean and medical professional look

---

## 4. Calendar View Screen

**AI Image Generation Prompt:**

Design a mobile calendar view screen for a Urine Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Background: #FDFBFF | Outline Variant: #CAC4D0

**Layout**:
- App bar with:
  - "Calendar" title in PT Serif font (24px, bold) in #1D1B20
  - Month/year selector dropdown in center (clickable, shows current month/year)
  - Today button on right in #6750A4
  - Background: #FEF7FF
- Month view calendar (background #FDFBFF):
  - 7-column grid (Sun-Sat)
  - Day name headers in #49454F (12px, uppercase)
  - Each date cell (40px square):
    - Date number at top (14px) in #1D1B20
    - Small colored dots below number (4px diameter each, max 5 dots):
      - 1-3 entries: Light purple #E8DEF8
      - 4-6 entries: Medium purple #9A82DB
      - 7+ entries: Dark purple #6750A4
    - Today's date: Circular border (2px) in #6750A4
    - Selected date: Solid background #6750A4, text #FFFFFF
    - Previous/next month dates: Text in #79747E (faded)
    - Normal dates: Text in #1D1B20
  - Grid cell dividers in #CAC4D0 (very subtle)
  - 8px padding per cell
- Legend strip below calendar (background #F3EDF7):
  - Horizontal row with color-coded dots and labels:
    - "Low (1-3)" with #E8DEF8 dot
    - "Normal (4-6)" with #9A82DB dot
    - "High (7+)" with #6750A4 dot
  - Text in #49454F (12px)
  - 12px padding, 8px rounded corners
- Selected date detail card at bottom:
  - Background: #FFFFFF
  - Selected date in large text (20px, bold) in #1D1B20
  - List of entries for that day:
    - Each entry: Timestamp in #49454F, water drop icon in #6750A4
    - Brief detail text in #1D1B20 (14px)
    - 12px spacing between entries
  - "View Details" button: Background #6750A4, text #FFFFFF, 40px height, 16px rounded
  - Card: 16px padding, 16px rounded corners, elevated shadow
- Month navigation arrows on left/right of calendar (icons in #6750A4)

**Style**: Calendar grid layout, clean and organized, medical tracking aesthetic, Material 3 design, clear visual hierarchy

---

## 5. Add Entry Bottom Sheet

**AI Image Generation Prompt:**

Create a mobile bottom sheet modal for adding a urine tracking entry in a Material 3 design app with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Surface Container Lowest: #FFFFFF | Outline: #79747E | Outline Variant: #CAC4D0

**Layout**:
- Bottom sheet slides up from bottom, covering 70% of screen
- Rounded top corners (28px)
- Handle bar at very top (centered, 32px wide, 4px height) in #CAC4D0
- Background: #FFFFFF with elevated shadow (elevation 4)

**Content inside bottom sheet**:
- Header section:
  - "Add New Entry" title (22px, bold, PT Serif font) in #1D1B20
  - Close button (X icon) on top right in #49454F
  - Small subtitle "Record your bathroom visit" (14px) in #49454F
  - 16px padding

- Form fields (vertically stacked with 16px spacing, 16px horizontal padding):

  1. **Date & Time Picker**:
     - Two side-by-side fields (48% width each with 4% gap)
     - Left: Date field with calendar icon in #6750A4, text "Today" in #1D1B20
     - Right: Time field with clock icon in #6750A4, text showing time in #1D1B20
     - Background: #E8DEF8 (primary container)
     - 12px padding, 12px rounded corners
     - 48px height per field

  2. **Volume Slider**:
     - Label "Volume" (14px, bold) in #1D1B20 with small info icon in #49454F
     - Horizontal slider:
       - Active track: #6750A4
       - Inactive track: #E8DEF8
       - Thumb: Circle in #6750A4 (20px diameter)
     - Range: 0 - 500ml with tick markers every 100ml in #CAC4D0
     - Current value displayed above thumb in bold (18px) in #6750A4
     - "ml" unit label in #49454F

  3. **Color Indicator**:
     - Label "Urine Color" (14px, bold) in #1D1B20
     - Horizontal row of 6 color circles (32px each, 8px spacing):
       - Colors: #F9F9E0 (pale yellow) → #F5E87F → #F4C842 → #E8A428 → #CC8A1E → #A36B14 (dark amber)
     - Selected circle: 3px border ring in #6750A4
     - Unselected: 1px border in #CAC4D0
     - Small labels below (10px) in #49454F: "Clear", "Pale", "Normal", "Dark", "V.Dark", "Amber"

  4. **Notes Field** (optional):
     - Multi-line text input (4 rows)
     - Placeholder: "Add any notes... (optional)" in #79747E
     - Border: 1px in #CAC4D0 (outline variant)
     - Background: #FDFBFF
     - Text color: #1D1B20
     - 12px padding, 12px rounded corners
     - 96px height

  5. **Symptoms Chips** (optional):
     - Label "Any symptoms?" (14px, bold) in #1D1B20
     - Horizontal scrollable row of selectable chips
     - Chip options: "Urgency", "Pain", "Burning", "Difficulty", "Other"
     - Selected chips: Background #6750A4, text #FFFFFF
     - Unselected chips: Background #F3EDF7, text #1D1B20, border #CAC4D0 (1px)
     - 32px height, 16px horizontal padding, 16px rounded (pill shape)
     - 8px spacing between chips

- Action buttons at bottom (with 16px padding):
  - Two buttons side by side (48% width each with 4% gap)
  - "Cancel" button (text button):
    - Text in #6750A4
    - No background
    - 48px height
  - "Save Entry" button (filled button):
    - Background: #6750A4
    - Text: #FFFFFF
    - Elevated shadow (elevation 2)
    - 48px height, 16px rounded corners

**Style**: Modal bottom sheet, form-based, easy input fields, Material 3 design, purple theme, medical app aesthetic, clear visual hierarchy, touch-friendly 48dp minimum touch targets

---

## 6. Bottom Navigation Bar

**AI Image Generation Prompt:**

Design a bottom navigation bar for a mobile Urine Tracker app using Material 3 design with purple theme (matching MainPage.dart implementation).

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 (with 50% opacity) | On Primary: #FFFFFF
- Surface Container: #F3EDF7 | On Surface Variant: #49454F
- Scrim: #000000 (with 10% opacity for shadow)

**Layout**:
- Fixed bar at bottom of screen
- Background: #F3EDF7 (surface container)
- Total height: 80px (includes safe area padding)
- Subtle shadow above bar: 0px -2px 12px rgba(0,0,0,0.1)
- 16px horizontal padding, 12px vertical padding
- Safe area insets respected

- 4 navigation items evenly spaced in horizontal row:

1. **Home** (selected state):
   - Home icon (rounded style) in #6750A4 (primary)
   - Label "Home" below icon in #6750A4
   - Background container: #E8DEF8 with 50% opacity, 16px rounded corners
   - Icon size: 26px
   - Label: 12px, font weight 600 (semibold)
   - Container padding: 16px horizontal, 8px vertical

2. **Pets** (unselected):
   - Paw/pet icon (rounded style) in #49454F (on surface variant)
   - Label "Pets" in #49454F
   - No background container
   - Icon size: 24px
   - Label: 12px, font weight 500 (medium)
   - Padding: 16px horizontal, 8px vertical

3. **Features** (unselected):
   - Featured play list icon (rounded style) in #49454F
   - Label "Features" in #49454F
   - No background container
   - Icon size: 24px
   - Label: 12px, font weight 500
   - Padding: 16px horizontal, 8px vertical

4. **Settings** (unselected):
   - Person icon (rounded style) in #49454F
   - Label "Settings" in #49454F
   - No background container
   - Icon size: 24px
   - Label: 12px, font weight 500
   - Padding: 16px horizontal, 8px vertical

**Interaction States**:
- Selected item: Larger icon (26px vs 24px), background container with primary container color
- Selected item: Bold label (weight 600 vs 500)
- Smooth 200ms animation between states (AnimatedContainer)
- Ripple effect on tap with InkWell (16px border radius)
- 4px spacing between icon and label

**Style**: Modern Material 3 bottom navigation, purple accent with 50% opacity container, clear active state, touch-friendly 48dp minimum touch targets, professional medical app look

---

## Additional UI Components

### 7. Empty State Screens

**AI Image Generation Prompt:**

Design an empty state screen for a Urine Tracker app when no data exists yet, using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | On Primary: #FFFFFF
- Background: #FDFBFF | On Surface: #1D1B20 | On Surface Variant: #49454F

**Layout**:
- Full screen with background #FDFBFF
- Centered content vertically and horizontally
- Large illustration or icon at top (128px × 128px):
  - Simple line art of water drop or clipboard with checkmark
  - Icon color: #6750A4 (primary)
  - Stroke width: 2px
- Heading below illustration (24px vertical spacing):
  - Text: "No Entries Yet"
  - Font: PT Serif, 24px, bold (weight 700)
  - Color: #1D1B20 (on surface)
- Subtext below heading (16px vertical spacing):
  - Text: "Start tracking your bathroom visits to see insights and patterns"
  - Font: Regular, 14px, weight 400
  - Color: #49454F (on surface variant)
  - Center-aligned, max width 280px
  - Line height: 1.5
- Primary action button (32px vertical spacing from subtext):
  - Text: "Add First Entry"
  - Background: #6750A4 (primary)
  - Text color: #FFFFFF (on primary)
  - Height: 48px, horizontal padding: 32px
  - Border radius: 24px (fully rounded pill shape)
  - Elevated shadow (elevation 2)
- Optional "Learn How" text link below button (16px vertical spacing):
  - Text color: #6750A4 (primary)
  - Font: 14px, weight 500
  - Underline on hover

**Style**: Minimal, encouraging, clean empty state, Material 3 design, centered layout

---

### 8. Settings Page Components

**AI Image Generation Prompt:**

Create a settings screen for a Urine Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Background: #FDFBFF | Outline Variant: #CAC4D0 | Error: #BA1A1A

**Layout**:
- App bar with:
  - "Settings" title (24px, bold, PT Serif) in #1D1B20
  - Back button on left in #6750A4
  - Background: #FEF7FF
- Scrollable list of setting groups (background #FDFBFF):

1. **Appearance Section**:
   - Section header "Appearance" (16px, weight 600) in #6750A4, 16px top/bottom padding
   - Setting items:
     - "Theme": Icon in #6750A4 (24px), label "Theme" in #1D1B20 (16px), value "Purple" in #49454F, chevron right in #49454F
     - "Dark Mode": Icon in #6750A4, label in #1D1B20, toggle switch (thumb #FFFFFF, active track #6750A4, inactive track #E8DEF8)
     - "Language": Icon in #6750A4, label in #1D1B20, value "English" in #49454F, chevron in #49454F

2. **Notifications Section**:
   - Section header "Notifications" (16px, weight 600) in #6750A4, 16px top/bottom padding
   - Setting items:
     - "Reminders": Icon in #6750A4, label in #1D1B20, toggle switch
     - "Daily Reports": Icon in #6750A4, label in #1D1B20, toggle switch
     - "Reminder Time": Icon in #6750A4, label in #1D1B20, time "9:00 AM" in #49454F, chevron in #49454F

3. **Data & Privacy Section**:
   - Section header "Data & Privacy" (16px, weight 600) in #6750A4, 16px top/bottom padding
   - Setting items:
     - "Export Data": Download icon in #6750A4, label in #1D1B20, chevron in #49454F
     - "Clear History": Trash icon in #BA1A1A (error color), label in #BA1A1A, chevron in #49454F
     - "Privacy Policy": Link icon in #6750A4, label in #1D1B20, external link icon in #49454F

4. **Premium Section** (if applicable):
   - Banner card with:
     - Gradient background: #6750A4 to #8B7ABC
     - "Upgrade to Premium" heading in #FFFFFF (20px, bold, PT Serif)
     - Feature list with checkmark icons in #FFFFFF
     - "Unlock Features" button: Background #FFFFFF, text #6750A4, 48px height, 16px rounded
     - Card: 16px padding, 16px rounded corners, elevated shadow

Each standard setting item:
- Layout: Horizontal row with space between
- Left side: Icon (24px) + Label (16px) with 16px spacing
- Right side: Value/Toggle/Chevron
- Height: 56px (minimum touch target)
- Horizontal padding: 16px
- Background: #FFFFFF (surface container lowest)
- Divider between items: 1px in #CAC4D0 (outline variant)
- Ripple effect on tap (except for items with toggles)

**Style**: Clean, organized, hierarchical sections, Material 3 design, purple accents, standard settings UI patterns matching SettingsPage.dart

---

## Color Usage Guidelines

### Primary Actions (Material 3 Generated Colors)
- Filled buttons, FABs: `primary` #6750A4 with `onPrimary` #FFFFFF text
- Outlined buttons: Border `primary` #6750A4 with `primary` #6750A4 text
- Text buttons: `primary` #6750A4 text only
- Active/Selected states: `primary` #6750A4
- Selected containers: `primaryContainer` #E8DEF8 with `onPrimaryContainer` #21005D text

### Backgrounds (Light Mode)
- Screen background: `background` #FDFBFF
- Main surface: `surface` #FEF7FF
- Surface containers: `surfaceContainer` #F3EDF7
- Surface container high: `surfaceContainerHigh` #EDE7F1
- Surface container low: `surfaceContainerLow` #F9F3FC
- Surface container lowest (cards): `surfaceContainerLowest` #FFFFFF
- Alternative surface: `surfaceVariant` #E7E0EC

### Text Colors (Light Mode)
- Primary text: `onSurface` #1D1B20
- Secondary text: `onSurfaceVariant` #49454F
- Disabled text: `outline` #79747E (40% opacity)
- Text on primary: `onPrimary` #FFFFFF
- Text on containers: `onPrimaryContainer` #21005D

### Borders & Dividers
- Default borders/dividers: `outline` #79747E
- Subtle borders: `outlineVariant` #CAC4D0
- Shadow/scrim: `scrim` #000000 (with opacity)

### Status Colors (Custom - Not from ColorScheme)
- Success/Completed: #2E7D32 (Green)
- Warning/Upcoming: #F57C00 (Orange)
- Error/Missed: `error` #BA1A1A (Red from Material 3)
- Error container: `errorContainer` #FFDAD6
- Info: #1976D2 (Blue)

### Inverse Colors (for special surfaces)
- Inverse surface: `inverseSurface` #322F35
- On inverse surface: `onInverseSurface` #F5EFF7
- Inverse primary: `inversePrimary` #D0BCFF

---

## Animation & Interaction Guidelines

- **Navigation transitions**: 300ms ease-in-out
- **Component state changes**: 200ms ease
- **Bottom sheet slide**: 300ms cubic-bezier
- **Button press**: 100ms scale + ripple effect
- **List item interactions**: Ripple effect with 200ms fade
- **Chart animations**: 500ms ease-out on load
- **Loading states**: Shimmer effect in light purple

---

## Spacing System
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- XXL: 48px

## Elevation Shadows
- Level 1 (cards): 0px 1px 2px rgba(0,0,0,0.1)
- Level 2 (raised buttons): 0px 2px 4px rgba(0,0,0,0.15)
- Level 3 (modals): 0px 4px 8px rgba(0,0,0,0.2)
- Level 4 (bottom sheets): 0px 8px 16px rgba(0,0,0,0.25)

---

## Notes for AI Image Generation

When generating UI images from these prompts:
1. Use the exact color codes provided (#6750A4 for primary purple)
2. Maintain Material 3 design language with rounded corners and elevated surfaces
3. Keep text readable with proper contrast ratios (WCAG AA standard)
4. Show realistic data and content (avoid Lorem Ipsum where possible)
5. Include proper spacing and padding as specified
6. Display the UI in a mobile phone frame (e.g., iPhone or Android device)
7. Use the PT Serif font for headings and titles
8. Show subtle shadows for elevation
9. Include interactive states where relevant (hover, pressed, disabled)
10. Maintain consistency across all screens with the design system

---

*Document created for Urine Tracker App - Version 1.0*
*Last updated: 2025-10-22*
