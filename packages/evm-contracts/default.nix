{
  halfBoardModule = {
    dependencies = [
      ../..
    ];
    outputs = [
      "out"
    ];
    includedFiles = [
      ./package.json
      ./foundry.toml
      ./remappings.txt
      # nix 2.18.2 regression: ./.solhint.json
      #   - https://github.com/NixOS/nix/pull/10327
      "\.solhint\.json$"
      ./src
      ./script
      ./test
      ./wagmi.config.ts
      ./tsconfig.json
    ];
  };
}
