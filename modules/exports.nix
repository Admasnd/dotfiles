{
  inputs,
  ...
}:
{
  # Export aspects publicly
  imports = [ (inputs.den.namespace "admasnd" true) ];
}
