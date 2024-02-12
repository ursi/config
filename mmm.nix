l:
with builtins;
let
  users = [ "mason" "root" ];
  moves = { i3 = "xsession.windowManager.i3"; };

  removeAttrsByPath = path: set:
    let
      next = head path;
      rest = tail path;
      wipe = removeAttrs set [ next ];
    in
    if rest == [] then
      wipe
    else
    let new = removeAttrsByPath rest (set.${next} or {}); in
    wipe // l.optionalAttrs (new != {}) { ${next} = new; };

  # [String] -> [[String]] -> Set -> Set
  moveAttr = from: to: set:
    removeAttrsByPath from
      (foldl'
         (acc: path:
            if l.hasAttrByPath from acc then
              l.recursiveUpdate
                acc
                (l.setAttrByPath path (l.getAttrFromPath from acc))
            else
              acc)
         set
         to);

  hm-paths = map (user: [ "home-manager" "users" user ]) users;
in
set:
  l.pipe moves
    [ l.attrsToList
      (map (nv: moveAttr
                  ([ "my-modules" ] ++ l.splitString "." nv.name ++ [ "hm" ])
                  (map (path: path ++ l.splitString "." nv.value) hm-paths)))
      (ms: ms ++ [ (moveAttr [ "my-modules" "hm" ] hm-paths) ])
      (foldl' (acc: f: set: (acc (f (set)))) (_:_))
      (f: f set)
    ]
