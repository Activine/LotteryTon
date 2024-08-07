import { beginCell } from '@ton/ton';
export function createOffchainContent(str: string) {
    return beginCell().storeUint(1, 8).storeStringTail(str).endCell();
}
