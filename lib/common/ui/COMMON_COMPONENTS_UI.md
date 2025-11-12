# Common Components - UI Design Documentation

**Reference**: See `/lib/ui/UI.md` for complete design system, colors, and typography.

---

## Navigation Components

### 1. Bottom Navigation Bar

**AI Image Generation Prompt:**

Design a bottom navigation bar for a mobile Psoriasis Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 (50% opacity) | On Primary: #FFFFFF
- Surface Container: #F3EDF7 | On Surface Variant: #49454F

**Layout**:
- Fixed bar at bottom
- Background: #F3EDF7 (surface container)
- Height: 80px (includes safe area)
- Shadow above: 0px -2px 12px rgba(0,0,0,0.1)
- 16px horizontal padding, 12px vertical padding

- 5 navigation items evenly spaced:

  1. **Dashboard** (selected):
     - Home icon (26px) in #6750A4
     - Label "Dashboard" (12px, weight 600) in #6750A4
     - Background container: #E8DEF8 with 50% opacity, 16px rounded
     - 16px horizontal, 8px vertical padding

  2. **Symptoms** (unselected):
     - Activity/pulse icon (24px) in #49454F
     - Label "Symptoms" (12px, weight 500) in #49454F
     - No background
     - 16px horizontal, 8px vertical padding

  3. **Triggers** (unselected):
     - Warning/alert icon (24px) in #49454F
     - Label "Triggers" (12px, weight 500) in #49454F

  4. **Treatments** (unselected):
     - Medical/pill icon (24px) in #49454F
     - Label "Treatments" (12px, weight 500) in #49454F

  5. **Photos** (unselected):
     - Camera icon (24px) in #49454F
     - Label "Photos" (12px, weight 500) in #49454F

- Interaction: 200ms AnimatedContainer transition
- Ripple effect on tap (16px border radius)
- 4px spacing between icon and label

**Style**: Material 3 bottom nav, purple accent, selected container background, touch-friendly

---

### 2. App Bar Variants

**Standard App Bar**:
- Height: 56px
- Background: #FEF7FF (surface)
- Title: PT Serif font, 20-24px, bold, #1D1B20
- Icons: 24px, #6750A4
- Leading: Back arrow or menu icon
- Actions: 1-3 action icons (filter, search, more)
- Elevation: 0 (flat) with subtle bottom border #CAC4D0 (1px)

**Large App Bar** (with scroll collapse):
- Initial height: 120px
- Collapses to: 56px on scroll
- Background: #FEF7FF
- Large title: 32px, bold, PT Serif, #1D1B20
- Subtitle (optional): 14px, #49454F
- Smooth collapse animation (300ms)

---

## Dialog Components

### 3. Confirmation Dialog

**AI Image Generation Prompt:**

Create a confirmation dialog for delete/discard actions in a Psoriasis Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Error: #BA1A1A | On Primary: #FFFFFF
- Surface: #FFFFFF | On Surface: #1D1B20

**Layout**:
- Modal dialog (280px width, auto height)
- Background: #FFFFFF
- Rounded corners (28px)
- Elevated shadow (level 4)

**Content**:
- Icon at top (center):
  - Warning/alert icon (48px) in #BA1A1A (for delete actions)
  - Info icon (48px) in #6750A4 (for other confirmations)
  - 16px top padding

- Title:
  - "Delete Entry?" or "Discard Changes?" (20px, bold, PT Serif) in #1D1B20
  - Center-aligned
  - 16px top padding

- Message:
  - "This action cannot be undone." (14px) in #49454F
  - Center-aligned
  - 12px top padding
  - Max width: 240px

- Action buttons (horizontal row, bottom):
  - Two buttons:
    - "Cancel" - text button, #6750A4 text
    - "Delete" or "Discard" - filled button, background #BA1A1A (error), text #FFFFFF
  - 48px height for filled button
  - 16px rounded corners
  - 16px padding
  - Equal width buttons with 8px gap

**Style**: Material 3 dialog, clear warning for destructive actions

---

### 4. Info Dialog

**AI Image Generation Prompt:**

Design an information dialog showing detailed info or help text in a Psoriasis Tracker app.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8
- Surface: #FFFFFF | On Surface: #1D1B20

**Layout**:
- Modal dialog (90% screen width, max 360px, auto height max 70% screen)
- Background: #FFFFFF
- Rounded corners (20px)
- Elevated shadow (level 3)

**Content**:
- Header (optional):
  - Icon (32px) in #6750A4
  - Title (18px, bold, PT Serif) in #1D1B20
  - Close button (X) top right in #49454F
  - Background: #E8DEF8 (primary container)
  - 16px padding

