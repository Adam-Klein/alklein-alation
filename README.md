# alklein-alation

## SRE assignment for Adam Klein

# Synopsis

A web-hit-counter implemented in Python with Flask and Gunicorn, storing the count a Redis db, load balanced by an Nginx instance. Running under container (Docker) orchestration (Kubernetes).  Access web hit counter via URL (browser or command-line).  Counter is incremented by one for each successful connection. The app includes a health-check which is referenced via Kubernetes livenessProbe. 

Successfull connection returns "Holla! we have hit *number* times" (where *number* is the current total of successful connections)
# Deploying and running the counter

* Assumptions / requirements:
  * Access to https://github.com
  * Access to https://hub.docker.com
  * Recent version of git installed on host system


  1. `git clone https://github.com/Adam-Klein/alklein-alation.git`
## Minikube 

* Assumptions / requirements: 
  * Up and running minikube instance (see https://kubernetes.io/docs/tutorials/hello-minikube/).
  * Recent version of `kubectl` installed and working, `kubectl config current-context` returns `minikube` (if deploying with kubectl)
  * Recent version of Terraform installed and working (if deploying with Terraform)

* Deploying
  
      With kubectl:

      1. `cd alklein-alation/kubernetes`
      2. `kubectl create -f .`

      with Terraform:

      1. `cd alklein-alation/terraform`
      2. `terraform init`
      3. `terraform plan`
      4. `terraform apply`
        1. Enter `yes` when prompted
  
   1. `minikube tunnel`
   2. In another terminal (as minikube tunnel will tie up your terminal), `kubectl get service proxy` 
   3. With the IP address returned under the "EXTERNAL-IP" column, access the URL in a browser or `curl http://IP_address`
## AWS

* Assumptions / requirements
  1. Access to AWS with appropriate IAM permissions, including EKS write / view 
  2. Terraform recent version installed on host system
  3. You are willing to incur any AWS charges for additional workload / nodes deployed to cluster

* Deploying
  1. `cd alklein-alation/terraform`
  2. `terraform init`
  3. `terraform plan`
  4. `terraform apply` (enter `yes` when prompted)
  5. `kubectl get services proxy`
  6. With the IP address returned under the "EXTERNAL-IP" column, access the URL in a browser or `curl http://IP_address`

# Monitoring

The flask app has a built-in healthcheck, avaialble at the URL `/health`.  When operating normally, it returns `{"status":"UP"}`

Assuming an existing Prometheus monitoring deployment, the scrape job config for these components would be:

App:
```
- job_name: Hit counter app
  target: app:8000
- job_name: Hit counter redis db
  target: redis:6379
- job_name: Hit counter LB
  target: proxy:80
```
# Orignal assignment

![screenshot](./images/assignment_p1.png?raw=True)
![screenshot](./images/assignment_p2.png?raw=True)
## Update strategy
* App, Proxy, and Redis deployments are configured with `strategy` of `RollingUpdate` which should allow for a zero-downtime upgrade or rollback, with `MaxSurge` and `MaxUnavailable` set.  I did not have time to test the upgrade implementation. A `kubectl set image deployment/app alation_app:[new_ver]` would peform a rolling upgrade from the version described in the deployment file to `[new_ver]`.  Alternatively, updating the image in the deployment `.yaml` file and performing a `kubectl apply -f deployment_file.yaml` would have the same result. 
## Challenges

* Getting the docker-compose file translated properly into Kubernetes deployment and service files.
* I have successfully deployed on-prem Kubernetes clusters (using RKE) and am comfortable with minikube.  I have not fully / successfully deployed a Kubernetes cluster in AWS (I have gotten most of the way using `kops` and `eksctl`, but have not completed my learning of the IAM requirements for accessing the proxy or properly configuring the LoadBalancer. I was not able to validate the Terraform deployment to AWS for this reason. 
* I am not very experienced with resource requests and limits - I understand what they are for and mean, but I was not able to determine useful and meaningful values for the deployments that I was confident would work. 
*  I have worked with Python requirements enough to know that maintaining a static requirements file is adding to rather than reducing tech debt.  I have started using requirements.in files and using python virtual environments, then running `source venv/bin/activate ; pip install pip-tools; pip-compile; pip-sync`  If I had more time / practice with Dockerfiles and python, I would re-implement the docker-compose to do this in the build.  

## What I liked about my solution

Blah

## What I didn't like about my solution

Blah