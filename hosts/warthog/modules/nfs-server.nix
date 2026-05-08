{
  # TODO: freeipa or some other authentication management? lldap? needs to support kerberos
  services.nfs.server = {
    enable = true;
    exports = ''
      /pool/backup     10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
      /pool/media      10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
      /pool/old_disks  10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
      /pool/services   10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
      /pool/transfer   10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
      /pool/camera     10.0.0.0/8(rw,no_subtree_check) 2a01:4b00:bd20:7010::/64(rw,no_subtree_check)
    '';
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
