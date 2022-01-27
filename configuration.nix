{ config, pkgs, ... }:

with pkgs;
let
  my-python-packages = python-packages: with python-packages; [
    requests
  ]; 
  python-with-my-packages = python3.withPackages my-python-packages;
in
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Timezone
  time.timeZone = "America/Sao_Paulo";

  # OpenGL
  hardware.opengl.enable = true;

  # Networking
  networking.hostName = "i5"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  
  # Non-root user
  users.extraUsers.arroyo = {
    isNormalUser = true;
    home = "/home/arroyo";
    extraGroups = [ "wheel" "qemu-libvirtd" "libvirtd" "docker" ];
    shell = pkgs.fish;
  };

  # Disable sudo password
  security.sudo.wheelNeedsPassword = false;

  # Enable libvirtd
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  # Enable docker
  virtualisation.docker.enable = true;
  
  # Xorg
  services.xserver = {
    enable = true;
    layout = "br";

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };


  # System packages
  environment.systemPackages = with pkgs; [
    postgresql
    python-with-my-packages
    wget
    xorg.xmodmap
    zip
    filezilla
    pavucontrol
    tdesktop
    docker
    vagrant
    pulumi-bin
    bitwarden
    bitwarden-cli
    nodejs
    whatsapp-for-linux
    # stack
  ];

  # Arroyo programs
  home-manager.users.arroyo = {
    programs = {
      firefox = {
        enable = true;
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
      };

      vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          haskell.haskell
          justusadam.language-haskell
          jnoortheen.nix-ide
          asvetliakov.vscode-neovim
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            "name" = "monokai-charcoal-high-contrast";
            "publisher" = "74th";
            "version" = "3.4.0";
            "sha256" = "2ec51074ee2052e065b4ef2a04e9e186edbde4e3b7d59eca4cbec78a316fc817";
          }
        ];
      };

      kitty = {
        enable = true;
      };

      git = {
        enable = true;
        userName = "leonardoarroyo";
        userEmail = "git@leonardoarroyo.com";
        extraConfig = {
          alias = {
            co = "checkout";
            ci = "commit";
            st = "status";
          };
        };
      };

      fish = {
        enable = true;
      };

      rofi = {
        enable = true;
      };
    };
  };

  # Haskell binary caches
  nix = {
    binaryCaches          = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
    binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
