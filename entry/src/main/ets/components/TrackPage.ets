import { map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';

@Component
export struct TrackPage {
  @Prop mapController: map.MapComponentController | undefined;
  @Prop center: mapCommon.LatLng;

  @State isTracking: boolean = false;
  @State distanceM: number = 0;
  @State duration: number = 0;

  private timerHandle: number = -1;
  private sessionStart: number = 0;
  private accumulatedMs: number = 0;
  private lastLat: number = 0;
  private lastLng: number = 0;
  private hasLast: boolean = false;

  private haversine(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000;
    const r = (v: number) => v * Math.PI / 180;
    const a = Math.sin(r(lat2 - lat1) / 2) ** 2 +
      Math.cos(r(lat1)) * Math.cos(r(lat2)) * Math.sin(r(lon2 - lon1) / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  private fmt(sec: number): string {
    const h = Math.floor(sec / 3600);
    const m = Math.floor((sec % 3600) / 60);
    const s = sec % 60;
    if (h > 0) {
      return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
    }
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '00')}`;
  }

  private fmtDist(): string {
    if (this.distanceM >= 1000) {
      return `${(this.distanceM / 1000).toFixed(2)} km`;
    }
    return `${Math.round(this.distanceM)} m`;
  }

  private tick(): void {
    this.duration = Math.floor((this.accumulatedMs + Date.now() - this.sessionStart) / 1000);
    this.timerHandle = setTimeout(() => this.tick(), 1000) as number;
  }

  private startTimer(): void {
    this.sessionStart = Date.now();
    this.tick();
  }

  private stopTimer(): void {
    if (this.timerHandle !== -1) {
      clearTimeout(this.timerHandle);
      this.timerHandle = -1;
    }
  }

  start(): void {
    this.distanceM = 0;
    this.duration = 0;
    this.accumulatedMs = 0;
    this.hasLast = false;
    this.isTracking = true;
    this.startTimer();
    try {
      geoLocationManager.on('locationChange', {
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION,
        timeInterval: 1,
        distanceInterval: 0,
        maxAccuracy: 0
      }, (loc) => {
        if (!this.isTracking) {
          return;
        }
        if (this.hasLast) {
          const d = this.haversine(this.lastLat, this.lastLng, loc.latitude, loc.longitude);
          if (d >= 1 && d < 300) {
            this.distanceM = this.distanceM + d;
          }
        }
        this.lastLat = loc.latitude;
        this.lastLng = loc.longitude;
        this.hasLast = true;
      });
    } catch (e) {
      console.error(`[Track] ${e.code}`);
    }
  }

  stop(): void {
    this.isTracking = false;
    this.stopTimer();
    try { geoLocationManager.off('locationChange'); } catch (_) {}
  }

  aboutToDisappear(): void {
    this.stop();
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .layoutWeight(1)
        .hitTestBehavior(HitTestMode.Transparent)

      Column() {
        Text(this.isTracking ? '● Recording' : 'Ready')
          .fontSize(11)
          .fontColor(this.isTracking ? '#FF5252' : 'rgba(255,255,255,0.5)')
          .margin({ bottom: 8 })

        Row() {
          Column() {
            Text(this.fmtDist())
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('Distance')
              .fontSize(10)
              .fontColor('rgba(255,255,255,0.4)')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider().vertical(true).height(40).color('rgba(255,255,255,0.15)')

          Column() {
            Text(this.fmt(this.duration))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('Süre')
              .fontSize(10)
              .fontColor('rgba(255,255,255,0.4)')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 14 })

        Button(this.isTracking ? '⏹  Start' : '▶  Finish')
          .onClick(() => {
            if (this.isTracking) {
              this.stop();
            } else {
              this.start();
            }
          })
          .backgroundColor(this.isTracking ? '#FF5252' : '#2979FF')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .borderRadius(22)
          .height(42)
          .padding({ left: 32, right: 32 })
      }
      .width('100%')
      .padding({ top: 12, bottom: 24, left: 16, right: 16 })
      .backgroundColor('rgba(10,15,30,0.93)')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
  }
}