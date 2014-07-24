# Photo Gallery

使用 AngularJS + CoffeeScript + Brunch

## Getting started
* 安装 [Brunch](http://brunch.io): `npm install -g brunch`
* 安装 Brunch 插件: `npm install` (如果抛错，很可能是网络原因，试试 `npm config set registry https://registry.npmjs.org/`)
* 安装 [Bower](http://bower.io) components: `bower install`
* 运行程序可以使用 `sh server.sh`. 正常情况会启动在 http://localhost:3333
* 用户登录：`{username:'test', password:123}, {username:'ryan', password:123}`, 也可以注册新用户
* 如果需要重新构建可以运行 `sh setup.sh`

最终生成的文件都在 `public/` 目录下：
* `js/app.js` - 主程序 js 文件
* `js/vendor.js` - 依赖的 js 文件
* `partials` - 所有 html 模板

项目中的结构：
* `app/*` - 主程序, 包括 程序逻辑，html模板，css样式
* `app/mocks.coffee` - 主要做 服务端 的模拟
* `vendor` - 第3方依赖包

主要的功能：
* User Login/Register/Logout, Reload
* Upload photo - done 50% 点击上传 会给当前用户创建一个新的图片信息，并保存到模拟数据库
* Display photo thumbnail in a fancy way - done 50% 从模拟数据库中获取当前用户的图片信息，并用幻灯片展示
* 加了一个模拟后端，方便前端开发
