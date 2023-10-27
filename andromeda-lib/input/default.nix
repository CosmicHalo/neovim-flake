{core-inputs, ...}: let
  inherit (core-inputs.nixpkgs.lib) mapAttrs' filterAttrs hasPrefix removePrefix nameValuePair;
in {
  input = {
    fromInputs = inputs: prefix:
      mapAttrs'
      (n: v: nameValuePair (removePrefix prefix n) {src = v;})
      (filterAttrs (n: _: hasPrefix prefix n) inputs);
  };
}
