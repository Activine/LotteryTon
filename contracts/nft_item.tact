import "@stdlib/deploy";
import "./messages";

struct NftData {
    deployed: Bool;
    index: Int;
    collection: Address;
    owner: Address;
    content: Cell;
}

contract NftItem with Deployable {
    deployed: Bool = false;
    collection: Address;
    owner: Address;
    operator: Address;
    index: Int as uint256;
    content: Cell;

    init(collection: Address, index: Int) {
        self.collection = collection;
        self.index = index;

        self.operator = self.collection;
        self.owner = self.collection;
        self.content = emptyCell();
    }

    receive(msg: NftDeploy) {
        require(sender() == self.collection, "Invalid Sender");
        require(self.index == msg.index, "Invalid Index");
        require(!self.deployed, "Already Deployed");
        self.owner = msg.owner;
        self.operator = msg.operator;
        self.content = msg.content;
        self.deployed = true;
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

    get fun get_nft_data(): NftData {
        return NftData{deployed: self.deployed, index: self.index, collection: self.collection, owner: self.owner, content: self.content};
    }
}
