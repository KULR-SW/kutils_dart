import 'package:kutils_dart/kutils_dart.dart';
import 'package:test/test.dart';
import 'dart:io';

//========================================================================================
void main() {

  //======================================================================================
  test('round', () {
    expect(KUtilsDart.round(3.1416, 2), 3.14);
  });

  //======================================================================================
  test('parseJsonFile', () {
    Map<String,dynamic> testData = KUtilsDart.parseJsonFile("./test/test.json");
    expect(testData["name"], "foobar");
    expect(testData["value"], 3.14);
    try {
      testData = KUtilsDart.parseJsonFile("test/foobar.json");
    } catch(e) {
      expect('$e', "Exception: Unable to open and parse file test/foobar.json: PathNotFoundException: Cannot open file, path = \'test/foobar.json\' (OS Error: No such file or directory, errno = 2)");
    }
  });

  //======================================================================================
  test('shiftLeft', () {
    List<double> list = [0.0, 1.0, 2.0, 3.0];
    expect(KUtilsDart.shiftLeft(list, 1), [1.0, 2.0, 3.0]);

    List<int> intList = [1,2,3,4];
    expect(KUtilsDart.shiftLeft(intList, 2), [3,4]);

    List<String> strList = ["Foo", "bar"];
    expect(KUtilsDart.shiftLeft(strList, 3), []);
  });

  //======================================================================================
  test('isNumericInt', () {
    expect(KUtilsDart.isNumericInt("231"), true);
    expect(KUtilsDart.isNumericInt("foobar47"), false);
    expect(KUtilsDart.isNumericInt("3.14"), false);
    expect(KUtilsDart.isNumericInt("foobar"), false);
    expect(KUtilsDart.isNumericInt("1s"), false);
    expect(KUtilsDart.isNumericInt("00"), true);
    expect(KUtilsDart.isNumericInt("45"), true);
    expect(KUtilsDart.isNumericInt("56.9"), false);
  });

  //======================================================================================
  test('verifyClockStr', () {
    expect(KUtilsDart.verifyClockStr("foobar"), false);
    expect(KUtilsDart.verifyClockStr(":"), false);
    expect(KUtilsDart.verifyClockStr("1:"), false);
    expect(KUtilsDart.verifyClockStr("1:60"), false);
    expect(KUtilsDart.verifyClockStr("1.60"), false);
    expect(KUtilsDart.verifyClockStr("1:3"), true);
    expect(KUtilsDart.verifyClockStr("1:03"), true);
    expect(KUtilsDart.verifyClockStr("1:0"), true);
  });

  //======================================================================================
  test('angleToClock', () {
    expect(KUtilsDart.angleToClock(45.0), "1:30");
    expect(KUtilsDart.angleToClock(90.0), "3:00");
    expect(KUtilsDart.angleToClock(15), "12:30");
    expect(KUtilsDart.angleToClock(91.0), "3:02");
  });

  //======================================================================================
  test('getLocalTimezone', () {
    expect(KUtilsDart.getLocalTimezone(), "PST");
  });

  //======================================================================================
  test('getFolders', () {
    const relativePath = '.';
    final String testPath = File(relativePath).absolute.path.replaceAll(".", "");
    expect(KUtilsDart.getFolders(testPath), ['test', 'lib', '.dart_tool', '.git', '.idea']);
  });

  //======================================================================================
  test('getAllFileNamesWithExtension', () async {
    const relativePath = '.';
    String testPath = File(relativePath).absolute.path;
    testPath = testPath.substring(0, testPath.length - 1);
    expect(await KUtilsDart.getAllFileNamesWithExtension("${testPath}lib", ".dart"), ['kutils_dart.dart']);
  });

}
