# Custom topology rules.
#
# - systemd-network interface names:
#   https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

# Full schema:
# https://oddlama.github.io/nix-topology/topology-options.html
{
  networks.home = {
    name = "Home";
    cidrv4 = "10.20.0.0/16";
  };
  nodes = {
    laptop.interfaces.wlp192s0.network = "home";
  };
}
