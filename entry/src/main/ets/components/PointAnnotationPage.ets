import { mapCommon, map } from '@kit.MapKit';

@Component
export struct PointAnnotationPage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      console.error('PointAnnotationPage: mapController');
      return;
    }
    await this.addPointAnnotation();
  }

  private async addPointAnnotation() {
    const lat = this.center!.latitude;
    const lng = this.center!.longitude;

    const m1: mapCommon.MarkerOptions = {
      position: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      title: 'Point A',
      clickable: true
    };
    const m2: mapCommon.MarkerOptions = {
      position: { latitude: lat + 0.005, longitude: lng - 0.007 } as mapCommon.LatLng,
      title: 'Point B',
      clickable: true
    };
    const m3: mapCommon.MarkerOptions = {
      position: { latitude: lat - 0.005, longitude: lng + 0.007 } as mapCommon.LatLng,
      title: 'Point C',
      clickable: true
    };

    this.mapController?.addMarker(m1);
    this.mapController?.addMarker(m2);
    this.mapController?.addMarker(m3);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('PointAnnotation')
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