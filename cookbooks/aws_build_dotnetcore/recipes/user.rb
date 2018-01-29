#
# Cookbook:: aws_build_dotnetcore
# Recipe:: user
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# FIXME: This recipe DOES NOT WORK when run via Packer.
#        It has to be run from a console, due to an ancient Cygwin bug in the ssh-host-config script.
#        Perhaps we can submit a PR for that bug?  Or run a copy of ssh-host-config that we maintain ourselves?
#        For now we have to manually apply this recipe to the AMI and recreate.

# generate a random password for the cyg_server account under which sshd runs.
# we don't ever need this password, just needs to be set so the service can run as the user.

user 'jenkins' do
  password 'CV9@Y90BTvDe'
end

group 'Administrators' do
  action :modify
  members 'jenkins'
  append true
end

# Set passwords to not expire
powershell_script 'set_password_expire' do
  code <<-EOF
    foreach ($Username in "jenkins", "Administrator" ) {
      $user = Get-WmiObject Win32_UserAccount -Filter ("Domain='{0}' and Name='{1}'" -f $env:ComputerName,$Username)
      if ($user) {
        $user.PasswordExpires = 0
        $user.Put()
      }
    }
  EOF
end

# jenkins_sshd_dir = 'C:\\Users\\jenkins\\.ssh'
# directory jenkins_sshd_dir do
#   # # owner 'jenkins'
#   # rights :full_control, 'jenkins', :applies_to_children => true
#   action :create
#   recursive true
# end
# # rubocop:enable HashSyntax
#
# file "#{jenkins_sshd_dir}\\authorized_keys" do
#   # rights :full_control, 'jenkins'
#   action :create
#   content 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo99k/seu/m7pplhjXEusJXNORqMtvqvXNMio8MFgqWbBSC1l9mMSi2NMIByIf/pqbObo69qGFNILAMMBzTJDKF8CI1n5l/EB5Q7kiiOBboeMfp1wO7o7JMEeK6YNSdvj96zpdWHLhFnuCq40R7o70j4ufW08cOj2uY8Hg8zYZ9lmCmHiNf2KQnehSp59suCnHtoUR7HaDOtQHvdgscjVEOqGKXg+Sg8DcqhCPFgzKJqDH0LUkioQHhis6VuwOOrrnHTpPgmu7shtL4GZNSA1ZjY7GDiFaAxuiCZ4bYSlGM5xyy+N6hG/eiurelnxwGkUmfQTSF6vvNj4yiwiKka3d jenkins@ip-172-31-20-130.ec2.internal-2017-01-24T19:59:50+0000'
# end
#
# powershell_script 'Set jenkin permissions' do
#   code <<-EOF
#   bash -c "chmod 700 C:/Users/jenkins/.ssh/"
#   bash -c "chmod 600 C:/Users/jenkins/.ssh/authorized_keys"
#   EOF
#   returns [0]
# end
