# SonicWall ConnectTunnel in Docker/Podman with SELinux

Step 0: Get ConnectTunnel-Linux64.tar from your friendly VPN webpage/admin.

Build the image:
```
podman build -t startct .
```
Add the SELinux module defined in [`connecttunnel-container.cil`](./connecttunnel-container.cil), otherwise ConnectTunnel won't work inside the container:
```
sudo semodule -i connecttunnel-container.cil
```

Ensure the host kernel has the `tun` module:
```
modprobe -v tun
```

Start an interactive container
```
podman run -it --rm --cap-add NET_ADMIN --device /dev/net/tun --publish 1080:1080 --security-opt label=type:connecttunnel-container.process startct --server <SERVER>
```
Log in when prompted.
Optionally pass the `--realm` `--username` and `--password` arguments.

Configure a proxy extension such as [FoxyProxy](https://addons.mozilla.org/en-GB/firefox/addon/foxyproxy-standard/) to SOCKS5 `127.0.0.1:1080`. Make sure to proxy DNS.

Testable with: curl -x socks5h://localhost:1080 http://icanhazip.com


## SELinux notes

The `connecttunnel-container` SELinux module was created with the help of `audit2allow` and `checkmodule`:
```
audit2allow -a -M connecttunnel-container
```
If necessary edit `connecttunnel-container.te` to remove permissions related to other applications, then create the CIL file:
```
checkmodule -C -m -o connecttunnel-container.cil connecttunnel-container.te
```

If you need to modify the SELinux policy it's probably easiest to manually convert/add the output of `audit2allow` to `connecttunnel-container.cil`.

Update the module:
```
semodule -i connecttunnel-container.cil
```
Uninstall the module:
```
semodule -r connecttunnel-container
```
