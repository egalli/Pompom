import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;

class CountdownView extends WatchUi.View {
  private var _pauseOverlay as WatchUi.Drawable?;
  private var _isPaused as Boolean;
  private var _isBreak as Boolean;
  private var _timeLbl as WatchUi.Text;
  private var _countLbl as WatchUi.Text;
  private var _angle as Number;
  private var _fillArc as bool;
  private var _minutes as Number;
  private var _count as Number;

  public function initialize() {
    View.initialize();
    _isBreak = false;
    _minutes = 0;
    _angle = 0;
    _fillArc = true;
    _count = 0;
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.CountdownLayout(dc));
    _timeLbl = View.findDrawableById("timeLbl");
    _countLbl = View.findDrawableById("countLbl");
    _pauseOverlay = new $.Rez.Drawables.pauseOver();
    _fillArc = true;

    _timeLbl.setText(_minutes.format("%02d"));
    _countLbl.setText(_count.toString());

    if (_isBreak) {
      _timeLbl.setColor(Graphics.COLOR_BLUE);
    }
  }

  public function onUpdate(dc as Dc) as Void {
    View.onUpdate(dc);
    dc.setPenWidth(4);
    var x = (dc.getWidth() - 1) / 2.0;
    var y = (dc.getHeight() - 1) / 2.0;
    if (_isPaused) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      dc.drawCircle(x, y, x - 2);
      _pauseOverlay.draw(dc);
    } else {
      dc.setColor(
        _isBreak ? Graphics.COLOR_BLUE : Graphics.COLOR_GREEN,
        Graphics.COLOR_TRANSPARENT
      );
      var a = 360 - _angle;
      if (!_fillArc) {
        dc.drawArc(x, y, x - 2, Graphics.ARC_CLOCKWISE, 90, a + 90);
      } else if (a != 360) {
        dc.drawArc(x, y, x - 2, Graphics.ARC_COUNTER_CLOCKWISE, 90, a + 90);
      }
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

  public function setTime(time as Number) {
    var minutesFloat = time / 60.0;
    var minutes = Math.ceil(minutesFloat).toNumber();
    if (_timeLbl != null && _minutes != minutes) {
      _timeLbl.setText(minutes.format("%02d"));
      WatchUi.requestUpdate();
    }
    var seconds = minutesFloat - minutesFloat.toNumber();
    var angle = seconds * 360.0;
    if (_angle != angle) {
      if (seconds == 0) {
        _fillArc = !_fillArc;
      }
      _angle = angle;
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
