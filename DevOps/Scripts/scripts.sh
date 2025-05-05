# To create the ssh key
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -f terraform_key

# transfer the key to the main node
scp -P 1337 -i ~/.ssh/terraform_key ubuntu@172.31.149.4

# install ansible on the main server
sudo apt update
python3 --version
sudo apt install python3-pip
pip3 install ansible ansible-navigator

# verify installation of packages
ansible --version
docker --version
nginx -v

# run ansible
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv

# login to ecr
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 992122884453.dkr.ecr.eu-central-1.amazonaws.com


# build and deploy backend.
scp -P 1337 .env   ubuntu@3.76.209.15:/home/ubuntu/configs/.env #move the env file

mvn clean install
docker build -t validator-backend-image .
docker tag validator-backend-image:latest 992122884453.dkr.ecr.eu-central-1.amazonaws.com/validator-backend-image:latest
docker run -p 8080:8080 --env-file .env  992122884453.dkr.ecr.eu-central-1.amazonaws.com/validator-backend-image:latest



# build frontend
npm install
npm run build
docker build -t validator-frontend-image .


docker tag validator-frontend-image:latest 992122884453.dkr.ecr.eu-central-1.amazonaws.com/validator-frontend-image:latest
docker push 992122884453.dkr.ecr.eu-central-1.amazonaws.com/validator-frontend-image:latest
docker run -p 8081:8081 992122884453.dkr.ecr.eu-central-1.amazonaws.com/validator-frontend-image:latest




open http://localhost:8081