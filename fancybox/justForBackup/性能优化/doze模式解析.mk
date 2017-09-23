### Android Doze模式下的AlarmManager策略

## Doze 模式的定义
Android 6.0引入了Doze模式,用户拔掉电源，在关闭手机屏幕并且不动的一段时间后，系统便会进入Doze模式。<br>
此模式下通过延缓CPU和网络活动减少电量的消耗。阻止APP访问网络,推迟jobs,syncs,标准 alarms.定期系统会退出Doze模式一小段时间<br>
让app完成推迟的活动,此段时间称为 'maintenance window'(维护时段),在这段时间系统运行此前挂起的syncs,jobs,alarms,并且让app能够访问网络<br>
<img src="http://o6lxzg30h.bkt.clouddn.com/doze.png" width=800/><br>
在每个维护时段结束后，系统会再次进入Doze模式，暂停网络访问并推迟作业、同步和闹铃。 随着时间的推移，系统安排维护时段的次数越来越少，<br>
这有助于在设备未连接至充电器的情况下长期处于不活动状态时降低电池消耗。

## Doze模式下对 AlarmManager 的影响
AlarmManager提供了一个系统体型服务,允许你设置自己的程序在未来某一时刻执行任务,说白了就像闹钟,日历一样在设置的时间提醒用户.代码如下:<br>
``` java
AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
Intent intent = new Intent();
intent.setAction("com.test.broadcast");
PendingIntent pendingIntent = PendingIntent.getBroadcast(this,1,intent,FLAG_UPDATE_CURRENT);
alarmManager.setExact(AlarmManager.RTC_WAKEUP,System.currentTimeMillis()+5000,pendingIntent);
```
上面这段代码设置了在五秒钟后发送一个广播(action:'com.test.broadcast'),这种方式在Doze引入之前是正常的,当时Doze mode 下就显示了Alarm的使用<br>
下面是官方文档的描述:<br>

``` java
	标准 AlarmManager 闹铃（包括 setExact() 和 setWindow()）推迟到下一维护时段
	如果您需要设置在低电耗模式下触发的闹铃，请使用 setAndAllowWhileIdle() 或 setExactAndAllowWhileIdle()
	一般情况下，使用 setAlarmClock() 设置的闹铃将继续触发 — 但系统会在这些闹铃触发之前不久退出低电耗模式
```
官方给的解决方法是用setAndAllowWhileIdle(),setExactAndAllowWhileIdle(),setAlarmClock()<br>
这三个方法我自己实机测试了一下,Doze模式官方给了个手动进入的方法

``` bash
##下面是开启的方法
adb shell dumpsys battery unplug ##设置为非充电
adb shell dumpsys deviceidle enable ##设置idle模式可用
adb shell dumpsys deviceidle force-idle ##强制进入idle模式

##下面是退出idle指令
adb shell dumpsys deviceidle disable
adb shell dumpsys battery reset
```

如果成功进入idle,输入 adb shell dumpsys deviceidle 是会看到的,如图显示mStat=IDLE:<br>
<img src="http://o6lxzg30h.bkt.clouddn.com/idle.PNG" width=800/><br>
从测试结果看setAndAllowWhileIdle和setExactAndAllowWhileIdle并不起作用(官方文档自己打自己的脸-_-?,也可能是我的测试机三星S8系统并非完全原生的原因),setAlarmClock是能唤醒的,<br>
而且通过指令adb shell dumpsys deviceidle查看mStat状态也变成了mState=INACTIVE,不过有一点比较尴尬,setAlarmClock设置了以后再通知栏里有一个闹钟的图标(不能偷偷摸摸的干事情了...)<br>
从实验结果看setAlarmClock()估计是现在最靠谱的唤醒方法了.也许有人会说加入白名单当个贵族哈哈但是官方文档时这样描述的:<br>
``` java
在低电耗模式和应用待机模式期间，加入白名单的应用可以使用网络并保留部分 wake locks。 不过，正如其他应用一样，其他限制仍然适用于加入白名单的应用。
例如，加入白名单的应用的作业和同步将推迟（在 API 级别 23 及更低级别中），并且其常规 AlarmManager 闹铃不会触发。
```
很遗憾,白名单只保留网络和部分wake locks,并不包括 AlarmManager
