module VagrantPlugins
  module CIKit
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def provision
        result = Vagrant::Util::Subprocess.execute(
          'bash',
          '-c',
          "#{config.controller} #{config.playbook} #{cikit_args}",
          workdir: @machine.env.root_path.to_s,
          notify: %i[stdout stderr],
          env: environment_variables
        ) do |_io_name, data|
          @machine.env.ui.info(data, new_line: false, prefix: false)
        end

        raise Vagrant::Errors::VagrantError.new, 'CIKit provisioner responded with a non-zero exit status.' unless result.exit_code.zero?
      end

      protected

      def environment_variables
        environment_variables = {}
        environment_variables['ANSIBLE_INVENTORY'] = ansible_inventory
        environment_variables['ANSIBLE_SSH_ARGS'] = ansible_ssh_args
        environment_variables['ANSIBLE_VERBOSITY'] = ENV['ANSIBLE_VERBOSITY']
        environment_variables['DEBIAN_FRONTEND'] = 'noninteractive'
        environment_variables['CIKIT_LIST_TAGS'] = ENV['CIKIT_LIST_TAGS']
        environment_variables['CIKIT_TAGS'] = ENV['CIKIT_TAGS']
        environment_variables['PATH'] = ENV['VAGRANT_OLD_ENV_PATH']

        environment_variables
      end

      def ansible_ssh_args
        ansible_ssh_args = []
        ansible_ssh_args << '-o ForwardAgent=yes' if @machine.ssh_info[:forward_agent]
        ansible_ssh_args << '-o StrictHostKeyChecking=no'
        ansible_ssh_args << ENV['ANSIBLE_SSH_ARGS']

        ansible_ssh_args.join(' ')
      end

      def cikit_args
        args = []
        # Append the host being provisioned.
        args << "--limit=#{@machine.name}"

        playbook = config.playbook ? config.playbook.chomp(File.extname(config.playbook)) + '.yml' : ''

        if File.exist?(playbook)
          extra_vars = parse_env_vars('EXTRA_VARS')
          prompts_file = File.dirname(@machine.env.local_data_path) + '/.cikit/environment.yml'
          playbook = YAML.load_file(playbook)
          prompts = File.exist?(prompts_file) ? YAML.load_file(prompts_file) : {}
          taglist = ENV.key?('CIKIT_TAGS') ? ENV['CIKIT_TAGS'].split(',') : {}

          if playbook[0].include?('vars_prompt')
            playbook[0]['vars_prompt'].each do |var_prompt|
              default_value = ''

              # We have previously saved value. Use it as default!
              if prompts.key?(var_prompt['name'])
                default_value = prompts[var_prompt['name']]
              elsif var_prompt.key?('default')
                default_value = var_prompt['default'].to_s
              end

              # Use default value if condition intended for not Vagrant or script
              # was run with tags and current prompt have one of them.
              if (taglist.any? && (var_prompt['tags'] & taglist).none?) || 'not localhost' == var_prompt['when']
                value = default_value
              else
                var_prompt['prompt'] += " [#{default_value}]" unless default_value.empty?
                var_prompt['prompt'] += ': '

                # Preselect value from the environment variable.
                if extra_vars.key?(var_prompt['name'])
                  value = extra_vars[var_prompt['name']]
                  @machine.env.ui.say(:success, var_prompt['prompt'] + value)
                else
                  value = @machine.env.ui.ask(var_prompt['prompt'], new_line: false).chomp
                  value = value.empty? ? default_value : value
                end
              end

              args << "--#{var_prompt['name']}=#{value}"
              prompts[var_prompt['name']] = value
            end
          end

          write_cache(prompts_file, YAML.dump(prompts))
        end

        args.join(' ')
      end

      # Auto-generate "safe" inventory file based on Vagrantfile.
      def ansible_inventory
        inventory_content = ['# Generated by CIKit']
        inventory_file = @machine.env.local_data_path + '/provisioners/cikit/ansible/inventory'

        @machine.env.active_machines.each do |active_machine|
          begin
            m = @machine.env.machine(*active_machine)

            if !m.ssh_info.nil?
              entry = [m.name]
              entry << 'ansible_host=' + m.ssh_info[:host]
              entry << 'ansible_port=' + m.ssh_info[:port]
              entry << 'ansible_user=' + m.ssh_info[:username]

              if m.ssh_info[:private_key_path].any?
                entry << 'ansible_ssh_private_key_file=' + m.ssh_info[:private_key_path][0].gsub(ENV['HOME'], '~')
              else
                entry << 'ansible_password=' + m.ssh_info[:password]
              end

              inventory_content << entry.join(' ')
            else
              @logger.error(%(Auto-generated inventory: Impossible to get SSH information for the "#{m.name} (#{m.provider_name})" machine. This machine should be recreated.))
              # Leave a note about the missing machine.
              inventory_content << %(# MISSING: "#{m.name}" machine was probably removed without using Vagrant.)
            end
          rescue Vagrant::Errors::MachineNotFound
            @logger.info(%(Auto-generated inventory: Skip the "#{active_machine[0]} (#{active_machine[1]})" machine, which is not configured for this Vagrant environment.))
          end
        end

        write_cache(inventory_file, inventory_content.join("\n"))

        inventory_file
      end

      # @param env_var [String]
      #   Name of environment variable to parse. Format: "--param1=option --param2=value2".
      #
      # @return [Hash]
      #   List of parsed options and assigned values.
      def parse_env_vars(env_var)
        vars = {}

        ENV.key?(env_var) && ENV[env_var].scan(/--?([^=\s]+)(?:=(\S+))?/).each do |pair|
          key, value = pair

          next if value.nil?

          # Trim quotes if string starts and ends by the same character.
          value = value[1...-1] if value[0] == value[-1] && %w[' "].include?(value[0])

          vars[key.tr('-', '_')] = value
        end

        vars
      end

      # @param file [String]
      #   Absolute path to file to write to.
      # @param content [String]
      #   Content to store inside the file.
      def write_cache(file, content)
        file = Pathname.new(file)

        unless File.exist?(file)
          dir = File.dirname(file)

          FileUtils.mkdir_p(dir) unless File.directory?(dir)
        end

        Mutex.new.synchronize do
          file.open('w') do |descriptor|
            descriptor.write(content)
          end
        end
      end
    end
  end
end
