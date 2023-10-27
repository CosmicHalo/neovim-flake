{
  lib,
  inputs,
}: {
  rawPlugins = lib.andromeda.input.fromInputs inputs "plugin-";
}
