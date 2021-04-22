pkgs:
  let
    b = builtins; l = p.lib; p = pkgs; t = l.types;
    ini = p.formats.ini {};
    json = p.formats.json {};

    get-type = type-str:
      if type-str == "ini" then
        ini.type
      else if type-str == "json" then
        json.type
      else if t?${type-str} then
        t.${type-str}
      else
        null;
  in
  type:
    l.mkOptionType
      { name = "null-or ${type.name}";
        inherit (t.nullOr type) check;

        merge = loc: defs:
          let
            filtered =
              b.filter
                (d: d.value != null)
                defs;
          in
          if b.length filtered == 0 then
            null
          else
            type.merge loc filtered;
      }
