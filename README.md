# Deploy Django, Gunicorn, Nginx, and Postgres on Kubernetes
**Requirements:**
1. A working Kubernetes cluster with ingress controller (in this set up, we used HAproxy). I won't dicuss in detail for how to build Kubernetes cluster as
there are a lot of documents show how to do this. I also have a repo that can be used to [launch Kubernetes cluster in AWS with Terraform.](https://github.com/zeebote/create-kubernetes-cluster-on-aws-with-terraform)  
1. Share storage for serving Postgres pesistent data and static files which are sharing between Django and Nginx (we use NFS in this setup)
1. Django app (we use the polls app in Django official tutorials. For detail please use following [link](https://docs.djangoproject.com/en/3.1/intro/tutorial01/)
1. Docker - use to build container for Django, Postgres, and Nginx. For more infomation how to install Docker please follow this [link](https://docs.docker.com/engine/install/)

**How to use:**
1. Clone this repo to your workspace
   ```
   git clone https://github.com/zeebote/Django-Gunicorn-Nginx-Postgres-on-Kubernetes .
   cd Django-Gunicorn-Nginx-Postgres/
   Django-Gunicorn-Nginx-Postgres$ tree
    .
    ├── deployment            #Kubernetes deployment yaml
    │   ├── django.yml
    │   ├── nginx.yml
    │   └── postgres.yml
    ├── DjangoApp             # Django 
    │   ├── apps              # apps project
    │   │   ├── asgi.py
    │   │   ├── __init__.py
    │   │   ├── __pycache__
    │   │   │   ├── __init__.cpython-36.pyc
    │   │   │   ├── __init__.cpython-39.pyc
    │   │   │   ├── settings.cpython-36.pyc
    │   │   │   ├── settings.cpython-39.pyc
    │   │   │   ├── urls.cpython-36.pyc
    │   │   │   ├── urls.cpython-39.pyc
    │   │   │   ├── wsgi.cpython-36.pyc
    │   │   │   └── wsgi.cpython-39.pyc
    │   │   ├── settings.py
    │   │   ├── urls.py
    │   │   └── wsgi.py
    │   ├── docker-entrypoint.sh
    │   ├── Dockerfile                    #Docker file for building Django container
    │   ├── manage.py
    │   ├── polls                         # Polls app 
    │   │   ├── admin.py
    │   │   ├── apps.py
    │   │   ├── __init__.py
    │   │   ├── migrations
    │   │   │   ├── 0001_initial.py
    │   │   │   ├── __init__.py
    │   │   │   └── __pycache__
    │   │   │       ├── 0001_initial.cpython-36.pyc
    │   │   │       ├── 0001_initial.cpython-39.pyc
    │   │   │       ├── __init__.cpython-36.pyc
    │   │   │       └── __init__.cpython-39.pyc
    │   │   ├── models.py
    │   │   ├── __pycache__
    │   │   │   ├── admin.cpython-36.pyc
    │   │   │   ├── admin.cpython-39.pyc
    │   │   │   ├── apps.cpython-36.pyc
    │   │   │   ├── apps.cpython-39.pyc
    │   │   │   ├── __init__.cpython-36.pyc
    │   │   │   ├── __init__.cpython-39.pyc
    │   │   │   ├── models.cpython-36.pyc
    │   │   │   ├── models.cpython-39.pyc
    │   │   │   ├── urls.cpython-36.pyc
    │   │   │   ├── urls.cpython-39.pyc
    │   │   │   ├── views.cpython-36.pyc
    │   │   │   └── views.cpython-39.pyc
    │   │   ├── static
    │   │   │   └── polls
    │   │   │       ├── images
    │   │   │       │   └── background.gif
    │   │   │       └── style.css
    │   │   ├── templates
    │   │   │   └── polls
    │   │   │       ├── detail.html
    │   │   │       ├── index.html
    │   │   │       └── results.html
    │   │   ├── tests.py
    │   │   ├── urls.py
    │   │   └── views.py
    │   └── requirements.txt
    ├── nginx                                    # Nginx 
    │   ├── default.conf                         # Configure to work with Gunicorn
    │   └── Dockerfile                           # Docker file for building nginx container
    └── README.md
   ```
1. Deploy Postgres to Kubernetes - We use official Postgress container on Docker hub - This deployment will create a namespace "apps", Persistent nfs volume, 
a persitent volume claim, configmap, service, secret (for postgress user and password), and a pod which host postgres container.
   ```
   Django-Gunicorn-Nginx-Postgres$ kubectl apply -f deployment/postgres.yml
   namespace/apps created
   persistentvolume/nfs-postgresdb created
   persistentvolumeclaim/postgres-pv-claim created
   service/postgres created
   configmap/postgres-config created
   secret/postgres-secret created
   deployment.apps/postgres created
   ```
   Verify if Postgres running on Kubernetes
   ```
   kubectl -n apps get pod
   NAME                        READY   STATUS    RESTARTS   AGE
   postgres-6675bd8f46-q2d4t   1/1     Running   0          102s
   ```
   
4. Build Django app container
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ docker build -t polls ./DjangoApp
   :~/Django-Gunicorn-Nginx-Postgres$ docker images
   REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
   polls                  latest              7b6142935f09        36 seconds ago      77.8MB
   ```
   Tag images and push to docker hub account
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ docker tag polls trucv/polls
   :~/Django-Gunicorn-Nginx-Postgres$ docker push trucv/polls
   The push refers to repository [docker.io/trucv/polls]
    3343c4701cb6: Pushed
    f18b2f5668e3: Pushed
    b0f1a1954549: Pushed
    162dfdb1d604: Layer already exists
    2884295f40ee: Layer already exists
    d979a769ea12: Layer already exists
    f04cc38c0ac2: Layer already exists
    ace0eda3e3be: Layer already exists
    latest: digest: sha256:f27db317d54186b54e63bafd2f20ae60d9b1adb36e0f1659ac3d71a45c646f35 size: 1996
   ```
1. Deploy Django to Kubernetes - Before deploy make sure update configmap data DJANGO_ALLOWED_HOSTS with your FQDN to serve for the app. 
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl apply -f deployment/django.yml
   persistentvolume/nfs-polls created
   persistentvolumeclaim/nfs-pvc created
   configmap/polls-config created
   secret/polls-secret created
   service/polls created
   deployment.apps/polls-app created
   ```
   Verify on Kubernetes 
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl -n apps get pod
   NAME                         READY   STATUS    RESTARTS   AGE
   polls-app-6768d954f9-jkcdl   1/1     Running   0          81s
   polls-app-6768d954f9-mvfz6   1/1     Running   0          81s
   postgres-6675bd8f46-q2d4t    1/1     Running   0          13m
   ```
1. Build Nginx container - Before deploy nginx, you need to update the ingress with the correct FQDN to server for your app
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ docker build -t nginx ./nginx
   Sending build context to Docker daemon  3.072kB
    Step 1/2 : FROM nginx:1.19.4-alpine
     ---> e5dcd7aa4b5e
    Step 2/2 : COPY ./default.conf /etc/nginx/conf.d/default.conf
     ---> 23c565b432e2
    Successfully built 23c565b432e2
    Successfully tagged nginx:latest
   ```
   Tag image amd push to docker hub
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ docker tag nginx trucv/nginx
   :~/Django-Gunicorn-Nginx-Postgres$ docker push trucv/nginx
   The push refers to repository [docker.io/trucv/nginx]
    09a5968ac1c3: Pushed
    2367050c34dd: Layer already exists
    2c8583333eb3: Layer already exists
    e2a648dc6400: Layer already exists
    93e19e6dd56b: Layer already exists
    ace0eda3e3be: Layer already exists
    latest: digest: sha256:06674a4b377ead1308bac6245a42fd6f8365c43e01889898c08f2be546f63185 size: 1567
   ```
1. Deploy Nginx to Kubernetes
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl apply -f deployment/nginx.yml
   service/nginx created
   ingress.extensions/nginx created
   deployment.apps/nginx-app created
   ```
   Verify on Kubernetes
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl -n apps get pod
   NAME                         READY   STATUS    RESTARTS   AGE
   nginx-app-7c58fcd59b-49w6f   1/1     Running   0          2m8s
   polls-app-6768d954f9-jkcdl   1/1     Running   0          8m48s
   polls-app-6768d954f9-mvfz6   1/1     Running   0          8m48s
   postgres-6675bd8f46-q2d4t    1/1     Running   0          21m
   ```
1. Initilize Django app database - We can run this on either of the polls-app pod
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl -n apps exec polls-app-6768d954f9-jkcdl -- python3 manage.py migrate
   Operations to perform:
   Apply all migrations: admin, auth, contenttypes, polls, sessions
   Running migrations:
    Applying contenttypes.0001_initial... OK
    Applying auth.0001_initial... OK
    Applying admin.0001_initial... OK
    Applying admin.0002_logentry_remove_auto_add... OK
    Applying admin.0003_logentry_add_action_flag_choices... OK
    Applying contenttypes.0002_remove_content_type_name... OK
    Applying auth.0002_alter_permission_name_max_length... OK
    Applying auth.0003_alter_user_email_max_length... OK
    Applying auth.0004_alter_user_username_opts... OK
    Applying auth.0005_alter_user_last_login_null... OK
    Applying auth.0006_require_contenttypes_0002... OK
    Applying auth.0007_alter_validators_add_error_messages... OK
    Applying auth.0008_alter_user_username_max_length... OK
    Applying auth.0009_alter_user_last_name_max_length... OK
    Applying auth.0010_alter_group_name_max_length... OK
    Applying auth.0011_update_proxy_permissions... OK
    Applying auth.0012_alter_user_first_name_max_length... OK
    Applying polls.0001_initial... OK
    Applying sessions.0001_initial... OK
   ```
   Collect static files
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl -n apps exec polls-app-6768d954f9-jkcdl -- python3 manage.py collectstatic
   134 static files copied to '/apps/polls/static'.
   ```
   Create admin user
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ kubectl -n apps exec -ti polls-app-6768d954f9-jkcdl -- python3 manage.py createsuperuser
   Username (leave blank to use 'root'): DjangoAdmin
   Email address: admin@examle.com
   Password:
   Password (again):
   Superuser created successfully.
   ```
1. Verify if the app is working. 
   ```
   :~/Django-Gunicorn-Nginx-Postgres$ curl http://your.domain.com/polls/
   <link rel="stylesheet" type="text/css" href="/static/polls/style.css">
    
    <p>No polls are available.</p>
   ```
   Since we don't have any vote record yet, it should show "No polls are avaiable" as it suppose to. Your Django app is running ok on Kubernetes.  
   
   
