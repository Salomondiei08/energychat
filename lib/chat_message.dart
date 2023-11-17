import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  final bool isUser;
  final String text;
  final AnimationController animationController;

  const ChatMessage(
      {super.key,
      required this.text,
      required this.animationController,
      this.isUser = false});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.elasticOut,
      ),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment:
              widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.isUser
              ? <Widget>[
                  Column(
                    children: <Widget>[
                      widget.isUser
                          ? Text(
                              'Vous',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              'Energy Bot',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(widget.text),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    height: 50,
                    width: 50,
                    decoration: widget.isUser
                        ? const BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle)
                        : const BoxDecoration(
                            image: DecorationImage(
                            image: AssetImage('assets/energie.jpeg'),
                          )),
                  ),
                ]
              : <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    height: 50,
                    width: 50,
                    decoration: widget.isUser
                        ? const BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle)
                        : const BoxDecoration(
                            image: DecorationImage(
                            image: AssetImage('assets/energie.jpeg'),
                          )),
                  ),
                  Column(
                    children: <Widget>[
                      widget.isUser
                          ? Text(
                              'Vous',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              'Energy Bot',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                      Container(
                        width: size.width / 2,
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(widget.text),
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}
