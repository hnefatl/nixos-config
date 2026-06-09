{ pkgs, ... }:
{
  home.packages = [
    # Orca-Slicer with bambuddy's virtual printer cert appended.
    (pkgs.orca-slicer.overrideAttrs (oldAttrs: {
      postInstall = oldAttrs.postInstall + ''
        cat << EOF >> "$out/share/OrcaSlicer/cert/printer.cer"

-----BEGIN CERTIFICATE-----
MIIC7jCCAdagAwIBAgIUMH8XwV813NnUafrjCLJ85tNUVuowDQYJKoZIhvcNAQEL
BQAwHTEbMBkGA1UEAwwSVmlydHVhbCBQcmludGVyIENBMB4XDTI2MDYwODE3NDgz
MloXDTQ2MDYwMzE3NDgzMlowHTEbMBkGA1UEAwwSVmlydHVhbCBQcmludGVyIENB
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3jm4jr6re8KiTe6T6DgP
bNdGhMwU7Nk/jIihKL9mpwu/MJpvVFUjB9G0PMrRchCkPSaueL7PMydqxb1jhrw3
xs+oSEySObFJ4LZV8DdcTYT+BveB7w5yXXWOGzOAVCTxKSgeU+FrJZP5Sz+LiZxL
kbGRJnvrDeIkJOb2Hoc/PsnvZTHEiewr8BonhepkeZqOujp+IsT/QnrfhuBz7dzr
m6NE5ZUVdkHy0ZlE7P12g3iWpe48oylfnTQqGTKZWJaoVmiUO/rW5SibUIBd/7Cm
VhB/P9VycifZQbsn2ATXlrHNu2llw43EsuAS45MDrTAFzzeNlJPHL4HT9xyCUiV7
ewIDAQABoyYwJDASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjAN
BgkqhkiG9w0BAQsFAAOCAQEATMk/uPr6S3jr+UzQlnsvt4ZWwskktejNklk3b5km
PkQnPLgngZbDpu9svnyIQeIADz5v2wDSuvoFyPMOXvc4//ayrWJZ5rQ+2jCyejep
nJxiH2RHbUGKmL0PChaOpuhsDnH5GILxaCaUw1qH/4A9d9459Hjw3BVPbF9RgxvX
PKZm2P9I0v5+FACWT6a34qKAGtUkhh/OwS6obE6Y9LKWuapyKJOQQ1Qf/r1hFLtA
GAkMwDD5Y07uTM+oYVHh4VrNzH/l9gMDHjvKPo1XlVw/Ho8Sbd20qbY6HXnxp7GT
gMcgaihbUjR16I7DqJeSFOUsMrlXSt+UumDv9o9T0IMTNg==
-----END CERTIFICATE-----
EOF
      '';
    }))
  ];
}
