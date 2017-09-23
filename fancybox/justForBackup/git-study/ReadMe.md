## 关联远程服务器
``` bash
git remote -v #查看远程关联
#https协议类型,提交时下需要输入用户名,密码
git remote add origin https://github.com/keji/keji.github.io.git
#ssh协议类型,只需要服务器端配置完公钥后,就可以免密码 push
git remote add origin git@github.com:keji/keji.github.io.git
#用过从https协议切换为ssh协议
git remote set-url origin git@github.com:keji/keji.github.io.git
```

## 查看某个修改记录
``` bash
git blame "xxx/xxx/xxx.java" | grep "搜索的内容"
#此时会列出一些信息包括时间,下面的搜索就用时间这个字符串
git log | grep -A 10 "上面的时间字符串" #此方法就可以列出包含查询的提交记录了
```
