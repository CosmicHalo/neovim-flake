{
  lib,
  inputs,
  sources ? import ../nix/sources.nix,
}: {
  rawPlugins = lib.andromeda.input.fromInputs sources;
  # rawPlugins = lib.andromeda.input.fromInputs inputs "plugin-";
}
