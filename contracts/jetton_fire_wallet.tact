import "@stdlib/deploy";
import "./messages";

struct JettonFireData {
    balance: Int;
    owner: Address;
    walletCode: Cell;
}

contract JettonFireWallet with Deployable {
    parent: Address;
    owner: Address;
    operator: Address;
    balance: Int as coins;

    init(parent: Address, owner: Address, operator: Address) {
        self.parent = parent;
        self.owner = owner;
        self.operator = operator;
        self.balance = 0;
    }   

    receive(msg: InternalAdd) {
        if(msg.origin == self.parent) {
            require(sender() == self.parent, "Parent only");
        } else {
            let init: StateInit = initOf JettonFireWallet(self.parent, msg.origin, self.operator);
            require(sender() == contractAddress(init), "Wallet only");
        }
        self.balance = self.balance + msg.amount;
        dump(self.balance);
    }

    receive(msg: Transfer) {
        dump(self.owner);
        dump(sender());
        let ctx: Context = context();
        dump(ctx.sender);
        dump(self.operator);
        require(sender() == self.owner|| sender() == self.operator, "Only owner");
        require(self.balance >= msg.amount, "Insufficient balance");
        self.balance = self.balance - msg.amount;
        let init: StateInit = initOf JettonFireWallet(self.parent, msg.to, self.operator);
        send(SendParameters{
            to: contractAddress(init),
            body: InternalAdd{amount: msg.amount, origin: self.owner}.toCell(),
            value: ton("0.03"),
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });
        self.reply("transfered".asComment());
    }

    get fun get_wallet_data(): JettonFireData {
        return JettonFireData{
            balance: self.balance,
            owner: self.owner,
            walletCode: (initOf JettonFireWallet(self.parent, self.owner, self.operator)).code
        };
    }
}
