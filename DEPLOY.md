## Sablier deployment example with Catapulta

1. Sign up with Github at [Catapulta website](https://catapulta.sh) to generate your `CATAPULTA_API_KEY` once you create
   a project.

2. Fill `CATAPULTA_API_KEY` and `MNEMONIC` in Sablier .env file

Install latest version of catapulta with your node package manager

```
npm i -g catapulta@0.2.13
```

3. Deploy any Sablier script with `catapulta script [path] --network [network_name]`

```
catapulta script script/DeployComptroller.s.sol --network sepolia --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce
```

You can load Sablier `optimized` foundry config profile as always via FOUNDRY_PROFILE env var

```
FOUNDRY_PROFILE=optimized catapulta script --network sepolia script/DeployComptroller.s.sol  --sig "run(address)" 0x4735517616373c5137dE8bcCDc887637B8ac85Ce
```
