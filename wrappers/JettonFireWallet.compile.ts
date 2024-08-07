import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/jetton_fire_wallet.tact',
    options: {
        debug: true,
    },
};
