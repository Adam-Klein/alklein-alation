# alklein-alation

## SRE assignment for Adam Klein

# Synopsis

A web-hit-counter implemented in Python with Flask and Gunicorn, storing the count a Redis db, load balanced by an Nginx instance. Running under container (Docker) orchestration (Kubernetes).  Access web hit counter via URL (browser or command-line).  Counter is incremented by one for each successful connection. The app includes a health-check which is referenced via Kubernetes livenessProbe. 

Successfull connection returns **"Holla! we have hit *number* times"** (where *number* is the current total of successful connections)

* _Note - I have included the source for the python / flask app and docker files for each component to provide visiblity into my development process.  In a production implementation, I would have included only the yaml files or Terraform tf files._
# Deploying and running the counter

* Assumptions / requirements:
  * Access to https://github.com
  * Access to https://hub.docker.com
  * Recent version of git installed on host system
## Minikube 

* Assumptions / requirements: 
  * Up and running minikube instance (see https://kubernetes.io/docs/tutorials/hello-minikube/).
  * Recent version of `kubectl` installed and working, `kubectl config current-context` returns `minikube` (if deploying with kubectl)
  * Recent version of Terraform installed and working (if deploying with Terraform)

* Deploying
  
  1. `git clone https://github.com/Adam-Klein/alklein-alation.git`

    With kubectl:

    1. `cd alklein-alation/kubernetes`
    2. `kubectl create -f .`

    With Terraform:

    1. `cd alklein-alation/terraform`
    2. `terraform init`
    3. `terraform plan`
    4. `terraform apply`, enter `yes` when prompted

  Accessing the app:
  
   1. `minikube tunnel`
   2. In another terminal (as minikube tunnel will tie up your terminal), `kubectl get service proxy` 
   3. With the IP address returned under the "EXTERNAL-IP" column, access the URL in a browser or `curl http://IP_address`
## AWS

* Assumptions / requirements
  1. Access to AWS with appropriate IAM permissions, including EKS write / view 
  2. Terraform recent version installed on host system
  3. You are willing to incur any AWS charges for additional workload / nodes deployed to cluster

* Deploying (not fully tested, see comment in challenges section about IAM)
  1.  `git clone https://github.com/Adam-Klein/alklein-alation.git`
  2.  `cd alklein-alation/terraform`
  3. `terraform init`
  4. `terraform plan`
  5. `terraform apply` (enter `yes` when prompted)

  Accessing the app:

  1.   `kubectl get services proxy` (or view AWS console LB settings for external IP)
  2.   With the IP address returned under the "EXTERNAL-IP" column, access the URL in a browser or `curl http://IP_address`

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
* App, Proxy, and Redis deployments are configured with `strategy` of `RollingUpdate` which should allow for a zero-downtime upgrade or rollback, with `MaxSurge` and `MaxUnavailable` set (25% for the app, 1 for the proxy and db).  I did not have time to test the upgrade implementation. A `kubectl set image deployment/app alation_app:[new_ver]` would peform a rolling upgrade from the version described in the deployment file to `[new_ver]`. Alternatively, updating the image in the deployment `.yaml` file and performing a `kubectl apply -f "deployment_file".yaml` would have the same result. If `kubectl set image` is used, once test is completed, the app version should be updated in the yaml and terraform files to reflect current state.
## Challenges

* Getting the docker-compose file translated properly into Kubernetes deployment and service files.
* I have successfully deployed on-prem Kubernetes clusters (using RKE) and am comfortable with minikube.  I have not fully / successfully deployed a Kubernetes cluster in AWS (I have gotten most of the way using `kops` and `eksctl`, but have not completed my learning of the IAM requirements for accessing the proxy or properly configuring the LoadBalancer. I was not able to validate the Terraform deployment to AWS for this reason. 
* I am not very experienced with resource requests and limits - I understand what they are for and mean, but I was not able to determine relevant and meaningful values for the deployments that I was confident would work. 
*  I have worked with Python requirements enough to know that maintaining a static requirements file is adding to rather than reducing tech debt.  I have started using `requirements.in` files and using python virtual environments, then running `source venv/bin/activate ; pip install pip-tools; pip-compile; pip-sync`  If I had more time / practice with Dockerfiles and python, I would re-implement the docker-compose to do this in the build.  

## What I liked about my solution

I very much enjoyed the process of developing and testing the app, implementing it in a container, then deploying it to Kubernetes.  The simplicty of Flask is not something I have worked with before, but it definitely made the process easy.  I had a lot of fun testing and learning (as I often experience when learning new patterns).  The decomposability of containerization and container orchestration is very appealing to me.  

I liked being able to implement patterns I have used in the past and seen implemented elsewhere in this solution. I was not familiar with and plan to learn more about gunicorn. Including a healh check was simple and provides a useful way to ensure the app and proxy are functioning.  I was very pleased to be able to implement the rolling update strategy and plan to learn more about this pattern
## What I didn't like about my solution

I was frustrated by my not being able to get the pattern of a python `requirements.in` file implemented for the container.  I have learned a great deal over the past few years, and as I have learned more, I have recognized the accumulated tech debt that some of the old patterns created.  I don't know there is much optimization or further modularization that can be done with a web hit counter, but I would be interested in learning what reasonable improvements can be made (at least up to a point of diminishing returns).  I was frustrated at not fully understanding IAM roles and permissions in AWS, and would liked to have been able to deploy an EKS cluster and successfully deploy the app to it and validate the proxy implementation.
