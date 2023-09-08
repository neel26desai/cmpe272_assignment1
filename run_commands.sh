#first we set up ec2 instances
ansible-playbook ec2-creation2.yml -e  "ansible_python_interpreter=/usr/bin/python3" 
#Manually add the new host by adding their public ip addressess to the inventory file
#install all dependencies the ec2 Instances 
ansible-playbook installing_dependencies.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 
#move the code from local to EC2 instances
ansible-playbook move_code.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 
#run the play to start the flask server
ansible-playbook run_flask_server.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

# to destroy every thing
ansible-playbook ec2-destruction.yml -i ./inventory.ini --key-file="./ec2-demo.pem" -e  "ansible_python_interpreter=/usr/bin/python3" 

