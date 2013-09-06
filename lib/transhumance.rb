# encoding: UTF-8

# Assumptions:
# - there is an :id and :updated_at column
# - new records have incrementing IDs
# - THERE IS AN INDEX ON updated_at (STOP HERE IF YOU DON'T)
#
require 'logger'

require 'helpers/sql'
require 'helpers/logging'

class Transhumance

  include Helpers::SQL
  include Helpers::Logging

  attr_reader :context, :source, :target, :chunk_size, :logger

  def initialize(options = {})
    @context    = options.fetch(:context) { raise ArgumentError.new("Missing context") }
    @source     = options.fetch(:source)  { raise ArgumentError.new("Missing source") }

    @target     = options.fetch(:target)     { "#{@source}_new" }
    @chunk_size = options.fetch(:chunk_size) { 5_000 }
    @logger     = options.fetch(:logger)     { Logger.new(STDOUT) }

    if options.fetch(:debug, false)
      @logger.level = Logger::DEBUG
    end
  end

  # Pass it the schema changes you want on the final table
  def with_schema_changes(&block)
    self.tap { @schema_changes = block }
  end

  def run
    # Start
    puts "\n"
    logger.info("Transhumance started at #{Time.current.to_s(:db)}")

    # Setup destination table with schema changes
    create_target_table(context) do
      apply_schema_changes(@schema_changes, target) if @schema_changes
    end

    ## Migrate data to the new table

    # - 1st pass: copy everything existing as of now
    first_pass_start = Time.current
    with_logging(:debug, "Migration 1st pass") do
      migrate_data
    end
    first_pass_end = Time.current

    # - 2nd pass: copy everything added/updated while 1st pass was running
    second_pass_start = Time.current
    with_logging(:debug, "Migration 2nd pass") do
      migrate_data(:after => first_pass_start)
    end
    second_pass_end = Time.current

    # - 3rd pass: with a transaction lock on both tables
    #   copy the very last records (should be smaller than 10 entries)
    #   and swap the tables
    with_logging(:debug, "Migration 3rd pass") do
      migrate_data(:after => second_pass_start)
    end

    # End
    logger.info("Transhumance completed at #{Time.current.to_s(:db)}")
  end

end
