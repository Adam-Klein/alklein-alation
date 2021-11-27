# alklein-alation

## SRE assignment for Adam Klein <alklein@gmail.com>

# Synopsis

A web-hit-counter implemented in Python with Flask and Gunicorn, storing the count a Redis db, load balanced by an Nginx instance. Running under container (Docker) orchestration (Kubernetes).  Access web hit counter via URL (browser or command-line).  Counter is incremented by one for each successful connection. The app includes a health-check which is referenced via Kubernetes livenessProbe. 

Successfull connection returns "Holla! we have hit *number* times" (where *number* is the current total of successful connections)
# Deploying and running the counter

## Minikube 

* Assumptions / requirements: 
  * Up and running minikube instance (see https://kubernetes.io/docs/tutorials/hello-minikube/).
  * Access to https://github.com
  * Access to https://hub.docker.com

* Deploying:
  1. `git clone https://github.com/Adam-Klein/alklein-alation.git`
  2. `cd alklein-alation/kubernetes`
  3. `kubectl create -f .`
  4. `minikube service proxy --url`
  5. Access URL that is returned either in browser or with `curl` (e.g. `curl http://192.168.49.2:31315`)
  6. Health-check is accessible at `/health`

# Monitoring

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


## Terraform to AWS
### In progress - may not be completed



* Assumptions / requirements
  1. Access to AWS with appropriate IAM permissions, including EKS write / view 
  2. Terraform recent version installed on host system
  3. Access to github.com
  4. git recent version installed on host system
  5. You are willing to incur any AWS charges for additional workload / nodes deployed to cluster

* Deploying
  1.  `git clone https://github.com/Adam-Klein/alklein-alation.git`
  2. `cd alklein-alation/kubernetes`
  3. `cd Terraform`
  4. `terraform plan`
# Orignal assignment

![screenshot](./images/assignment_p1.png?raw=True)
![screenshot](./images/assignment_p2.png?raw=True)
# Who I am

My background is in systems administration.  A few years ago, I was introduced to and received training in DevOps and LEAN / Agile practices as they aligned with Infrastructure Engineering.  I learned version control using git (which complimented my having deployed GitHub Enterprise for my company), sprint planning (story writing, retrospectives, scrum management / product ownership), configuration management (using Puppet), and infrastructure automation.  I do not consider myself a developer.  I am currently learning Python.  For the past two years, I have been a member of a Platform Engineering team, responsible for deployment and configuration of tools and services on-prem to support development and business teams.  I have managed and deployed instances of ELK clusters (load-balanced with Ngninx and more recently HAProxy), Hashicorp Consul and Vault clusters performing serivce discovery, healthcheck, and secret management of microservices, and collaborated with several members of my team to implement automation of F5 iRules, pools, and nodes using Terraform.  Currently, I am working with my teammates to demonstrate contanerinizing Java microservices and deploying to on-prem Kubernetes clusters (which my team has deployed and manages).

## Experience with assignment

I did not initially approach this assignment with a great deal of confidence. I am not a developer, my coding skills are not strong, and I while I understood the underlying concepts of the assignment, I was uncertain how far I would get.

A teammate of mine had recently demoed a Flask app, so I had some basic idea of where to start.  I began by looking up python web hit counters, and found one implemented with Flask to use as a reference. I was not familiar with Gunicorn and ran into a couple of issues I was able to work through (workers not starting).  I have worked with containers for a few years, and was able to put together Dockerfiles for the Flask app, redis, and Nginx load balancer.  

Once I had the solution working with a docker-compose file, I struggled with the python source not updating in the container image even after I stopped and deleted the older containers and images.  *I am still puzzling out why I had to manually edit the code in the container to get the update to work, but once I did this, the new image builds worked.* 

I found the Kompose app which converts a docker-compose file into separate yaml files for kubernetes deployments, services, etc. The original configuration for the Python flask app created a separate directory and made a volume mount, which I found was unnecessary when deploying in Kubernetes. Minikube does not support a LoadBalancer exposing an external port, but there are a few ways to access it:

* `minikube service --url <service-name>`
* Access service port through `minikube dashboard`
* Access service through temporary forwarded port (using a tool like Lens)

## Challenges

My first struggle was with gunicorn and workers not starting.  I corrected a few typos and experimented to better understand the Flask syntax.  

The next challenge was in getting the docker-compose file translated properly into Kubernetes deployment and service files.  I was able to correct some unnecessary configurations (mounting a volume for the python app).  

Once I had the deployment and serivces working in kubernetes, I struggled with (and was not able to resolve) deploying to an AWS Kubernetes cluster (either deployed with Kops or an EKS instance) using Terraform. I don't know if the issue was IAM rights, a connectivity issue between components, or something wrong in the Terraform implementation.

 I have worked with Python requirements enough to know that maintaining a static requirements file is adding to rather than reducing tech debt.  I have started using requirements.in files and using python virtual environments, then running `source venv/bin/activate ; pip install pip-tools; pip-compile; pip-sync`  I am planning to re-implement the docker-compose to do this in the build.  

## What I liked

This experience was pleasantly uncomfortable for me.  Much of this work was outside my comfort zone, and required exercising patience when things didn't work the way I expected, but I was able to solve and overcome many of the challenges I encountered.  As I progressed through each phase (writing the Flask app, deploying in containers, deploying in Kubernetes), I felt a great sense of accomplishment in overcoming obstacles, and completing challenges I had not taken on before.

## What I didn't like

Thinking I understand enough of how a pattern works and realizing I don't, or not being able to make it work can be a struggle for me.  I do not have a problem admitting I don't know something and am usually interested in learning new things and developing proficiency.  Parts of this exercize I thought I understood but struggled to realize I did not understand as well as I thought were frustrating.  I have deployed small Kubernetes clusters to AWS with kops many times, and deployed some services to the clusters, and I have done some Terraform work with my team; but implementing the Terraform Kubernetes provider to provision the deployments and services to AWS wound up very frustrating as both the deployment and connectivity failed.  I just didn't have time to unravel the parts that weren't working and resolve them.  Not being able to get these working was frustrating.