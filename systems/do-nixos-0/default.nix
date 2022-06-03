{ imports = [ ./do.nix ];
  system.stateVersion = "21.05";

  users.users.mason.openssh.authorizedKeys.keys =
      [ (import ../hp-envy/info.nix).ssh-keys.mason
        (import ../surface-go/info.nix).ssh-keys.mason
      ];
}
