{
  # TODO: freeipa or some other authentication management? lldap? needs to support kerberos
  services.nfs.server = {
    enable = true;
    exports = ''
      /pool/backup     10.20.0.0/16(rw,no_subtree_check)
      /pool/media      10.20.0.0/16(rw,no_subtree_check)
      /pool/old_disks  10.20.0.0/16(rw,no_subtree_check)
      /pool/services   10.20.0.0/16(rw,no_subtree_check)
      /pool/transfer   10.20.0.0/16(rw,no_subtree_check)
    '';
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
