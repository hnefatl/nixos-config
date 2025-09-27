{
  # If using another lock program, will need to update this PAM service name.
  security.pam.services.swaylock = {
    # Necessary to allow lockscreens
    text = ''
      auth include login
    '';
  };
}
