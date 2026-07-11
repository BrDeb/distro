# distro
Distribuição baseada no Debian dando suporte e prioridade a conteúdo e software brasileiro

Setup e build:

```sh
git clone --recursive https://github.com/brdeb/distro
cd distro
git submodule update --init --recursive --remote # so por garantia
chmod +x lb-config/one_setup.sh
chmod +x lb-config/lb_config_brdeb.sh
sudo ./lb-config/one_setup.sh
```
