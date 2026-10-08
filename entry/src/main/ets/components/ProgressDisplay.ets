@Component
export struct ProgressDisplay {
  @Prop progress: number = 0;
  @Prop label: string = '';
  @Prop status: string = '';
  @Prop isActive: boolean = false;
  @Prop emoji: string = '';

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Text(`${this.emoji} ${this.label}`)
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Stack() {
        Row() {
          Blank()
        }
        .width('100%')
        .height($r('app.float.progress_bar_height'))
        .backgroundColor('#E0E0E0')
        .borderRadius(4)

        Row() {
          Blank()
        }
        .width((this.progress / 100 * 180) + 'fp')
        .height($r('app.float.progress_bar_height'))
        .backgroundColor(this.isActive ? '#007DFF' : '#4CAF50')
        .borderRadius(4)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .animation({
          duration: 100,
          curve: Curve.Linear
        })
      }
      .alignContent(Alignment.Start)
      .width($r('app.float.progress_bar_width'))
      .height($r('app.float.progress_bar_height'))

      Text(`${this.progress}%`)
        .fontSize($r('app.float.status_font_size'))
        .fontColor('#666666')
        .margin({ top: 4 })

      Text(this.status)
        .fontSize($r('app.float.status_font_size'))
        .fontColor(this.isActive ? '#007DFF' : '#4CAF50')
        .margin({ top: 2 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(12)
  }
}