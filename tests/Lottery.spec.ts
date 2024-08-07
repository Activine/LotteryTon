import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano, Cell } from '@ton/core';
import { JettonFireMaster } from '../wrappers/JettonFireMaster';
import { JettonFireWallet } from '../wrappers/JettonFireWallet';
import { NftCollection } from '../wrappers/NFTCollection';
import { NftItem } from '../wrappers/NftItem';
import { Lottery } from '../wrappers/Lottery';
import { createOffchainContent } from './helpers';

import '@ton/test-utils';

describe('Lottery', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let jettonFireMaster: SandboxContract<JettonFireMaster>;
    let lottery: SandboxContract<Lottery>;
    let nftCollection: SandboxContract<NftCollection>;
    let content: Cell;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        jettonFireMaster = blockchain.openContract(await JettonFireMaster.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await jettonFireMaster.send(
            deployer.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: jettonFireMaster.address,
            deploy: true,
            success: true,
        });

        lottery = blockchain.openContract(await Lottery.fromInit());

        const deployResultLottery = await lottery.send(
            deployer.getSender(),
            {
                value: toNano('0.5'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResultLottery.transactions).toHaveTransaction({
            from: deployer.address,
            to: lottery.address,
            deploy: true,
            success: true,
        });

        content = createOffchainContent(
            'https://magenta-rich-deer-409.mypinata.cloud/ipfs/QmXWdMkG7xnfEre1kmfTmeqv7ioBWSTAd38JTLd6gpttxQ',
        );

        nftCollection = blockchain.openContract(await NftCollection.fromInit(deployer.address, content));

        const deployResultNFT = await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.1'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResultNFT.transactions).toHaveTransaction({
            from: deployer.address,
            to: nftCollection.address,
            deploy: true,
            success: true,
        });

        const setData = await lottery.send(
            deployer.getSender(),
            { value: toNano('0.1') },
            {
                $$type: 'SetData',
                nftAddress: nftCollection.address,
                jettonAddress: jettonFireMaster.address,
            },
        );
        console.log('jettonFireMaster', jettonFireMaster.address);
        const paymentToken = await lottery.getPaymentToken();
        console.log('paymentToken', paymentToken);
    });

    it('should deploy', async () => {});

    it('should be set initial data', async () => {
        const metadata = await jettonFireMaster.getMetadata();
        console.log('metadata', metadata);

        expect(metadata.symbol).toEqual('4ire');
        // expect(metadata.totalSupply).toEqual(toNano('500'));
    });

    it('should be increase balance', async () => {
        const walletAddress = await jettonFireMaster.getWalletAddress(deployer.address);
        const ownerWallet = blockchain.openContract(JettonFireWallet.fromAddress(walletAddress));
        // console.log('wallet address', walletAddress);
        // console.log('owner wallet address', ownerWallet.address);
        // console.log('owner wallet address', ownerWallet.abi);
        const walletData = await ownerWallet.getGetWalletData();
        // console.log(walletData);
        // expect(walletData.balance).toEqual(toNano('500'));

        // @@@@@@@@
        const bob = await blockchain.treasury('bob');
        const res = await lottery.send(
            bob.getSender(),
            { value: toNano('1.5') },
            {
                $$type: 'BuyToken',
                target: 0n,
            },
        );
        let balance = await lottery.getBalance();
        console.log('balance', balance);
        // @@@@@@@@
        // console.log(res);
        // console.log('lottery.', lottery.address);
        // console.log('jettonFireMaster.', jettonFireMaster.address);
        const walletBob = await jettonFireMaster.getWalletAddress(bob.address);
        const bobWallet = blockchain.openContract(JettonFireWallet.fromAddress(walletBob));
        // console.log('wallet address', walletAddress);
        // console.log('owner wallet address', ownerWallet.address);
        // console.log('owner wallet address', ownerWallet.abi);
        let bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance', bobData.balance);

        console.log('nftCollection', nftCollection.address);
        console.log('nftCollection', await lottery.getNftCollection());

        // const resBuyTicket = await lottery.send(
        //     bob.getSender(),
        //     { value: toNano('0.5') },
        //     {
        //         $$type: 'BuyTicket',
        //         amount: toNano('5'),
        //         target: 0n,
        //     },
        // );

        // bobData = await bobWallet.getGetWalletData();
        // console.log('bobData.balance', bobData.balance);

        await bobWallet.send(
            bob.getSender(),
            { value: toNano('0.5') },
            {
                $$type: 'Transfer',
                amount: toNano('20'),
                to: lottery.address,
            },
        );

        bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance', bobData.balance);

        const walletLottery = await jettonFireMaster.getWalletAddress(lottery.address);
        const lotteryWallet = blockchain.openContract(JettonFireWallet.fromAddress(walletLottery));
        let lotteryData = await lotteryWallet.getGetWalletData();
        console.log('lotteryData.balance', lotteryData.balance);

        let tx = await lottery.send(
            bob.getSender(),
            { value: toNano('1') },
            {
                $$type: 'BuyTicket',
                amount: toNano('5'),
                target: 0n,
            },
        );

        // console.log(tx);
        console.log('bob', bob.address);
        console.log('lottery.address', lottery.address);

        bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance after', bobData.balance);

        // const NftAddress = await nftCollection.getGetNftAddressByIndex(0n);
        // const nftItem = blockchain.openContract(NftItem.fromAddress(NftAddress));
        // console.log('nftItem.address', nftItem.address);

        // let nftData = await nftItem.getGetNftData();
        // console.log('nftData', nftData);
    });
});
