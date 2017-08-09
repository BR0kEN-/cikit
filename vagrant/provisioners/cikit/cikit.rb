module VagrantPlugins
  module CIKit
    class Plugin < Vagrant.plugin("2")
      name "cikit"

      config :cikit, :provisioner do
        require_relative "config"
        Config
      end

      provisioner :cikit do
        require_relative "provisioner"
        Provisioner
      end
    end
  end
end
