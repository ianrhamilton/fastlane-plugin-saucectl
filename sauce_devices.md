---
layout: default
title: Get available RDC Devices
nav_order: 6
---

# Sauce Devices

Use the Real Device Cloud (RDC) API methods to look up device types and availability in your data center.

# Help
Information and help for the `sauce_devices` action can be printed out by executed the following command:
```sh
  fastlane action sauce_devices
```

---------------------------------------------------------------------------
## `platform`

| Required | Type     | Description                            | Options         |
|----------|----------|----------------------------------------|-----------------|
| `true`   | `String` | Device platform that you wish to query | `ios`,`android` |   

---------------------------------------------------------------------------
## `region`

| Required | Type     | Description                   | Options    |
|----------|----------|-------------------------------|------------|
| `true`   | `String` | Data Center you wish to query | `us`, `eu` |

---------------------------------------------------------------------------
## `sauce_username`

| Required | Type     | Description                                                | 
|----------|----------|------------------------------------------------------------|
| `false`  | `String` | Your sauce labs username in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_USERNAME` environment variable set.**

___________________________________________________________________________
## `sauce_access_key`

| Required | Type     | Description                                                  | 
|----------|----------|--------------------------------------------------------------|
| `false`  | `String` | Your sauce labs access key in order to authenticate requests |

**If this parameter is not set the plugin expects there to be an `SAUCE_ACCESS_KEY` environment variable set.**

__________________________________________________________________________

# Example actions

### Get Android devices

```ruby
lane :get_android_devices do
         sauce_devices(platform: 'android',
                       region: 'eu',
                       sauce_username: 'foo',
                       sauce_access_key: 'bar123')
end

lane :get_android_devices do
         sauce_devices(platform: 'android',
                       region: 'eu')
