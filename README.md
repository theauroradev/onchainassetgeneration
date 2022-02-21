# On chain asset generation usnig native random function in Aurora

This smart contract uses Random function which is native to Aurora. Random number generation is not a reality on blockchain but using some methods we can make it possible.

In case of Aurora, it done by calling native random function in NEAR protocol on which the Aurora EVM is built.

If you want to learn about how this thing works on the inside (I mean the part where smart contract calls NEAR function), you can check out PR created on aurora-is-near repo.

Following are contracts I have deployed recently (If you want to interact with the contracts you can):
```
Eggs contract address:  0x6cc8Ce5e2705F59FFdB2CC43a49DCBc7003F8630
Metadata contract address:  0xa7B6eD6F0aa4B2AB01BDf3E81e609ec03aD1a1cA
random contract address:  0xebfB28DaFfcdF394A109a29c18086A973198B647
FoxHen contract address:  0x26aE9276FC9BBBD8C297353d9F389F7a4d08e69f
```

But first if you're new to solidity you can learn how to compile exsiting smart contract and try to interact with them. Go to hardhat and learn that.
