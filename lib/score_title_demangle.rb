#
# $Id: score_title_demangle.rb 165 2008-02-10 05:59:44Z nicb $
#
# This module is needed to demangle the Title part in the scores that have parts
#
top_prefix = File.dirname(__FILE__) + '/..'
$:.unshift top_prefix + '/app/models/'
$:.unshift top_prefix + '/app/helpers/'
$:.unshift top_prefix + '/vendor/rails/activerecord/lib/'
require 'connection_lib'
require 'display/model/display_item'
require 'document'
require 'score'

include ConnectionLib

require 'yaml'

module ScoreTitleDemangle

  def self.calculate_new_name(s, c)
    return s.name
  end

  def self.children_in_need_of_processing(s)
    return Score.find(:all,
              :conditions => ["parent_id = ? and name regexp ?", s.id, "^#{s.name}\. .*$"])
  end

  def self.find_scores_with_parts
    return Score.find(:all, :conditions => ["children_count > 0"])
  end

  def self.create_yaml_filename_prefix(env)
      return (File.basename(__FILE__, '.rb') + "_#{env[0..2]}_" + 'output_')
  end

  def self.last_yaml_filename_index(env, output_path='.')
    pfx = create_yaml_filename_prefix(env)
    entries = Dir.entries(File.dirname(output_path))
    found = entries.sort.find_all { |e| e =~ /^#{pfx}/ }
    num = 0
    unless found.empty? # the last one is the right one
      num = found[-1].sub(/^#{pfx}/,'').to_i 
    end
    return num
  end

  def self.yaml_filename(env, idx)
    return create_yaml_filename_prefix(env) + sprintf("%03d", idx) + '.yml'
  end

  def self.create_yaml_filename(env, output_path='.')
    num = last_yaml_filename_index(env, output_path)
    return yaml_filename(env, num + 1)
  end

  def self.last_yaml_filename(env, output_path='.')
    num = last_yaml_filename_index(env, output_path)
    return yaml_filename(env, num)
  end

  def self.yaml_file_header(yaml_filename, arg0)
    yaml_file = File.open(yaml_filename, 'w')
    yaml_file.puts("#\n# WARNING: this file was created automagically by the #{arg0} library:\n# DO NOT EDIT! Unless you know what you are doing...\n#")
    return yaml_file
  end

  def self.analyze(env)
    yaml_file_name = nil
    scores = find_scores_with_parts
    yaml_output = {}
  
    n = 0
    scores.map do
      |s| 
      childs = children_in_need_of_processing(s)
      unless childs.empty?
        puts("Partitura: #{s.name}")
        childs.map do
          |c|
          new_name = calculate_new_name(s, c)
          printf("    %-60s >> %s\n", c.name, new_name)
          tag = sprintf("p%06d", n)
          yaml_output[tag] = { 'id' => c.id, 'from' => c.name, 'to' => new_name }
          n += 1
        end
      end
    end

    unless yaml_output.empty?
      yaml_file_name = create_yaml_filename(env)
      yaml_file = yaml_file_header(yaml_file_name, File.basename(__FILE__))
      YAML.dump(yaml_output, yaml_file)
      yaml_file.close
      File.chmod(0444, yaml_file_name)
    end 

    return yaml_file_name
  end

  def self.change_score_titles(yfn, &block)
    yfile = File.open(yfn, 'r')
    changes = YAML.load(yfile)
    if changes
      ActiveRecord::Base.transaction do
  	    changes.each do
  	      |k, v|
  	      s = Score.find(v['id'].to_i)
            yield(s, v)
  	    end
      end
      yfile.close
    else
      $stderr.puts("YAML change file empty! Removing it...")
      yfile.close
      File.delete(yfn)
    end
  end

  def self.demangle_score_titles(env)
    yfn = analyze(env)
    change_score_titles(yfn) { |s, v| s.update_attribute('name', v['to']) } if yfn
  end

  def self.restore_score_titles(env)
    yfn = last_yaml_filename(env)
    change_score_titles(yfn) { |s, v| s.update_attribute('name', v['from']) } 
  end

  def self.setup(&block)
	env = ENV['RAILS_ENV'] ? ENV['RAILS_ENV'] : 'development'
	Score.open_db(env)
    yield(env)
	Score.close_db
  end

  def self.analyze_only
	setup { |env| analyze(env) }
  end

  def self.up
	setup { |env| demangle_score_titles(env) }
  end

  def self.down
	setup { |env| restore_score_titles(env) }
  end
end
