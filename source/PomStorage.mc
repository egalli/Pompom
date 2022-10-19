import Toybox.Application.Storage;
import Toybox.System;

module AppState {
  const PAUSED = 0x100;

  function isPaused(state as AppState) {
    return (state & PAUSED) != 0;
  }

  enum AppState {
    MAIN_VIEW = 0x0,
    POM = 0x1,
    BREAK_SHORT = 0x2,
    BREAK_LONG = 0x3,

    POM_PAUSED = POM | PAUSED,
    BREAK_SHORT_PAUSED = BREAK_SHORT | PAUSED,
    BREAK_LONG_PAUSED = BREAK_LONG | PAUSED,
  }
}

module PomStorage {
  const SETTINGS_VERSION = 0;

  enum StorageKeys {
    VERSION,
    SETTINGS_POM_TIME,
    SETTINGS_SHORT_BREAK,
    SETTINGS_LONG_BREAK,
    SETTINGS_POM_COUNT_TO_LONG,

    // Current application state
    STATE_CURRENT,
    STATE_COUNT,
    STATE_LAST_STORE,
  }

  function setupStorage() {
    if (Storage.getValue(VERSION) == SETTINGS_VERSION) {
      return;
    }
    System.println("Resetting setting");
    Storage.setValue(VERSION, SETTINGS_VERSION);
    Storage.setValue(SETTINGS_POM_TIME, 25);
    Storage.setValue(SETTINGS_SHORT_BREAK, 5);
    Storage.setValue(SETTINGS_LONG_BREAK, 15);
    Storage.setValue(SETTINGS_POM_COUNT_TO_LONG, 4);

    Storage.setValue(STATE_CURRENT, $.AppState.MAIN_VIEW);
    Storage.setValue(STATE_COUNT, 0);
  }

  function getPomTime() as Number {
    return Storage.getValue(SETTINGS_POM_TIME);
  }
  function setPomTime(value as Number) {
    Storage.setValue(SETTINGS_POM_TIME, value);
  }

  function getShortBreak() as Number {
    return Storage.getValue(SETTINGS_SHORT_BREAK);
  }
  function setShortBreak(value as Number) {
    Storage.setValue(SETTINGS_SHORT_BREAK, value);
  }

  function getLongBreak() as Number {
    return Storage.getValue(SETTINGS_LONG_BREAK);
  }
  function setLongBreak(value as Number) {
    Storage.setValue(SETTINGS_LONG_BREAK, value);
  }

  function getPomCountToLong() as Number {
    return Storage.getValue(SETTINGS_POM_COUNT_TO_LONG);
  }
  function setPomCountToLong(value as Number) {
    Storage.setValue(SETTINGS_POM_COUNT_TO_LONG, value);
  }

  function getCurrent() as AppState {
    return Storage.getValue(STATE_CURRENT);
  }
  function setCurrent(value as AppState) {
    Storage.setValue(STATE_CURRENT, value);
  }

  function getCount() as Number {
    return Storage.getValue(STATE_COUNT);
  }
  function setCount(value as Number) {
    Storage.setValue(STATE_COUNT, value);
  }

  function getLastStore() as Number {
    return Storage.getValue(STATE_LAST_STORE);
  }
  function setLastStore(value as Number) {
    Storage.setValue(STATE_LAST_STORE, value);
  }
}
