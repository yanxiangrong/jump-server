初始用户名: `ubuntu`  
初始密码: `password`

拉取镜像
```shell
docker pull ghcr.io/yanxiangrong/jump-server:master
```

运行
```shell
docker run -d -p 2222:22/tcp --name jump-server --restart=unless-stopped ghcr.io/yanxiangrong/jump-server:master
```

测试
```shell
ssh ubuntu@localhost -p 2222
```
