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

cd /venv_kolla/share/c4/k8s-pre-bootstrap
ansible-playbook -i hosts k8s-prep.yml
ansible-playbook snapshot_vms_k8s_cluster_c4.yml

kubeadm init \
  --apiserver-advertise-address=10.1.17.81 \
  --pod-network-cidr 192.168.128.0/24 \
  --upload-certs

#https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
#kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
#kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml 
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

kubectl describe node c4-m-1
kubeadm reset
rm -f /etc/cni/net.d/*
rm -rf $HOME/.kube

# C2:
 
for i in c5-m-1 c5-w-1 c5-w-2 ;
do 
  ssh-copy-id -f -i ~/.ssh/id_rsa.pub root@$i ; 
done

kubeadm init \
  --apiserver-advertise-address=10.1.17.87 \
  --pod-network-cidr 192.168.0.0/16 \
  --upload-certs

kubeadm init \
  --apiserver-advertise-address=10.1.17.87 \
  --pod-network-cidr 172.16.0.0/16 \
  --upload-certs