import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:tiktok_flutter/data/video.dart';
import 'package:tiktok_flutter/screens/feed_viewmodel.dart';
import 'package:tiktok_flutter/widgets/video_description.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();

  @override
  void initState() {
    feedViewModel.loadVideo(0);

    // feedViewModel.loadVideo(1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
        disposeViewModel: false,
        builder: (context, model, child) => feedVideos(),
        viewModelBuilder: () => feedViewModel);
  }

  Widget feedVideos() {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(
              initialPage: 0,
              viewportFraction: 1,
            ),
            itemCount: feedViewModel.videoSource?.listVideos.length,
            onPageChanged: (index)=>_onPageView(index),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              index = index % (feedViewModel.videoSource.listVideos.length);
              return videoCard(feedViewModel.videoSource.listVideos[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget videoCard(Video video) {
    return Stack(
      children: [
        video.controller != null
            ? GestureDetector(
                onTap: () {
                  if (video.controller.value.isPlaying) {
                    video.controller?.pause();
                  } else {
                    video.controller?.play();
                  }
                },
                child: SizedBox.expand(
                    child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: video.controller?.value.size.width ?? 0,
                    height: video.controller?.value.size.height ?? 0,
                    child: VideoPlayer(video.controller),
                  ),
                )),
              )
            : Container(
                color: Colors.black,
                child: Center(
                  child: Text("Loading"),
                ),
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                VideoDescription(video.user, video.videoTitle, video.songName),
              ],
            ),
            SizedBox(height: 20)
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    feedViewModel.controller?.dispose();
    super.dispose();
  }

  _onPageView(int page) {
    print("Page=======================================$page");
    int index = page % (feedViewModel.videoSource.listVideos.length);
    feedViewModel.changeVideo(index);
  }
}
