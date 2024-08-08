import "@stdlib/deploy";
import "./nft_item.tact";
import "./messages.tact";

struct CollectionData {
    next_index: Int;
    content: Cell;
    owner: Address;
}

contract NftCollection with Deployable {
    const minTonForStorage: Int = ton("0.03");
    const gasConsumption: Int = ton("0.03");

    next_item_index: Int as uint32 = 0;
    content: Cell;
    operator: Address;
    owner: Address;

    init(operator: Address, content: Cell, owner: Address) {
        self.operator = operator;
        self.content = content;    
        self.owner = owner;
        dump(self.next_item_index);
    }

    receive(msg: RequestNftDeploy){
        let index = self.next_item_index;
        dump(index);
        // require(index >= 0, "non-sequential NFTs");
        let nft_init: StateInit = initOf NftItem(index);
        let nft_address: Address = contractAddress(nft_init);
        let msgValue: Int = context().value;
        let tonBalanceBeforeMsg: Int = myBalance() - msgValue;
        let storageFee: Int = self.minTonForStorage - min(tonBalanceBeforeMsg, self.minTonForStorage);
        msgValue = msgValue - (storageFee + self.gasConsumption);

        send(SendParameters{
            to: nft_address,
            value: ton("0.2"),
            mode: SendIgnoreErrors,
            bounce: false,
            code: nft_init.code,
            data: nft_init.data,
            body: NftDeploy{
                index: index,
                owner: msg.owner,
                operator: msg.operator,
                collection: myAddress(),
                content: self.content,
            }.toCell()
        });
    
        self.next_item_index = self.next_item_index + 1;
    }

    get fun get_collection_data(): CollectionData {
        return CollectionData{next_index: self.next_item_index, content: self.content, owner: self.owner};
    }
    
    get fun get_nft_address_by_index(index: Int): Address {
        return contractAddress(initOf NftItem(index));
    }

    get fun get_nft_content(index: Int, individual_content: Cell): Cell {
        return individual_content;
    }

    get fun getItemIndex(): Int {
        return self.next_item_index;
    }
}