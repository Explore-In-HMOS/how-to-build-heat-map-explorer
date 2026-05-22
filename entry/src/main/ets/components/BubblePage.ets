import { mapCommon, map } from '@kit.MapKit';

@Component
export struct BubblePage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      return;
    }

    const lat = this.center.latitude;
    const lng = this.center.longitude;

    this.mapController?.moveCamera(
      map.newCameraPosition({ target: this.center, zoom: 13 })
    );

    const c1: mapCommon.MapCircleOptions = {
      center: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      radius: 400,
      fillColor: 0x993b82f6,
      strokeColor: 0xffffffff,
      strokeWidth: 1,
      clickable: true
    };
    const c2: mapCommon.MapCircleOptions = {
      center: { latitude: lat + 0.005, longitude: lng - 0.007 } as mapCommon.LatLng,
      radius: 600,
      fillColor: 0x9910b981,
      strokeColor: 0xffffffff,
      strokeWidth: 1,
      clickable: true
    };
    const c3: mapCommon.MapCircleOptions = {
      center: { latitude: lat - 0.005, longitude: lng + 0.007 } as mapCommon.LatLng,
      radius: 250,
      fillColor: 0x99f59e0b,
      strokeColor: 0xffffffff,
      strokeWidth: 1,
      clickable: true
    };

    this.mapController?.addCircle(c1);
    this.mapController?.addCircle(c2);
    this.mapController?.addCircle(c3);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('Bubble')
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor('#88000000')
        .padding(4)
        .margin({ bottom: 48 })
    }
    .width('100%')
    .height('100%')
  }
}