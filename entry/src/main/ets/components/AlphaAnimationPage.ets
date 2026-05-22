import { mapCommon, map } from '@kit.MapKit';

@Component
export struct AlphaAnimationPage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      console.error('AlphaAnimationPage: mapController');
      return;
    }
    await this.runAlphaAnimation();
  }

  private async runAlphaAnimation() {
    const lat: number = this.center!.latitude;
    const lng: number = this.center!.longitude;

    this.mapController?.moveCamera(
      map.newCameraPosition({ target: this.center!, zoom: 14 })
    );

    const opts: mapCommon.MarkerOptions = {
      position: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      title: 'Fading',
      clickable: true
    };

    try {
      const marker: map.Marker | undefined = await this.mapController?.addMarker(opts);
      if (!marker) {
        return;
      }

      const alpha: map.AlphaAnimation = new map.AlphaAnimation(0, 1);
      alpha.setDuration(1500);
      alpha.setRepeatCount(-1);
      alpha.setRepeatMode(map.AnimationRepeatMode.REVERSE);

      marker.setAnimation(alpha);
      marker.startAnimation();
    } catch (e) {
      console.error(`runAlphaAnimation failed: ${e.code} - ${e.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('AlphaAnimation')
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
