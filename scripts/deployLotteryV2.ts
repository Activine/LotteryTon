import { toNano } from '@ton/core';
import { LotteryV2 } from '../wrappers/LotteryV2';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const lotteryV2 = provider.open(await LotteryV2.fromInit());

    await lotteryV2.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(lotteryV2.address);

    // run methods on `lotteryV2`
}
