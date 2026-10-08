import { http } from '@kit.NetworkKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'HttpService';

const UPLOAD_URL = '<SERVER_URL_TO_UPLOAD_FILE>';
const DOWNLOAD_URL = '<FILE_URL_TO_DOWNLOAD>';
const THROTTLE_INTERVAL = 100;

const LOREM_IPSUM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';

export class HttpService {
  private static instance: HttpService | null = null;
  private lastUiUpdate: number = 0;

  private constructor() {}

  public static getInstance(): HttpService {
    if (HttpService.instance === null) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  public uploadFile(context: Context, onProgress: (progress: number) => void): Promise<number> {
    return new Promise((resolve: (size: number) => void, reject: (err: Error) => void) => {
      const httpRequest = http.createHttp();
      const totalSize: number = LOREM_IPSUM.length;

      this.lastUiUpdate = 0;

      hilog.info(DOMAIN, TAG, 'Starting upload, total size: %{public}d', totalSize);

      httpRequest.on('dataSendProgress', (data: http.DataSendProgressInfo) => {
        const currentTime = Date.now();
        if (currentTime - this.lastUiUpdate >= THROTTLE_INTERVAL) {
          const progress: number = Math.round((data.sendSize / data.totalSize) * 100);
          hilog.debug(DOMAIN, TAG, 'Upload progress: %{public}d', progress);
          onProgress(progress);
          this.lastUiUpdate = currentTime;
        }
      });

      httpRequest.request(
        UPLOAD_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'text/plain'
          },
          extraData: LOREM_IPSUM,
          expectDataType: http.HttpDataType.STRING
        }
      ).then((resp: http.HttpResponse) => {
        hilog.info(DOMAIN, TAG, 'Upload response code: %{public}d', resp.responseCode);
        onProgress(100);
        httpRequest.destroy();
        resolve(totalSize);
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, 'Upload error: %{public}s', JSON.stringify(err));
        httpRequest.destroy();
        reject(err);
      });
    });
  }

  public downloadFile(context: Context, onProgress: (progress: number) => void): Promise<string> {
    return new Promise((resolve: (filePath: string) => void, reject: (err: Error) => void) => {
      const httpRequest = http.createHttp();
      const totalSize: number = 200 * 1024 * 1024;

      this.lastUiUpdate = 0;

      hilog.info(DOMAIN, TAG, 'Starting download from: %{public}s', DOWNLOAD_URL);

      const tempFileName: string = `download_temp_${Date.now()}.zip`;
      const tempFilePath: string = `${context.cacheDir}/${tempFileName}`;

      let file: fileIo.File | null = null;
      let receivedSize: number = 0;

      try {
        file = fileIo.openSync(tempFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      } catch (openErr) {
        hilog.error(DOMAIN, TAG, 'Failed to open file: %{public}s', JSON.stringify(openErr));
        reject(openErr as Error);
        return;
      }

      httpRequest.on('dataReceiveProgress', (data: http.DataReceiveProgressInfo) => {
        receivedSize = data.receiveSize;
        const currentTime = Date.now();
        if (currentTime - this.lastUiUpdate >= THROTTLE_INTERVAL) {
          const progress: number = Math.round((data.receiveSize / data.totalSize) * 100);
          hilog.debug(DOMAIN, TAG, 'Download progress: %{public}d', progress);
          onProgress(progress);
          this.lastUiUpdate = currentTime;
        }
      });

      httpRequest.requestInStream(
        DOWNLOAD_URL,
        {
          method: http.RequestMethod.GET,
          expectDataType: http.HttpDataType.ARRAY_BUFFER
        },
        (err: BusinessError, responseCode: number) => {
          if (err) {
            hilog.error(DOMAIN, TAG, 'Download error: %{public}s', JSON.stringify(err));
            if (file) {
              fileIo.closeSync(file.fd);
            }
            httpRequest.destroy();
            reject(new Error(err.message));
            return;
          }
          hilog.info(DOMAIN, TAG, 'Download response code: %{public}d', responseCode);
          onProgress(100);
          if (file) {
            fileIo.closeSync(file.fd);
          }
          httpRequest.destroy();
          resolve(tempFilePath);
        }
      );
    });
  }
}