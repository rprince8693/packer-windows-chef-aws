#
# Cookbook:: aws_build_dotnetcore
# Recipe:: sshd
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# generate a random password for the cyg_server account under which sshd runs.
# we don't ever need this password, just needs to be set so the service can run as the user.
# def generate_str(number)
#   charset = Array('A'..'Z') + Array('a'..'z') + Array('0'..'9')
#   Array.new(number) { charset.sample }.join
# end

# Use the random password plus a string to guarantee it meets policy
node.default['cygwin']['ssh']['sshd_user'] = 'Administrator'
node.default['cygwin']['ssh']['sshd_passwd'] = 'CV9@Y90BTvDe'

# cygwin::ssh will instal cygwin and configure sshd
include_recipe 'cygwin::ssh'

powershell_script 'Open firewall port for SSH' do
  code <<-EOF
    New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH
  EOF
  returns [0]
end
# rubocop:disable HashSyntax
# Create jenkins .ssh dir and authorized_keys. SSHD service needs read-only access.
jenkins_sshd_dir = 'C:\\cygwin\\home\\jenkins'
directory jenkins_sshd_dir do
  owner 'jenkins'
  rights :full_control, 'Administrators', :applies_to_children => true
  action :create
  recursive true
end
jenkins_ssh_dir = 'C:\\cygwin\\home\\jenkins\\.ssh'
directory jenkins_ssh_dir do
  owner 'jenkins'
  # rights :full_control, 'Administrators', :applies_to_children => true
  action :create
  recursive true
end
# rubocop:enable HashSyntax

file "#{jenkins_ssh_dir}\\authorized_keys" do
  owner 'jenkins'
  action :create
  content 'ssh-rsa AAAAB3wefjsodnfliajdnveijnqGFNILAMMBzadkfjnvadlkjnvdfkjnvjad0j4ufW08cOjvadfvdfvfdaDOtQHvdgscjVEOqG1ZjY7GDiFaAxuiCZ4bYSlGM5xyy+N6hG/eiurelnxwGkUmfQTSF6vvNj4yiwiKka3d jenkins@ip-172-xx-xx-xx.ec2.internal-2017-01-24T19:59:50+0000'
end

powershell_script 'Set cygwin permissions' do
  code <<-EOF
    bash -c "chmod 700 ~jenkins/.ssh"
    bash -c "chmod 600 ~jenkins/.ssh/authorized_keys"
  EOF
  returns [0]
end
