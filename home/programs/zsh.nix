{ config, pkgs, ... }:
{
    # zsh settings (powerlevel10k, wallust, fastfetch)
    programs.zsh = {
        enable = true;
        initExtra = ''
            source ~/.p10k.zsh
            bindkey -e
            fastfetch
        '';
        plugins = [   
            {                                                                                   
                name = "powerlevel10k";                                                           
                src = pkgs.zsh-powerlevel10k;                                                     
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";                         
            }
        ];
        shellAliases = {
            ls = "eza --icons";
            ll = "eza --icons -la";
            nrs = "sudo nixos-rebuild switch --flake . --verbose --show-trace --specialisation";
            update = "nix flake update";
            office = "wlr-randr --output eDP-1 --off --output DP-7 --mode 1920x1080 0,0 --output DP-6 --mode 1920x1080 1920,0 --output HDMI-A-1 --mode 1280x720 3840,0 --transform 90";
            laptop = "wlr-randr --output eDP-1 --mode 1920x1080 0,0 --output DP-7 --off --output DP-6 --off --output HDMI-A-1 --off";
            backup = "rclone sync --log-level NOTICE --log-file=/home/wingej0/.config/rclone/log.txt --stats 2s --progress --transfers 32 --checkers 32 --check-first --delete-during --retries 1 --max-backlog 999999 --buffer-size 256M --copy-links /home/wingej0 --filter-from /home/wingej0/.config/rclone/filter.txt personal:backup";
            personal = "rclone mount personal: cloud/personal --daemon";
            upersonal = "sudo umount cloud/personal";
            work = "rclone mount work: cloud/work --daemon";
            uwork = "sudo umount cloud/work";
            private = "sudo mount -t ecryptfs Pictures/.backup Pictures/backup -o ecryptfs_cipher=aes -o ecryptfs_key_bytes=16 -o ecryptfs_unlink_sigs -o ecryptfs_fnek_sig=de0c23f0827ccfe3 -o ecryptfs_sig=de0c23f0827ccfe3";
            uprivate = "sudo umount Pictures/backup";       
        };
    };
}