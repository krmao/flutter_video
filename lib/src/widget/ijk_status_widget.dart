import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video/flutter_video.dart';

/// Construct a Widget based on the current status.
typedef Widget StatusWidgetBuilder(
  BuildContext context,
  IjkMediaController controller,
  IjkStatus status,
  //新添加属性 视频详情
);

/// Default IjkStatusWidget
class IjkStatusWidget extends StatelessWidget {
  final IjkMediaController controller;
  final StatusWidgetBuilder statusWidgetBuilder;

  const IjkStatusWidget({
    this.controller,
    this.statusWidgetBuilder = IjkStatusWidget.buildStatusWidget,
  });

  @override
  Widget build(BuildContext context) {
    var statusBuilder =
        this.statusWidgetBuilder ?? IjkStatusWidget.buildStatusWidget;
    return StreamBuilder<IjkStatus>(
      initialData: controller.ijkStatus,
      stream: controller.ijkStatusStream,
      builder: (BuildContext context, snapshot) {
        return statusBuilder.call(context, controller, snapshot.data);
      },
    );
  }

  static Widget _buildProgressWidget(
      BuildContext context, IjkMediaController controller) {
    var content;
    print(controller);
    if (controller.videoInfo.tcpSpeed == null) {
      content = Container();
    } else {
      print("视频播放的速度：${controller.videoInfo.tcpSpeed}");
      int tcpSpeed = 0;
      if (controller.videoInfo.tcpSpeed == null) {
        tcpSpeed = 0;
      } else {
        tcpSpeed = controller.videoInfo.tcpSpeed;
      }

      List<String> unitArr = List()
        ..add('B/S')
        ..add('K/S')
        ..add('M/S')
        ..add('G/S');
      int index = 0;
      while (tcpSpeed > 1024) {
        index++;
        tcpSpeed = tcpSpeed ~/ 1024;
      }
      String size = tcpSpeed.toStringAsFixed(0);
      String speed = size + unitArr[index];

      content = Center(
        child: Container(
          alignment: Alignment.center,
          color: Color.fromRGBO(0, 0, 0, 0.54),
          width: 80,
          height: 80,
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                width: 120,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.greenAccent,
                ),
              ),
              Container(
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  "$speed",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              )
            ],
          ),
        ),
      );
    }
    return content;
  }

  static Widget buildStatusWidget(
    BuildContext context,
    IjkMediaController controller,
    IjkStatus status,
  ) {
    if (status == IjkStatus.noDatasource) {
      return _buildNothing(context);
    }

    if (status == IjkStatus.preparing) {
      return _buildProgressWidget(context, controller);
    }
    if (status == IjkStatus.prepared) {
      //return _buildPreparedWidget(context, controller);

      return _buildProgressWidget(context, controller);
    }
    if (status == IjkStatus.error) {
      return _buildFailWidget(context);
    }
    if (status == IjkStatus.pause) {
      return _buildCenterIconButton(Icons.play_arrow, controller.play);
    }
    if (status == IjkStatus.complete) {
      return _buildCenterIconButton(Icons.replay, () async {
        await controller?.seekTo(0);
        await controller?.play();
      });
    }
    return Container();
  }

  // static Widget _buildPreparedWidget(
  //   BuildContext context,
  //   IjkMediaController controller,
  // ) {
  //   return _buildCenterIconButton(Icons.play_arrow, controller.play);
  // }
}

Widget _buildNothing(BuildContext context) {
  return Center(
    child: Text(
      "",
      style: TextStyle(color: Colors.white),
    ),
  );
}

Widget _buildCenterIconButton(IconData iconData, Function onTap) {
  return Center(
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        iconSize: 30,
        color: Colors.black,
        icon: Icon(iconData),
        onPressed: onTap,
      ),
    ),
  );
}

Widget _buildFailWidget(BuildContext context) {
  return Center(
    child: Icon(
      Icons.error,
      color: Colors.white,
      size: 44,
    ),
  );
}
