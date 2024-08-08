import "@stdlib/deploy";
import "./messages";

struct NftData {
    deployed: Bool;
    index: Int;
    collection: Address;
    owner: Address;
    content: Cell;
}

struct Numbers {
    one: Int;
    two: Int;
    three: Int;
}

contract NftItem with Deployable {
    deployed: Bool = false;
    collection: Address;
    owner: Address;
    index: Int as uint256;
    content: Cell;
    operator: Address;
    lotteryChecked: Bool = false;
    numbers: Numbers = Numbers{one: 0, two: 0, three: 0};


    init(index: Int) {
        self.index = index;

        self.collection = myAddress();
        self.operator = myAddress();
        self.owner = myAddress();
        self.content = emptyCell();
        dump(self.deployed);
        dump(self.content);
    }

    receive(msg: NftDeploy) {
        dump(self.deployed);

        // require(sender() == self.collection || sender() == self.operator, "Invalid Sender");
        // require(self.index == msg.index, "Invalid Index");
        require(!self.deployed, "Already Deployed");

        self.collection = msg.collection;
        self.owner = msg.owner;
        self.operator = msg.operator;
        self.content = msg.content;
        self.deployed = true;
        dump(self.deployed);
    }

    receive(msg: NftDestroy) {
        require(sender() == self.owner || sender() == self.operator, "Invalid Owner");
        self.owner = myAddress();
        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendRemainingBalance,
            body: NftExcesses{
                query_id: msg.query_id
            }.toCell()
        });
    }

    receive(msg: SetLotteryData) {
        // require(sender() == self.operator, "Operator only");
        dump(sender());
        dump(myAddress());
        dump(msg.one);
        dump(msg.two);
        dump(msg.three);

        self.lotteryChecked = true;
        self.numbers = Numbers{one: msg.one, two: msg.two, three: msg.three};
    }

    get fun get_nft_data(): NftData {
        return NftData{deployed: self.deployed, index: self.index, collection: self.collection, owner: self.owner, content: self.content};
    }

    get fun get_numbers(): Numbers {
        return self.numbers;
    }

    get fun get_lottery_check(): Bool {
        return self.lotteryChecked;
    }
}
