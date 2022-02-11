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

  # Nvidia
  # services.xserver.videoDrivers = [ "nvidia" ];

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

  # Flatpak
  services.flatpak.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  xdg.portal.enable = true;
  
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

  # Enable virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "arroyo" ];
  
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

  # GNUPG
  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "curses";
     enableSSHSupport = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry
    pinentry-curses
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
    stack
    evince
    okular
    xournal
    gimp
    hakuneko
    qbittorrent
    qimgv
    scrot
    calibre
    slack
    zoom-us
    teams
    evolution
    git-crypt
    chromium
  ];

  programs.steam.enable = true;
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
        package = pkgs.vscode;
        extensions = with pkgs.vscode-extensions; [
          haskell.haskell
          justusadam.language-haskell
          jnoortheen.nix-ide
          asvetliakov.vscode-neovim
	  eamodio.gitlens
          ms-vscode-remote.remote-ssh
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            "name" = "monokai-charcoal-high-contrast";
            "publisher" = "74th";
            "version" = "3.4.0";
            "sha256" = "2ec51074ee2052e065b4ef2a04e9e186edbde4e3b7d59eca4cbec78a316fc817";
          }
          {
            "name" = "github-markdown-preview";
            "publisher" = "bierner";
            "version" = "0.1.0";
            "sha256" = "8c7b0d454a2d95e7a1f28265d98a1a84039b818b95b05c227fb21952c3f44a4f";
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
	    lp = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          };
        };
      };

      fish = {
        enable = true;
      };

      rofi = {
        enable = true;
      };

      # whatsappForLinux = {
      # 	enable = true;
      #   package = pkgs.whatsapp-for-linux;
      # };
    };
  };

  # Haskell binary caches
  nix = {
    binaryCaches          = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
    binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  };

  # Allow unfree
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
