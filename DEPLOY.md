## Sablier multi-chain deployment example with Catapulta

## Getting started

1. Sign up with Github at [Catapulta website](https://catapulta.sh) to generate your `CATAPULTA_API_KEY` once you create
   a project.

2. Fill `CATAPULTA_API_KEY` and `MNEMONIC` in Sablier .env file

3. Install latest version of catapulta with your node package manager

```
npm i -g catapulta@0.2.19
```

4. Deploy any Sablier script with `catapulta script [path] --network [network_name]`

```
catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Cel --network sepolia
```

You can load Sablier `optimized` foundry config profile as always via FOUNDRY_PROFILE env var

```
FOUNDRY_PROFILE=optimized catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce --network sepolia
```

## Multi-chain deployment

Deploy any Sablier script with `catapulta script [path] --networks [a,b,c]`

```
catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce --network sepolia,maticMumbai,avalancheFuji
```

## Simulated deployment

Simulate a Solidity script with `catapulta scrip## Multi-chain deployment

Deploy any Sablier script with `catapulta script [path] --networks [a,b,c]`

````
catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce --network sepolia,maticMumbai,avalancheFuji
```
## Multi-chain deployment

Deploy any Sablier script with `catapulta script [path] --networks [a,b,c]`

````

catapulta script script/DeployComptroller.s.sol --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce
--network sepolia,maticMumbai,avalancheFuji ``` t [path] --networks [a,b,c] --simulate`

```
catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce --network sepolia,maticMumbai,avalancheFuji --simulate
```

## Verbose deployment or simulation

You can add the `-vvvv` forge verbose flag and Catapulta will show all the debug logs and deployment traces. This will
remove concurrency during multi-chain deployments, making it slower.

```
catapulta script script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce --network sepolia,maticMumbai,avalancheFuji --simulate -vvvv
```
