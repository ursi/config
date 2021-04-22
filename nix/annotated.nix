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
  l.mkOptionType
    { name = "annotated";
      check = a:
        if a?value && a?type then
          let type = get-type a.type; in
          if type != null then
            type.check a.value
          else
            false
        else
          false;

      merge = loc: defs:
        let
          type-str = (b.head defs).value.type;
          type = get-type type-str;
        in
        if b.all (a: a.value.type == type-str) defs then
          if type != null then
            { value =
                type.merge
                  loc
                  (b.map
                     (d: d // { value = d.value.value; })
                     defs
                  );

              type = type-str;
            }
          else
            b.throw "this should never happen because of 'check'"
        else
          b.throw "Not all the types for ${b.concatStringsSep "." loc} are the same.";
    }
