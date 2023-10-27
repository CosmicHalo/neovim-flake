{core-inputs, ...}: let
  inherit (core-inputs.nixpkgs.lib) mkOption types mkEnableOption;
in {
  module = rec {
    #---------------------------------------#
    # Core
    #---------------------------------------#
    mkOpt = type: default: description:
      mkOption
      {inherit type default description;};

    mkOptWithExample = type: default: description: example:
      mkOption
      {inherit type default description example;};

    ## Create a NixOS module option without a description.
    mkOpt' = type: default: mkOpt type default null;

    #---------------------------------------#
    # Null options
    #---------------------------------------#

    ## Create a NixOS module option without a default.
    mkNullOpt = type: description: mkOpt type null description;

    ## Create a NixOS module option without a default and description.
    mkNullOpt' = type: mkOpt type null null;

    #---------------------------------------#
    # STR options
    #---------------------------------------#

    ## Create a boolean NixOS module option.
    mkStrOpt = mkOpt types.str;

    ## Create a boolean NixOS module option without a description.
    mkStrOpt' = mkOpt' types.str;

    #---------------------------------------#
    # Bool options
    #---------------------------------------#

    ## Create a boolean NixOS module option.
    mkBoolOpt = mkOpt types.bool;

    ## Create a boolean NixOS module option without a description.
    mkBoolOpt' = mkOpt' types.bool;

    #---------------------------------------#
    # Int options
    #---------------------------------------#

    ## Create a int NixOS module option.
    mkIntOpt = mkOpt types.int;

    ## Create a int NixOS module option without a description.
    mkIntOpt' = mkOpt' types.int;

    #---------------------------------------#
    # Euum options
    #---------------------------------------#

    ## Create a int NixOS module option.
    mkEnumOpt = enumType: mkOpt (types.enum enumType);

    ## Create a int NixOS module option without a description.
    mkEnumOpt' = enumType: mkOpt' (types.enum enumType);

    #---------------------------------------#
    # Enabled options
    #---------------------------------------#

    ## Create an enabled module option.
    mkEnableOpt = name: {
      enable = mkEnableOption name;
    };

    ## Create an enabled module option defaulting to true.
    mkEnableOpt' = name: {
      enable = mkOpt types.bool true "Whether to enable ${name}.";
    };

    enabled = {
      ## Quickly enable an option.
      enable = true;
    };

    disabled = {
      ## Quickly disable an option.
      enable = false;
    };
  };
}
