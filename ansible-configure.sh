# Note:
systemctl list-unit-files | grep kubelet
systemctl daemon-reload

# C1:
cd /venv_kolla/share/c4/
ansible-playbook deploy_vms_k8s_cluster.yml

for i in c4-m-1 c4-w-1 c4-w-2 ;
do 
  ssh-copy-id -f -i ~/.ssh/id_rsa.pub root@$i ; 
done

# C2:
 
for i in c5-m-1 c5-w-1 c5-w-2 ;
do 
  ssh-copy-id -f -i ~/.ssh/id_rsa.pub root@$i ; 
done

