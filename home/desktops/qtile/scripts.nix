{ pkgs, ... }:
let
  # Clipboard history picker. No argument pastes, `d` deletes an entry,
  # `w` wipes the history after asking.
  qtile-clipboard = pkgs.writeShellApplication {
    name = "qtile-clipboard";
    runtimeInputs = with pkgs; [ cliphist rofi wl-clipboard ];
    text = ''
      case "''${1:-}" in
        d)
          cliphist list | rofi -dmenu -theme menu -p "Delete" | cliphist delete
          ;;
        w)
          if [ "$(printf 'Clear\nCancel' | rofi -dmenu -theme menu -p "Clear history?")" = "Clear" ]; then
            cliphist wipe
          fi
          ;;
        *)
          cliphist list | rofi -dmenu -theme menu -p "Clipboard" | cliphist decode | wl-copy
          ;;
      esac
    '';
  };

  # Screenshot of an area or the whole layout, opened in swappy for editing
  qtile-screenshot = pkgs.writeShellApplication {
    name = "qtile-screenshot";
    runtimeInputs = with pkgs; [ grim slurp swappy rofi libnotify ];
    text = ''
      area="Selected area"
      full="Fullscreen (delay 3 sec)"

      choice=$(printf '%s\n%s' "$area" "$full" | rofi -dmenu -theme menu -i -p "Screenshot") || exit 0

      case "$choice" in
        "$area")
          geometry=$(slurp) || exit 0
          grim -g "$geometry" - | swappy -f -
          ;;
        "$full")
          sleep 3
          grim - | swappy -f -
          ;;
      esac
    '';
  };

  # Record an area to a GIF. Run it again to stop recording.
  qtile-gif-recorder = pkgs.writeShellApplication {
    name = "qtile-gif-recorder";
    runtimeInputs = with pkgs; [ wf-recorder slurp zenity ffmpeg procps coreutils ];
    text = ''
      # A second press stops the running recording
      if pkill --euid "$USER" --signal SIGINT wf-recorder; then
        exit 0
      fi

      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      geometry=$(slurp) || exit 0

      # Stop after 10 minutes in case it was forgotten
      timeout 600 wf-recorder -g "$geometry" -f "$tmp/capture.mp4" || true
      [ -s "$tmp/capture.mp4" ] || exit 1

      save=$(zenity --file-selection --save --confirm-overwrite \
        --file-filter='*.gif' --filename="$HOME/Videos/.gif") || exit 0
      [[ $save == *.gif ]] || save+=".gif"

      ffmpeg -i "$tmp/capture.mp4" -filter_complex "palettegen=stats_mode=full" "$tmp/palette.png" -y
      ffmpeg -i "$tmp/capture.mp4" -i "$tmp/palette.png" -filter_complex "paletteuse=dither=sierra2_4a" "$save" -y
    '';
  };

  # On AC, pick a battery charge threshold; on battery, pick a power profile.
  # system76-power comes from the system so it matches the running daemon.
  qtile-power = pkgs.writeShellApplication {
    name = "qtile-power";
    runtimeInputs = with pkgs; [ rofi libnotify gawk ];
    text = ''
      if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
        current=$(system76-power charge-thresholds | awk -F': ' '/Profile/{print $2}')
        choice=$(printf 'Full Charge\nBalanced\nMax Lifespan' | rofi -dmenu -theme menu -i -p "Charge ($current)") || exit 0
        case "$choice" in
          "Full Charge") system76-power charge-thresholds --profile full_charge ;;
          "Balanced") system76-power charge-thresholds --profile balanced ;;
          "Max Lifespan") system76-power charge-thresholds --profile max_lifespan ;;
          *) exit 0 ;;
        esac
        notify-send "Charge threshold" "$choice"
      else
        current=$(system76-power profile | awk '/Power Profile/{print $NF}')
        choice=$(printf 'Battery\nBalanced\nPerformance' | rofi -dmenu -theme menu -i -p "Power ($current)") || exit 0
        case "$choice" in
          Battery | Balanced | Performance) system76-power profile "''${choice,,}" ;;
          *) exit 0 ;;
        esac
        notify-send "Power profile" "$choice"
      fi
    '';
  };
in
{
  home.packages = [
    qtile-clipboard
    qtile-screenshot
    qtile-gif-recorder
    qtile-power
  ];
}
