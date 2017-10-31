# Usage

```
# Donate
docker run -d -t kawaz/nheqminer_cpu

# Easy way
docker run -d -t -e WALLET=YOUR_BTC_ADDRESS kawaz/nheqminer_cpu

# Free way, you can use custom parameters
docker run -d -t kawaz/nheqminer_cpu -h
```

tty (-t) is required for nhminer_cpu ...

# Features

- auto detect closer server
- auto detect cpu count
- small image
