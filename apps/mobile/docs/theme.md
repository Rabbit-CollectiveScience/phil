# Phil Mobile App - Design Theme

## Design Principles

**Bold Studio Aesthetic**
- High contrast, bold geometric shapes
- Sharp corners (no rounded edges on primary UI elements)
- Pronounced visual hierarchy
- Minimalist, focused interactions

**Visual Style**
- Dark theme optimized for gym environments
- High contrast for readability in various lighting conditions
- Vibrant accent color for emphasis and feedback
- Clean, distraction-free interface

**Interaction Design**
- Swipe-based primary interactions
- Haptic feedback for tactile confirmation
- Smooth, purposeful animations (300-600ms)
- Large touch targets (44×44px minimum)

---

## Color Palette

### Primary Colors

**Lime Green (Accent)**
```
#B9E479
RGB: 185, 228, 121
Usage: Primary actions, selected states, completion indicators
```

**Deep Charcoal (Background)**
```
#1A1A1A
RGB: 26, 26, 26
Usage: App background, page backgrounds
```

**Bold Grey (Cards)**
```
#4A4A4A
RGB: 74, 74, 74
Usage: Card backgrounds, unselected buttons, secondary surfaces
```

### Secondary Colors

**Dark Grey (Modal/Overlay)**
```
#2A2A2A
RGB: 42, 42, 42
Usage: Modal backgrounds, overlays, elevated surfaces
```

**Off-White (Text)**
```
#F2F2F2
RGB: 242, 242, 242
Usage: Primary text on dark backgrounds, icons
```

**Pure Black (Inverted Text)**
```
#000000
RGB: 0, 0, 0
Usage: Text on lime green backgrounds for maximum contrast
```

---

## Usage Examples

### Filter Button
- Background: `#B9E479` (Lime Green)
- Icon: `#000000` (Black)
- Shape: Rectangle with sharp corners

### Exercise Cards
- Background: `#4A4A4A` (Bold Grey)
- Text: `#F2F2F2` (Off-White)
- Shadow: Black with opacity

### Completion Counter
- Background: `#B9E479` (Lime Green)
- Text: `#000000` (Black)
- Label: "ZET"

### Selection States
- Unselected: `#4A4A4A` (Bold Grey)
- Selected: `#B9E479` (Lime Green) with glow effect
- Glow: `#B9E479` at 30% opacity, 12px blur

---

## Typography

- **Primary Font**: System default (San Francisco on iOS, Roboto on Android)
- **Weights**: Regular (400), Semi-Bold (600), Bold (700), Black (900)
- **Sizes**: 
  - Body: 16px
  - Labels: 12-14px
  - Titles: 20-24px
  - Display: 32px+

---

## Shadows & Elevation

**Standard Shadow**
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

**Accent Glow (Selected State)**
```dart
BoxShadow(
  color: Color(0xFFB9E479).withOpacity(0.3),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

---

## Animation Timings

- **Fast**: 300ms (page transitions, state changes)
- **Medium**: 600ms (token animations, card transitions)
- **Slow**: 1000ms+ (complex multi-step animations)
- **Curve**: `Curves.easeInOut` (standard), `Curves.easeInCubic` (falling tokens)
