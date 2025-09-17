{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."keith" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3J/ndFYzeWuY/CGBHNimWBay3+kxoqA1UhH/1trO9zvPXeWkchthMrN86LxO4vbkFCUVXGaQyTy2OgdPiRlULLD2get0XWQ7myVOQXx16pARZnPj8uov1aP6PcRIRbgWdxwAI8HyR9k/EgktbczUwW1PysESsRZNbmKDtnN3a/UabkG3GeyxKTCQGux7wYOFIIYP61IGhLRVF+yWXoOprlp/M53UNy7bXbskEUygH6OGZiu5gsWSMQKCnrEFPeiLc83HmlUmClOxlseH2pMtR1nH80ftKuH9CCO+lweRkluSR1zkhX8t5fUp3/ixNIpZHOvePRAc+lPWWmbT7zrFz2UbcnXTJapK8auEPlxeSmj6w45cCKs5VMUyXz5JKIvrtzIolJd6i0b0fUskxj30vVXTi58ENqfcoDgOfLNTJU5ZhYUee8MERcs0UJapFUjznHrZTxoi1SD/8AgM1Y+Jq2P97TfYuBJby8YQ74QFjPwxaYKvd226ZSAnaSwKPKU= keith@desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
    ];
  };
}
