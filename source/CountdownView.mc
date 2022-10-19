import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;

class CountdownView extends WatchUi.View {
  private var _pauseOverlay as WatchUi.Drawable?;
  private var _isPaused as Boolean;
  private var _isBreak as Boolean;
  private var _timeLbl as WatchUi.Text;
  private var _countLbl as WatchUi.Text;
  private var _minutes as Number;
  private var _count as Number;

  public function initialize() {
    View.initialize();
    _isBreak = false;
    _minutes = 0;
    _count = 0;
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.CountdownLayout(dc));
    _timeLbl = View.findDrawableById("timeLbl");
    _countLbl = View.findDrawableById("countLbl");
    _pauseOverlay = View.findDrawableById("pauseOver");
    _pauseOverlay.setVisible(_isPaused);

    _timeLbl.setText(_minutes.format("%02d"));
    _countLbl.setText(_count.toString());

    if (_isBreak) {
      _timeLbl.setColor(Graphics.COLOR_BLUE);
    }
  }

  public function setBreak(isBreak as Boolean) {
    if (_timeLbl != null && _isBreak != isBreak) {
      if (isBreak) {
        _timeLbl.setColor(Graphics.COLOR_BLUE);
      } else {
        _timeLbl.setColor(Graphics.COLOR_GREEN);
      }
      WatchUi.requestUpdate();
    }
    _isBreak = isBreak;
  }

  public function setPaused(paused as Boolean) {
    if (_pauseOverlay != null && _isPaused != paused) {
      _pauseOverlay.setVisible(paused);
      WatchUi.requestUpdate();
    }
    _isPaused = paused;
  }

  public function setMinutes(minutes as Number) {
    if (_timeLbl != null && _minutes != minutes) {
      _timeLbl.setText(minutes.format("%02d"));
      WatchUi.requestUpdate();
    }
    _minutes = minutes;
  }

  public function setCount(count as Number) {
    if (_timeLbl != null && _count != count) {
      _countLbl.setText(count.toString());
      WatchUi.requestUpdate();
    }
    _count = count;
  }
}
