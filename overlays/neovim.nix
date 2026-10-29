(final: prev: {
  neovim = prev.symlinkJoin {
    name = "neovim-wrapped";
    paths = [ prev.neovim ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.sqlite ]}"
    '';
  };
})
