import "@stdlib/deploy";
import "@stdlib/ownable";
import "./nft_item.tact";
import "./messages.tact";

struct CollectionData {
    next_index: Int;
    content: Cell;
    owner: Address;
}

contract NftCollection with Deployable, Ownable {
    const minTonForStorage: Int = ton("0.03");
    const gasConsumption: Int = ton("0.03");

    owner: Address;
    next_item_index: Int as uint32 = 0;
    content: Cell;

    init(owner: Address, content: Cell) {
        self.owner = owner;
        self.content = content;    
    }

    receive(msg: RequestNftDeploy){
        self.requireOwner();
        let index = self.next_item_index;
        require(index >= 0, "non-sequential NFTs");
        let nft_init: StateInit = initOf NftItem(myAddress(), index);
        let nft_address: Address = contractAddress(nft_init);
        let msgValue: Int = context().value;
        let tonBalanceBeforeMsg: Int = myBalance() - msgValue;
        let storageFee: Int = self.minTonForStorage - min(tonBalanceBeforeMsg, self.minTonForStorage);
        msgValue = msgValue - (storageFee + self.gasConsumption);

        send(SendParameters{
            to: nft_address,
            value: msgValue,
            mode: SendIgnoreErrors,
            bounce: false,
            code: nft_init.code,
            data: nft_init.data,
            body: NftDeploy{
                index: index,
                owner: msg.owner,
                operator: msg.operator,
                content: self.content,
            }.toCell()
        });
    
        self.next_item_index = self.next_item_index + 1;
    }

    get fun get_collection_data(): CollectionData {
        return CollectionData{next_index: self.next_item_index, content: self.content, owner: self.owner};
    }
    
    get fun get_nft_address_by_index(index: Int): Address {
        return contractAddress(initOf NftItem(myAddress(), index));
    }

    get fun get_nft_content(index: Int, individual_content: Cell): Cell {
        return individual_content;
    }
}