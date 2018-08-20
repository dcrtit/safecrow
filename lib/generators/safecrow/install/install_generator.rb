require 'rails/generators/base'
require 'rails/generators/active_record'

module Safecrow
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_safecrow_initializer
        copy_file 'safecrow.rb', 'config/initializers/safecrow.rb'
      end
    end
  end
end