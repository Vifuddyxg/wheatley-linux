# Wheatley live session: on the first console (tty1) auto-launch the installer.
# On any other tty (or after the installer exits) you get a normal shell.
case "$(tty)" in
/dev/tty1)
    clear
    cat <<'EOF'

  Welcome to Wheatley Linux (live).

  Launching the installer...  (press Ctrl-C to drop to a shell instead)
  No network? Run 'nmtui' to connect, then 'sudo wheatley-install'.

EOF
    # only auto-start once, and only if the installer is present
    if [ -z "${WHEATLEY_NOAUTO:-}" ] && command -v wheatley-install >/dev/null 2>&1; then
        export WHEATLEY_NOAUTO=1
        sudo wheatley-install || true
        cat <<'EOF'

  Installer exited. Re-run any time with:  sudo wheatley-install
  Preview a window manager with:           startx        (apeturewm)

EOF
    fi
    ;;
*)
    command -v wheatley-install >/dev/null 2>&1 && \
        echo "Wheatley live — run 'sudo wheatley-install' to install."
    ;;
esac
