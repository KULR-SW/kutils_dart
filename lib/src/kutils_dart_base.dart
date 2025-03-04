import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:path/path.dart' as path;

const int DEGREES_PER_HOUR = 30; // 360 degrees / 12 hours
const int DEGREES_PER_MIN  = 6;  // 360 degrees / 60 minutes
const int MINUTES_PER_HOUR = 60;
const int DEFAULT_PRECISION = 3;

//========================================================================================
/// Static class with general utility methods
class KUtilsDart {

  //======================================================================================
  /// Attempts to identify the platform
  ///
  /// This method is mostly effective at identifying which platform the code is running on.
  /// It returns a string identifying the platform as a string as follows:
  /// "Android"
  /// "iOS"
  /// "Linux"
  /// "Windows"
  /// "macOS"
  /// "Web"
  /// "Unknown"
  static String getPlatform() {
    String platform = "Unknown";
    if (Platform.isAndroid) {
      platform = "Android";
    } else if (Platform.isIOS) {
      platform = "iOS";
    } else if (Platform.isMacOS) {
      platform = "macOS";
    } else if (Platform.isWindows) {
      platform = "Windows";
    } else if (Platform.isLinux) {
      platform = "Linux";
    }
    return platform;
  }

  //======================================================================================
  /// Determines if the platform is desktop or mobile
  ///
  /// This method is based on the discussion on stack overflow at the following address:
  /// [Detect Host Platform](https://stackoverflow.com/questions/45924474/how-do-you-detect-the-host-platform-from-dart-code)
  /// Desktop is defined as being Windows, macOS or Linux
  ///
  /// Returns boolean true is a desktop app else boolean false
  static bool isDesktopApp() {
    try {
      return (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ? true : false;
    } catch(e) {
      return false;
    }
  }

  //======================================================================================
  /// Returns the current time as a string in the format YYYY-MM-DD HH:MM:SS
  static String timestamp() {
    DateTime now = DateTime.now();
    return ('${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}');
  }

  //======================================================================================
  /// Round a [value] to a given [precision]
  static double round(double value, int precision) {
    num mod = pow(10.0, precision);
    return ((value * mod).round().toDouble() / mod);
  }

  //======================================================================================
  /// Open and read a JSON file
  ///
  /// Given a [pathname] to a json file this methods opens and parses it
  ///
  /// Returns a JSON map
  static dynamic parseJsonFile(String pathname) {
    final file = File(pathname);
    late dynamic jsonMap;

    try {
      final jsonString = file.readAsStringSync();
      jsonMap = jsonDecode(jsonString);
    } catch(e) {
      throw Exception("Unable to open and parse file $pathname: $e");
    }

    return jsonMap;
  }

  //======================================================================================
  /// Shift a list left
  ///
  /// Takes a [list] and shifts it left by [num] values returning the shifted list reduced
  /// in size by the number of elements removed.
  /// e.g. [1,2,3,4] sifted 2 returns [3,4]
  ///
  /// Returns a new list reduced in size by the number of elements removed
  static List<dynamic> shiftLeft(List<dynamic> list, int num) {
    List<dynamic> newList = [...list];
    if (num > newList.length) {
      newList = [];
    } else {

      for(int j=0; j<num; j++) {
        for(int i=0; i<newList.length; i++) {
          if (i == newList.length-1) {
            newList.removeLast();
          } else {
            newList[i] = newList[i+1];
          }
        }
      }
    }

    return newList;
  }

  //======================================================================================
  /// Determines if a string is representative of a numeric integer value
  ///
  /// For example, if the string "3" numeric? Yes, "Foobar47", No
  ///
  /// Returns boolean true if numeric int, else boolean false
  static bool isNumericInt(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  //======================================================================================
  /// Determines if a string [clockStr] represents a clock value or not
  ///
  /// This method is useful when converting between polar and clock angle values
  /// For example, the string "3:15" is a clock string where "three fifteen" is not
  ///
  /// Returns boolean true if a clock string, else boolean false
  static bool verifyClockStr(String clockStr) {
    bool valid = false;
    if (clockStr.contains(':')) {
      List<String> values = clockStr.split(':');
      if ( (isNumericInt(values[0])) && (isNumericInt(values[1])) ) {
        int h = int.parse(values[0]);
        int m = int.parse(values[1]);
        if ((h >= 1 && h <= 12) && (m >= 0 && m <= 59 )) {
          valid = true;
        }
      }
    }
    return valid;
  }

  //======================================================================================
  /// Converts an angle to clock representation
  ///
  /// Input takes a double [angle] value and returns it as a clock value
  /// For example, the angle value 45.0 degrees would convert to "1:30"
  ///
  /// Returns a string in the format: HH:mm
  static String angleToClock(double angle) {
    String retValue = "";

    int hour = (angle / DEGREES_PER_HOUR).floor(); // get just hours
    // get just decimal part and assure a default precision
    String tmp = ((angle / DEGREES_PER_HOUR) - hour).toStringAsFixed(DEFAULT_PRECISION);
    int min = ( double.parse(tmp)  * MINUTES_PER_HOUR ).round();
    if (hour == 0) { hour = 12; }
    if (min < 10) { // pad minutes if single digit
      retValue = "$hour:0$min";
    } else {
      retValue = "$hour:$min";
    }
    return retValue;
  }

  //======================================================================================
  /// Gets the local timezone based on the machine time
  static String getLocalTimezone() {
    String tz = "";
    final now = DateTime.now();
    final timezoneName = now.timeZoneName;
    List<String> tzStrList = timezoneName.split(" ");
    tz = tzStrList[0];
    return tz;
  }

  //======================================================================================
  /// Give a directory path this returns a list of all folders at the top level
  static List<String> getFolders(String path) {
    List<String> folderList = [];
    String delimiter = Platform.isWindows ? "\\" : "/";

    final directory = Directory(path);

    // List contents synchronously (might block)
    final allContents = directory.listSync(recursive: false);

    // Filter directories from the list
    final folders = allContents.whereType<Directory>();

    // Process the list of folders (e.g., print names)
    for (var folder in folders) {
      final pathList = folder.path.split(delimiter);
      folderList.add(pathList.last);
    }

    return folderList;
  }

  //======================================================================================
  /// Given a directory path this returns a list of all files in that folder with
  /// the given suffix
  static Future<List<String>> getAllFileNamesWithExtension(String directoryPath, String extension) async {
    final directory = Directory(directoryPath);
    List<String> fileList = [];
    String delimiter = KUtilsDart.getPlatform() == "Windows" ? "\\" : "/";

    // List contents asynchronously
    final stream = directory.list(recursive: false);

    // Filter files with the given extension and map to file names
    final fileNames = await stream
        .where((entity) => entity is File && path.extension(entity.path) == extension)
        .map((entity) => entity.path)
        .toList();

    for (var path in fileNames) {
      final tmpList = path.split(delimiter);
      fileList.add(tmpList.last);
    }

    return fileList;
  }

} // class KUtilsDart
