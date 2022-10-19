import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.Application.Storage;
import Toybox.Time;

class MainView extends WatchUi.View {
  var _startElement as Drawable?;
  var _timer as Timer.Timer;

  public function initialize() {
    View.initialize();
    _timer = new Timer.Timer();
  }

  public function onLayout(dc as Dc) as Void {
    setLayout($.Rez.Layouts.MainLayout(dc));
    self._startElement = View.findDrawableById("start");

    _timer.start(method(:flashingCallback), 1000, true);
  }

  function onHide() {
    _timer.stop();
  }

  function flashingCallback() {
    self._startElement.setVisible(!self._startElement.isVisible);
    WatchUi.requestUpdate();
  }
}
