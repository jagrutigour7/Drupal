echo "Step 1. Checking update"
sudo apt-get update
sudo apt --fix-missing update
echo "Step 2. Installing Ansible"
sudo apt install ansible -y
echo "Step 3. Checking ansible version"
ansible --version
echo "Step 4. Change ownership"
chown adminuser:adminuser /home/adminuser/.ssh
echo "Step 5. Change permission"
chmod 700 /home/adminuser/.ssh
echo "Step 6. Change permission of authorized key"
chmod 600 /home/adminuser/.ssh/authorized_keys
echo "Step 7. Change ownership of authorized key"
chown adminuser:adminuser /home/adminuser/.ssh/authorized_keys








