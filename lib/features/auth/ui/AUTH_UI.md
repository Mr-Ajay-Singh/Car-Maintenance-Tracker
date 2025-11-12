# Authentication - UI Design Documentation

**Reference**: See `/lib/ui/UI.md` for complete design system, colors, and typography.

---

## 1. Welcome / Onboarding Screen

**AI Image Generation Prompt:**

Create a welcoming onboarding screen for a Psoriasis Tracker application using Material 3 design.

**Exact Theme Colors** (from ColorScheme.fromSeed with seed #6750A4):
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | On Surface Variant: #49454F
- Background: #FDFBFF

**Layout**:
- Full-screen layout with background #FDFBFF

- App branding (top):
  - App logo/icon (120px diameter)
  - Circular background in #E8DEF8
  - Psoriasis awareness ribbon or medical icon in #6750A4
  - 48px margin top
  - Centered

- Headline section:
  - App name "Psoriasis Tracker" (32px, bold, PT Serif) in #1D1B20
  - Tagline "Take control of your health journey" (16px) in #49454F
  - Centered, 24px margin below logo

- Feature highlights (scrollable carousel):
  - Three cards with illustrations:

    Card 1 - Track Progress:
    - Illustration: Calendar/chart icon (64px) in #6750A4
    - Title "Track Your Symptoms" (20px, bold) in #1D1B20
    - Description "Monitor daily symptoms and triggers" (14px) in #49454F
    - Background: #FFFFFF with subtle shadow
    - 16px padding, 16px rounded

    Card 2 - Photo Journal:
    - Illustration: Camera icon in #6750A4
    - Title "Document Progress"
    - Description "Visual tracking with photo journal"

    Card 3 - Insights:
    - Illustration: Lightbulb/chart icon in #6750A4
    - Title "Get Insights"
    - Description "Personalized reports and recommendations"

  - Dots indicator below (3 dots):
    - Active dot: #6750A4, 8px diameter
    - Inactive dots: #CAC4D0, 6px diameter
    - 4px spacing

- Call-to-action buttons (bottom):
  - "Get Started" button:
    - Background: #6750A4
    - Text "Get Started" in #FFFFFF (16px, bold)
    - Full width minus 32px horizontal padding
    - 56px height, 16px rounded
    - Elevation 2
    - 16px margin bottom

  - "Sign In" button:
    - Outlined style
    - Border: #6750A4, 2px
    - Text "Sign In" in #6750A4 (16px, bold)
    - Same dimensions as above
    - 32px margin bottom

- Privacy notice (bottom):
  - "By continuing, you agree to our" in #49454F (12px)
  - "Terms of Service" and "Privacy Policy" links in #6750A4
  - Centered, 16px margin bottom

**Style**: Welcoming, feature-focused, clear CTAs, Material 3 design

---

## 2. Sign Up Screen

**AI Image Generation Prompt:**

Design a user registration screen for a Psoriasis Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF
- Error: #B71C1C

**Layout**:
- App bar:
  - Back arrow (left) in #6750A4
  - Title "Create Account" (20px, bold, PT Serif) in #1D1B20
  - Background: #FEF7FF
  - Elevation 0

- Progress indicator (if multi-step):
  - Step indicator: "Step 1 of 2"
  - Progress bar: 50% filled in #6750A4
  - 16px horizontal margin

- Scrollable form content:

  1. **Email Section**:
     - Label "Email Address" (14px, bold) in #1D1B20
     - Text input field:
       - Background: #E8DEF8
       - 48px height, 12px rounded
       - 16px padding
       - Placeholder: "your@email.com" in #79747E
       - Email icon prefix in #6750A4
       - Validation icon suffix:
         - Valid: Check icon in #4CAF50
         - Invalid: Error icon in #B71C1C
       - Error text below: "Please enter a valid email" in #B71C1C (12px)
     - Helper text: "We'll use this for account recovery" (12px) in #49454F
     - 20px margin bottom

  2. **Password Section**:
     - Label "Password"
     - Text input field (same style):
       - Lock icon prefix
       - Show/hide password toggle icon suffix
       - Obscured text (dots)
       - Min 8 characters
     - Password strength indicator:
       - Progress bar below field
       - Weak (red), Medium (amber), Strong (green)
       - Text: "Password strength: Medium"
     - Requirements checklist:
       - "At least 8 characters" with checkmark/cross
       - "One uppercase letter" with checkmark/cross
       - "One number" with checkmark/cross
       - Each requirement: 12px, with icon (8px) in #4CAF50 or #F44336

  3. **Confirm Password Section**:
     - Label "Confirm Password"
     - Text input field
     - Validation: "Passwords match" with check icon

  4. **Full Name Section**:
     - Label "Full Name"
     - Text input field
     - Person icon prefix

  5. **Terms Acceptance**:
     - Checkbox with text:
       - Unchecked: Outline #79747E
       - Checked: Filled #6750A4 with white checkmark
       - Text: "I agree to the Terms of Service and Privacy Policy"
       - Links in #6750A4, underlined
       - 14px text in #1D1B20
     - Required field

- Alternative sign-up section:
  - Divider with text "OR" (centered, #49454F)
  - 16px margin top and bottom

  Social sign-up buttons:
  - "Continue with Google" button:
    - Background: #FFFFFF
    - Border: 1px #CAC4D0
    - Google logo icon (20px) on left
    - Text in #1D1B20
    - 48px height, 12px rounded
    - 8px margin bottom

  - "Continue with Apple" button:
    - Same style as Google
    - Apple logo icon

  - "Continue with Facebook" button:
    - Background: #1877F2 (Facebook blue)
    - Facebook logo icon in white
    - Text in #FFFFFF

- Create account button (bottom):
  - Fixed position at bottom
  - Background: #6750A4
  - Text "Create Account" in #FFFFFF
  - Full width minus 32px padding
  - 56px height, 16px rounded
  - Elevation 3
  - Disabled state: Background #CAC4D0 when form invalid

- Sign in link (bottom):
  - "Already have an account? Sign In" (14px)
  - "Sign In" in #6750A4, bold
  - Centered, 16px margin bottom

**Style**: Form-based, validation feedback, social login, Material 3 design

---

## 3. Sign In Screen

**AI Image Generation Prompt:**

Create a user login screen for a Psoriasis Tracker app using Material 3 design with purple theme.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF

**Layout**:
- App bar:
  - Back arrow (left) in #6750A4
  - Title "Sign In" (20px, bold, PT Serif) in #1D1B20
  - Background: #FEF7FF

- Welcome section:
  - App icon (80px diameter) in #E8DEF8 circle
  - "Welcome Back!" (28px, bold) in #1D1B20
  - "Sign in to continue tracking" (14px) in #49454F
  - Centered, 32px margin top

- Login form:

  1. **Email Field**:
     - Label "Email" (14px, bold) in #1D1B20
     - Text input:
       - Background: #E8DEF8
       - 48px height, 12px rounded
       - Email icon prefix in #6750A4
       - Placeholder: "your@email.com"
       - 16px padding
     - 20px margin bottom

  2. **Password Field**:
     - Label "Password"
     - Text input:
       - Lock icon prefix
       - Show/hide toggle icon suffix
       - Obscured text
     - "Forgot Password?" link (14px) in #6750A4
       - Right-aligned below field

  3. **Remember Me**:
     - Checkbox with label "Remember me" (14px)
     - Checkbox: Unchecked outline #79747E, checked filled #6750A4
     - 24px margin top

- Sign in button:
  - Background: #6750A4
  - Text "Sign In" in #FFFFFF (16px, bold)
  - Full width minus 32px padding
  - 56px height, 16px rounded
  - 32px margin top
  - Loading indicator when processing:
    - Circular progress in white
    - Button disabled during loading

- Divider section:
  - "OR" text centered with lines
  - Lines in #CAC4D0
  - 24px margin top and bottom

- Social login buttons:
  - "Continue with Google":
    - White background, border #CAC4D0
    - Google logo + text
    - 48px height
    - 8px margin bottom

  - "Continue with Apple":
    - Same style

  - "Continue with Facebook":
    - Blue background #1877F2
    - White text and icon

- Biometric login (if available):
  - Fingerprint/Face ID button:
    - Circular button, 64px diameter
    - Background: #E8DEF8
    - Icon in #6750A4
    - Centered
    - "Use Biometrics" text below (12px)
    - 24px margin top

- Sign up link:
  - "Don't have an account? Sign Up" (14px)
  - "Sign Up" in #6750A4, bold
  - Centered, 24px margin top

- Error message (if login fails):
  - Card with red border
  - Background: #FFCDD2 (light red)
  - Error icon in #B71C1C
  - Message: "Invalid email or password"
  - Close button
  - Appears at top after failed attempt

**Style**: Clean login form, social options, biometric support, Material 3 design

---

## 4. Forgot Password Screen

**AI Image Generation Prompt:**

Design a password recovery screen for a Psoriasis Tracker app using Material 3 design.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF

**Layout**:
- App bar:
  - Back arrow in #6750A4
  - Title "Reset Password" (20px, bold) in #1D1B20
  - Background: #FEF7FF

- Illustration section:
  - Key/lock icon (96px) in #6750A4
  - Circular background in #E8DEF8 (120px diameter)
  - Centered, 48px margin top

- Instructions section:
  - Title "Forgot Your Password?" (24px, bold) in #1D1B20
  - Description (14px) in #49454F:
    - "Enter your email address and we'll send you a link to reset your password."
  - Centered, 16px margin top and bottom

- Email input:
  - Label "Email Address" (14px, bold)
  - Text input field:
    - Background: #E8DEF8
    - Email icon prefix in #6750A4
    - 48px height, 12px rounded
    - Placeholder: "your@email.com"
  - Validation feedback below

- Send button:
  - Background: #6750A4
  - Text "Send Reset Link" in #FFFFFF
  - Full width minus 32px padding
  - 56px height, 16px rounded
  - 24px margin top
  - Loading state when sending

- Success state (after sending):
  - Illustration changes to checkmark in green circle
  - Title "Email Sent!"
  - Message: "Check your inbox for password reset instructions"
  - Timer: "Resend available in 60s" (countdown)
  - "Didn't receive email?" link in #6750A4
  - "Back to Sign In" button (outlined)

- Alternative options:
  - Divider with "OR"
  - "Try another email" link in #6750A4
  - "Contact Support" link in #6750A4

- Info card (bottom):
  - Background: #E8DEF8
  - Info icon in #6750A4
  - Text: "The reset link will expire in 15 minutes" (12px)
  - 16px padding, 12px rounded

**Style**: Helpful, clear process, confirmation states, Material 3 design

---

## 5. Email Verification Screen

**AI Image Generation Prompt:**

Create an email verification screen for a Psoriasis Tracker app using Material 3 design.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF

**Layout**:
- Full screen, no app bar

- Illustration section (centered):
  - Email envelope icon (120px) in #6750A4
  - Animated: Envelope opens with checkmark emerging
  - Circular background #E8DEF8 (160px diameter)
  - 64px margin top

- Content section:
  - Title "Verify Your Email" (28px, bold, PT Serif) in #1D1B20
  - Subtitle with email address:
    - "We sent a verification link to" (14px) in #49454F
    - User's email in #6750A4, bold
  - Description:
    - "Click the link in the email to verify your account"
    - 14px, in #49454F
  - Centered text, 24px margins

- Status indicator:
  - "Waiting for verification..." text with animated dots
  - Circular progress indicator in #6750A4
  - Auto-checks verification status every 5 seconds

- Action buttons:

  1. **Check Verification Button**:
     - Outlined button
     - Border: #6750A4
     - Text "Check Verification Status" in #6750A4
     - Refresh icon
     - 48px height, 16px rounded
     - Full width minus 32px padding
     - 16px margin bottom

  2. **Resend Email Button**:
     - Text button (no background)
     - Text "Resend Verification Email" in #6750A4
     - Disabled for 60s after sending (with countdown timer)
     - "Resend available in 45s" in #49454F when disabled

  3. **Change Email Link**:
     - Text link "Wrong email? Change it" in #6750A4
     - 14px, centered
     - 16px margin top

- Verified state (when verification successful):
  - Illustration changes to checkmark in green circle
  - Title "Email Verified!" in #4CAF50
  - Success message
  - Confetti animation (brief)
  - "Continue" button:
    - Background: #4CAF50
    - Text in #FFFFFF
    - Auto-navigates after 2 seconds

- Help section (bottom):
  - Expandable accordion "Didn't receive the email?"
  - When expanded:
    - "Check your spam folder"
    - "Make sure john@example.com is correct"
    - "Try resending the email"
    - "Contact support if issues persist"
  - Background: #E8DEF8
  - 12px padding, 12px rounded

- Skip option (if allowed):
  - "Skip for now" link at bottom
  - Gray text, warning icon
  - Shows warning dialog before skipping

**Style**: Verification flow, status updates, helpful guidance, Material 3 design

---

## 6. Account Setup Wizard (Multi-Step)

**AI Image Generation Prompt:**

Design a multi-step account setup wizard for a Psoriasis Tracker app using Material 3 design.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF

**Layout**:
- App bar:
  - Close icon (left) in #49454F
  - Title "Account Setup" (20px, bold) in #1D1B20
  - Background: #FEF7FF

- Progress stepper (top):
  - Horizontal step indicator (5 steps)
  - Each step: Circle (32px diameter)
    - Completed: Filled #6750A4 with checkmark
    - Current: Filled #6750A4 with step number
    - Upcoming: Outlined #CAC4D0 with step number
  - Lines connecting steps (2px) in #CAC4D0
  - Active line in #6750A4
  - Step labels below (10px):
    - "Profile", "Medical", "Goals", "Preferences", "Done"

**Step 1: Basic Profile**
- Title "Let's Get Started" (24px, bold)
- Subtitle "Tell us a bit about yourself"

- Profile photo upload:
  - Circular placeholder (100px)
  - Camera icon overlay
  - "Add Photo" text below
  - Optional

- Form fields:
  - Full Name (required)
  - Date of Birth (required)
  - Gender (optional dropdown)
  - Location (optional, for climate data)

- "Continue" button (bottom, fixed)
  - Background: #6750A4
  - 56px height, full width minus 32px padding

**Step 2: Medical History**
- Title "Medical Information"
- Subtitle "Help us personalize your experience"

- Questions:
  1. "When were you diagnosed with psoriasis?"
     - Date picker

  2. "What type of psoriasis do you have?"
     - Dropdown with types
     - Info icon for each type

  3. "Which areas are most affected?"
     - Multi-select body area chips
     - Visual body diagram (optional)

  4. "Are you currently seeing a dermatologist?"
     - Yes/No radio buttons

  5. "Current medications (optional)"
     - Text area
     - "+ Add medication" button

- "Continue" button
- "Skip" option in top right (gray text)

**Step 3: Set Goals**
- Title "Set Your Goals"
- Subtitle "What do you want to achieve?"

- Goal cards (selectable, multiple):
  - "Reduce symptom intensity"
    - Target intensity slider
  - "Track consistently"
    - Daily tracking commitment
  - "Identify triggers"
    - Log triggers regularly
  - "Document progress"
    - Photo frequency selector

- Each card:
  - Checkbox (top left)
  - Icon and title
  - Brief description
  - Configuration options when selected

**Step 4: Preferences**
- Title "Customize Your Experience"
- Subtitle "Set up notifications and reminders"

- Quick settings:
  - Daily reminder time
  - Medication reminders
  - Photo reminders
  - Theme preference
  - Notification preferences

- All with quick toggle/selectors
- Can be changed later in settings

**Step 5: Completion**
- Illustration: Checkmark in green circle (120px)
- Title "You're All Set!" (28px, bold)
- Congratulations message
- Summary of setup:
  - Profile completed ✓
  - Medical info saved ✓
  - Goals configured ✓
  - Preferences set ✓

- "Start Tracking" button:
  - Background: #6750A4
  - Full width
  - 56px height
  - Navigates to main app

- Optional tutorial link:
  - "Take a quick tour" in #6750A4
  - Launches interactive tutorial

**Common Elements (All Steps)**:
- Progress saved automatically
- "Back" button to return to previous step
- "Skip" option where appropriate
- Validation before proceeding
- Clean, focused layout
- Generous spacing
- Clear visual hierarchy

**Style**: Wizard flow, step progression, focused content, Material 3 design

---

## 7. Biometric Setup Screen

**AI Image Generation Prompt:**

Create a biometric authentication setup screen for a Psoriasis Tracker app using Material 3 design.

**Exact Theme Colors**:
- Primary: #6750A4 | Primary Container: #E8DEF8 | On Primary: #FFFFFF
- Surface: #FEF7FF | On Surface: #1D1B20 | Background: #FDFBFF

**Layout**:
- App bar:
  - Back arrow in #6750A4
  - Title "Biometric Login" (20px, bold) in #1D1B20
  - Background: #FEF7FF

- Biometric icon section:
  - Large fingerprint or face icon (120px) in #6750A4
  - Animated pulse effect
  - Circular background #E8DEF8
  - Centered, 48px margin top

- Information section:
  - Title "Secure Your Account" (24px, bold) in #1D1B20
  - Description (14px) in #49454F:
    - "Use your fingerprint or face to quickly and securely access your health data"
  - Centered, 24px margin

- Benefits list:
  - Card with light background #E8DEF8
  - Icons + text for each benefit:
    - "Quick access" with speed icon
    - "Enhanced security" with shield icon
    - "No passwords to remember" with key icon
  - Each item: 14px text, 16px icon in #6750A4
  - 16px padding, 12px rounded

- Biometric type detection:
  - Automatically detects available biometric:
    - Fingerprint
    - Face ID
    - Both
  - Shows appropriate icon and text

- Setup button:
  - Background: #6750A4
  - Text "Enable [Fingerprint/Face ID]" in #FFFFFF
  - Full width minus 32px padding
  - 56px height, 16px rounded
  - 32px margin top

- Testing section (after enabling):
  - "Test Your Biometric Login" card
  - "Try it now" button (outlined)
  - Success/failure feedback

- Skip option:
  - "Skip for now" text button
  - Gray text
  - "You can enable this later in Settings"
  - Bottom of screen

- Security note:
  - Info icon in #6750A4
  - Text in #49454F (12px):
    - "Your biometric data is stored securely on your device and never shared"
  - Background: #E8DEF8
  - 12px padding, 12px rounded

**Style**: Security focused, trust-building, clear benefits, Material 3 design

---

*Feature UI Documentation - Authentication*
*Part of Psoriasis Tracker App v1.0*
