import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'cubit/suggestion_cubit.dart';

class SuggestionWidget extends StatefulWidget {
  final SuggestionCubit cubit;
  final TextEditingController? controller;
  final Function(TextEditingController)? onTap;
  final SuggestionPosition? suggestionPosition;
  final Widget Function(Suggestion)? suggestionCard;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? backgroundColor;

  SuggestionWidget({
    required this.cubit,
    this.controller,
    this.onTap,
    this.suggestionPosition,
    this.suggestionCard,
    this.titleStyle,
    this.subtitleStyle,
    this.backgroundColor,
  });

  @override
  _SuggestionWidgetState createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestionCubit, SuggestionState>(
        bloc: widget.cubit,
        builder: (context, provider) {
          return Container(
              color: widget.backgroundColor,
              constraints: BoxConstraints(
                minHeight: 1,
                maxHeight: provider.suggestionHeight,
                maxWidth: double.infinity,
                minWidth: double.infinity,
              ),
              child: provider.loading
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
                      ))
                  : Scrollbar(
                      thickness: 3,
                      child: provider.last.startsWith('@')
                          ? ListView.builder(
                              itemCount: provider.suggestions.length,
                              itemBuilder: (context, index) {
                                var user = provider.suggestions[index];
                                if (user == null) return Container();
                                return widget.suggestionCard?.call(user) ??
                                    MemberItem(
                                      avatar: user.imageURL,
                                      name: user.subtitle,
                                      backgroundColor: widget.backgroundColor ?? Color(0xFF1F2329),
                                      fullName: user.title,
                                      nameStyle: widget.subtitleStyle,
                                      fullNameStyle: widget.titleStyle,
                                      onTap: () {
                                        var _controller =
                                            widget.cubit.onUserSelect('@${user.subtitle} ', widget.controller!);
                                        widget.onTap!(_controller);
                                      },
                                    );
                              },
                            )
                          : provider.hashtags.isNotEmpty
                              ? ListView.builder(
                                  itemBuilder: (context, position) {
                                    var item = provider.hashtags[position];
                                    return ListTile(
                                      onTap: () {
                                        var _controller =
                                            widget.cubit.onUserSelect('${item.hashtag} ', widget.controller!);
                                        widget.onTap!(_controller);
                                      },
                                      title: Text(
                                        item.hashtag,
                                        style: Theme.of(context).textTheme.subtitle2,
                                      ),
                                      subtitle: Text(item.subtitle ?? ''),
                                      trailing: item.trending
                                          ? Text('Trending')
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            ),
                                    );
                                  },
                                  itemCount: provider.hashtags.length)
                              : Container(),
                    ));
        });
  }
}

class ListUserItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Function()? onClick;

  ListUserItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.onClick,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Row(children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 20,
          ),
          Flexible(
              child: Container(
            margin: EdgeInsets.only(left: 20.0, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        title.trim(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: Container(
                      child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
                  )),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                )
              ],
            ),
          )),
        ]),
      ),
    );
  }
}

class MemberItem extends StatelessWidget {
  final String avatar;
  final String name;
  final String fullName;
  final Color backgroundColor;
  final void Function()? onTap;
  final TextStyle? nameStyle;
  final TextStyle? fullNameStyle;

  const MemberItem({
    required this.avatar,
    required this.name,
    required this.backgroundColor,
    required this.fullName,
    this.onTap,
    this.nameStyle,
    this.fullNameStyle,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        color: backgroundColor,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    avatar,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: fullName,
                        style: fullNameStyle,
                      ),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
