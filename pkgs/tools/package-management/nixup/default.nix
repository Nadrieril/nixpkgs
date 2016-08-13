{ pkgs }:

pkgs.substituteAll {
  name = "nixup";
  src = ./nixup.sh;
  dir = "bin";
  isExecutable = true;
}
