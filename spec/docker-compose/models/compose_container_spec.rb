require 'spec_helper'

describe ComposeContainer do
  context 'Object creation' do
    before(:all) do
      @attributes = {
        image: 'busybox:latest',
        links: ['service:label'],
        ports: ['3000', '8000:8000', '127.0.0.1:8001:8001'],
        volumes: {'/tmp' => {}},
        command: 'ping -c 3 localhost',
        environment: ['ENVIRONMENT']
      }

      @entry = ComposeContainer.new(@attributes)
    end

    it 'should prepare attributes correctly' do
      expect(@entry.attributes[:image]).to eq(@attributes[:image])
      expect(@entry.attributes[:links]).to eq({'service' => 'label'})
      expect(@entry.attributes[:volumes]).to eq(@attributes[:volumes])
      expect(@entry.attributes[:command]).to eq(@attributes[:command].split(' '))
      expect(@entry.attributes[:environment]).to eq(@attributes[:environment])
    end

    it 'should map ports' do
      # Check ports structure
      expect(@entry.attributes[:ports].length).to eq(@attributes[:ports].length)

      # Port 1: '3000'
      port_entry = @entry.attributes[:ports][0]
      expect(port_entry.container_port).to eq('3000')
      expect(port_entry.host_ip).to eq(nil)
      expect(port_entry.host_port).to eq(nil)

      # Port 2: '8000:8000'
      port_entry = @entry.attributes[:ports][1]
      expect(port_entry.container_port).to eq('8000')
      expect(port_entry.host_ip).to eq(nil)
      expect(port_entry.host_port).to eq('8000')

      # Port 3: '127.0.0.1:8001:8001'
      port_entry = @entry.attributes[:ports][2]
      expect(port_entry.container_port).to eq('8001')
      expect(port_entry.host_ip).to eq('127.0.0.1')
      expect(port_entry.host_port).to eq('8001')
    end
  end

  context 'From image' do
    before(:all) do
      attributes = {
        image: 'busybox:latest',
        links: ['links:links'],
        volumes: {'/tmp' => {}},
        command: 'ping -c 3 localhost',
        environment: ['ENVIRONMENT']
      }

      @entry = ComposeContainer.new(attributes)
    end

    it 'should start/stop a container' do
      #Start container
      @entry.start
      expect(@entry.running?).to be true

      # Stop container
      @entry.stop
      expect(@entry.running?).to be false
    end

    it 'should provide container stats' do
      #Start container
      @entry.start
      expect(@entry.running?).to be true

      expect(@entry.stats).to_not be_nil

      # Stop container
      @entry.stop
      expect(@entry.running?).to be false
    end
  end

  context 'From Dockerfile' do
    before(:all) do
      attributes = {
        build: File.expand_path('spec/docker-compose/fixtures/'),
        links: ['links:links'],
        volumes: {'/tmp' => {}}
      }

      @entry = ComposeContainer.new(attributes)
    end

    it 'should start/stop a container' do
      #Start container
      @entry.start
      expect(@entry.running?).to be true

      # Stop container
      @entry.stop
      expect(@entry.running?).to be false
    end

    it 'should provide container stats' do
      #Start container
      @entry.start
      expect(@entry.running?).to be true

      expect(@entry.stats).to_not be_nil

      # Stop container
      @entry.stop
      expect(@entry.running?).to be false
    end
  end

  context 'Without image or Dockerfile' do
    before(:all) do
      attributes = {
        links: ['links:links'],
        volumes: {'/tmp' => {}},
        command: 'ps aux',
        environment: ['ENVIRONMENT']
      }

      @entry = ComposeContainer.new(attributes)
    end

    it 'should not start a container' do
      expect{@entry.start}.to raise_error(ArgumentError)
    end
  end
end
