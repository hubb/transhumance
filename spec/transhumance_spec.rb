# encoding: UTF-8

require 'spec_helper'

describe Transhumance do

  context '(new)' do
    let(:mock_context) { double("ActiveRecord::Migration").as_null_object }

    it 'raises an error if no context given' do
      expect { described_class.new(:source => 'a') }.to raise_error(ArgumentError)
    end

    it 'raises an error if no source given' do
      expect { described_class.new(:context => mock_context) }.to raise_error(ArgumentError)
    end

    it 'works with a context and a source' do
      expect { described_class.new(:context => mock_context, :source => 'a') }.to_not raise_error
    end
  end


  context '(integration)' do

    # This would be your classical Rails migration,
    # unless it's using the MigrationService
    class TranshumanceTest < ActiveRecord::Migration
      def self.up
        Transhumance.new(:context    => self,
                         :source     => "sheeps",
                         :chunk_size => 5).
          with_schema_changes do |target_table|
            remove_column target_table, :notes
          end.run
      end

      def self.down
        drop_table :sheeps_new
      end
    end

    subject  { TranshumanceTest }
    let(:db) { subject.connection }

    it 'has copied all data from source to destination and applied schema changes' do
      org_count = 0

      org_count = db.select_value("SELECT COUNT(id) FROM sheeps")
      subject.up

      db.select_value("SELECT COUNT(id) FROM sheeps_new").should == org_count
    end

  end
end

