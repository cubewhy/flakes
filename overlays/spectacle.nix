(final: prev: {
  kdePackages = prev.kdePackages.overrideScope (
    kdeFinal: kdePrev: {
      spectacle = kdePrev.spectacle.override {
        tesseractLanguages = [
          "fra"
          "eng"
          "deu"
          "spa"
          "chi_sim"
          "chi_tra"
          "jpn"
        ];
      };
    }
  );
})
