import 'package:flutter/material.dart';

class AnnotatedString extends StatelessWidget {
  const AnnotatedString(
      {super.key,
      required this.text,
      this.defaultStyle,
      this.richTextStyle,
      this.fontSize});

  final String text;
  final TextStyle? defaultStyle;
  final TextStyle? richTextStyle;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    double fontSizeIn = fontSize ?? 18;
    TextStyle defaultStyling = defaultStyle ??
        TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
          fontSize: fontSizeIn,
        );

    TextStyle richStyling = richTextStyle ??
        TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: fontSizeIn,
        );

    List<TextSpan> spans = [];
    final RegExp richTextRegex = RegExp(r'<(s|0)>(.*?)</\1>');
    int currentIndex = 0;

    for (final match in richTextRegex.allMatches(text)) {
      // Add the text before the match with default styling.
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: defaultStyling,
          ),
        );
      }

      // Add the matched text with rich styling.
      spans.add(
        TextSpan(
          text: match.group(2),
          style: richStyling,
        ),
      );
      currentIndex = match.end;
    }

    // Add any remaining text after the last match.
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: defaultStyling,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.start,
    );
  }
}

class SelectableButton extends StatelessWidget {
  const SelectableButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
    this.width,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlinedButtonCustom extends StatelessWidget {
  const OutlinedButtonCustom({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Theme.of(context).colorScheme.onTertiary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
