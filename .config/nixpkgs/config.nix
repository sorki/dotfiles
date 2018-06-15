with import <nixpkgs> {};


let
  minimal = [
    rxvt_unicode
    irssi
    screen
    tree
    wget
    curl
    openssl
  ];

  audio = [
    ardour
    # audacious
    # vcvrack
    supercollider
    #supercollider_sc3_plugins
    #supercollider-with-plugins # -- FIXME
  ];

  desktop = [
    wmname
    feh
    firefox
    libreoffice
    kicad
    epdfview
    mate.atril
    graphviz
    gimp
    parcellite
    urxvt_perls
    wireshark
    redshift
    scrot
    stalonetray
    xsel
    geeqie

    #openscad
    #slic3r

    gnuplot
    qrcode

    texlive.combined.scheme-small

    virtmanager
    gnome3.dconf # due to virt-managers amnesia

    x264
    vlc
    ffmpeg
    youtube-dl
    # transmission-gtk

    xsane
  ];

  devel = [
    gitFull
    nix-prefetch-scripts
    nix-repl
    nox
    #nixopsUnstable
  ];

  embedded-devel = [
    gcc-arm-embedded

    dfu-util

    # FPGA
    arachne-pnr
    icestorm
    verilog
    yosys
    #(callPackage ./riscv-gnu.nix {})
    # orbuculum # -- FIXME
  ];

  games = [
    teeworlds
    #steam
  ];

  haskellish = with haskellPackages; [
    dhall
    escoger
    tidal
    pandoc
    xmobar
    blaze-from-html
    ghcid
  ];


  haskelldev = haskellPackages.ghcWithPackages
  (pkgs: with haskellPackages; [
    json-autotype
  ]);

  pythondev = python.withPackages
  (pkgs: with python35Packages; [
    canopen
  ]);

in
{
  packageOverrides = pkgs: rec {
    srk = buildEnv {
      name = "srk";
      paths = [
        myvim
        mydesktop
        haskellDev
        pythonDev
      ];
    };

    mydesktop = buildEnv {
      name = "mydesktop";
      paths = minimal
           ++ audio
           ++ desktop
           ++ devel
           ++ embedded-devel
           ++ games
           ++ haskellish;
    };

    haskellDev = buildEnv {
      name = "haskellDev";
      paths = [ haskelldev ];
    };

    pythonDev = buildEnv {
      name = "pythonDev";
      paths = [ pythondev ];
    };

    myvim = vim_configurable.customize {
      name = "myvim";
      vimrcConfig.packages.thisPackage.start = with vimPlugins; [
        vimwiki
        vimwiki-tasks
        vim-nix
        haskellConcealPlus
        vim-tidal
      ];
    };


  };

  allowUnfree = true;
  allowBroken = true;
}
