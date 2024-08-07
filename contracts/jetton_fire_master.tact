import "@stdlib/deploy";
import "./jetton_fire_wallet";
import "./messages";

struct Metadata {
    symbol: String;
    totalSupply: Int as coins;
}

contract JettonFireMaster with Deployable {
    symbol: String; 
    totalSupply: Int as coins;
    
    init() {
        self.symbol = "4ire";
        self.totalSupply = ton("500");
        self.mint(self.totalSupply, sender());
    }

    receive(msg: MintToken) {
        self.mint(msg.amount, msg.to);
    }

    fun mint(amount: Int, to: Address) {
        let init: StateInit = initOf JettonFireWallet(myAddress(), to);
        // dump(to);
        // dump(amount);
        send(SendParameters{
            to: contractAddress(init),
            body: InternalAdd{amount: amount, origin: myAddress()}.toCell(),
            value: ton("0.1"),
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });
        self.totalSupply = self.totalSupply + amount;
    }
 
    get fun walletAddress(owner: Address): Address {
        let init: StateInit = initOf JettonFireWallet(myAddress(), owner);
        return contractAddress(init);
    }

    get fun metadata(): Metadata {
        return Metadata{symbol: self.symbol, totalSupply: self.totalSupply};
    }
}
