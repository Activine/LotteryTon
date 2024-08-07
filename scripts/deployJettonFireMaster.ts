import { toNano } from '@ton/core';
import { JettonFireMaster } from '../wrappers/JettonFireMaster';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const jettonFireMaster = provider.open(await JettonFireMaster.fromInit());

    await jettonFireMaster.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(jettonFireMaster.address);

    // run methods on `jettonFireMaster`
}
