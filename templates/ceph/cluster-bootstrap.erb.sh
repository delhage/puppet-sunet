#!/bin/bash

ceph="/usr/sbin/cephadm shell ceph"

adm_private_key="$(cat /root/.ssh/id_ed25519_adm)"
adm_public_key="$(ssh-keygen -y -f /root/.ssh/id_ed25519_adm)"
echo "$adm_public_key" > /root/.ssh/id_ed25519_adm.pub

ssh -4 -i /root/.ssh/id_ed25519_adm "<%= @firstmon %>" /opt/ceph/bootstrap.sh # Run bootstrap script on first monitor
scp -4 -i /root/.ssh/id_ed25519_adm "<%= @firstmon %>:/etc/ceph/*" /etc/ceph/ # Copy over config <% monitors = [] %><% osd = [] %><% @nodes.each do |node| %>
${ceph} orch host add "<%= node['hostname'] %>" # Add <%= node['hostname'] %><% node['labels'].each do |label| %><% if label == 'mon' %><% monitors.append(node['hostname']) %><% elsif label == 'osd' %><% osd.append(node['hostname']) %><% end %>
${ceph} orch host label add "<%= node['hostname'] %>" "<%= label %>" # <% end %><% end %>
ceph config-key set mgr/cephadm/ssh_identity_key -i /root/.ssh/id_ed25519_adm
ceph config-key set mgr/cephadm/ssh_identity_pub -i /root/.ssh/id_ed25519_adm.pub

adm_keyring="$(cat /etc/ceph/ceph.client.admin.keyring)"
echo "Now run:"
echo -e "\t ./edit-secrets $(hostname -f)"
echo "and add:"
echo "adm_private_key: >"
echo "  DEC::PKCS7[$adm_private_key"
echo "]!"
echo "adm_keyring: >"
echo "  DEC::PKCS7[$adm_keyring"
echo "]!"
echo -e "\n\n\nFinaly add:"
echo "adm_public_key: '$adm_public_key'"
echo "to the common group.yaml file"
