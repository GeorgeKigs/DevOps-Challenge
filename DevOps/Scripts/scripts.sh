# To create the ssh key
ssh-keygen -t rsa -b 4096 -f ./key_pair


# install ansible on the main server
python3 --version
sudo apt install python3-pip
pip3 install ansible ansible-navigator