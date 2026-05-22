import { mapCommon, map } from '@kit.MapKit';

@Component
export struct MapPolygonPage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      console.error('MapPolygonPage: mapController');
      return;
    }
    await this.addPolygon();
  }

  private async addPolygon() {
    const lat: number = this.center!.latitude;
    const lng: number = this.center!.longitude;

    this.mapController?.moveCamera(
      map.newCameraPosition({ target: this.center!, zoom: 13 })
    );

    const r: number = 0.01;
    const sides: number = 6;
    const ring: mapCommon.LatLng[] = [];
    for (let i = 0; i < sides; i++) {
      const theta: number = (i / sides) * 2 * Math.PI;
      const p: mapCommon.LatLng = {
        latitude: lat + r * Math.cos(theta),
        longitude: lng + r * Math.sin(theta) * 1.3
      };
      ring.push(p);
    }

    const hole: mapCommon.LatLng[] = [];
    const hr: number = 0.003;
    for (let i = 0; i < sides; i++) {
      const theta: number = (i / sides) * 2 * Math.PI;
      const p: mapCommon.LatLng = {
        latitude: lat + hr * Math.cos(theta),
        longitude: lng + hr * Math.sin(theta) * 1.3
      };
      hole.push(p);
    }

    const options: mapCommon.MapPolygonOptions = {
      points: ring,
      holes: [hole],
      fillColor: 0x6610b981,
      strokeColor: 0xff10b981,
      strokeWidth: 3,
      clickable: false,
      geodesic: false
    };

    try {
      await this.mapController?.addPolygon(options);
    } catch (e) {
      console.error(`addPolygon failed: ${e.code} - ${e.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('MapPolygon')
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
