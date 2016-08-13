#! @shell@

set -e

showSyntax() {
    # exec man nixup #!!! FIXME
    cat <<'EOF'
Usage:
    nixup init
    nixup {switch | build | dry-switch | dry-build} [--rollback]
EOF
    exit 1
}

initNixup() {
    mkdir -p "$HOME/.nixup"
    if [ ! -e "$HOME/.nixup/configuration.nix" ]; then
        echo > "$HOME/.nixup/configuration.nix" <<'EOF'
{ pkgs, ... }:
{
  user.packages = with pkgs; [ nixup ];

  user.resourceFiles.test = {
    target = ".nixup-test";
    text = "blah";
  };
}
EOF
    fi

    cat <<'EOF'
You can now add "nixup-config=$HOME/.nixup/configuration.nix" to your NIX_PATH and "$HOME/.nixup/profile/sw/bin" to your PATH.
EOF
    exit 1
}

if [ -z "$NIX_USER_PROFILE_DIR" ]; then
  NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
fi

# Parse the command line.
extraBuildFlags=()
action=
rollback=
upgrade=
repair=
profile=$NIX_USER_PROFILE_DIR/nixup

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      --help)
        showSyntax
        ;;
      init|switch|login|test|build|dry-build|dry-switch)
        action="$i"
        ;;
      --rollback)
        rollback=1
        ;;
      --upgrade)
        upgrade=1
        ;;
      --repair)
        repair=1
        extraBuildFlags+=("$i")
        ;;
      --show-trace|--no-build-hook|--keep-failed|-K|--keep-going|-k|--verbose|-v|-vv|-vvv|-vvvv|-vvvvv|--fallback|--repair|--no-build-output|-Q)
        extraBuildFlags+=("$i")
        ;;
      --max-jobs|-j|--cores|-I)
        j="$1"; shift 1
        extraBuildFlags+=("$i" "$j")
        ;;
      --option)
        j="$1"; shift 1
        k="$1"; shift 1
        extraBuildFlags+=("$i" "$j" "$k")
        ;;
      *)
        echo "$0: unknown option \`$i'"
        exit 1
        ;;
    esac
done

if [ -z "$action" ]; then showSyntax; fi

if [ "$action" = init ]; then
    initNixup
    exit 1
fi

if [ "$action" = login -o  "$action" = test ]; then
    echo "error: login-based commands are not yet implemented" >&2
    exit 1
fi

if [ "$action" = dry-build ]; then
    extraBuildFlags+=(--dry-run)
fi


# Get the new configuration, and build it if necessary
if [ -z "$rollback" ]; then
    echo "building the nixup configuration..." >&2
    pathToConfig="$(nix-build '<nixpkgs/nixup>' --no-out-link -A profile "${extraBuildFlags[@]}")"
else
    systemNumber=$(
        nix-env -p "$profile" --list-generations |
        sed -n '/current/ {g; p;}; s/ *\([0-9]*\).*/\1/; h'
    )
    pathToConfig="$profile"-${systemNumber}-link
fi

# If we're not just building, activate to the new configuration
case "$action" in
  switch|login|test|dry-switch)
    $pathToConfig/activate "$action"
    if ! [ $? -eq 0 ]; then
        echo "warning: error(s) occurred while switching to the new configuration" >&2
        exit 1
    fi
    ;;
  *)
    ;;
esac

# Set configuration as new default, or simply link it to ./result
case "$action" in
  switch|login)
    nix-env -p "$profile" --set "$pathToConfig"
    ;;
  *)
    ln -sfT "$pathToConfig" ./result
    ;;
esac
