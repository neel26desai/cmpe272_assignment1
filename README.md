# cmpe272_assignment1
This repo contains code for ansible assignment for CMPE 272

Our goal is to set up 2 web servers using ansible that respond to requests on port 8080 and respond with message "Hello World! from SJSU -X" , where X is the web server. 

To accomplish this we will be using a local system running WSL as the machine which runs ansible and maintains the inventory (lists of hosts in our case webservers), the each web server will run on an AWS EC2 instance. We will be using ansible to create these EC2 instances, install the required packages on it and run our Flask web server on them.

Prerequisite: 
1. Create a key value pair which be used connect with the EC2 instances. Download the private key as a pem file and save it in the current working folder. and run chmod 600 /path/to/file.pem
2. Install anisble and aws modules on WSL
3. Install aws cli and set up AWS-ACCESS_KEY, AWS_SECRET_ACCESS_KEY & region using aws configure. (You can get the keys from your AWS account)
4. Install boto3 and boto python packages using pip

Playbooks, Tasks and how to run:
1. ec2-creation.yml : this playbook has includes a play to create a security group which determines what network traffic will be can be allowed on the EC2 instances which will be created. It also includes 2 other plays to create 2 EC2 instances with seperate names i.e. WebServer1 and WebServer2. The play also includes conditions to make sure that it will only spin up an instance if an existing instance with the same name doesn't exists.
    To run: ansible-playbook ec2-creation.yml -e  "ansible_python_interpreter=/usr/bin/python3" 
    Info about command: If you have multiple instances of python installed in your system, you would need to specify exatly which python you want it to use and you set that after the -e flasg as the ansible_python_interpreter. 

Before moving to the nect playbooks make sure you put the public ip of the new instances created inside a file and name it inventory.ini in the following manner host1 ansible_host=public_ip

As these are new hosts you would need add their SSH identity to your system to do so we will ping each host one by one.
    1. ansible -i ./inventory.ini -m ping host1 --key-file="./ec2-demo.pem" --user "ec2-user"
        on running it you will be asked if you want to add the SSH fingerprint, type yes and press enter. The path after -i is the path to your inventory.ini file .The key-file includes the path to the pem file previous saved. We are using an Amazon Linux Instance image, which has default user "ec2-user" hence we specify that as our user.
    2. ansible -i ./inventory.ini -m ping host2 --key-file="./ec2-demo.pem" --user "ec2-user"
        do the same thing as above

2. installing_dependencies.yml : This playbook includes play to install our dependencies and packages on the EC2 instances, we use single play to install dependecies on both the server. We install tmux, htop, pip3 and Flask.
    To run: ansible-playbook installing_dependencies.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

3. move_code.yml: This playbook include the plays to copy the flask server code from our current working directory to our EC2 instances. We copy app1.py file from local to host1 and app2.py from local to host2. We use one play for each of the copy operation. 
    To run: ansible-playbook move_code.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

4. run_flask_server.yml: This playbook includes the play to run the flask web servers on both of our hosts(EC2 instances). We deploy the flask servers in development mode and using tmux to run the server without blocking the stdout.
    To run:  ansible-playbook run_flask_server.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 
To test:
    After the above playbook is done running we can test out the web servers. We do this using the curl command.
    run: curl http://{public_ip_host1}:8080/
    run: curl http://{public_ip_host2}:8080/
    If the servers are up then you'll get a an appropriate "Hello World! from SJSU -X" response

5. ec2-destruction.yml: This playbook includes plays to undo our deployment i.e. it will first terminate the 2 EC2 instance, we we have assigned each instance with a unique name we use that to delete a particular EC2 instance. After that we delete the security group which we created.
    To run: ansible-playbook ec2-destruction.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

Additional Files present in the repo:
1. app1.py: contains the python code which will run on host1
2. app2.py: contains the python code which will run on host2
3. run.sh: contains the commands needed to be run for each file
4. inventory.ini: contains the list of hosts and their public ips 
References:
[1] https://www.middlewareinventory.com/blog/ansible-aws-ec2/
[2] https://www.coachdevops.com/2021/07/ansible-playbook-for-provisioning-new.html
[4] https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_security_group_module.html
[5] https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_instance_module.html
[6] https://medium.com/@dharmesh.gangwar/use-ansible-to-create-terminate-ec2-instances-d57743bfb4cc
[7] https://www.twilio.com/blog/deploy-flask-python-app-aws