- Body:
  - Scrollable content area
  - Text (14px, line height 1.5) in #1D1B20
  - Bullet points or numbered lists if needed
  - Links in #6750A4
  - Images or icons if applicable
  - 20px padding

- Footer (optional):
  - "Got it" or "Close" button
  - Background: #6750A4, text #FFFFFF
  - 48px height, 16px rounded
  - Full width with 16px margin

**Style**: Informational, scrollable content, Material 3 dialog

---

## Picker Components

### 5. Date Picker Dialog

**AI Image Generation Prompt:**

Create a date picker dialog for a Psoriasis Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8
- Surface: #FFFFFF | On Surface: #1D1B20

**Layout**:
- Modal dialog (340px width, auto height)
- Background: #FFFFFF
- Rounded corners (28px)
- Elevated shadow (level 4)

**Content**:
- Header:
  - Selected date display: "Oct 25, 2025" (24px, bold) in #1D1B20
  - Day of week: "Wednesday" (16px) in #49454F
  - Background: #E8DEF8 (primary container)
  - 20px padding

- Calendar view:
  - Month/Year header with nav arrows
    - "October 2025" (16px, bold) in #1D1B20
    - Left/right arrows in #6750A4
  - Day name headers: S M T W T F S (12px, bold) in #49454F
  - Date grid (7×6 max):
    - Each cell 40px × 40px
    - Today's date: Border circle (2px) in #6750A4
    - Selected date: Filled circle background #6750A4, text #FFFFFF
    - Other dates: Text #1D1B20
    - Previous/next month: Text #79747E (faded)
    - Disabled dates: Text #CAC4D0
    - Hover: Light background #E8DEF8
  - 12px padding

