import { mapCommon, map } from '@kit.MapKit';

@Component
export struct MapCirclePage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      console.error('MapCirclePage: mapController');
      return;
    }
    await this.addCircles();
  }

  private async addCircles() {
    const lat: number = this.center!.latitude;
    const lng: number = this.center!.longitude;

    this.mapController?.moveCamera(
      map.newCameraPosition({ target: this.center!, zoom: 14 })
    );

    const inner: mapCommon.MapCircleOptions = {
      center: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      radius: 200,
      fillColor: 0x553b82f6,
      strokeColor: 0xff3b82f6,
      strokeWidth: 2,
      clickable: false
    };
    const middle: mapCommon.MapCircleOptions = {
      center: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      radius: 500,
      fillColor: 0x333b82f6,
      strokeColor: 0xff3b82f6,
      strokeWidth: 2,
      clickable: false
    };
    const outer: mapCommon.MapCircleOptions = {
      center: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      radius: 1000,
      fillColor: 0x223b82f6,
      strokeColor: 0xff3b82f6,
      strokeWidth: 2,
      clickable: false
    };

    try {
      await this.mapController?.addCircle(outer);
      await this.mapController?.addCircle(middle);
      await this.mapController?.addCircle(inner);
    } catch (e) {
      console.error(`addCircles failed: ${e.code} - ${e.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('MapCircle')
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
