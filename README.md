# miniTransfer

mini file transfer tool, use it just curl o wget

# How to use

## upload file

```bash
curl -T localFileName 127.0.0.1:1234 # default save as localFileName
curl -T localFileName 127.0.0.1:1234/SaveFileName
wget --post-file localFileName 127.0.0.1:1234/SaveFileName -O /dev/null
```

## downlod file

```bash
curl 127.0.0.1:1234/localFileName
```
