import { toNano } from '@ton/core';
import { JettonFireWallet } from '../wrappers/JettonFireWallet';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const jettonFireWallet = provider.open(await JettonFireWallet.fromInit());

    await jettonFireWallet.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(jettonFireWallet.address);

    // run methods on `jettonFireWallet`
}
