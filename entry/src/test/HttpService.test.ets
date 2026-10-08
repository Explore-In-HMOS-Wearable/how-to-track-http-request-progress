import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { HttpService } from '../main/ets/common/HttpService';

export default function httpServiceTest() {
  describe('HttpServiceTest', () => {
    beforeAll(() => {
    });

    afterEach(() => {
    });

    afterAll(() => {
    });

    it('HttpService_getInstance_returnsSameInstance', 0, () => {
      const instance1 = HttpService.getInstance();
      const instance2 = HttpService.getInstance();
      expect(instance1).not().assertNull();
      expect(instance2).not().assertNull();
      expect(instance1 === instance2).assertTrue();
    });

    it('HttpService_getInstance_returnsNonNull', 0, () => {
      const instance = HttpService.getInstance();
      expect(instance).not().assertNull();
    });

    it('HttpService_singletonPattern', 0, () => {
      const instance1 = HttpService.getInstance();
      const instance2 = HttpService.getInstance();
      const instance3 = HttpService.getInstance();
      expect(instance1 === instance2).assertTrue();
      expect(instance2 === instance3).assertTrue();
    });
  });
}