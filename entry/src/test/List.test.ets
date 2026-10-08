import localUnitTest from './LocalUnit.test';
import httpServiceTest from './HttpService.test';
import progressDisplayTest from './ProgressDisplay.test';
import indexPageTest from './IndexPage.test';

export default function testsuite() {
  localUnitTest();
  httpServiceTest();
  progressDisplayTest();
  indexPageTest();
}