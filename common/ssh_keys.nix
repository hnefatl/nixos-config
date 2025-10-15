{
  # User public keys
  keith = {
    laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop";
    desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVXUPyteZDsBXLsiFSVpW8Qr9qXi4wY7NkEQLeADAim keith@desktop";
    warthog = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9Fy/pN77dfMrER6gnP+cnxNdn2J/eJQ2NDzPWrGvPN keith@warthog";
    corp-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister";
  };
  # Host keys (for known hosts checking)
  hosts = {
    warthog = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4jIgx+67E0XCzKHKQ0WxEYZoMYB8011JQOArGWvWY2 warthog";
  };
  zfsreplicator = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzNe+/idMWvukllAbesse5AGU26QeBTNNaHt9THmHXH zfsreplicator";
}
