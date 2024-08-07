import "@stdlib/deploy";
import "./jetton_fire_master";
import "./jetton_fire_wallet";
import "./nft_item.tact";
import "./nft_collection.tact";
import "./messages";

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

    init() {
        self.nftCollection = myAddress();
        self.paymentToken = myAddress();
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
        let init: StateInit = initOf JettonFireWallet(self.paymentToken, sender());
        dump(contractAddress(init));
        send(SendParameters{
            to: contractAddress(init),
            body: Transfer{amount: msg.amount, to: myAddress()}.toCell(),
            value: 0,
            mode: SendRemainingValue
        });
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
