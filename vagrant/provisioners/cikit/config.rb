module VagrantPlugins::CIKit
  class Config < Vagrant.plugin("2", :config)
    attr_accessor :playbook
    attr_accessor :controller

    def validate(machine)
      errors = _detected_errors

      unless controller
        errors << ":cikit provisioner requires :controller to be set."
      end

      {"CIKit Provisioner" => errors}
    end
  end
end
