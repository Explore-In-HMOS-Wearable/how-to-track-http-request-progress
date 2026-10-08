import { HttpService } from '../common/HttpService';
import { ProgressDisplay } from '../components/ProgressDisplay';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0002;
const TAG = 'Index';

function formatBytes(bytes: number): string {
  const mb: number = bytes / (1024 * 1024);
  return mb.toFixed(2) + ' MB';
}

@Entry
@Component
struct Index {
  @State uploadProgress: number = 0;
  @State downloadProgress: number = 0;
  @State uploadStatus: string = 'Ready';
  @State downloadStatus: string = 'Ready';
  @State isUploading: boolean = false;
  @State isDownloading: boolean = false;
  @State currentIndex: number = 0;
  private httpService: HttpService = HttpService.getInstance();

  private showNotification(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 3000
      });
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'showToast error: %{public}s', JSON.stringify(e));
    }
  }

  private async startUpload(): Promise<void> {
    if (this.isUploading || this.isDownloading) {
      return;
    }

    this.isUploading = true;
    this.uploadProgress = 0;
    this.uploadStatus = 'Uploading...';

    try {
      const bytesSent: number = await this.httpService.uploadFile(
        getContext(this),
        (progress: number) => {
          this.uploadProgress = progress;
        }
      );
      this.uploadStatus = `Upload complete: ${formatBytes(bytesSent)}`;
      this.showNotification('Upload successful');
    } catch (err) {
      this.uploadStatus = 'Upload failed';
      this.showNotification('Upload failed');
    } finally {
      this.isUploading = false;
    }
  }

  private async startDownload(): Promise<void> {
    if (this.isUploading || this.isDownloading) {
      return;
    }

    this.isDownloading = true;
    this.downloadProgress = 0;
    this.downloadStatus = 'Downloading...';

    try {
      const filePath: string = await this.httpService.downloadFile(
        getContext(this),
        (progress: number) => {
          this.downloadProgress = progress;
        }
      );
      const fileName: string = filePath.split('/').pop() || filePath;
      this.downloadStatus = `Saved: ${fileName}`;
      this.showNotification(`Download saved to: ${fileName}`);
    } catch (err) {
      this.downloadStatus = 'Download failed';
      this.showNotification('Download failed');
    } finally {
      this.isDownloading = false;
    }
  }

  build() {
    Swiper() {
      Column() {
        ProgressDisplay({
          progress: this.uploadProgress,
          label: 'Upload',
          status: this.uploadStatus,
          isActive: this.isUploading,
          emoji: '📤'
        })

        Button($r('app.string.btn_start_upload'))
          .width('80%')
          .height(40)
          .fontSize($r('app.float.btn_font_size'))
          .enabled(!this.isUploading && !this.isDownloading)
          .backgroundColor(this.isUploading || this.isDownloading ? '#CCCCCC' : '#007DFF')
          .fontColor(Color.White)
          .borderRadius(20)
          .margin({ top: 12 })
          .onClick(() => {
            this.startUpload();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        ProgressDisplay({
          progress: this.downloadProgress,
          label: 'Download',
          status: this.downloadStatus,
          isActive: this.isDownloading,
          emoji: '📥'
        })

        Button($r('app.string.btn_start_download'))
          .width('80%')
          .height(40)
          .fontSize($r('app.float.btn_font_size'))
          .enabled(!this.isUploading && !this.isDownloading)
          .backgroundColor(this.isUploading || this.isDownloading ? '#CCCCCC' : '#007DFF')
          .fontColor(Color.White)
          .borderRadius(20)
          .margin({ top: 12 })
          .onClick(() => {
            this.startDownload();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .vertical(true)
    .indicator(new DotIndicator().color(Color.Gray))
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}