require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'msmtp' do

  let(:title) { 'msmtp' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test minimal installation' do
    it { should contain_package('msmtp').with_ensure('present') }
    it { should contain_file('msmtp.conf').with_ensure('present') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('msmtp').with_ensure('1.0.42') }
  end

  describe 'Test msmtp.conf managed throuh template' do
    let(:facts) { {:operatingsystem => 'Debian' } }
    let(:params) { {:template => 'msmtp/msmtprc.erb', 
                    :auth => 'on', :user => 'someuser', :password => 'somepassword' } }
    it { should contain_file('msmtp.conf').without_source }
    it { should contain_file('msmtp.conf').with_content(/auth on
user someuser
password somepassword/) }
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true } }
    it 'should remove Package[msmtp]' do should contain_package('msmtp').with_ensure('absent') end 
    it 'should remove msmtp configuration file' do should contain_file('msmtp.conf').with_ensure('absent') end
  end

  describe 'Test noops mode' do
    let(:params) { {:noops => true} }
    it { should contain_package('msmtp').with_noop('true') }
    it { should contain_file('msmtp.conf').with_noop('true') }
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "msmtp/spec.erb" , :options => { 'opt_a' => 'value_a' } } }
    it 'should generate a valid template' do
      content = catalogue.resource('file', 'msmtp.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'msmtp.conf').send(:parameters)[:content]
      content.should match "value_a"
    end
  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet:///modules/msmtp/spec"} }
    it { should contain_file('msmtp.conf').with_source('puppet:///modules/msmtp/spec') }
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "msmtp::spec" } }
    it { should contain_file('msmtp.conf').with_content(/rspec.example42.com/) }
  end

end
