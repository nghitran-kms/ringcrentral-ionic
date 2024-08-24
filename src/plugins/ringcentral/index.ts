import { registerPlugin } from '@capacitor/core';

import type { RingCentralPlugin } from './definitions';

const RingCentral = registerPlugin<RingCentralPlugin>('RingCentral');

export * from './definitions';
export { RingCentral };
