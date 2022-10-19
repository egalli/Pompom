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
    Background.requestApplicationWake("test!");
    Background.exit(true);
  }
}


(:background)
class PompomApp extends Application.AppBase {
  private var _logic as PomLogic;

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

  public function onKey(keyEvent as KeyEvent) as Boolean {
    return false;
  }
}

function getApp() as PompomApp {
  return Application.getApp() as PompomApp;
}
