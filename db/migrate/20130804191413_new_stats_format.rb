class NewStatsFormat < ActiveRecord::Migration
  def self.up
    # can’t use add_column, because for some reason the columns are not
    # directly available
    execute(%|ALTER TABLE stats ADD COLUMN "skipped" boolean DEFAULT 'f'|)
    execute(%|ALTER TABLE stats ADD COLUMN "selected_answers" varchar(255)|)

    # don’t print the update statement for each stat
    ActiveRecord::Base.logger.quietly do
      Stat.unscoped.all.each do |s|
        skipped, selansw = nil, nil
        if s.answer_id == -1
          selansw = "--- []\n"
          skipped = 't'
        else
          skipped = 'f'
          selansw = "---\n- #{s.answer_id}\n"
        end

        execute "UPDATE stats SET skipped = '#{skipped}', selected_answers = '#{selansw}' WHERE id = #{s.id} LIMIT 1"
      end
    end

    remove_column :stats, :answer_id
  end

  def self.down
    add_column :stats, :answer_id, :string

    Stat.unscoped.all.each do |s|
      # this will lose information
      if s.skipped?
        s.answer_id = -1
      else
        s.answer_id = s.selected_answers[0]
      end
      s.save(:validate => false)
    end

    remove_column :stats, :selected_answers
    remove_column :stats, :skipped
  end
end
