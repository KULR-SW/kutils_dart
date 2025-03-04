library periodic_timer;

import "dart:async";

//========================================================================================
/// Implements a periodic timer
///
/// Create an instance passing the [period] which is number of milliseconds between timer
/// firing. The [timerCallback] is a function passed to the constructor that will be
/// executed each time the timer fires.
class PeriodicTimer {
  final Function timerCallback;
  final int period;

  PeriodicTimer(this.period, this.timerCallback);

  Timer? _periodicTimer;

  @override
  void dispose() {
    _periodicTimer!.cancel();
  }

  //======================================================================================
  /// Starts the timer
  void startTimer() {
    _periodicTimer?.cancel(); // Cancel the previous timer if running
    _periodicTimer = Timer.periodic(
        Duration(milliseconds: period),
        (timer) => timerCallback()
    );
  }

  //======================================================================================
  /// Stops the timer
  void stopTimer() {
    _periodicTimer?.cancel();
  }

} // class PeriodicTimer