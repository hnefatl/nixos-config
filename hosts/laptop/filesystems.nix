{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "a5647497-3434-454a-bafc-eecb3f96412d";
    swap = "7ebfa198-972a-49ee-8f8c-e33c01271b8a";
    boot = "1fd3542b-4c9d-4355-ba94-2336252adfa1";
  };
}
