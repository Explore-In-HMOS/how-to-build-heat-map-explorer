import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError, AsyncCallback } from '@kit.BasicServicesKit';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { HeatmapPage } from '../components/HeatmapPage';
import { PointAnnotationPage } from '../components/PointAnnotationPage';
import { BubblePage } from '../components/BubblePage';
import { MapCirclePage } from '../components/MapCirclePage';
import { MapPolygonPage } from '../components/MapPolygonPage';
import { AnimationPage } from '../components/AnimationPage';
import { AlphaAnimationPage } from '../components/AlphaAnimationPage';
import { TrackPage } from '../components/TrackPage';

@Entry
@Component
struct MapKitDemo {
  @State currentPage: number = 0;
  @State mapReady: boolean = false;
  @State userLocation?: mapCommon.LatLng = undefined;
  private totalPages: number = 8;
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: { latitude: 0, longitude: 0 },
        zoom: 1
      }
    };

    this.callback = async (err, mapController) => {
      if (err) {
        console.error(`Map init failed: ${err.code} - ${err.message}`);
        return;
      }

      this.mapController = mapController;
      this.mapEventManager = this.mapController.getEventManager();

      const granted = await this.checkPermissions();
      if (granted) {
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        await this.moveToUserLocation();
      } else {
        this.requestPermissions();
      }

      this.mapReady = true;
    };
  }

  private changePage(): void {
    this.mapController?.clear();
    this.currentPage = (this.currentPage + 1) % this.totalPages;
  }

  private async moveToUserLocation(): Promise<void> {
    return new Promise((resolve) => {
      try {
        const request: geoLocationManager.CurrentLocationRequest = {
          priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
          scenario: geoLocationManager.LocationRequestScenario.UNSET,
          timeoutMs: 10000,
          maxAccuracy: 0
        };

        geoLocationManager.getCurrentLocation(request, (err, location) => {
          if (err) {
            console.error(`getCurrentLocation error: ${err.code} - ${err.message}`);
            resolve();
            return;
          }

          this.userLocation = {
            latitude: location.latitude,
            longitude: location.longitude
          };

          this.mapController?.moveCamera(
            map.newCameraPosition({
              target: this.userLocation,
              zoom: 15
            })
          );
          resolve();
        });
      } catch (e) {
        console.error(`moveToUserLocation failed: ${e.code} - ${e.message}`);
        resolve();
      }
    });
  }

  async checkPermissions(): Promise<boolean> {
    const permissions: Array<Permissions> = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];
    for (const permission of permissions) {
      const status = await this.checkAccessToken(permission);
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true;
      }
    }
    return false;
  }

  requestPermissions(): void {
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(
      this.getUIContext().getHostContext() as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']
    )
      .then(async (data: PermissionRequestResult) => {
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        await this.moveToUserLocation();
        this.mapReady = true;
      })
      .catch((err: BusinessError) => {
        console.error(`Permission denied: ${err.code} - ${err.message}`);
        this.mapReady = true;
      });
  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager = abilityAccessCtrl.createAtManager();
    const bundleInfo = await bundleManager.getBundleInfoForSelf(
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
    );
    const tokenId = bundleInfo.appInfo.accessTokenId;
    return await atManager.checkAccessToken(tokenId, permission);
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%')
        .height('100%')

      if (this.mapReady && this.userLocation) {
        if (this.currentPage === 0) {
          HeatmapPage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 1) {
          PointAnnotationPage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 2) {
          BubblePage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 3) {
          MapCirclePage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 4) {
          MapPolygonPage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 5) {
          AnimationPage({ mapController: this.mapController, center: this.userLocation })
        } else if (this.currentPage === 6) {
          AlphaAnimationPage({ mapController: this.mapController, center: this.userLocation })
        } else {

          TrackPage({ mapController: this.mapController, center: this.userLocation })
        }
      }

      Row() {
        Text(`${this.currentPage + 1}/${this.totalPages}`)
          .fontSize(11)
          .fontColor(Color.White)
          .margin({ right: 4 })
        Text('›')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor('#88000000')
      .borderRadius(12)
      .margin({ top: 48, right: 12 })
      .onClick(() => this.changePage())
    }
    .width('100%')
    .height('100%')
  }
}
