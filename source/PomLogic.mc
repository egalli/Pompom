import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Timer;
import Toybox.Time;

class PomLogic extends WatchUi.BehaviorDelegate {
  private var _mainView as MainView;
  private var _countdownView as CountdownView;
  private var _state as AppState;
  private var _timer as Timer;
  private var _count as Number;
  private var _timerStart as Number;
  private var _startSeconds as Number;

  function initialize() {
    BehaviorDelegate.initialize();

    $.PomStorage.setupStorage();
    _mainView = new MainView();
    _countdownView = new CountdownView();
    _state = $.PomStorage.getCurrent();
    _timer = new Timer.Timer();

    if (_state != $.AppState.MAIN_VIEW) {
    }
  }

  public function getInitialView() as WatchUi.View {
    return stateToView();
  }

  private function stateToView() as WatchUi.View {
    var state = _state;
    switch (state) {
      case $.AppState.MAIN_VIEW:
        return _mainView;

      case $.AppState.POM:
      case $.AppState.POM_PAUSED:
        _countdownView.setBreak(false);
        break;

      default:
        _countdownView.setBreak(true);
        break;
    }

    _countdownView.setPaused($.AppState.isPaused(state));
    return _countdownView;
  }

  private function startOrResume() {
    _countdownView.setTime(_startSeconds);
    _timerStart = Time.now().value();
    _timer.start(method(:tickCallback), 1000, true);
  }

  function tickCallback() {
    var now = Time.now().value();
    var seconds = _startSeconds - (now - _timerStart);
    var minutes = Math.ceil(seconds / 60.0);
    System.println(seconds / 60.0);
    if (minutes < 0) {
      minutes = 0;
    }

    if (minutes == 0) {
      switch (_state) {
        case $.AppState.POM:
          if (_count == PomStorage.getPomCountToLong() - 1) {
            _state = $.AppState.BREAK_LONG;
            _startSeconds = PomStorage.getLongBreak() * 60;
            System.println("long break");
          } else {
            _state = $.AppState.BREAK_SHORT;
            _startSeconds = PomStorage.getShortBreak() * 60;
            System.println("short break");
          }
          _countdownView.setBreak(true);
          _countdownView.setTime(_startSeconds);
          _timerStart = Time.now().value();
          break;
        case $.AppState.BREAK_SHORT:
          _state = $.AppState.POM_PAUSED;
          _startSeconds = PomStorage.getPomTime() * 60;
          _countdownView.setTime(_startSeconds);
          _countdownView.setPaused(true);
          _countdownView.setBreak(false);
          ++_count;
          _countdownView.setCount(_count + 1);
          _timer.stop();

          break;
        case $.AppState.BREAK_LONG:
          _state = $.AppState.MAIN_VIEW;
          WatchUi.switchToView(stateToView(), self, WatchUi.SLIDE_IMMEDIATE);
          _timer.stop();

          break;
      }
    } else {
      _countdownView.setTime(seconds);
    }
  }

  function onKey(keyEvent as KeyEvent) as Boolean {
    switch (_state) {
      case $.AppState.MAIN_VIEW:
        if (keyEvent.getKey() == KEY_ENTER) {
          _state = $.AppState.POM;
          _count = 0;
          var pomTime = PomStorage.getPomTime();
          _startSeconds = pomTime * 60;
          _countdownView.setCount(_count + 1);
          startOrResume();
          WatchUi.switchToView(stateToView(), self, WatchUi.SLIDE_IMMEDIATE);
          return true;
        }
        break;

      case $.AppState.BREAK_SHORT:
      case $.AppState.BREAK_LONG:
      case $.AppState.POM:
        if (keyEvent.getKey() == KEY_ENTER) {
          _timer.stop();
          _state |= $.AppState.PAUSED;
          var now = Time.now().value();
          _startSeconds -= now - _timerStart;
          _countdownView.setPaused(true);
        }
        return true;

      case $.AppState.BREAK_SHORT_PAUSED:
      case $.AppState.BREAK_LONG_PAUSED:
      case $.AppState.POM_PAUSED:
        if (keyEvent.getKey() == KEY_ENTER) {
          _state &= ~$.AppState.PAUSED;
          startOrResume();
          _countdownView.setPaused(false);
        } else {
          _state = $.AppState.MAIN_VIEW;
          WatchUi.switchToView(stateToView(), self, WatchUi.SLIDE_IMMEDIATE);
        }

        return true;
    }

    return false;
  }

  // function onKey2(keyEvent as KeyEvent) as Boolean {
  //   if (_state == $.AppState.MAIN_VIEW) {
  //     if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
  //       _state = $.AppState.POM;
  //       WatchUi.switchToView(getActiveView(), self, WatchUi.SLIDE_IMMEDIATE);

  //       return true;
  //     }
  //   } else {
  //     if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
  //       if ((_state & $.AppState.PAUSED) != 0) {
  //         _state &= ~$.AppState.PAUSED;
  //         _countdownView.setPaused(false);
  //       } else {
  //         _state |= $.AppState.PAUSED;
  //         _countdownView.setPaused(true);
  //       }
  //     }
  //     if (keyEvent.getKey() == WatchUi.KEY_ESC) {
  //       _state = $.AppState.MAIN_VIEW;
  //       WatchUi.switchToView(getActiveView(), self, WatchUi.SLIDE_IMMEDIATE);
  //       return true;
  //     }
  //   }
  //   return false;
  // }
}
