storage_keys = """    VERSION,
     SETTINGS_POM_TIME,
     SETTINGS_SHORT_BREAK,
     SETTINGS_LONG_BREAK,
     SETTINGS_POM_COUNT_TO_LONG,

     STATE_CURRENT,
     STATE_COUNT,
     STATE_LAST_STORE""".strip().replace(
     "\n", ""
 ).replace(
     " ", ""
 ).split(
     ","
 )[1:]

for k in storage_keys:
      words = k.split("_")[1:]
      name = "".join(w.capitalize() for w in words)
      print(
          f"""
    function get{name}() as Number {{
      return Storage.getValue({k});
    }}
    function set{name}(value as Number) {{
        Storage.setValue({k}, value);
    }}
    """
      )
