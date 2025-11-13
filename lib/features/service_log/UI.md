# Attack Log Feature - UI Design Documentation

## Feature Overview
The Attack Log feature allows users to record, track, and analyze their asthma attacks. Users can log attack severity, associated activities, possible triggers, and view analytics to understand patterns.

## Design System Reference
**Use colors from app theme only** - `Theme.of(context).colorScheme`

### Coral Color Scheme (from main.dart)
- **Primary**: #E2725B (Coral - buttons, active states)
- **On Primary**: #FFFFFF (White text on coral)
- **Surface**: #FFF8F6 (Main surface background)
- **Surface Container**: #FCEAE5 (Card containers)
- **On Surface**: #504442 (Primary text)
- **On Surface Variant**: #544C4A (Secondary text)
- **Background**: #FFF8F6 (Screen background)
- **Outline**: #9A8C8A (Borders/dividers)
- **Outline Variant**: #EADFE0 (Subtle borders)
- **Error**: #B71C1C

### Severity Colors (Status - Custom)
- **Mild (1)**: #4CAF50 (Green)
- **Moderate (2)**: #FFC107 (Amber)
- **Severe (3)**: #FF9800 (Orange)
- **Very Severe (4)**: #FF5722 (Deep Orange)
- **Critical (5)**: #B71C1C (Error Red)

---

## 1. Attack History Page (Main Screen)

**Screen Purpose:** Display list of all logged attacks with summary cards and quick actions.

**AI Image Generation Prompt:**

Create a mobile attack history screen for an Asthma Diary app using Material 3 design with coral theme.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442 | On Surface Variant: #544C4A
- Background: #FFF8F6 | Outline: #9A8C8A

**Layout**:
- App bar at top with:
  - Title "Attack History" in PT Serif font (24px, bold) in color #504442
  - Filter icon button on right in #E2725B
  - Background: #FFF8F6

- Summary card below app bar:
  - Background: #FCEAE5 (surface container)
  - "This Month" heading (16px, bold) in #504442
  - Three metrics in horizontal row:
    * "8 Attacks" with attack icon in #E2725B (18px)
    * "Avg Severity: 2.5" with star icon in #FF9800
    * "3 Days Since Last" with clock icon in #4CAF50
  - 16px padding, 16px rounded corners

- Tab selector below summary:
  - Two tabs: "List View" and "Calendar View"
  - Active tab: Background #E2725B, text #FFFFFF
  - Inactive tab: Background transparent, text #544C4A
  - Underline indicator in #E2725B

