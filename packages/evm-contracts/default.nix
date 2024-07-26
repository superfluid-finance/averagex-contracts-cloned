{
  halfBoardModule = {
    dependencies = [
      ../..
    ];
    outputs = [
      "out"
    ];
    includedFiles = [
      ./Makefile
      ./foundry.toml
      ./remappings.txt
      ./src
      ./script
      ./test
      ./.solhint.json
    ];
  };
}
