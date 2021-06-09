import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({@required this.child, @required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.deepPurple)),
    onPressed: onPressed,
    child: child,
  );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content);
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text(
      content,
      style: TextStyle(fontSize: 10),
    ),
  );
}

class ParagraphDate extends StatelessWidget {
  const ParagraphDate(this.content);
  final DateTime content;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        content.toString(),
        style: TextStyle(fontSize: 8),
      ),
    ),
  );
}