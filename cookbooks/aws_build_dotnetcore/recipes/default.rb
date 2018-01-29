#
# Cookbook:: aws_build_dotnetcore
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

packages = {
  # package => version,
  'dotnetcore' => '2.0.0',
  'dotnetcore-sdk' => '2.0.0.20170906',
  'netfx-4.5.2-devpack' => '4.5.5165101',
  'netfx-4.6.2-devpack' => '4.6.01590.20170129',
  'visualstudio2017buildtools' => '15.2.26430.20170605',
  'visualstudio2017-workload-webbuildtools' => '1.1.0',
  'visualstudio2017-workload-netcoretools' => '1.1.0',
  'docker' => '17.06.0',
  'docker-compose' => '1.16.1',
  'nodejs-lts' => '6.11.3',
  'jq' => '1.5',
  'selenium' => '3.7.1',
  'visualstudiocode' => '1.18.1'
}

packages.each do |package, version|
  chocolatey_package package do
    version version unless version.nil? || (version == '')
    action :install
  end
  log 'reboot' do
    message 'A reboot pending signal was detected!!!!!!!'
    only_if { reboot_pending? }
  end
end

env 'path' do
  delim ';'
  value 'C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\MSBuild\\15.0\\Bin'
  action :modify
end

# Need to add environment variable so that msbuild knows where to find the SDKs
dotnet_sdks_path = 'C:\\Program Files\\dotnet\\sdk\\2.0.0\\Sdks'
env 'MSBuildSDKsPath' do
  delim ';'
  value dotnet_sdks_path
  action :create
end

# Also need to copy the Docker SDK to the SDK path- it only comes with VS full install
# remote_docker_sdk_path = 'https://ci.spokci.com/nexus/repository/files/Microsoft.Docker.Sdk.zip'
remote_docker_sdk_path = 'https://s3.amazonaws.com/spok-buildbox/Microsoft.Docker.Sdk.zip'
local_docker_sdk_path = "#{dotnet_sdks_path}\\Microsoft.Docker.Sdk.zip"

remote_file local_docker_sdk_path do
  source remote_docker_sdk_path
  action :create
  notifies :run, 'powershell_script[unzip docker sdk]', :immediately
end

powershell_script 'unzip docker sdk' do
  code <<-EOF
    7z x "#{local_docker_sdk_path}" -o"#{dotnet_sdks_path}"
  EOF
  returns [0]
  action :nothing # only run when called by the remote_file resource
end

powershell_script 'install-angular-cli' do
  code <<-EOF
    npm config set prefix "C:\Program Files\nodejs"
    npm install -g @angular/cli@1.0.4
  EOF
  returns [0, 1]
end
