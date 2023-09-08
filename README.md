# cmpe272_assignment1
This repo contains code for ansible assignment for CMPE 272

### Our goal is to set up 2 web servers using Ansible that respond to requests on port 8080 and respond with the message "Hello World! from SJSU -X", where X is the web server. 

To accomplish this we will be using a local system running WSL as the machine which runs Ansible and maintains the inventory (lists of hosts in our case webservers), each web server will run on an AWS EC2 instance. We will be using Ansible to create these EC2 instances, install the required packages, and run our Flask web server on them.

Prerequisite: 
1. Create a key-value pair which be used to connect with the EC2 instances. Download the private key as a PEM file and save it in the current working folder. and run chmod 600 /path/to/file.pem. (The private key should have limited access)
2. Install Ansible and aws modules on WSL
3. Install aws cli and set up AWS-ACCESS_KEY, AWS_SECRET_ACCESS_KEY & region using aws configure. (You can get the keys from your AWS account)
4. Install boto3 and boto python packages using pip

Playbooks, Tasks and how to run:
1. **ec2-creation.yml** : This playbook includes a play to create a security group which determines what network traffic can be allowed on the EC2 instances which will be created. It also includes 2 other plays to create 2 EC2 instances with separate names i.e. WebServer1 and WebServer2. The play also includes conditions to make sure that it will only spin up an instance if an existing instance with the same name doesn't exist.
    - To run: ansible-playbook ec2-creation.yml -e  "ansible_python_interpreter=/usr/bin/python3" 
    - Info about the command: If you have multiple instances of Python installed in your system, you would need to specify exactly which Python you want it to use and you set that after the -e flag as the ansible_python_interpreter. 

Before moving to the next playbooks make sure you put the public IP of the new instances created inside a file and name it inventory.ini in the following manner host1 ansible_host=public_ip

As these are new hosts you would need to add their SSH identity to your system to do so we will ping each host one by one.
    - ansible -i ./inventory.ini -m ping host1 --key-file="./ec2-demo.pem" --user "ec2-user"
    
    - On running it you will be asked if you want to add the SSH fingerprint, type yes and press enter. The path after -i is the path to your inventory.ini file . The --key-file includes the path to the pem file previously saved. We are using an Amazon Linux Instance image, which has the default user "ec2-user" hence we specify that as our user.
    
    - ansible -i ./inventory.ini -m ping host2 --key-file="./ec2-demo.pem" --user "ec2-user"
    
    - Do the same thing as the above

2. **installing_dependencies.yml** : This playbook includes play to install our dependencies and packages on the EC2 instances, we use single play to install dependencies on both servers. We install tmux, htop, pip3 and Flask.
    - To run: ansible-playbook installing_dependencies.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

3. **move_code.yml**: This playbook includes the plays to copy the flask server code from our current working directory to our EC2 instances. We copy app1.py file from local to host1 and app2.py from local to host2. We use one play for each of the copy operations. 
    - To run: ansible-playbook move_code.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

4. **run_flask_server.yml**: This playbook includes the play to run the Flask web servers on both of our hosts(EC2 instances). We deploy the flask servers in development mode and use tmux to run the server without blocking the stdout.
    - To run:  ansible-playbook run_flask_server.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 
To test:
   - After the above playbook is done running we can test out the web servers. We do this using the curl command.
   - run: curl http://{public_ip_host1}:8080/
   - run: curl http://{public_ip_host2}:8080/
   - If the servers are up then you'll get an appropriate "Hello World! from SJSU -X" response
   

6. **ec2-destruction.yml**: This playbook includes plays to undo our deployment i.e. it will first terminate the 2 EC2 instances, we have assigned each instance with a unique name we use that to delete a particular EC2 instance. After that, we delete the security group which we created.
    - To run: ansible-playbook ec2-destruction.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

Additional Files present in the repo:
1. app1.py: contains the python code which will run on host1
2. app2.py: contains the python code which will run on host2
3. run_commands.sh: contains the commands needed to be run for each file
4. inventory.ini: contains the list of hosts and their public ips 

References:

[1] https://www.middlewareinventory.com/blog/ansible-aws-ec2/

[2] https://www.coachdevops.com/2021/07/ansible-playbook-for-provisioning-new.html

[3] https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_security_group_module.html

[4] https://docs.ansible.com/ansible/latest/collections/amazon/aws/ec2_instance_module.html

[5] https://medium.com/@dharmesh.gangwar/use-ansible-to-create-terminate-ec2-instances-d57743bfb4cc

[6] https://www.twilio.com/blog/deploy-flask-python-app-aws

