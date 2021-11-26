# alklein-alation

SRE assignment for Adam Klein <alklein@gmail.com>

Orignal assignment

Exercise:
Create a simple counter web application using python or Golang. Whenever we hit the URL, it
should return a “Holla! we have hit <counter> times” should print on the webpage . You can
make use of Redis or any database for storing the counter value.

Containerize all the web applications and build the images using docker and run it on K8s.
GuideLines:
In order to keep this exercise repeatable by our staff we have chosen the minikube cluster and
docker for building images. Selection of OS, config management, and software packages are up
to you. We only ask you to follow the guidelines below.

Required Tools:
● Minikube
○ https://minikube.sigs.k8s.io/
● Docker
○ https://www.docker.com/get-started

Additional Tools:
● FOSS(Free and open source software)
● External software dependencies must be hosted on the public internet
Submission:
● DeadLine: 1 week from the time you have received this document
● We will accept zip, or tar.gz or helm charts formats or Github
● Readme file on how to re-create your environment file
● Your submission must be repeatable by a staff member at Alation
Review Process:
● Alation will make an effort to re-create your environment in our lab using instructions
provided in your readme
● If we run into issues re-creating your environment we may reach out to you for further clarification
