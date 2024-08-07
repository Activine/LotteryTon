import "@stdlib/deploy";
import "./messages";
import "./wallet";
import "./master";

struct Metadata{
    symbol: String;
    totalSupply: Int;
}

contract JettonFire with Deployable {

    symbol: String;
    totalSupply: Int as coins;

    init() {
        self.symbol = "TON";
        self.totalSupply = ton("500");
        self.mint(self.totalSupply, sender());
    }

    fun mint(amount: Int, to: Address) {
        let init: StateInit = initOf JettonDefaultWallet(myAddress(), to);
        send(SendParameters{
            to: contractAddress(init),
            body: InternalAdd{amount: amount, origin: myAddress()}.toCell(),
            value: ton("0.03"),
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });
    }

    get fun walletAddress(owner: Address): Address{
        let init: StateInit = initOf JettonDefaultWallet(myAddress(), owner);
        return contractAddress(init);
    }

    get fun metadata(): Metadata{
        return Metadata{symbol: self.symbol, totalSupply: self.totalSupply};
    }
}