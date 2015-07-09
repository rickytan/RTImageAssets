RTImageAssets [![Build Status](https://travis-ci.org/rickytan/RTImageAssets.svg)](https://travis-ci.org/rickytan/RTImageAssets) [![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](./LICENSE) [![](https://img.shields.io/gratipay/rickytan.svg)](https://gratipay.com/~rickytan/)
=============

[![Donate](https://www.paypalobjects.com/webstatic/en_US/btn/btn_donate_pp_142x27.png "Donate me a cup of coffee")](paypal://ricky_tan@live.cn "Donate me a cup of coffee")

Brief
---
A Xcode plugin to automatically generate @2x, @1x image from @3x image for you, or upscale to @3x from @2x. As easy as you press `Ctrl+Shift+A`, and **DONE**!

Features
---
- Only generate those missing assets, if you have already set your own @2x image, it does nothing
- Automaticaly rename those image files under `N.imageset` to `N.png`, `N@2x.png`, `N@3x.png`
- Easy to use, don't need ask for your designer's help any more!

### _New Feature!!!_
- **Auto generate all the App icons needed**。press `Ctrl+Shift+Option+A` to open **App Icon** window, choose the  `xcasset`, then the `appiconset` you want to use, drag & drop **1024x1024** big icon, and click **generate**, DONE!

![Usage](./ScreenCap/usage.gif)

![Iconset](./ScreenCap/iconset-gen.gif)

Settings
---
![Setting](./ScreenCap/p.png)

Install
---

### From Source
Clone this Repo, build it in `Xcode`, and restart your `Xcode`.

### From Plugin Manager
Install [Package Manager](http://alcatraz.io/) for **Xcode**, search: `RTImageAssets`.

Issues
---
This plugin is **NOT** fully tested, if you have any problems, please let me know: <https://github.com/rickytan/RTImageAssets/issues>

Alternatives
---
+ [Prepo](http://wearemothership.com/work/prepo/)
+ [Asset Catalog Creator](https://itunes.apple.com/us/app/asset-catalog-creator-app/id809625456?mt=12)


License
---
**MIT**


简介
---
本项目是一个 **Xcode** 插件，用来生成 @3x 的图片资源对应的 @2x 和 @1x 版本，只要拖拽高清图到 @3x 的位置上，然后按 `Ctrl+Shift+A` 即可自动生成两张低清的补全空位。当然你也可以从 @2x 的图生成 @3x 版本，如果你对图片质量要求不高的话。

特性
---
- 只会填补空位，如果你已经设置好了自己的 @2x 图，则不会生成；
- 自动重命名，保持项目干净（把 N.imageset 下的图片名字改为 `N.png` `N@2x.png` `N@3x.png` 等）；
- 使用简单，不用再麻烦美术同学缩放了；

### _新特性！！！_
- **自动生成所有所需的应用程序图标**。按 `Ctrl+Shift+Option+A` 打开 **App Icon** 窗口，选择 `xcasset`，再选择 `appiconset`，拖拽 **1024x1024** 的大图标到窗口中，点击 **generate**，完成！

    ***注意：***本插件从 @3x 到 @2x 的缩放保证图片在屏幕上显示的物理尺寸一样，而不是与屏幕比例一样，缩放系数是 **1.5**，而不是 `1242 / 640 = 1.94`。

![Usage](./ScreenCap/usage.gif)

![Iconset](./ScreenCap/iconset-gen.gif)

设置
---
![Setting](./ScreenCap/p.png)

安装
---

### 编译安装
下载本项目，在 `Xcode` 中打开，构建、重启即可。

### `Plugin Manager` 安装
安装 [插件管理](http://alcatraz.io/) 插件，搜索：`RTImageAssets`。

问题
---
此插件还没有经过严格测试，如果你有什么问题，请提出：<https://github.com/rickytan/RTImageAssets/issues>

其它选择
---
+ [Prepo](http://wearemothership.com/work/prepo/)
+ [Asset Catalog Creator](https://itunes.apple.com/us/app/asset-catalog-creator-app/id809625456?mt=12)

协议
---
**MIT**