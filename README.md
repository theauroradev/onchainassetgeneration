# On chain asset generation usnig native random function in Aurora

This smart contract uses Random function which is native to Aurora. Random number generation is not a reality on blockchain but using some methods we can make it possible.

In case of Aurora, it done by calling native random function in NEAR protocol on which the Aurora EVM is built.

If you want to learn about how this thing works on the inside (I mean the part where smart contract calls NEAR function), you can check out PR created on aurora-is-near repo.

Following are contracts I have deployed recently (If you want to interact with the contracts you can):
```
Eggs contract address:  0x0317004cF200D870a9dB6272B5fB47E72cb86E82
Metadata contract address:  0xe9326dF5e97Aa5c77Ae6af269F3683A942c4601D
random contract address:  0xcCeBa20a460F6639B73b44bd1B89D037e95dd511
FoxHen contract address:  0x3D4022B7dD2CdE02d78907af72F3f761A05e5489
```

But first if you're new to solidity you can learn how to compile exsiting smart contract and try to interact with them. Go to hardhat and learn that.


While deploying these smart contracts, I got stuck because it was sending wrong nonce with the transaction. simple solution clear artifacts, cache and node_modules, run all command again it will start working.

As I didn't change it manually above solution worked but if you're sending nonce manually you may have to follow some other method.