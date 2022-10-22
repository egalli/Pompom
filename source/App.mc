import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

(:background)
class BackgroundDelegate extends System.ServiceDelegate {
  public function initialize() {
    ServiceDelegate.initialize();
  }

  public function onTemporalEvent() {
    if ($.PomStorage.getCurrent() != $.AppState.MAIN_VIEW) {
      Background.requestApplicationWake("Countdown finished");
    }
    Background.exit(true);
  }
}

(:background)
class PompomApp extends Application.AppBase {
  private var _logic as PomLogic?;

  function initialize() {
    AppBase.initialize();
  }

  function getInitialView() as Array<Views or InputDelegates>? {
    _logic = new PomLogic();

    return [_logic.getInitialView(), _logic];
  }

  function getServiceDelegate() as Array<ServiceDelegate> {
    return [new BackgroundDelegate()] as Array<ServiceDelegate>;
  }

  function onStop(state as Lang.Dictionary?) as Void {
    if (_logic != null) {
      _logic.saveState();
    }
  }
}

function getApp() as PompomApp {
  return Application.getApp() as PompomApp;
}
