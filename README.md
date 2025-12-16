# SVG Text Replacer

A Flutter web application that allows you to open SVG files and replace text between curly braces `{}` with custom text.

## Features

- 📁 Upload SVG files using a file picker
- 🔍 Automatically detects all text placeholders in format `{placeholder}`
- ✏️ Replace multiple placeholders at once
- 👁️ Live preview of the modified SVG
- 💾 Download the modified SVG file
- 🎨 Beautiful and intuitive user interface

## How to Use

1. Click "Select SVG File" to upload an SVG file
2. The app will automatically find all text within curly braces `{text}`
3. Enter replacement text for each placeholder
4. Click "Apply Replacements" to see the changes in the preview
5. Click "Download SVG" to save the modified file

## Example

If your SVG contains:
```xml
<svg>
  <text>{name}</text>
  <text>{title}</text>
</svg>
```

You can replace `{name}` with "John Doe" and `{title}` with "Software Engineer".

## Setup & Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Chrome browser (for web development)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run -d chrome
```

Or build for production:
```bash
flutter build web
```

## Project Structure

```
svg_replacer/
├── lib/
│   └── main.dart          # Main application code
├── web/
│   ├── index.html         # HTML entry point
│   └── manifest.json      # Web app manifest
├── pubspec.yaml           # Dependencies
└── README.md             # This file
```

## Dependencies

- `flutter`: Flutter framework
- `file_picker`: ^8.0.0+1 - For selecting SVG files
- `flutter_svg`: ^2.0.10+1 - For rendering SVG previews

## Browser Support

This app works best in modern browsers:
- Chrome/Edge (recommended)
- Firefox
- Safari

## License

MIT License - Feel free to use and modify as needed.

