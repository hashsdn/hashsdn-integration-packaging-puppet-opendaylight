require 'spec_helper_acceptance'

# Note that helpers (`should`, `be_running`...) are documented here:
# http://serverspec.org/resource_types.html
describe 'opendaylight class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'opendaylight': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file('/opt/opendaylight-0.2.1/etc/org.apache.karaf.features.cfg') do
      it { should be_file }
      it { should contain 'featuresBoot' }
    end

    describe yumrepo('opendaylight') do
      it { should exist }
      it { should be_enabled }
    end

    describe package('opendaylight') do
      it { should be_installed }
    end

    describe service('opendaylight') do
      it { should be_enabled }
      it { should be_enabled.with_level(3) }
      it { should be_running }
    end

    # OpenDaylight will appear as a Java process
    describe process('java') do
      it { should be_running }
    end

    describe user('odl') do
      it { should exist }
      it { should belong_to_group 'odl' }
      # This dir will not be created because of -M switch in ODL's RPM.
      #   Should really be called a `login_dir` by serverspec, as it's
      #   checking `getent passwd odl` for a login dir vs looking at
      #   `/home/` to see if `odl/` exists.
      it { should have_home_directory '/home/odl' }
    end

    describe file('/home/odl') do
      # Home dir shouldn't be created for odl user
      it { should_not be_directory }
    end
  end
end
