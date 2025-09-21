{
  sops.secrets."user_passwords/root".neededForUsers = true;

  users.users.root = {
    uid = 0;
    # Generate with `mkpasswd > secrets/root_password`
    hashedPasswordFile = "/run/secrets-for-users/user_passwords/root";
  };
}
