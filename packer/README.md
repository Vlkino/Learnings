# **Note for me when using WSL and Packer, WSL run in isolated enviroment.**

Any service which is exposing port to the host machine is accesible only on host machine and not others devices.
Use this command to create proxy, Run in with evaulated powershell:
```
netsh interface portproxy add v4tov4 listenport=expected_port listenaddress=0.0.0.0 connectport=expected_port connectaddress=wsl_ip_address
```

> Source: https://chemejon.io/how-to-use-packer-and-subiquity-on-wsl2/
