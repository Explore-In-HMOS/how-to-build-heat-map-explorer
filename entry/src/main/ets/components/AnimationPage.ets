import { mapCommon, map } from '@kit.MapKit';

@Component
export struct AnimationPage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      console.error('AnimationPage: mapController');
      return;
    }
    await this.runAnimation();
  }

  private async runAnimation() {
    const lat: number = this.center!.latitude;
    const lng: number = this.center!.longitude;

    this.mapController?.moveCamera(
      map.newCameraPosition({ target: this.center!, zoom: 14 })
    );

    const opts: mapCommon.MarkerOptions = {
      position: { latitude: lat, longitude: lng } as mapCommon.LatLng,
      title: 'Animated',
      clickable: true
    };

    try {
      const marker: map.Marker | undefined = await this.mapController?.addMarker(opts);
      if (!marker) {
        return;
      }

      const target: mapCommon.LatLng = {
        latitude: lat + 0.01,
        longitude: lng + 0.01
      };

      const translate: map.TranslateAnimation = new map.TranslateAnimation(target);
      const scale: map.ScaleAnimation = new map.ScaleAnimation(0.5, 1.5, 0.5, 1.5);
      const rotate: map.RotateAnimation = new map.RotateAnimation(0, 360);

      const set: map.AnimationSet = new map.AnimationSet(true);
      set.addAnimation(translate);
      set.addAnimation(scale);
      set.addAnimation(rotate);
      set.setDuration(2000);
      set.setRepeatCount(-1);

      marker.setAnimation(set);
      marker.startAnimation();
    } catch (e) {
      console.error(`runAnimation failed: ${e.code} - ${e.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('Animation')
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
