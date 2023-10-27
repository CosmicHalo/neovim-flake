{lib}:
with lib; rec {
  fromInputs = inputs: prefix:
    mapAttrs'
    (n: v: nameValuePair (removePrefix prefix n) {src = v;})
    (filterAttrs (n: _: hasPrefix prefix n) inputs);

  pluginsFromInputs = inputs: fromInputs inputs "plugin-";
}
