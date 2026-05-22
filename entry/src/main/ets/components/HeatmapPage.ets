import { mapCommon, map } from '@kit.MapKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

function secureRandomNumber(): number {
  const rand = cryptoFramework.createRandom();
  const randData = rand.generateRandomSync(8);
  const bytes = randData.data;
  let bigIntValue = BigInt(0);
  for (let i = 0; i < 8; i++) {
    bigIntValue = (bigIntValue << BigInt(8)) | BigInt(bytes[i]);
  }
  const maxSafeValue = BigInt(1) << BigInt(53);
  return Number(bigIntValue >> BigInt(11)) / Number(maxSafeValue);
}

@Component
export struct HeatmapPage {
  mapController?: map.MapComponentController;
  center?: mapCommon.LatLng;

  async aboutToAppear() {
    if (!this.mapController || !this.center) {
      return;
    }
    await this.addHeatmap();
  }

  private async addHeatmap() {
    const lat = this.center!.latitude;
    const lng = this.center!.longitude;

    const data: mapCommon.WeightedLatLng[] = [];
    for (let i = 0; i < 500; i++) {
      data.push({
        point: {
          latitude: lat + (secureRandomNumber() * 0.1 - 0.05),
          longitude: lng + (secureRandomNumber() * 0.1 - 0.05)
        },
        intensity: secureRandomNumber()
      });
    }
    try {
      await this.mapController?.addHeatmap({
        id: 'heatmap0001',
        data: data,
        radius: 20,
        intensity: { 2: 1, 5: 5, 8: 10 }
      });
    } catch (e) {
      console.error(`addHeatmap failed: ${e.code} - ${e.message}`);
    }
  }

  build() {
    Text('Heatmap')
      .fontSize(13)
      .fontColor(Color.White)
      .backgroundColor('#88000000')
      .padding(4)
      .margin({ bottom: 48 })
  }
}