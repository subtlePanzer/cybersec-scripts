#!/bin/bash

#cd /home/ubuntu/Desktop
#sudo chmod 777 /home/ubuntu/Desktop
#sudo chmod 777 *.txt
#admin.txt
#users.txt
#test if users.txt exists
if test -f "users.txt"; then
    echo "starting script"
else
    echo "use users.txt idiot"
    echo "You Shouldn't be in the competition. L Bozo"
    touch users.txt
    chmod 777 users.txt
    nano users.txt
    exit
fi
if test -f "admin.txt"; then
    echo "starting script"
    
else
    echo "use admin.txt idiot"
    echo "You Shouldn't be in the competition. L Bozo"
    touch admin.txt
    chmod 777 admin.txt
    nano admin.txt
    exit
fi 

#to generate list of current users
cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > currentusers.txt

#generate list of current sudo
getent group sudo | cut -d: -f4 | tr ',' '\n' > currentadmin.txt

# Sort authorizedusers.txt and currentusers.txt
sort -o users.txt users.txt
sort -o currentusers.txt currentusers.txt

# Sort authorizedadmin.txt and currentadmin.txt
sort -o admin.txt admin.txt
sort -o currentadmin.txt currentadmin.txt

# Diff currentusers.txt and authorizedusers.txt, ignoring whitespaces
diff --ignore-all-space currentusers.txt users.txt >> diffusers.txt

# Extract users to add and remove from diffusers.txt
awk '/^< / {print $2}' diffusers.txt > removethese.txt
awk '/^> / {print $2}' diffusers.txt > addthese.txt

# Prompt for confirmation before proceeding with adding/removing users
echo "Users to remove:"
cat removethese.txt
echo -n "Confirm removal? [y/n] "
read confirm
if [[ "$confirm" == "y" ]]; then
    while read user; do
        echo -n "Removing user $user... "
        userdel "$user" && echo "done." || echo "failed!"
    done < removethese.txt
fi

echo "Users to add:"
cat addthese.txt
echo -n "Confirm addition? [y/n] "
read confirm
if [[ "$confirm" == "y" ]]; then
    while read user; do
        echo -n "Adding user $user... "
        useradd -s /bin/bash "$user" && echo "done." || echo "failed!"
        echo "54321Edcba" | passwd "$user"
        echo "Password for user $user set to: 54321Edcba"
    done < addthese.txt
fi

# Diff currentadmin.txt and authorizedadmin.txt, ignoring whitespaces
diff --ignore-all-space currentadmin.txt admin.txt >> diffadmin.txt

# Extract users to add and remove from diffadmin.txt
awk '/^< / {print $2}' diffadmin.txt > removeadmin.txt
awk '/^> / {print $2}' diffadmin.txt > addadmin.txt

# Prompt for confirmation before proceeding with adding/removing admin users
echo "Admin users to remove:"
cat removeadmin.txt
echo -n "Confirm removal? [y/n] "
read confirm
if [[ "$confirm" == "y" ]]; then
    while read admin; do
        echo -n "Removing admin user $admin from sudo group... "
        deluser "$admin" sudo && echo "done." || echo "failed!"
    done < removeadmin.txt
fi

echo "Admin users to add:"
cat addadmin.txt
echo -n "Confirm addition? [y/n] "
read confirm
if [[ "$confirm" == "y" ]]; then
    while read admin; do
        echo -n "Adding admin user $admin to sudo group... "
        useradd -s /bin/bash "$admin" && echo "done." || echo "failed!"
        echo "54321Edcba" | passwd "$admin"
        echo "Password for admin user $admin set to: 54321Edcba"
        usermod -aG sudo "$admin" && echo "Added to sudo group." || echo "Failed to add to sudo group."
    done < addadmin.txt
fi
rm /home/ubuntu/Desktop/addadmin.txt
rm /home/ubuntu/Desktop/removeadmin.txt
rm /home/ubuntu/Desktop/addthese.txt
rm /home/ubuntu/Desktop/removethese.txt

rm /home/ubuntu/Desktop/currentusers.txt
rm /home/ubuntu/Desktop/currentadmin.txt
rm /home/ubuntu/Desktop/diffusers.txt
rm /home/ubuntu/Desktop/diffadmin.txt

exit 0
