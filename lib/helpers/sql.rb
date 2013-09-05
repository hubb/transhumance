class Transhumance
  module Helpers
    module SQL

      def sanitize(*args)
        ActiveRecord::Base.send(:sanitize_sql_array, *args).gsub(/\s+/, ' ')
      end

      # Create the destination table
      def create_target_table(context, &block)
        with_logging(:debug, "Creating target table #{target} (from #{source})") do
          context.execute "CREATE TABLE #{target} LIKE #{source}"
          yield if block_given?
        end
      end

      def apply_schema_changes(changes, table)
        with_logging(:debug, "Applying schema changes to #{table}") do
          context.instance_eval { changes.call(table.to_sym) }
        end
      end

      def get_max_id(table = source)
        context.select_value(%Q(
          SELECT MAX(id) FROM #{table}
        )).to_i.tap do |id|
          logger.debug(" ✓ Max ID of #{table}: #{id}")
        end
      end

      # find the id of the next item so (current..next).size == chunk_size
      def get_next_offset(current)
        context.select_value(sanitize([
          %Q{
            SELECT MAX(id)
            FROM (
              SELECT id FROM #{source}
              WHERE id > ?
              ORDER BY id
              LIMIT ?
            ) AS t
          },
          current,
          chunk_size
        ])).tap do |next_offset|
          logger.debug(" ✓ Next offset is: #{next_offset}")
        end
      end

      def migrate_data(options = {})
        start_time    = Time.current
        source_max_id = get_max_id(source)

        if options.fetch(:after, false)
          offset = get_max_id(target)

          while offset < source_max_id
            next_offset = get_next_offset(offset)
            ActiveRecord::Base.transaction do
              do_copy_rows(offset..next_offset)
            end
            offset = next_offset + 1
          end
        else
          offset = 0
          # Copy everything between offset and next_offset
          while offset < source_max_id
            next_offset = get_next_offset(offset)
            ActiveRecord::Base.transaction do
              do_copy_rows(offset..next_offset)
            end
            offset = next_offset + 1
          end
        end

        # returns time elapsed
        Time.current.to_i - start_time.to_i
      end

      def do_copy_rows(offset_range)
        # get columns on newly created table
        columns = context.connection.columns(target).map {|c| "`#{c.name}`"}.join(', ')

        with_logging(:debug, "Copy rows #{offset_range.first} to #{offset_range.last} to #{target}") do
          context.insert(sanitize([
            %Q{
              INSERT INTO #{target} (#{columns})
              SELECT #{columns}
              FROM #{source}
              WHERE id BETWEEN ? AND ?
            }, offset_range.first, offset_range.last
          ]))
        end
      end
    end
  end
end
