import Toybox.WatchUi;
import Toybox.Background;
import Toybox.Application.Storage;
import Toybox.Timer;
import Toybox.Time;
import Toybox.Attention;

class PomLogic extends WatchUi.BehaviorDelegate {
  private var _mainView as MainView;
  private var _countdownView as CountdownView;
  private var _state as AppState;
  private var _timer as Timer;
  private var _count as Number;
  private var _timerStart as Number;
  private var _startSeconds as Number;

  private static const _START_PATTERN as Lang.Array<Attention.VibeProfile> = [
    new Attention.VibeProfile(50, 200),
  ];
  private static const _STOP_PATTERN as Lang.Array<Attention.VibeProfile> =
    _START_PATTERN;
  private static const _END_PATTERN as Lang.Array<Attention.VibeProfile> = [
    new Attention.VibeProfile(50, 400),
  ];
  private static const _BREAK_PATTERN as Lang.Array<Attention.VibeProfile> = [
    new Attention.VibeProfile(50, 200),
    new Attention.VibeProfile(0, 200),
    new Attention.VibeProfile(50, 200),
  ];
  private static const _POM_PATTERN as Lang.Array<Attention.VibeProfile> =
    _BREAK_PATTERN;

  function initialize() {
    BehaviorDelegate.initialize();
    Background.deleteTemporalEvent();
    $.PomStorage.setupStorage();
    _mainView = new MainView();
    _countdownView = new CountdownView();
    _state = $.PomStorage.getCurrent();
    _timer = new Timer.Timer();

    if (_state != $.AppState.MAIN_VIEW) {
      _count = $.PomStorage.getCount();
      _countdownView.setCount(_count + 1);
      _startSeconds = $.PomStorage.getLastStore();
      if (!$.AppState.isPaused(_state)) {
        var now = Time.now();
        _startSeconds -= now.value() - $.PomStorage.getExitTime();
      }
      while (_state != $.AppState.MAIN_VIEW && _startSeconds <= 0) {
        var extraTime = _startSeconds;
        nextState();
        if ($.AppState.isPaused(_state)) {
          break;
        }
        _startSeconds += extraTime;
      }
      _countdownView.setTime(_startSeconds);
    }
  }

  public function getInitialView() as WatchUi.View {
    if (_state != $.AppState.MAIN_VIEW && !$.AppState.isPaused(_state)) {
      startOrResume();
    }
    return stateToView();
  }

  private function nextState() {
    switch (_state) {
      case $.AppState.POM:
        if (_count == PomStorage.getPomCountToLong() - 1) {
          _state = $.AppState.BREAK_LONG;
          _startSeconds = PomStorage.getLongBreak() * 60;
        } else {
          _state = $.AppState.BREAK_SHORT;
          _startSeconds = PomStorage.getShortBreak() * 60;
        }
        _countdownView.setMode($.CountdownMode.appStateToMode(_state));
        _countdownView.setTime(_startSeconds);
        _timerStart = Time.now().value();
        break;
      case $.AppState.BREAK_SHORT:
        _state = $.AppState.POM_PAUSED;
        _startSeconds = PomStorage.getPomTime() * 60;
        _countdownView.setTime(_startSeconds);
        _countdownView.setPaused(true);
        _countdownView.setMode($.CountdownMode.appStateToMode(_state));
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
  }

  private function stateToView() as WatchUi.View {
    var state = _state;
    if (state == $.AppState.MAIN_VIEW) {
      return _mainView;
    }

    _countdownView.setMode($.CountdownMode.appStateToMode(state));
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

    if (minutes <= 0) {
      nextState();
      switch ($.AppState.baseState(_state)) {
        case $.AppState.MAIN_VIEW:
          Attention.vibrate(_END_PATTERN);
          break;
        case $.AppState.POM:
          Attention.vibrate(_POM_PATTERN);
          break;
        case $.AppState.BREAK_SHORT:
        case $.AppState.BREAK_LONG:
          Attention.vibrate(_BREAK_PATTERN);
          break;
      }
    } else {
      _countdownView.setTime(seconds);
    }
  }

  public function saveState() {
    PomStorage.setCurrent(_state);
    switch (_state) {
      case $.AppState.MAIN_VIEW:
        break;

      case $.AppState.BREAK_SHORT:
      case $.AppState.BREAK_LONG:
      case $.AppState.POM:
        _timer.stop();
        var now = Time.now();
        var remaining = _startSeconds - (now.value() - _timerStart);
        PomStorage.setLastStore(remaining);
        PomStorage.setCount(_count);
        PomStorage.setExitTime(now.value());
        Background.registerForTemporalEvent(
          now.add(new Time.Duration(remaining))
        );
        break;

      case $.AppState.BREAK_SHORT_PAUSED:
      case $.AppState.BREAK_LONG_PAUSED:
      case $.AppState.POM_PAUSED:
        PomStorage.setLastStore(_startSeconds);
        PomStorage.setCount(_count);
        break;
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
          _countdownView.reset();
          startOrResume();
          WatchUi.switchToView(stateToView(), self, WatchUi.SLIDE_IMMEDIATE);
          Attention.vibrate(_START_PATTERN);
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
          Attention.vibrate(_STOP_PATTERN);
        }
        return true;

      case $.AppState.BREAK_SHORT_PAUSED:
      case $.AppState.BREAK_LONG_PAUSED:
      case $.AppState.POM_PAUSED:
        if (keyEvent.getKey() == KEY_ENTER) {
          _state &= ~$.AppState.PAUSED;
          startOrResume();
          _countdownView.setPaused(false);
          Attention.vibrate(_START_PATTERN);
        } else {
          _state = $.AppState.MAIN_VIEW;
          WatchUi.switchToView(stateToView(), self, WatchUi.SLIDE_IMMEDIATE);
          Attention.vibrate(_END_PATTERN);
        }

        return true;
    }

    return false;
  }
}
