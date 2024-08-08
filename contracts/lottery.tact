import "@stdlib/deploy";
import "./jetton_fire_master";
import "./jetton_fire_wallet";
import "./nft_item.tact";
import "./nft_collection.tact";
import "./messages";

struct RoundData {
    first: Int as uint8;
    second: Int as uint8;
    third: Int as uint8; 
    match: Int as uint8;   
}

message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}

contract Lottery with Deployable {
    const twoMatch: Int = ton("10");
    const threeMatch: Int = ton("15");
    const priceForToken: Int = ton("1");

    nftCollection: Address;
    paymentToken: Address;
    tokenBalance: Int as coins;

    init() {
        self.nftCollection = myAddress();
        self.paymentToken = myAddress();
        self.tokenBalance = 0;
    }

    receive(msg: SetData) {
        self.nftCollection = msg.nftAddress;
        self.paymentToken = msg.jettonAddress;
    }

    receive(msg: BuyToken) {
        require(context().value >= self.priceForToken, "Only 1 TON payments are accepted");
        send(SendParameters{
            to: self.paymentToken,
            body: MintToken{amount: ton("100"), to: sender()}.toCell(),
            value: ton("0.5"),
            mode: SendIgnoreErrors
        });
    }

    receive(msg: BuyTicket) {
        dump(sender());
        dump(myAddress());
        dump(msg.amount);
        let init: StateInit = initOf JettonFireWallet(self.paymentToken, sender(), myAddress());
        dump(contractAddress(init));
        require(msg.amount == ton("5"), "incorrect token amount");
        self.tokenBalance = self.tokenBalance + msg.amount;
        send(SendParameters{
            to: contractAddress(init),
            body: Transfer{amount: msg.amount, to: myAddress()}.toCell(),
            value: ton("0.3"),
            mode: SendIgnoreErrors
        });
        // let initNFT: StateInit = initOf NftItem(self.nftCollection, sender(), myAddress());
        send(SendParameters{
            to: self.nftCollection,
            body: RequestNftDeploy{owner: sender(), operator: myAddress()}.toCell(),
            value: ton("0.5"),
            mode: SendIgnoreErrors
        });
    }

    receive(msg: CheckTicket) {
        let initNFT: StateInit = initOf NftItem(msg.index);

        // dump(data.first);
        // dump(data.second);
        // dump(data.third);
        // dump(data.match);

        send(SendParameters{
            to: contractAddress(initNFT),
            body: "ticketStatus".asComment(),
            value: ton("0.2"),
            mode: SendIgnoreErrors
        });

        // dump(msg.index);
        // dump(self.requestStatus);
        // send(SendParameters{
        //     to: contractAddress(initNFT),
        //     body: SetLotteryData{one: data.first, two: data.second, three: data.third}.toCell(),
        //     value: ton("0.2"),
        //     mode: SendIgnoreErrors
        // });

        // self.setReward(data.match, sender());
    }

    receive(msg: GetTicketStatus) {
        dump(msg.status);
        if(!msg.status) {
            let data: RoundData = self.threeRandom();
            let initNFT: StateInit = initOf NftItem(msg.index);

            send(SendParameters{
                to: contractAddress(initNFT),
                body: SetLotteryData{one: data.first, two: data.second, three: data.third}.toCell(),
                value: ton("0.2"),
                mode: SendIgnoreErrors
            });
            
            if(data.match != 0) {    
                self.setReward(data.match, sender());
            }
        }
        // require(msg.status, "ticket used");
    }

    fun setReward(match: Int, winner: Address) {
        let init: StateInit = initOf JettonFireWallet(self.paymentToken, myAddress(), myAddress());
        dump(match);
        dump(winner);

        if(match == 1) {
        dump(match);
            send(SendParameters{
                to: contractAddress(init),
                body: Transfer{amount: self.twoMatch, to: winner}.toCell(),
                value: ton("0.5"),
                mode: SendIgnoreErrors
            });
        } else if(match == 3) {
        dump(match);
            send(SendParameters{
                to: contractAddress(init),
                body: Transfer{amount: self.threeMatch, to: winner}.toCell(),
                value: ton("0.5"),
                mode: SendIgnoreErrors
            });
        }
    }

    get fun threeRandom(): RoundData {
        let one = random(0, 10);
        let two = random(0, 10);
        let three = random(0, 10);
        let match = self.amountMatch(one, two, three);
        return RoundData{first: one, second: two, third: three, match: match};
    }
    get fun random(): Int {
        return random(0, 10);
    }

    get fun amountMatch(a: Int, b: Int, c: Int): Int {
    let match = 0;
    match = (a == b ? 1 : 0) + (a == c ? 1 : 0) + (b == c ? 1 : 0);
    return match;
    
}
    get fun nativeRandom(): Int {
        return randomInt();
    }

    get fun balance(): Int {
        return myBalance();
    }

    get fun paymentToken(): Address {
        return self.paymentToken;
    }

    get fun nftCollection(): Address {
        return self.nftCollection;
    }
}
