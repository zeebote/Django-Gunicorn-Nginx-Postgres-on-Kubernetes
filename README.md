# Deploy Django, Gunicorn, Nginx, and Postgres on Kubernetes
**Requirements:**
1. A working Kubernetes cluster with ingress controller (in this set up, we used HAproxy). I won't dicuss in detail for how to build Kubernetes cluster as
there are a lot of documents show how to do this. I also have a repo that can be used to [launch Kubernetes cluster in AWS with Terraform.](https://github.com/zeebote/create-kubernetes-cluster-on-aws-with-terraform)  
1. Share storage for serving Postgres pesistent data and static files which are sharing between Django and Nginx (we use NFS in this setup)
1. Django app (we use the polls app in Django official tutorials. For detail please use following [link](https://docs.djangoproject.com/en/3.1/intro/tutorial01/)
1. Docker - use to build container for Django, Postgres, and Nginx. For more infomation how to install Docker please follow this [link](https://docs.docker.com/engine/install/)

**How to use:**
1. Clone this repo to your workspace
2. Build Postgres container
3. Deploy Postgres to Kubernetes
4. Build Django app container
5. Deploy Django to Kubernetes
6. Build Nginx container
7. Deploy Nginx to Kubernetes