end 
```

# Example Response
```json
[
  "Samsung_Galaxy_S21_Plus_5G_real",
  "Xiaomi_Redmi_Note_8_real",
  "Samsung_Galaxy_A8_2018_real",
  "Samsung_Galaxy_A31_real",
  "Samsung_Galaxy_A2_Core_real",
  "Huawei_Mate_20_Pro_real",
  "Samsung_Galaxy_S10_real",
  "LG_G8S_ThinQ_real",
  "Samsung_Galaxy_S21_5G_real",
  "Sony_Xperia_L3_real",
  "Sony_Xperia_XZ_real",
  "Samsung_Galaxy_A7_2018_real",
  "Google_Pixel_5_real",
  "Samsung_Galaxy_S8_8_real",
  "Samsung_Galaxy_S9_Plus_real",
  "HTC_U12_life_real",
  "Google_Pixel_3_real",
  "Samsung_Galaxy_Note10_Plus_real",
  "Oppo_A52_real",
  "LG_Q_Stylo_4_real",
  "Samsung_Galaxy_S7_Edge_real",
  "Vivo_Y70_real",
  "Huawei_MediaPad_M3_Lite_10_real",
  "Motorola_Moto_X_Play_real",
  "Sony_Xperia_XA2_real",
  "Samsung_Galaxy_S10_Plus_private",
  "Samsung_Galaxy_A9_2018_real",
  "Samsung_Galaxy_A9s_real",
  "Sony_Xperia_10_real",
  "Motorola_Moto_E4_real",
  "Oppo_Reno4_Z_5G_real",
  "Google_Pixel_4_12_real",
  "Samsung_Galaxy_Note_8_private",
  "Sony_Xperia_5_real",
  "Samsung_Galaxy_Tab_S3_real",
  "HUAWEI_nova_2_real",
  "Xiaomi_Mi_A3_real",
  "LG_G7_Thinq_real",
  "Samsung_Galaxy_S10_private",
  "Samsung_Galaxy_M20_real",
  "Google_Pixel_3a_real",
  "Google_Pixel_3_XL_real",
  "Xiaomi_Poco_X3_Pro_real",
  "Meizu_16th_real",
  "HUAWEI_P10_Plus_real",
  "Motorola_Moto_G6_Plus_real",
  "Huawei_Mate_9_real",
  "LG_G6_real",
  "Huawei_MediaPad_T3_10_real",
  "Samsung_Galaxy_Tab_A_10_1_2019_real",
  "Samsung_Galaxy_A40_real",
  "Samsung_Galaxy_J5_2017_real",
  "LG_G5_SE_real",
  "Samsung_Galaxy_A70_real",
  "Samsung_Galaxy_Note_5_real",
  "Samsung_Galaxy_Note10_private",
  "Nokia_2_1_Go_real",
  "Samsung_Galaxy_S10_Plus_real",
  "Samsung_Galaxy_Xcover_5_real",
  "Huawei_P_Smart_2019_real",
  "Samsung_Galaxy_Tab_S7_real",
  "Samsung_Galaxy_S21_Ultra_5G_real",
  "Samsung_Galaxy_Note10_Plus_private",
  "Huawei_MediaPad_M5_Lite_real",
  "Huawei_P9_Lite_2017_real",
  "Oppo_A73_5G_real",
  "Samsung_Galaxy_Tab_A_10_5_real",
  "Sony_XA1_real",
  "Samsung_Galaxy_S6_Edge_real",
  "Google_Pixel_4_real",
  "BQ_Aquaris_X2_real",
  "Samsung_Galaxy_S9_private",
  "Motorola_Moto_G_5G_Plus_real",
  "Nokia_4_2_real",
  "Huawei_P20_Lite_real",
  "LG_K10_2017_real",
  "Samsung_Galaxy_S6_real",
  "Samsung_Galaxy_S8_Plus_real",
  "Samsung_Galaxy_A30_real",
  "Lenovo_Tab_M10_real",
  "LG_V30_real",
  "Google_Pixel_6_real",
  "Motorola_One_Vision_real",
  "Samsung_Galaxy_S20_Plus_real",
  "Huawei_P40_real",
  "Samsung_Galaxy_J3_2017_real",
  "Samsung_Galaxy_Note9_private",
  "Lenovo_Tab_4_10_Plus_real",
  "Motorola_Moto_G4_real",
  "Samsung_Galaxy_Tab_S5e_real",
  "Samsung_Galaxy_Note20_real",
  "Samsung_Galaxy_S8_real",
  "Nokia_7_2_real",
  "Google_Pixel_4a_real",
  "Sony_Xperia_Z5_Premium_real",
  "Samsung_Galaxy_A80_real",
  "One_Plus_7_real",
  "OnePlus_7T_real",
  "Samsung_Galaxy_A20e_real",
  "Samsung_Galaxy_Fold_5G_open_real",
  "Samsung_Galaxy_S20_Ultra_5G_real",
  "Motorola_Moto_G8_Plus_real",
  "Huawei_Nova_5i_real",
  "Huawei_Mate_20_lite_real",
  "Motorola_Moto_X4_real",
  "Zebra_Technologies_TC75x_private",
  "OnePlus_6T_11_real",
  "Google_Pixel_4_private",
  "Huawei_Mate_30_real",
  "OnePlus_8T_real",
  "Xiaomi_Redmi_Note_9_Pro_private",
  "Motorola_Moto_G6_real",
  "Samsung_Galaxy_S10e_real",
  "Xiaomi_Mi_Note_10_Lite_real",
  "Samsung_Galaxy_Note_9_real",
  "Samsung_Galaxy_Note10_real",
  "HUAWEI_P20_real",
  "Huawei_Mate_20_Pro_private",
  "Samsung_Galaxy_S20_real",
  "Honor_10_Lite_real",
  "Amazon_Fire_HD_8_Plus_2020_real",
  "Samsung_Galaxy_A5_2017_real",
  "Samsung_Galaxy_Tab_A_10_1_2016_real",
  "LG_K30_2019_real",
  "Samsung_Galaxy_Tab_S4_10_5_real",
  "Zebra_Technologies_TC77_private",
  "Huawei_P8_Lite_2017_real",
  "OnePlus_Nord_real",
  "Samsung_Galaxy_S8_Plus_private",
  "Google_Pixel_2_real",
  "Samsung_Galaxy_Note9_real",
  "Motorola_One_Action_real",
  "Amazon_Fire_HD10_2019_real",
  "Samsung_Galaxy_A10_real",
  "HUAWEI_P9_real",
  "Honor_Play_real",
  "Google_Pixel_4_XL_real",
  "Nokia_8_real",
  "Motorola_Moto_G7_Play_real",
  "OnePlus_6T_real",
  "Huawei_P30_real",
  "Nokia_2_3_real",
  "Sony_Xperia_XA_real",
  "Google_Pixel_6_Pro_real",
  "Motorola_Nexus_6_real",
  "OnePlus_Five_real",
  "Huawei_Y5p_real",
  "Samsung_Galaxy_S9_real",
  "Samsung_Galaxy_Note8_real",
  "Samsung_Galaxy_S20_FE_real",
  "Huawei_P30_Lite_real"
]
```

### Get ios only devices

```ruby
         sauce_devices(platform: 'ios',
                       region: 'eu',
                       sauce_username: 'foo',
                       sauce_access_key: 'bar123')

        sauce_devices(platform: 'ios',
                      region: 'eu')
```

Example Response
```json
[
  "iPhone_12_15_beta_real",
  "iPhone_6_11_real",
  "iPhone_7_32GB_10_real",
  "iPhone_5S_12_real",
  "iPhone_6_10_3_real",
  "iPad_10_2_14_real",
  "iPad_mini_2_12_real",
  "iPhone_Xr_12_real",
  "iPad_9_7_2017_13_real",
  "iPhone_XS_13_real",
  "iPhone_8_Plus_13_4_real",
  "iPhone_12_mini_14_private",
  "iPhone_6S_11_real",
  "iPhone_6S_Plus_14_real",
  "iPhone_12_14_real",
  "iPad_mini_2021_15_real",
  "iPad_10_2_2021_15_real",
  "iPhone_XS_13_3_real",
  "iPhone_SE_11_real",
  "iPhone_X_14_real",
  "iPhone_13_Pro_Max_15_real",
  "iPhone_XS_Max_13_real",
  "iPad_Pro_11_2021_15_real",
  "iPhone_7_Plus_13_real",
  "iPhone_11_Pro_13_private",
  "iPhone_6S_Plus_12_real",
  "iPod_Touch_7_real",
  "iPhone_7_Plus_13_5_real",
  "Xiaomi_Poco_X3_Pro_real",
  "iPhone_12_mini_14_real",
  "iPhone_8_Plus_13_5_real"
]

```