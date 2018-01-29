#
# Cookbook:: aws_build_dotnetcore
# Recipe:: win2016_base.rb
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# install chocolatey packages
packages = {
  # package => version,
  'carbon' => '2.5.0',
  '7zip.commandline' => '16.02.0.20170209',
  '7zip.install' => '16.4.0.20170506',
  'poshgit' => '0.7.1',
  'jdk8' => nil,
  'vim' => '8.0.604',
  'sysinternals' => '2017.11.31',
  'nuget.commandline' => '4.3.0',
  'googlechrome' => nil,
  'awscli' => '1.11.159',
  'curl' => '7.56.1',
  'pswinupdate' => '1.5.2',
}

packages.each do |package, version|
  chocolatey_package package do
    version version unless version.nil? || (version == '')
    # TODO: we need an upgrade_or_install mechanism
    action :upgrade
  end
end

# Disable automatic Java updates since updates will be handled through Chef / Chocolatey.
powershell_script 'disable_java_update' do
  code <<-EOF
        taskkill /F /IM jusched.exe
        taskkill /F /IM jucheck.exe
    EOF
  returns [0, 128]
end
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy' do
  recursive true
  values [{
    name: 'EnableJavaUpdate',
    type: :dword,
    data: '0',
  }]
end
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run' do
  recursive true
  values [{
    name: 'SunJavaUpdateSched',
    type: :string,
    data: '',
  }]
  action :delete
end
