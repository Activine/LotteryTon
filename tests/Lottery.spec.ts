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
        deployer = await blockchain.treasury('deployer');

        // lottery
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

        // jettonFireMaster
        jettonFireMaster = blockchain.openContract(await JettonFireMaster.fromInit(lottery.address));

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

        content = createOffchainContent(
            'https://magenta-rich-deer-409.mypinata.cloud/ipfs/QmXWdMkG7xnfEre1kmfTmeqv7ioBWSTAd38JTLd6gpttxQ',
        );

        nftCollection = blockchain.openContract(
            await NftCollection.fromInit(lottery.address, content, deployer.address),
        );

        const deployResultNFT = await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.3'),
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

        console.log(tx.events);
        console.log('bob', bob.address);
        console.log('lottery.address', lottery.address);
        console.log('NFT.address', nftCollection.address);

        bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance after', bobData.balance);

        lotteryData = await lotteryWallet.getGetWalletData();
        console.log('lotteryData.balance', lotteryData.balance);
        console.log(await nftCollection.getGetItemIndex());
        console.log(await nftCollection.getGetCollectionData());
        console.log('deployer.address', deployer.address);

        // const NftAddress = await nftCollection.getGetNftAddressByIndex(0n);
        // const nftItem = blockchain.openContract(NftItem.fromAddress(NftAddress));
        // console.log('nftItem.address', nftItem.address);

        // let nftData = await nftItem.getGetNftData();
        // console.log('nftData', nftData);
        const NFTItem0 = await nftCollection.getGetNftAddressByIndex(0n);
        const nft0 = blockchain.openContract(NftItem.fromAddress(NFTItem0));
        console.log('nft0.address', nft0.address);

        const NFTItem1 = await nftCollection.getGetNftAddressByIndex(1n);
        const nft1 = blockchain.openContract(NftItem.fromAddress(NFTItem1));
        console.log('nft1.address', nft1.address);

        const NFTItem2 = await nftCollection.getGetNftAddressByIndex(2n);
        const nft2 = blockchain.openContract(NftItem.fromAddress(NFTItem2));
        console.log('nft2.address', nft2.address);
        console.log('bob', bob.address);
        console.log(await lottery.getThreeRandom());

        let tx2 = await nftCollection.send(
            bob.getSender(),
            { value: toNano('1') },
            {
                $$type: 'RequestNftDeploy',
                owner: deployer.address,
                operator: lottery.address,
            },
        );
        console.log(tx2.events);
        console.log(await nft0.getGetNftData());
        console.log(await nft1.getGetNftData());
        // console.log('getGetLotteryCheck', await nft1.getGetNumbers());
        // console.log('getGetLotteryCheck', await nft1.getGetLotteryCheck());

        console.log(await lottery.getRandom());
        console.log(await lottery.getThreeRandom());
        console.log(await lottery.getThreeRandom());
        console.log(await lottery.getThreeRandom());
        console.log(await lottery.getAmountMatch(1n, 2n, 3n));
        console.log(await lottery.getAmountMatch(1n, 2n, 2n));
        console.log(await lottery.getAmountMatch(2n, 2n, 2n));

        bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance before', bobData.balance);
        lotteryData = await lotteryWallet.getGetWalletData();
        console.log('lotteryData.balance before', lotteryData.balance);
        let txCheck = await lottery.send(
            bob.getSender(),
            { value: toNano('2') },
            {
                $$type: 'CheckTicket',
                index: 0n,
            },
        );
        console.log(tx2.events);
        console.log('getGetLotteryCheck', await nft0.getGetNumbers());

        bobData = await bobWallet.getGetWalletData();
        console.log('bobData.balance after', bobData.balance);
        lotteryData = await lotteryWallet.getGetWalletData();
        console.log('lotteryData.balance after', lotteryData.balance);
    });
});
