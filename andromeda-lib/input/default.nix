{core-inputs, ...}: let
  inherit (core-inputs.nixpkgs.lib) mapAttrs' filterAttrs hasPrefix removePrefix nameValuePair;
in {
  input = rec {
    fromInputs = inputs: fromInputsWithPrefix inputs "";

    fromInputsWithPrefix = inputs: prefix:
      mapAttrs'
      (n: v: nameValuePair (removePrefix prefix n) {src = v;})
      (filterAttrs (n: _: (hasPrefix prefix n) && (!hasPrefix "__" n)) inputs);
  };
}
