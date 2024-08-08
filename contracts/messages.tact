message InternalAdd {
    amount: Int as coins;
    origin: Address;
}

message Transfer {
    amount: Int as coins;
    to: Address;
}

message NftDeploy {
    index: Int as uint256;
    owner: Address;
    operator: Address;
    collection: Address;
    content: Cell;
}

message(0x1f04537a) NftDestroy {
    query_id: Int as uint64;
}

message(0x6f89f5e3) NftExcesses {
    query_id: Int as uint64;
}

message RequestNftDeploy {
    owner: Address;
    operator: Address;
}

message SetData {
    nftAddress: Address;
    jettonAddress: Address;
}

message MintToken {
    amount: Int as coins;
    to: Address;
}
message BuyToken {
    target: Int as uint32;
}
message BuyTicket {
    amount: Int as coins;
    target: Int as uint32;
}
message CheckTicket {
    index: Int as uint256;
}

message SetLotteryData{
    one: Int as uint8;
    two: Int as uint8;
    three: Int as uint8;
}