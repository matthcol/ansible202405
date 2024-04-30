# need ssh key
ansible -i hosts -m ping all

# with current user and password
ansible -i hosts -k -m ping all

# with specific user and password
ansible -i hosts -k -u srvadmin -m ping all

# in directory: ansible/02-deployuser
# run playbook with ssh current user + password + sudo password
ansible-playbook -i hosts -k -K playbook-deployuser.yml
# run playbook with ssh specific user + password + sudo password
ansible-playbook -i hosts -k -K -u srvadmin playbook-deployuser.yml
# verbose mode
ansible-playbook -i hosts -k -K -u srvadmin -v playbook-deployuser.yml
ansible-playbook -i hosts -k -K -u srvadmin -vv playbook-deployuser.yml
ansible-playbook -i hosts -k -K -u srvadmin -vvv playbook-deployuser.yml

# create SSH key with passphrase unlock it with ssh-agent
# generate ssh key
 ssh-keygen
 # file: /home/srvadmin/.ssh/id_rsa_deploy
 # passphrase: <a long passphrase>
 # checkup keys:
 ls ~/.ssh
 ssh-agent
# copy-paste output
ssh-add ~/.ssh/id_rsa_deploy
# type ONCE passphrase
# checkup identities managed by agent
ssh-add -L
# connect to remote host without password (key unlocked)
ssh deploy@host1
ansible-playbook -i hosts --u toto playbook-deployuser.yml
# after deployment: remove unlocked key from agent
ssh-key -D

# set python interpreter
# with gathering facts
ansible -i hosts  -u toto -v -m ping all
# with ansible.cfg
sudo mkdir /etc/ansible
sudo vi /etc/ansible/ansible.cfg
# content:
[defaults]
interpreter_python=/usr/bin/python3
# check
ansible -i hosts  -u toto -v -m ping all
# inside inventory (host-python)
ansible -i hosts-python  -u toto -v -m ping all

# choose deploy user
ansible-playbook -i hosts -u toto -e "user_deploy=jenvoie" playbook-deployuser.yml

# remove sudo privilege for toto user
ansible-playbook -i hosts -u jenvoie  playbook-deactivateuser.yml
# remove sudo privilege for jenvoie user
ansible-playbook -i hosts -u jenvoie  -e "user_deploy=jenvoie" playbook-deactivateuser.yml

# reactivate sudo privilege
ansible-playbook -i hosts -u srvadmin -k -K -e "user_deploy=jenvoie" playbook-deployuser.yml


# directory ansible/03-JavaApplication
ansible-playbook -u jenvoie -i hosts playbook-javainstall.yml
# check on host1
ssh jenvoie@host1 java --version
# install another version: 
ansible-playbook -u jenvoie -i hosts -e "jre_version=1.8.0" playbook-javainstall.yml

Note: host pattern
https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html

ansible-playbook -i hosts --list-tasks playbook-javainstall.yml
ansible-playbook -i hosts --list-hosts playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie --start-at-task "Install JRE Debian" playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie --start-at-task "Install JRE Debian" --step playbook-javainstall.yml

# tags
ansible-playbook -i hosts --list-tags playbook-javainstall.yml
ansible-playbook -i hosts --list-tasks playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie -t API playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie -t TEST playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie -t PACKAGE playbook-javainstall.yml (error: no gathering facts => ansible_os_family undefined)
ansible-playbook -i hosts -u jenvoie --skip-tags TEST playbook-javainstall.yml
ansible-playbook -i hosts -u jenvoie -t API --skip-tags PACKAGE playbook-javainstall.yml

# test API on host1 (port 8080 mapped on docker host)
http://localhost:8080/swagger-ui/index.html

# playbook with roles
ansible-galaxy init roles/api
ansible-galaxy init roles/db
ansible-galaxy init roles/test

ansible-playbook -i hosts --list-tasks playbook-javainstall.yml
ansible-playbook -i hosts --list-tags playbook-javainstall.yml
ansible-playbook -i hosts --list-hosts playbook-javainstall.yml
ansible-playbook -i hosts --list-tasks --list-hosts playbook-javainstall.yml

ansible-playbook -i hosts -u jenvoie playbook-javainstall.yml

# Import vs Include
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse.html

# handlers
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

# templates
# check
ssh jenvoie@host1 systemctl status api
ssh jenvoie@host1 cat /usr/lib/systemd/system/api.service
ssh jenvoie@host1 sudo systemctl start api

https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html


# Database on debian host3
ansible-playbook -i hosts -u jenvoie -t DB playbook-javainstall.yml
# check MariaDB (root user)
mysql (or mariadb)
show databases;
select host, user from mysql.user;

# Conditonals
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html

# Errors
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_error_handling.html

# Ansible Vaults
# VAULT
- https://docs.ansible.com/ansible/latest/vault_guide/index.html
- https://www.digitalocean.com/community/tutorials/how-to-use-vault-to-protect-sensitive-ansible-data

ansible-vault create somevault.yml
ansible-vault encrypt group_vars/all.yml
ansible-vault view group_vars/all.yml
ansible-vault edit group_vars/all.yml
ansible-vault decrypt group_vars/all.yml

ansible-playbook --ask-vault-password -i hosts -u jenvoie -t DB playbook-javainstall.yml 

# NB:you can also put the password in a temporrary file and use a ENV VAR
vi .vault_pass # with vault password
export ANSIBLE_VAULT_PASSWORD_FILE=./.vault_pass
ansible-playbook -i hosts -u jenvoie -t DB playbook-javainstall.yml
rm .vault_pass

















