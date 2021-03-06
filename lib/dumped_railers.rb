# frozen_string_literal: true

require 'dumped_railers/version'
require 'dumped_railers/file_helper.rb'
require 'dumped_railers/dump'
require 'dumped_railers/import'

module DumpedRailers
  class << self

    def dump!(*models, base_dir: './', preprocessors: nil)
      preprocessors = [Preprocessor::StripIgnorables.new, *preprocessors].compact.uniq

      fixture_handler = Dump.new(*models, preprocessors: preprocessors)
      fixture_handler.build_fixtures!
      fixture_handler.persist_all!(base_dir)
    end

    def import!(*paths)
      # make sure class-baseed caches starts with clean state
      DumpedRailers::RecordBuilder::FixtureRow::RecordStore.clear!
      DumpedRailers::RecordBuilder::DependencyTracker.clear!

      fixture_handler = Import.new(*paths)
      fixture_handler.import_all!
    end

    class Configuration < ::OpenStruct; end

    def config
      @_config ||= Configuration.new
    end

    def configure
      yield config
    end

    # FIXME: make it minimum
    IGNORABLE_COLUMNS = %w[id created_at updated_at]
    def configure_defaults!
      configure do |config|
        config.ignorable_columns = IGNORABLE_COLUMNS
      end
    end
  end

  configure_defaults!
end
