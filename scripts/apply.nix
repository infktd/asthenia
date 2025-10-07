{ lib, pkgs, system }:

let
  colors = {
    red = "\\033[0;31m";
    green = "\\033[0;32m";
    yellow = "\\033[1;33m";
    nc = "\\033[0m";
  };

  # Helper functions
  print = msg: ''
    ${if pkgs.stdenv.isDarwin then ''
      echo -e "${msg}"
    '' else ''
      echo "${msg}"
    ''}
  '';

  prompt = message: variable: ''
    ${print message}
    read -r ${variable}
  '';

  openUrl = url: ''
    ${if pkgs.stdenv.isDarwin then ''
      ${pkgs.darwin.open}/bin/open "${url}"
    '' else ''
      ${pkgs.xdg-utils}/bin/xdg-open "${url}"
    ''}
  '';

in pkgs.writeShellScriptBin "apply" ''
  set -e

  VERSION=1.0

  # Color codes
  RED='${colors.red}'
  GREEN='${colors.green}'
  YELLOW='${colors.yellow}'
  NC='${colors.nc}'

  # Determine the operating system
  export OS=$(${pkgs.coreutils}/bin/uname)

  # Primary network interface
  if [[ "$OS" != "Darwin" ]]; then
    export PRIMARY_IFACE=$(${pkgs.iproute2}/bin/ip -o -4 route show to default | ${pkgs.gawk}/bin/awk '{print $5}')
    ${print "\${GREEN}Found primary network interface \$PRIMARY_IFACE\${NC}"}
  fi

  # Custom print function
  _print() {
    ${print "$1"}
  }

  # Custom prompt function
  _prompt() {
    local message="$1"
    local variable="$2"
    ${prompt "$message" "$variable"}
  }

  ask_for_star() {
    _print "''${YELLOW}Would you like to support my work by starring my GitHub repo? yes/no [yes]: ''${NC}"
    local response
    read -r response
    response=''${response:-yes} # Set default response to 'yes' if input is empty
    if [[ "$response" =~ ^[Yy](es)?$ ]] || [[ -z "$response" ]]; then
      ${openUrl "https://github.com/dustinlyons/nixos-config"}
    fi
  }

  ask_for_star

  # Fetch username from the system
  export USERNAME=$(${pkgs.coreutils}/bin/whoami)

  # If the username is 'nixos' or 'root', ask the user for their username
  if [[ "$USERNAME" == "nixos" ]] || [[ "$USERNAME" == "root" ]]; then
    _prompt "''${YELLOW}You're running as $USERNAME. Please enter your desired username: ''${NC}" USERNAME
  fi

  # Check if git is available
  if ${pkgs.git}/bin/git --version >/dev/null 2>&1; then
    # Fetch email and name from git config
    export GIT_EMAIL=$(${pkgs.git}/bin/git config --get user.email 2>/dev/null || echo "")
    export GIT_NAME=$(${pkgs.git}/bin/git config --get user.name 2>/dev/null || echo "")
  else
    _print "''${RED}Git is not available on this system.''${NC}"
  fi

  # If git email is not found or git is not available, ask the user
  if [[ -z "$GIT_EMAIL" ]]; then
    _prompt "''${YELLOW}Please enter your email: ''${NC}" GIT_EMAIL
  fi

  # If git name is not found or git is not available, ask the user
  if [[ -z "$GIT_NAME" ]]; then
    _prompt "''${YELLOW}Please enter your name: ''${NC}" GIT_NAME
  fi

  select_boot_disk() {
    local disks
    local _boot_disk

    _print "''${YELLOW}Available disks:''${NC}"
    disks=$(${pkgs.util-linux}/bin/lsblk -nd --output NAME,SIZE | ${pkgs.gnugrep}/bin/grep -v loop)
    echo "$disks"

    # Warning message for data deletion
    _print "''${RED}WARNING: All data on the chosen disk will be erased during the installation!''${NC}"
    _prompt "''${YELLOW}Please enter the name of your boot disk (e.g., sda, nvme0n1). Do not include the full path (\"/dev/\"): ''${NC}" _boot_disk

    # Confirmation for disk selection to prevent accidental data loss
    _print "''${YELLOW}You have selected $_boot_disk as the boot disk. This will delete everything on this disk. Are you sure? (Y/N): ''${NC}"
    read -r confirmation
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
      export BOOT_DISK=$_boot_disk
    else
      _print "''${RED}Disk selection cancelled by the user. Please run the script again to select the correct disk.''${NC}"
      exit 1
    fi
  }

  # Set hostname and find primary disk if this is NixOS
  if [[ "$OS" != "Darwin" ]]; then
    _prompt "''${YELLOW}Please enter a hostname for the system: ''${NC}" HOST_NAME
    export HOST_NAME
    select_boot_disk
  fi

  confirm_details() {
    _print "''${GREEN}Username: $USERNAME"
    _print "Email: $GIT_EMAIL"
    _print "Name: $GIT_NAME''${NC}"

    if [[ "$OS" != "Darwin" ]]; then
      _print "''${GREEN}Primary interface: $PRIMARY_IFACE"
      _print "Boot disk: $BOOT_DISK"
      _print "Hostname: $HOST_NAME''${NC}"
    fi

    _prompt "''${YELLOW}Is this correct? yes/no: ''${NC}" choice

    case "$choice" in
      [Nn] | [Nn][Oo] )
        _print "''${RED}Exiting script.''${NC}"
        exit 1
        ;;
      [Yy] | [Yy][Ee][Ss] )
        _print "''${GREEN}Continuing...''${NC}"
        ;;
      * )
        _print "''${RED}Invalid option. Exiting script.''${NC}"
        exit 1
        ;;
    esac
  }

  confirm_details

  # Function to replace tokens in each file
  replace_tokens() {
    local file="$1"
    if [[ $(${pkgs.coreutils}/bin/basename "$1") != "apply" ]]; then
      if [[ "$OS" == "Darwin" ]]; then
        # macOS
        LC_ALL=C LANG=C ${pkgs.gnused}/bin/sed -i '' -e "s/%USER%/$USERNAME/g" "$file"
        LC_ALL=C LANG=C ${pkgs.gnused}/bin/sed -i '' -e "s/%EMAIL%/$GIT_EMAIL/g" "$file"
        LC_ALL=C LANG=C ${pkgs.gnused}/bin/sed -i '' -e "s/%NAME%/$GIT_NAME/g" "$file"
      else
        # Linux or other
        ${pkgs.gnused}/bin/sed -i -e "s/%USER%/$USERNAME/g" "$file"
        ${pkgs.gnused}/bin/sed -i -e "s/%EMAIL%/$GIT_EMAIL/g" "$file"
        ${pkgs.gnused}/bin/sed -i -e "s/%NAME%/$GIT_NAME/g" "$file"
        ${pkgs.gnused}/bin/sed -i -e "s/%INTERFACE%/$PRIMARY_IFACE/g" "$file"
        ${pkgs.gnused}/bin/sed -i -e "s/%DISK%/$BOOT_DISK/g" "$file"
        ${pkgs.gnused}/bin/sed -i -e "s/%HOST%/$HOST_NAME/g" "$file"
      fi
    fi
  }

  # Traverse directories and call replace_tokens on each Nix file
  export -f replace_tokens
  ${pkgs.findutils}/bin/find . -type f -exec ${pkgs.bash}/bin/bash -c 'replace_tokens "$0"' {} \;

  echo "$USERNAME" > /tmp/username.txt
  _print "''${GREEN}User $USERNAME information applied.''${NC}"
''