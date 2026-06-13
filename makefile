NAMESPACE=stg
OVERLAY=k8s/overlays/staging

.PHONY: start deploy diff status logs port-forward clean

start:
	sudo k3s server --disable=traefik --snapshotter=native &
	sleep 25
	sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
	sudo chown $$USER:$$USER ~/.kube/config

build:
	docker build -t flask-api:stg ./app
	docker save flask-api:stg | sudo k3s ctr images import -

deploy:
	kubectl apply -k $(OVERLAY)

diff:
	kubectl diff -k $(OVERLAY)

status:
	kubectl get all -n $(NAMESPACE)

logs:
	kubectl logs -l app=flask-api -n $(NAMESPACE) --tail=50

port-forward:
	kubectl port-forward svc/stg-flask-api-svc 5000:80 -n $(NAMESPACE)

clean:
	kubectl delete -k $(OVERLAY)
	kubectl delete namespace $(NAMESPACE)
