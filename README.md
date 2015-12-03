foreman start -f Procfile.dev
ln -s op.sh op

1. 更新每个虚拟机上的/etc/hosts文件，可以解析node1,node2,node3
2. 在node1 node2 node3上分别执行:
ssh-keygen -t rsa
touch authorized_keys 将每个intance上的id_rsa.pub复制到这个文件里边。
在每个虚拟机上都分别ssh node1, node2, node3
3. 
