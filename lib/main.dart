import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

void main(){
  runApp(MaterialApp(home: music_deshbord(),));
}
class music_deshbord extends StatefulWidget {
  const music_deshbord({Key? key}) : super(key: key);

  @override
  State<music_deshbord> createState() => _music_deshbordState();
}

class _music_deshbordState extends State<music_deshbord> {

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final player = AudioPlayer();
  bool isPlaying =false;


  @override
 initState()  {
    // TODO: implement initState
    super.initState();

    get_permi();
    player.onDurationChanged.listen((Duration d) {

      print('Max duration: $d');
          });
    player.onPlayerStateChanged.listen((PlayerState s) {
      print('Current player state: $s');
    });


  }
  get_permi() async {

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      //var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      //var manufacturer = androidInfo.manufacturer;
      //var model = androidInfo.model;
      print('(SDK $sdkInt)');
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    if(sdkInt>=30){
      var status_audio = await Permission.audio.status;
      var status_str = await Permission.storage.status;
      if(status_str.isDenied || status_audio.isDenied){
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location,
          Permission.storage,
          Permission.audio,
        ].request();
      }else{
        var status_str = await Permission.storage.status;
        if(status_str.isDenied){
          Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,

          ].request();

        }

      }

    }
    }


  }
  get_song() async {

    List<SongModel> audios = await _audioQuery.querySongs();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Music"),),
      body: FutureBuilder(future: _audioQuery.querySongs() ,builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return CircularProgressIndicator();
        }else{

          List<SongModel> l=snapshot.data as List<SongModel>;
          return ListView.builder(itemCount: l.length,itemBuilder: (context, index) {
            return Card(child: ListTile(

              onTap: () {
                if(player.state==PlayerState.playing){
                  player.pause();

                  print(player.state);
                  }
                else{
                  player.play(DeviceFileSource("${l[index].data}"));
                  isPlaying =!isPlaying;
                  print(isPlaying );
                  setState(() {});

                }
              },title: Text("${l[index].displayName}"),
              trailing: (isPlaying)?Icon(Icons.stop):Icon(Icons.play_arrow),

            ),);
          },);
        }

      },),
    );
  }
}
