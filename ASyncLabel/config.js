var isTest = true;
var fs = require('fs');
const path = require('path')
var ConfigIniParser = require("config-ini-parser").ConfigIniParser;
var delimiter = "\n"; //or "\n" for *nux
parser = new ConfigIniParser(delimiter); //If don't assign the parameter delimiter then the default value \n will be used
var localConfig = path.join(__dirname, 'local_config.conf')
var iniContent = fs.readFileSync(localConfig, 'utf-8');
parser.parse(iniContent);
var reportUrl = parser.get("base", "reporturl");
var appHost = parser.get("base", "apphost");
var appIndex =  parser.get("base", "appindex");
var home = parser.get("base", "home");
var appId = parser.get("base", "appid");
var protocal = parser.get("base", "protocal");
var productName = parser.get("base", "productname");
var appName = parser.get("base", "appname");

var build = parser.get("base", "build");
var description = parser.get("base", "description");
var author = parser.get("base", "author");
var runTimeVersion = parser.get("base", "runtimeversion");
var version = parser.get("base", "version");
if(build == 'Debug')
{
  isTest = true;
}
else
{
  isTest = false;
}
// console.log(isTest);
var im_config = {
  //############ 以下为必改项 ##############
  //http://electron.atom.io/docs/api/crash-reporter/
  REPORT_URL: reportUrl,
  // APP_HOST: 'http://api-test.rcx.rongcloud.cn:8091/im',
  //测试环境   
  APP_HOST: appHost, 
  APP_INDEX: appIndex, 
  // APP_HOST: 'http://dev.im.rce.rongcloud.net/desktop-client',
  // APP_HOST: 'http://web.hitalk.im/rce',
  // APP_HOST: 'https://test.im.rce.rongcloud.net/voip',
  // APP_HOST: 'http://api-test.rcx.rongcloud.cn:8091/im',
  //生产环境 
  // APP_HOST: 'http://im.rce.rongcloud.net', 
  //############  以上为必改项  ##############

  APP_ID: appId,
  HOME: home,
  PROTOCAL: protocal,
  WINICON: 'app.ico',
  WIN: {
      //  WINDOWS ONLY,TRAY BLINK ON
      //  new Tray,tray.setImage    
      TRAY: 'Windows_icon.png',  
      //  WINDOWS ONLY,TRAY BLINK OFF
      //  tray.setImage
      TRAY_OFF: 'Windows_Remind_icon.png',  
      //  tray.displayBalloon
      BALLOON_ICON: 'app.png'
  },
  MAC: {
      //HELPER_BUNDLE_ID: 'SealTalk_Ent_Test',
      //  new Tray
      TRAY: 'Mac_Template.png',
      //  tray.setPressedImage
      PRESSEDIMAGE: 'Mac_TemplateWhite.png'
  },
  PACKAGE: {
      //以下参数设置需对照 配置说明 中 4 项列出的工具参数理解
      PRODUCTNAME: productName,
      APPNAME: appName,
      VERSION: version,
      DESCRIPTION: description,
      AUTHOR: author,
      RUNTIMEVERSION: runTimeVersion,
      COPYRIGHT: "",
      WIN: {
        APPICON: 'app.ico', 
        ICON_URL: 'http://7i7gc6.com1.z0.glb.clouddn.com/image/sealtalk.ico',
        LOADING_GIF: './res/loading.gif'
      },
      MAC: {
        APPICON: 'app.icns',
        BACKGROUND: 'bg.png'
        //CF_BUNDLE_VERSION: '1.0.3'
      },
      LINUX: {
        APPICON: 'app.png'
      }
  },
  VOIP: {
    INDEX: '/modules/voip/voip.html',  //暂时未用
    MINWIDTH: 100,
    MINHEIGHT: 100,
    BOUNDS: {
      X: 0,
      Y: 0,
      WIDTH: 338,
      HEIGHT: 260
    }
  },
  DEBUG: true,
  DEBUGOPTION: {
    VUEPATH: '/Users/zy/Library/Application Support/Google/Chrome/Default/Extensions/nhdogjmejiglipccpnnnanhbledajbpd/3.1.6_0'
  }
};

if(isTest){
    im_config.APP_ID += 'TEST'; 
    im_config.PROTOCAL += 'TEST'; 
    im_config.PACKAGE.APPNAME += 'TEST';
    im_config.PACKAGE.PRODUCTNAME += 'TEST';
    im_config.PACKAGE.DESCRIPTION = "RCE TEST Desktop Application.";
}
module.exports = im_config;

