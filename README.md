# alklein-alation

## SRE assignment for Adam Klein <alklein@gmail.com>

# Synopsis

A web-hit-counter implemented in Python with Flask, Gunicorn and Redis. Running under container (Docker) orchestration (Kubernetes), with an Ngnix load-balancer.  Access web hit counter by URL (browser or command-line).  Counter is incremented by one for each successful connection.  Count data is stored in and retrieved from redis database.  The python app includes a health-check which is referenced via Kubernetes livenessProbe. 

Successfull connection returns "Holla! we have hit *number* times" (where *number* is the current total of successful connections)
# Running web hit counter

## Minikube 

* Assumptions / requirements: 
  * Up and running minikube instance (see https://kubernetes.io/docs/tutorials/hello-minikube/), with at least 2CPU cores and 4GB memory available.
  * Access to https://github.com
  * Access to https://hub.docker.com

* Deploying:
  1. `git clone https://github.com/Adam-Klein/alklein-alation.git`
  2. `cd alklein-alation/kubernetes`
  3. `kubectl create -f .`
  4. `minikube service proxy --url`
  5. Access URL that is returned in browser or with `curl` (e.g. `curl http://192.168.49.2:31315`)
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
  * Account with and credentials for Amazon Web Services
  * Willingness to pay incurred charges for deploying four-node Kubernetes cluster with 
   
# Orignal assignment

![screenshot](./images/assignment_p1.png?raw=True)
![screenshot](./images/assignment_p2.png?raw=True)
# Who I am

My background is in systems administration.  Six years ago, I was introduced to and received training in DevOps and LEAN / Agile practices as they aligned with Infrastructure Engineering.  I learned version control with git (which complimented my having deployed GitHub Enterprise for my company), sprint planning (story writing, sprint planning, retrospectives, product ownership and scrum management), configuration management (using Puppet), and infrastructure automation.  I do not consider myself a developer.  I am currently learning Python.  For the past two years, I have been a member of a Platform Engineering team, responsible for deployment and configuration of tools and services on-prem to support development and business teams.  I have managed and deployed instances of ELK clusters (load-balanced with Ngninx and HAProxy), Hashicorp Consul and Vault clusters, and collaborated with several members of my team to implement automation of F5 iRules, pools, and nodes using Terraform.  Currently, I am working with my teammates to demonstrate contanerinizing Java microservices and deploying to on-prem Kubernetes clusters (which my team has deployed).

## Experience with assignment

I did not approach the assignment with a great deal of confidence. I am not a developer, my coding skills are not strong, and I while I understood the underlying concepts of the assignment, I did not know how far I would get.

A teammate of mine had recently demoed a Flask app.  When I started by looking up python web hit counters, I saw one implemented with Flask and this allowed me to identify a starting point. I was not familiar with Gunicorn and ran into a couple of issues I was able to work through (workers not starting).  I have worked with containers for a few years, and was able to put together Dockerfiles for the Flask app and the nginx load balancer.  

Once I had the solution working with a docker-compose file, I had a lot of frustration with the python source not updating in the container image even after I stopped and deleted the older containers and images.  *I am still puzzling out why I had to manually edit the code in the container to get the update to work, but once I did this, the new image builds worked.* 

I found the Kompose app which converts a docker-compose file into separate yaml files for kubernetes deployments, services, etc. The original configuration for the Python flask app created a separate directory and made a volume mount, which I found was unnecessary when deploying in Kubernetes. Minikube does not support a LoadBalancer exposing an external port, but there are a few ways to access it:

* `minikube service --url <service-name>`
* Access service port through `minikube dashboard`
* Access service through temporary forwarded port (using a tool like Lens)
* Access healthcheck at `http://<URL>/health`

## Challenges

I have worked with Python requirements enough to know that maintaining a static requirements file is adding to rather than reducing tech debt.  I have started using requirements.in files and using python virtual environments, then running `source venv/bin/activate ; pip install pip-tools; pip-compile; pip-sync`  I am planning to re-implement the docker-compose to do this in the build.