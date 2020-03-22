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
## 撤销git commit --amend
What you need to do is to create a new commit with the same details as the current HEAD commit, but with the parent as the previous version of HEAD. git reset --soft will move the branch pointer so that the next commit happens on top of a different commit from where the current branch head is now.
``` bash
# Move the current head so that it's pointing at the old commit
# Leave the index intact for redoing the commit.
# HEAD@{1} gives you "the commit that HEAD pointed at before 
# it was moved to where it currently points at". Note that this is
# different from HEAD~1, which gives you "the commit that is the
# parent node of the commit that HEAD is currently pointing to."
git reset --soft HEAD@{1}

# commit the current tree using the commit details of the previous
# HEAD commit. (Note that HEAD@{1} is pointing somewhere different from the
# previous command. It's now pointing at the erroneously amended commit.)
git commit -C HEAD@{1}
```

## 修改提交的author
``` bash
git commit --amend --author "Cao keji <caokeji@bytedance.com>"
```