- Action buttons (bottom):
  - "Cancel" (text button, #6750A4) and "OK" (text button, #6750A4)
  - Right-aligned, 48px height
  - 16px padding

**Style**: Material 3 date picker, calendar grid, purple theme

---

### 6. Time Picker Dialog

**AI Image Generation Prompt:**

Design a time picker dialog for a Psoriasis Tracker app using Material 3 design.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8
- Surface: #FFFFFF | On Surface: #1D1B20

**Layout**:
- Modal dialog (300px width, auto height)
- Background: #FFFFFF
- Rounded corners (28px)

**Content**:
- Header:
  - Selected time: "10:30 AM" (32px, bold, tabular nums) in #1D1B20
  - Background: #E8DEF8
  - 20px padding

- Time selection mode toggle:
  - Two options: "Clock" and "Input"
  - Selected: Background #6750A4, text #FFFFFF
  - 28px height, 16px rounded (pill shape)

- Clock view (if Clock mode):
  - Circular clock face (240px diameter)
  - Center dot in #6750A4 (8px)
  - Hour numbers around circle (12, 1, 2...11) in #1D1B20
  - Selected hour: Circle background #6750A4, text #FFFFFF (32px diameter)
  - Clock hand: Line from center to selected hour in #6750A4 (3px width)
  - Minute mode after hour selected (00, 05, 10...55)
  - Background: #F3EDF7 (light surface)

- Input view (if Input mode):
  - Two input fields side-by-side:
    - Hour field (00-12)
    - Minute field (00-59)
  - Colon separator ":"
  - AM/PM toggle buttons
  - Each field: 60px width, 56px height
  - Active field: Border #6750A4 (2px)
  - Background: #F3EDF7

- Action buttons:
  - "Cancel" and "OK" (right-aligned)
  - 16px padding

**Style**: Material 3 time picker, clock interface, purple theme

---

## Input Components

### 7. Severity Slider

**AI Image Generation Prompt:**

Create a severity rating slider component for a Psoriasis Tracker app.

**Exact Theme Colors**:
- Gradient: Green #4CAF50 → Amber #FFC107 → Red #F44336

**Layout**:
- Full width slider
- Height: 48px (touch target)
- Active track: Gradient from green (left) to red (right)
- Inactive track: #E0E0E0
- Track height: 6px, rounded ends

- Thumb:
  - Circle (24px diameter)
  - Color matches position on gradient
  - White border (3px)
  - Elevated shadow

- Value display above thumb:
  - Large number (28px, bold) in current gradient color
  - Background: #FFFFFF with shadow
  - 8px padding, 8px rounded
  - 8px above thumb

- Tick marks below track:
  - Small dots at each integer (0-10)
  - Active ticks (up to current value): gradient color
  - Inactive ticks: #E0E0E0
  - 4px diameter dots

- Descriptors below ticks (every 2-3 units):
  - "Minimal" (0-2) in #4CAF50
  - "Mild" (3-4) in #8BC34A
  - "Moderate" (5-6) in #FFC107
  - "Severe" (7-8) in #FF9800
  - "Very Severe" (9-10) in #F44336
  - 10px font size

**Style**: Color-coded severity scale, gradient track, interactive thumb

---

### 8. Multi-Select Chips

**AI Image Generation Prompt:**

Design multi-select chip components for filtering and selection in a Psoriasis Tracker app.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8
- Surface: #F3EDF7 | On Surface: #1D1B20

**Variants**:

**Filter Chips** (multiple selection):
- Unselected:
  - Background: #F3EDF7 (surface)
  - Border: 1px #CAC4D0
  - Text: #1D1B20
  - Icon (if any): #79747E
- Selected:
  - Background: #6750A4 (primary)
  - No border
  - Text: #FFFFFF
  - Checkmark icon: #FFFFFF
- Size: 32px height, 12-16px horizontal padding
- Rounded: 16px (pill shape)
- 8px spacing between chips
- Ripple effect on tap

**Input Chips** (with remove):
- Background: #E8DEF8 (primary container)
- Text: #6750A4
- X icon: #6750A4 (tappable to remove)
- Size: 28px height, 12px horizontal padding
- Rounded: 14px (pill shape)
- Wrap to multiple lines if needed

**Suggestion Chips** (single tap action):
- Background: #F3EDF7
- Text: #1D1B20
- Icon: #6750A4
- Size: 32px height
- Rounded: 16px
- Hover: Light #E8DEF8 background

**Style**: Material 3 chips, multiple variants, purple theme

---

## Empty States

### 9. Empty State Component

**AI Image Generation Prompt:**

Create an empty state screen component for when no data exists in a Psoriasis Tracker app.

**Exact Theme Colors**:
- Primary: #6750A4 | On Primary: #FFFFFF
- Background: #FDFBFF | On Surface: #1D1B20

**Layout**:
- Centered content (vertically and horizontally)
- Background: #FDFBFF

- Illustration:
  - Large icon or simple line art (128px × 128px)
  - Icon color: #6750A4 (primary)
  - Examples: Empty box, clipboard, calendar, camera
  - Stroke width: 2px

- Heading (24px vertical spacing from illustration):
  - Text: "No Entries Yet" or "No Data Available"
  - Font: PT Serif, 24px, bold (weight 700)
  - Color: #1D1B20

- Subtext (16px vertical spacing from heading):
  - Description text explaining what to do
  - Font: Regular, 14px, weight 400
  - Color: #49454F
  - Center-aligned
  - Max width: 280px
  - Line height: 1.5

- Primary action button (32px vertical spacing):
  - Text: "Add First Entry" or relevant action
  - Background: #6750A4
  - Text color: #FFFFFF
  - Height: 48px, horizontal padding: 32px
  - Rounded: 24px (fully rounded pill)
  - Elevated shadow (elevation 2)

- Optional secondary action (16px vertical spacing):
  - Text link: "Learn How" or "Learn More"
  - Color: #6750A4
  - Font: 14px, weight 500
  - Underline on tap

**Style**: Encouraging, minimal, centered, Material 3 design

---

## Charts & Visualizations

### 10. Line Chart (fl_chart)

**Standard styling for trend charts**:
- Chart area background: #FDFBFF or #FFFFFF
- Grid lines: #CAC4D0 (very subtle, 1px)
- X-axis labels: #49454F, 12px
- Y-axis labels: #49454F, 12px
- Line colors:
  - Primary data: #6750A4 (2px width)
  - Secondary: #FF9800, #E91E63, #2196F3 (as needed)
- Data points: Small circles (6px diameter) in line color
- Smooth curves (cubicBezier)
- Touch tooltip: White background, elevation, line color for text
- Legend: Horizontal below chart, colored squares + labels

### 11. Bar Chart (fl_chart)

**Standard styling for comparison charts**:
- Bars: Width 24px, rounded top corners (6px)
- Bar colors: Severity gradient or category colors
- Spacing: 16px between bars
- Grid lines: Horizontal only, #CAC4D0
- X-axis labels: Rotated 45° if needed, #49454F, 12px
- Y-axis: 0 to max with 4-5 tick marks
- Hover/tap: Highlight bar with lighter shade
- Value labels: Above bars (optional), 12px, bold

---

*Common Components UI Documentation*
*Part of Psoriasis Tracker App v1.0*