- **List View** (scrollable):
  - Each attack card contains:
    - Left colored border (4px) in severity color
    - Date/time at top (16px, bold) in #504442
    - Severity indicator with star icons and label
    - Activity text if present (14px) in #544C4A with activity icon
    - Trigger chip if linked (background #FCEAE5, text #504442, 24px height)
    - Notes preview (max 2 lines, 12px) in #544C4A, italic
    - Card background: #FFFFFF
    - 12px padding, 12px rounded corners
    - 8px spacing between cards
    - Tap to view details

- Floating action button at bottom right:
  - Circular button (56px diameter)
  - Background: #E2725B (primary)
  - Plus icon in #FFFFFF
  - Elevated with shadow
  - Opens "Add Attack" dialog

**Empty State** (when no attacks logged):
- Center icon: Alert/lungs icon in #E2725B (128px)
- Heading: "No Attacks Logged" (24px, bold, PT Serif) in #504442
- Subtext: "Track your asthma attacks to identify patterns and triggers" (14px) in #544C4A
- "Log First Attack" button: Background #E2725B, text #FFFFFF, 48px height

**Style**: Clean list layout, color-coded severity, Material 3 design, medical tracking aesthetic

---

## 2. Attack Calendar View

**Screen Purpose:** Visual calendar showing attack frequency and severity patterns.

**AI Image Generation Prompt:**

Design a calendar view for asthma attack tracking using Material 3 design with coral theme.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442 | Background: #FFF8F6

**Layout**:
- Same app bar and summary card as List View
- Tab selector showing "Calendar View" active

- Month calendar (background #FFF8F6):
  - Month/year header with navigation arrows in #E2725B
  - 7-column grid (Sun-Sat)
  - Day name headers in #544C4A (12px, uppercase)
  - Each date cell (48px square):
    - Date number at top (14px) in #504442
    - Attack indicators below:
      - Small colored circles for each attack (8px diameter)
      - Color matches severity (green to red)
      - Max 3 visible, "+2" if more
    - Today: Circular border (2px) in #E2725B
    - Selected: Background #E2725B, text #FFFFFF
    - Has attack: Bold date number
  - Grid dividers in #EADFE0

- Legend strip below calendar:
  - Background: #FCEAE5
  - Severity legend with colored dots:
    - "Mild" with #4CAF50 dot
    - "Moderate" with #FFC107 dot
    - "Severe" with #FF9800 dot
    - "Very Severe" with #FF5722 dot
    - "Critical" with #B71C1C dot
  - Text in #544C4A (12px)
  - 12px padding, 8px rounded corners

- Selected date detail card at bottom:
  - Expandable card showing attacks on selected date
  - Background: #FFFFFF
  - Date heading (18px, bold) in #504442
  - List of attacks with mini-cards
  - "Add Attack" button for selected date

**Style**: Calendar grid, color-coded severity, data visualization, Material 3

---

## 3. Add Attack Dialog (Bottom Sheet)

**Screen Purpose:** Form to log a new asthma attack with details.

**AI Image Generation Prompt:**

Create a mobile bottom sheet for logging an asthma attack in an Asthma Diary app using Material 3 design with coral theme.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442 | Outline: #9A8C8A

**Layout**:
- Bottom sheet slides up covering 85% of screen
- Rounded top corners (28px)
- Handle bar at top (32px wide, 4px height) in #EADFE0
- Background: #FFFFFF with elevated shadow

**Content**:
- Header section:
  - "Log Attack" title (22px, bold, PT Serif) in #504442
  - Close button (X icon) on right in #544C4A
  - 16px padding

- Form fields (vertically stacked with 16px spacing):

  1. **Date/Time Picker**:
     - Label "When did the attack occur?" (14px, bold) in #504442
     - Two fields side by side:
       - Date picker: Calendar icon, selected date displayed
       - Time picker: Clock icon, selected time displayed
     - Background: #FCEAE5
     - 12px padding, 12px rounded corners
     - 48px height each

  2. **Severity Selector** (REQUIRED):
     - Label "Severity Level" (14px, bold) in #504442 with asterisk
     - Horizontal row of 5 segmented buttons:
       - Each button shows number (1-5) and label below
       - "1-Mild", "2-Moderate", "3-Severe", "4-Very Severe", "5-Critical"
       - Selected: Background in severity color, text #FFFFFF
       - Unselected: Background #FCEAE5, text #504442
       - Icon: Star icons filled based on severity
       - 16px padding, 12px rounded corners
       - 64px height

  3. **Activity Field** (optional):
     - Label "What were you doing?" (14px, bold) in #504442
     - Text input field
     - Placeholder: "e.g., Running, Exercising, Sleeping" in #9A8C8A
     - Activity icon on left in #E2725B
     - Border: 1px in #EADFE0
     - Background: #FFF8F6
     - 48px height

  4. **Trigger Selector** (optional):
     - Label "Possible Trigger" (14px, bold) in #504442
     - Dropdown/picker showing saved triggers
     - "Select trigger..." placeholder in #9A8C8A
     - Link icon on left in #E2725B
     - Border: 1px in #EADFE0
     - Background: #FFF8F6
     - 48px height
     - "None" option available

  5. **Notes Field** (optional):
     - Label "Additional Notes" (14px, bold) in #504442
     - Multi-line text input (4 rows)
     - Placeholder: "Any additional details about the attack..." in #9A8C8A
     - Notes icon on top-left in #E2725B
     - Border: 1px in #EADFE0
     - Background: #FFF8F6
     - 96px height
     - Character counter "0/500" in #544C4A (bottom right)

- Action buttons at bottom:
  - Two buttons side by side (48% width each with 4% gap)
  - "Cancel" button:
    - Text in #E2725B
    - No background, text button style
    - 48px height
  - "Save Attack" button:
    - Background: #E2725B
    - Text: #FFFFFF
    - Disabled if severity not selected (gray)
    - 48px height, 16px rounded corners
    - Elevated shadow

**Validation**:
- Severity is required field
- Show error if user tries to save without severity
- All other fields optional

**Style**: Form-based modal, clear hierarchy, touch-friendly 48dp targets, Material 3

---

## 4. Attack Detail View (Bottom Sheet)

**Screen Purpose:** Display full details of a logged attack with edit/delete options.

**AI Image Generation Prompt:**

Design a detail view for a logged asthma attack using Material 3 design with coral theme.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442

**Layout**:
- Bottom sheet slides up covering 75% of screen
- Rounded top corners (28px)
- Handle bar at top in #EADFE0
- Background: #FFFFFF

**Content**:
- Header section:
  - Severity badge at top (large, with color)
  - Date/time in large text (20px, bold) in #504442
  - Edit icon button and Delete icon button on top right in #E2725B
  - 16px padding

- Details section (vertically stacked):

  1. **Severity Display**:
     - Large severity indicator with filled stars
     - Severity level text (e.g., "Severe Attack")
     - Color-coded background badge
     - 48px height, 16px rounded

  2. **Timing Information**:
     - Icon: Clock in #E2725B
     - "Attack Time" label in #544C4A (12px)
     - Full date/time in #504442 (16px)
     - "3 days ago" relative time in #544C4A (12px)

  3. **Activity Card** (if present):
     - Background: #FCEAE5
     - Icon: Activity icon in #E2725B
     - "Activity" label in #544C4A (12px)
     - Activity text in #504442 (16px)
     - 12px padding, 12px rounded corners

  4. **Trigger Card** (if linked):
     - Background: #FCEAE5
     - Trigger icon in trigger's color
     - "Possible Trigger" label in #544C4A (12px)
     - Trigger name in #504442 (16px)
     - "View Trigger Details" link in #E2725B (14px)
     - 12px padding, 12px rounded corners

  5. **Notes Card** (if present):
     - Background: #FFF8F6
     - Notes icon in #E2725B
     - "Notes" label in #544C4A (12px)
     - Notes text in #504442 (14px)
     - Border: 1px in #EADFE0
     - 12px padding, 12px rounded corners

  6. **Metadata**:
     - Small text at bottom
     - "Logged on [date]" in #544C4A (10px)
     - Last synced status if applicable

- Action buttons at bottom:
  - "Edit Attack" button: Background #E2725B, text #FFFFFF
  - "Delete Attack" button: Background transparent, text #B71C1C
  - 48px height, 16px spacing

**Delete Confirmation**:
- Show alert dialog:
  - "Delete Attack?" title
  - "This attack record will be permanently deleted" message
  - "Cancel" and "Delete" buttons

**Style**: Detail view, information cards, clear sections, Material 3

---

## 5. Attack Analytics Screen

**Screen Purpose:** Visual analytics and insights about attack patterns.

**AI Image Generation Prompt:**

Create an analytics dashboard for asthma attacks using Material 3 design with coral theme, featuring charts and statistics.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442 | Background: #FFF8F6

**Layout**:
- App bar:
  - Title "Attack Analytics" (24px, bold, PT Serif) in #504442
  - Date range selector on right in #E2725B
  - Background: #FFF8F6

- Time period selector:
  - Segmented buttons: "7D", "30D", "90D", "1Y", "All"
  - Active: Background #E2725B, text #FFFFFF
  - Inactive: Background #FCEAE5, text #504442
  - 8px between buttons

- Scrollable analytics cards:

  1. **Attack Frequency Card**:
     - Title "Attack Frequency" (18px, bold) in #504442
     - Large number showing total attacks
     - Line chart showing attacks over time
     - X-axis: Dates in #544C4A
     - Y-axis: Count in #544C4A
     - Line color: Gradient #E2725B to #FCEAE5
     - Data points as dots in #E2725B
     - Background: #FFFFFF
     - 16px padding, 16px rounded corners

  2. **Severity Distribution Card**:
     - Title "Severity Breakdown" (18px, bold) in #504442
     - Horizontal bar chart or pie chart
     - Each severity level with color:
       - Mild: #4CAF50
       - Moderate: #FFC107
       - Severe: #FF9800
       - Very Severe: #FF5722
       - Critical: #B71C1C
     - Percentage and count for each
     - Background: #FFFFFF
     - 16px padding, 16px rounded corners

  3. **Average Severity Card**:
     - Background: #FCEAE5
     - Large number showing avg severity (e.g., "2.8")
     - Star rating visualization
     - Trend indicator (↑/↓/→) with color
     - "Compared to previous period" subtext
     - 16px padding, 16px rounded corners

  4. **Time of Day Analysis Card**:
     - Title "When Attacks Occur" (18px, bold) in #504442
     - Bar chart with 4 bars:
       - Morning (6am-12pm)
       - Afternoon (12pm-6pm)
       - Evening (6pm-10pm)
       - Night (10pm-6am)
     - Color gradient #E2725B
     - Count labels on bars
     - Background: #FFFFFF
     - 16px padding, 16px rounded corners

  5. **Top Triggers Card**:
     - Title "Most Common Triggers" (18px, bold) in #504442
     - List of top 5 triggers with:
       - Trigger icon and name
       - Attack count badge
       - Percentage bar in #E2725B
     - "See all triggers" link in #E2725B
     - Background: #FFFFFF
     - 16px padding, 16px rounded corners

  6. **Days Since Last Attack Card**:
     - Background: Conditional color:
       - Green #4CAF50 if > 30 days
       - Yellow #FFC107 if 7-30 days
       - Red #B71C1C if < 7 days
     - Large number of days
     - "Days attack-free" text in #FFFFFF
     - Calendar icon in #FFFFFF
     - 16px padding, 16px rounded corners

  7. **Trend Analysis Card**:
     - Title "Overall Trend" (18px, bold) in #504442
     - Visual indicator:
       - ↑ "Attacks Increasing" in #B71C1C (concerning)
       - ↓ "Attacks Decreasing" in #4CAF50 (positive)
       - → "Attacks Stable" in #FF9800 (neutral)
     - Percentage change
     - Trend line visualization
     - Background: #FFFFFF
     - 16px padding, 16px rounded corners

- Export button at bottom:
  - "Export Report" button
  - Background: Outlined style
  - Border #E2725B, text #E2725B
  - Download icon
  - 48px height

**Style**: Data-focused, charts and graphs, insights, Material 3, professional medical analytics

---

## 6. Filter Dialog

**Screen Purpose:** Filter attack history by date range, severity, or trigger.

**AI Image Generation Prompt:**

Design a filter dialog for asthma attack history using Material 3 design with coral theme.

**Exact Theme Colors**:
- Primary: #E2725B | Surface Container: #FCEAE5 | On Primary: #FFFFFF
- Surface: #FFF8F6 | On Surface: #504442

**Layout**:
- Dialog modal (center of screen)
- Background: #FFFFFF
- Rounded corners (28px)
- Elevated shadow

**Content**:
- Header:
  - "Filter Attacks" title (20px, bold) in #504442
  - Close button (X) on right in #544C4A
  - 16px padding

- Filter options:

  1. **Date Range**:
     - Label "Date Range" (14px, bold) in #504442
     - Two date pickers side by side:
       - "From" date picker
       - "To" date picker
     - Background: #FCEAE5
     - 12px padding, 12px rounded corners

  2. **Severity Filter**:
     - Label "Severity" (14px, bold) in #504442
     - Multi-select checkboxes:
       - □ Mild (with green indicator)
       - □ Moderate (with amber indicator)
       - □ Severe (with orange indicator)
       - □ Very Severe (with deep orange indicator)
       - □ Critical (with red indicator)
     - Checkboxes use #E2725B when selected

  3. **Trigger Filter**:
     - Label "Trigger" (14px, bold) in #504442
     - Dropdown showing list of triggers
     - "Any trigger" option
     - Multi-select with chips

  4. **Activity Filter**:
     - Label "Has Activity" (14px, bold) in #504442
     - Toggle switch
     - Active: #E2725B, Inactive: #EADFE0

- Active filter count badge:
  - Shows "3 filters active" in #E2725B
  - Clear all button in #E2725B (text button)

- Action buttons:
  - "Reset" button: Text button in #544C4A
  - "Apply Filters" button: Filled button
    - Background: #E2725B
    - Text: #FFFFFF
    - 48px height, 16px rounded corners

**Style**: Filter dialog, multi-select options, Material 3, clear actions

---

## 7. Edit Attack Dialog

**Screen Purpose:** Edit existing attack details.

**Layout**:
- Same as "Add Attack Dialog" but:
  - Title: "Edit Attack" instead of "Log Attack"
  - All fields pre-filled with existing data
  - Save button text: "Update Attack"
  - Additional "Delete" text button at bottom in #B71C1C

**Pre-fill Behavior**:
- Load all existing attack details
- Date/time set to attack's dateTime
- Severity pre-selected
- Activity field populated if exists
- Trigger pre-selected if linked
- Notes populated if exists

**Style**: Same as Add Attack Dialog with pre-filled data

---

## 8. Quick Add Attack FAB Menu

**Screen Purpose:** Fast-access menu from FAB for common attack severities.

**Layout**:
- Speed dial from main FAB
- When tapped, expands upward showing 5 mini FABs:
  1. "Mild" mini FAB - Green #4CAF50 background
  2. "Moderate" mini FAB - Amber #FFC107 background
  3. "Severe" mini FAB - Orange #FF9800 background
  4. "Very Severe" mini FAB - Deep Orange #FF5722 background
  5. "Critical" mini FAB - Red #B71C1C background

- Each mini FAB:
  - 40px diameter
  - Number label (1-5) in white
  - Label text to the left in #504442
  - Tapping logs attack with that severity instantly
  - Shows timestamp dialog to confirm/adjust time

- Semi-transparent overlay behind FABs
- Tapping outside closes speed dial

**Quick Log Behavior**:
- Immediately creates attack with selected severity
- Uses current date/time
- Shows success snackbar: "Mild attack logged"
- Opens detail view to add more info (optional)

**Style**: Speed dial FAB, quick actions, one-tap logging

---

## Component Specifications

### Severity Indicator Component

**Visual Design**:
- Displays severity as stars, number, text, and color
- Variants:
  1. **Compact**: Small star icon + number (16px)
  2. **Standard**: Stars + text label (24px)
  3. **Large**: Filled stars + badge + text (48px)

**Color Mapping**:
- 1 (Mild): #4CAF50 - 1 filled star
- 2 (Moderate): #FFC107 - 2 filled stars
- 3 (Severe): #FF9800 - 3 filled stars
- 4 (Very Severe): #FF5722 - 4 filled stars
- 5 (Critical): #B71C1C - 5 filled stars

### Attack Card Component

**Layout**:
- White background #FFFFFF
- Left border (4px) in severity color
- 12px padding, 12px rounded corners
- Elevated shadow (elevation 1)

**Content Structure**:
- Top row: Date/time (bold) + Severity indicator
- Middle: Activity text with icon (if present)
- Trigger chip (if linked)
- Bottom: Notes preview (italic, 2 lines max)

**Interaction**:
- Tap opens detail view
- Long press shows context menu (Edit/Delete)
- Swipe actions: Edit (left), Delete (right)

### Empty State Component

**Layout**:
- Centered vertically and horizontally
- Icon: 128px in #E2725B
- Heading: 24px PT Serif bold in #504442
- Subtext: 14px in #544C4A
- CTA button: Filled button in #E2725B

---

## Navigation Flow

```
Attack History (Main)
├── Add Attack Dialog → Save → Back to History
├── Attack Detail → Edit Dialog → Save → Back to Detail
├── Attack Detail → Delete → Confirmation → Back to History
├── Calendar View → Select Date → Show Attacks
├── Filter Dialog → Apply → Filtered History
└── Analytics Screen → View Charts/Stats
```

---

## Data Handling

### Required Fields
- Date/Time (defaults to now)
- Severity (1-5, user must select)

### Optional Fields
- Activity (text input)
- Possible Trigger (link to trigger ID)
- Notes (multi-line text, max 500 chars)

### Validation Rules
- Severity must be between 1-5
- Date/time cannot be in future
- Notes max 500 characters
- Activity max 100 characters

### Local Storage
- All attacks stored in SQLite via DatabaseHelper
- Uses AttackLog model and static queries
- Supports offline-first with sync flags

---

## Analytics Calculations

### Frequency
- Count attacks in date range
- Group by day/week/month

### Severity Distribution
- Count attacks per severity level
- Calculate percentages

### Average Severity
- Sum all severity values / attack count
- Round to 1 decimal place

### Trend Analysis
- Compare first half vs second half of period
- Classify as increasing/decreasing/stable

### Time of Day
- Group by morning/afternoon/evening/night
- Count attacks in each period

---

## Accessibility

- All interactive elements minimum 48dp touch targets
- Color is not sole indicator (text labels too)
- Screen reader support for all fields
- High contrast text on backgrounds
- Keyboard navigation support

---

## Performance Considerations

- Lazy load attack list (paginate after 50 items)
- Cache analytics calculations
- Debounce filter inputs
- Optimize chart rendering
- Image/icon caching

---

*Attack Log Feature UI Specification - Asthma Diary App*
*Follows Material 3 Design with Coral Theme (#E2725B)*
*Last updated: 2025-10-31*
