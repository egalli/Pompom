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
  private var _lastTime as Number;

  public function initialize() {
    View.initialize();
    _isBreak = false;
    _minutes = 0;
    _angle = 0;
    _fillArc = true;
    _count = 0;
    _lastTime = 0;
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.CountdownLayout(dc));
    _timeLbl = View.findDrawableById("timeLbl");
    _countLbl = View.findDrawableById("countLbl");
    _pauseOverlay = new $.Rez.Drawables.pauseOver();
    _isPaused = false;
    _fillArc = true;
    _lastTime = 0;
    System.println("layout");

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
      if (!_fillArc) {
        System.println(_angle);
        dc.drawArc(x, y, x - 2, Graphics.ARC_CLOCKWISE, _angle + 90, 90);
      } else if (_angle != 0) {
        System.println(_angle);
        dc.drawArc(
          x,
          y,
          x - 2,
          Graphics.ARC_COUNTER_CLOCKWISE,
          _angle + 90,
          90
        );
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
    var minutes = Math.ceil(time / 60.0).toNumber();
    if (_timeLbl != null && _minutes != minutes) {
      _timeLbl.setText(minutes.format("%02d"));
      WatchUi.requestUpdate();
    }
    var seconds = time % 60;
    var angle = (seconds / 60.0) * 360.0;
    if (seconds == 0) {
      _fillArc = !_fillArc;
      WatchUi.requestUpdate();
    } else if (_angle != angle) {
      WatchUi.requestUpdate();
    }
    _angle = angle;
    _minutes = minutes;
    _lastTime = time;
  }

  public function setCount(count as Number) {
    if (_timeLbl != null && _count != count) {
      _countLbl.setText(count.toString());
      WatchUi.requestUpdate();
    }
    _count = count;
  }
}
