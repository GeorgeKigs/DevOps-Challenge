# To create the ssh key
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -f terraform_key

# transfer the key to the main node
scp -i ~/.ssh/terraform_key ubuntu@172.31.149.4

# install ansible on the main server
sudo apt update
python3 --version
sudo apt install python3-pip
pip3 install ansible ansible-navigator


# verify installation of packages

ansible --version
docker --version
nginx