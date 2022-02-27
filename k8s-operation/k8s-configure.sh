# http://www.vmlab.com.pl/manage-snapshot-via-ansible/
cd /venv_kolla/share/c4/k8s-pre-bootstrap
ansible-playbook -i hosts k8s-prep.yml
ansible-playbook snapshot_vms_k8s_cluster_c4.yml

kubeadm init \
  --apiserver-advertise-address=10.1.17.81 \
  --pod-network-cidr 192.168.128.0/24 \
  --upload-certs

https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises
curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O

https://computingforgeeks.com/deploy-kubernetes-cluster-on-centos-with-ansible-calico/
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

kubeadm init \
  --apiserver-advertise-address=10.1.17.87 \
  --pod-network-cidr 192.168.0.0/16 \
  --upload-certs

kubeadm init \
  --apiserver-advertise-address=10.1.17.87 \
  --pod-network-cidr 172.16.0.0/16 \
  --upload-certs

kubectl delete --all pods --namespace=foo
kubectl delete --all deployments --namespace=foo
kubectl delete --all namespaces
for each in $(kubectl get ns -o jsonpath="{.items[*].metadata.name}" | grep -v kube-system);
do
  kubectl delete --all deployments --namespace=$each
  kubectl delete --all pods --namespace=$each
  kubectl delete ns $each
done
kubectl delete daemonsets,replicasets,services,deployments,pods,rc --all --all-namespaces
kubectl delete all --all --all-namespaces


git clone https://github.com/nginxinc/kubernetes-ingress/
git checkout v2.1.1
cd kubernetes-ingress/deployments
git checkout v2.1.1
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f common/ingress-class.yaml
kubectl apply -f daemon-set/nginx-ingress.yaml
kubectl get ds -n nginx-ingress
kubectl get po -n nginx-ingress

vi app-test.yaml
vi app-test-ingress.yaml

kubectl apply -f app-test.yaml 
kubectl apply -f app-test-ingress.yaml
kubectl delete -f app-test-ingress.yaml 

[root@c4-m-1 deployments]# kubectl get all -n nginx-ingress -o wide 
NAME                                 READY   STATUS    RESTARTS   AGE   IP               NODE     NOMINATED NODE   READINESS GATES
pod/http-test-svc-5fbf5cddd6-6mtgc   1/1     Running   0          11h   192.168.185.66   c4-w-1   <none>           <none>
pod/http-test-svc-5fbf5cddd6-sm9s8   1/1     Running   0          11h   192.168.69.130   c4-w-2   <none>           <none>
pod/nginx-ingress-6t5gk              1/1     Running   0          11h   192.168.69.129   c4-w-2   <none>           <none>
pod/nginx-ingress-x7xg8              1/1     Running   0          11h   192.168.185.65   c4-w-1   <none>           <none>

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
service/http-test-svc   ClusterIP   10.99.248.3    <none>        80/TCP                       11h   run=http-test-app
service/nginx-ingress   NodePort    10.98.133.68   <none>        80:30760/TCP,443:30659/TCP   24m   app=nginx-ingress

NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS      IMAGES                      SELECTOR
daemonset.apps/nginx-ingress   2         2         2       2            2           <none>          11h   nginx-ingress   nginx/nginx-ingress:2.1.1   app=nginx-ingress

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES   SELECTOR
deployment.apps/http-test-svc   2/2     2            2           11h   http         httpd    run=http-test-app

NAME                                       DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES   SELECTOR
replicaset.apps/http-test-svc-5fbf5cddd6   2         2         2       11h   http         httpd    pod-template-hash=5fbf5cddd6,run=http-test-app

[root@c4-m-1 ~]# kubectl exec pod/nginx-ingress-x7xg8 env -n nginx-ingress
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=nginx-ingress-x7xg8
POD_NAMESPACE=nginx-ingress
POD_NAME=nginx-ingress-x7xg8
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
NGINX_VERSION=1.21.6
NJS_VERSION=0.7.2
PKG_RELEASE=1~bullseye
HOME=/nonexistent