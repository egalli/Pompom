import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.System;

// drawArc is kind of weird for even cirles (like the display). Therefore, we
// split it into 4 draws for each quadrant.
function drawSec(
  dc as Dc,
  r as Number,
  angle as Number,
  ccw as Boolean
) as Void {
  /*
  drawArc's angles
        90
   180 __|__ 0
         |
        270

  seconds to angles
         0
   270 __|__ 90
         |
        180

  */

  var x = dc.getWidth() / 2;
  var y = dc.getHeight() / 2;

  var arcAngle = (360 - angle + 90) % 360;
  var attr = Graphics.ARC_CLOCKWISE;

  if (!ccw) {
    if (angle <= 0) {
      return;
    }

    if (angle <= 90) {
      dc.drawArc(x, y - 1, r, attr, 90, arcAngle);
      return;
    } else {
      dc.drawArc(x, y - 1, r, attr, 90, 0);
    }
    if (angle <= 180) {
      dc.drawArc(x, y, r, attr, 360, arcAngle);
      return;
    } else {
      dc.drawArc(x, y, r, attr, 360, 270);
    }
    if (angle <= 270) {
      dc.drawArc(x - 1, y, r, attr, 270, arcAngle);
      return;
    } else {
      dc.drawArc(x - 1, y, r, attr, 270, 180);
    }
    dc.drawArc(x - 1, y - 1, r, attr, 180, arcAngle);
  } else {
    if (angle >= 360) {
      return;
    }
    if (angle >= 270) {
      dc.drawArc(x - 1, y - 1, r, attr, arcAngle, 90);
      return;
    } else {
      dc.drawArc(x - 1, y - 1, r, attr, 180, 90);
    }
    if (angle >= 180) {
      dc.drawArc(x - 1, y, r, attr, arcAngle, 180);
      return;
    } else {
      dc.drawArc(x - 1, y, r, attr, 270, 180);
    }
    if (angle >= 90) {
      dc.drawArc(x, y, r, attr, arcAngle, 270);
      return;
    } else {
      dc.drawArc(x, y, r, attr, 360, 270);
    }
    dc.drawArc(x, y - 1, r, attr, arcAngle, 0);
  }
}

module CountdownMode {
  enum CountdownMode {
    POM,
    SHORT_BREAK,
    LONG_BREAK,
  }

  function appStateToMode(state as AppState) as CountdownMode {
    switch ($.AppState.baseState(state)) {
      case $.AppState.BREAK_SHORT:
        return SHORT_BREAK;
      case $.AppState.BREAK_LONG:
        return LONG_BREAK;
      default:
        return POM;
    }
  }

  function modeToColor(mode as CountdownMode) as Graphics.ColorType {
    switch (mode) {
      case POM:
        return Graphics.COLOR_GREEN;
      case SHORT_BREAK:
        return Graphics.COLOR_BLUE;
      case LONG_BREAK:
        return Graphics.COLOR_PURPLE;
    }
    // This shouldn't happen
    return Graphics.COLOR_TRANSPARENT;
  }

  function modeToText(mode as CountdownMode) as Lang.String {
    // TODO: we should probably be using resource strings for these
    switch (mode) {
      case POM:
        return "Pom";
      case SHORT_BREAK:
        return "Short";
      case LONG_BREAK:
        return "Long";
    }
  }
}

class CountdownView extends WatchUi.View {
  private var _pauseOverlay as WatchUi.Drawable?;
  private var _isPaused as Boolean;
  private var _mode as CountdownMode;
  private var _color as Graphics.ColorType;
  private var _timeLbl as WatchUi.Text;
  private var _countLbl as WatchUi.Text;
  private var _msgLbl as WatchUi.Text;
  private var _angle as Number;
  private var _fillArc as bool;
  private var _minutes as Number;
  private var _count as Number;

  public function initialize() {
    View.initialize();
    _mode = $.CountdownMode.POM;
    _color = $.CountdownMode.modeToColor(_mode);
    _minutes = 0;
    _angle = 360;
    _fillArc = $.PomStorage.getFillArc();
    _count = 0;
  }

  public function reset() {
    // Will get flipping by the first setTime call
    _fillArc = true;
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.CountdownLayout(dc));
    _timeLbl = View.findDrawableById("timeLbl");
    _countLbl = View.findDrawableById("countLbl");
    _msgLbl = View.findDrawableById("msgLbl");
    _pauseOverlay = new $.Rez.Drawables.pauseOver();

    _timeLbl.setText(_minutes.format("%02d"));
    _countLbl.setText(_count.toString());
    _msgLbl.setText($.CountdownMode.modeToText(_mode));
    _timeLbl.setColor(_color);
  }

  public function onUpdate(dc as Dc) as Void {
    View.onUpdate(dc);
    if (_isPaused) {
      dc.setPenWidth(4);
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      drawSec(dc, 128, 360, false);
      _pauseOverlay.draw(dc);
    } else {
      dc.setPenWidth(7);
      dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
      drawSec(dc, 122, _angle, !_fillArc);
    }
  }

  public function onHide() as Void {
    $.PomStorage.setFillArc(_fillArc);
  }

  public function setMode(mode as CountdownMode) {
    var color = $.CountdownMode.modeToColor(mode);
    if (_timeLbl != null && _mode != mode) {
      _timeLbl.setColor(color);
      _msgLbl.setText($.CountdownMode.modeToText(mode));

      WatchUi.requestUpdate();
    }
    _mode = mode;
    _color = color;
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
    var angle = Math.round(seconds * 360.0).toNumber();
    if (angle == 0) {
      angle = 360;
    }
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
