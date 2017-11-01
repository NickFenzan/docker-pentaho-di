# Pentaho Kitchen Docker Image
This is a basic image with Pentaho Data Integration installed. It is intended
to run jobs from a local repository either copied or mounted to
/home/penatho/repo

## Basic Use Example
To run a job called Sample Job in a repo at /home/user/repo run:

`docker run --rm -ti -v /home/user/repo:/home/pentaho/repo mvnfenzan/pentaho-di -job="Sample Job"`
