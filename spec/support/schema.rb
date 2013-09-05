require 'benchmark'

ActiveRecord::Schema.define(:version => 1) do
	self.verbose = false

  create_table :sheeps, :force => true do |t|
    t.integer   :age
    t.decimal   :weight
    t.string    :sheepfold, :limit => 255
    t.text      :notes
    t.timestamps
  end

end
