#
# $Id: importer.rb 465 2009-10-15 23:15:54Z nicb $
#

require 'csv_reader'

module CdImporter

  class CdImporterError < StandardError
  end

  class CorruptedCsvRow < CdImporterError
  end

  class InvalidCD < CdImporterError
  end

  class InvalidCDTrack < CdImporterError
  end

  class InvalidName < CdImporterError
  end

  class InvalidPerformerFormat < CdImporterError
  end

  class InvalidEnsembleFormat < CdImporterError
  end

  class InvalidDuration < CdImporterError
  end

  class Importer
    attr_reader :csv, :log_fh, :creation_args, :creators
    attr_accessor :last_cd

    DATA_FILE = BASE_DIR + '/../../doc/blurbs/Catalogo CD.csv'

    def initialize(data_file = DATA_FILE, lfh = $stdout, c_args = {})
      @csv = CsvReader.new(data_file)
      verify_integrity
      @last_cd = nil
      @log_fh = lfh
      @creation_args = c_args
      @creators = { :creator_id => c_args[:creator].id, :last_modifier_id => c_args[:last_modifier].id }
    end

    def import
      parse_errors = []
      parent = creation_args[:parent]
      csv.data.each_with_index do
        |row, rn|
        rownum = sprintf("%03d", rn+1)
        begin
	        next if row.compact.blank?
	        type = row_selector(row, rownum)
	        case type
	        when 'album'
	          @last_cd = create_cd(row, rownum)
	        when 'track'
	          create_tracks(@last_cd, row, rownum)
	        else
	          raise(CorruptedCsvRow, "#{rownum}: Unrecognized row #{row}")
	        end
        rescue CdImporterError
          parse_errors << $!
        end
      end
      parent.reorder_children(:timeasc)
      return parse_errors
    end

  private

    def verify_integrity
      csv.data.each_with_index do
        |row, rownum|
        type = row_selector(row, rownum)
        if type == 'album'
          raise(CorruptedCsvRow, "#{rownum}: Malformed CSV row format for row '#{row}'") unless row[4].to_i.is_a?(Fixnum)
        end
      end
    end

    def row_selector(row, rownum)
      result = nil
      if row[0].blank?
        result = 'track'
      elsif row[1].blank?
        result = 'album'
      end
      raise(CorruptedCsvRow, "#{rownum}: Row '#{row}' is not conforming") unless result
      return result
    end

    def find_or_create(klass, exception, rn, line, args)
      result = klass.find_or_create(args, creators)
      filename = File.basename(__FILE__)
      raise(exception, "#{filename}(#{line}) - #{rn}: #{klass.name}.#{method}(#{args.inspect}) could not be created: #{$!}") unless result
      raise(exception, "#{filename}(#{line}) - #{rn}: #{klass.name}.#{method}(#{args.inspect}) is invalid: #{result.errors.full_messages.join(', ')}") unless result.valid?
      return result
    end

    def create_cd(row, rownum)
      (n, dummy, rl, cn, py, ba, notes) = row
      cdr = nil
      cd_data = CdData.find_by_record_label_and_publishing_year_and_catalog_number(rl, py, cn)
      unless cd_data && cd_data.cd_record && cd_data.cd_record.valid?
        args = { :name => n, :note => notes, :cd_data => { :record_label => rl,
          :catalog_number => cn, :publishing_year => py },
          :corda_alpha => 'CD' + py.to_s }
        c_args = creation_args.dup
        sess = c_args.read_and_delete(:session)
        args.update(c_args)
        log_fh.puts("#{rownum}: CdRecord.create_from_form(:parent => \"#{args[:parent].name}\", :name => #{n}, :record_label => #{rl}, :publishing_year => #{py}, :catalog_number => #{cn}, :booklet_authors => [ #{ba} ], :note => #{notes} )")
        cdr = CdRecord.create_from_form(args, sess)
        raise(InvalidCD, "#{rownum}: CdRecord \"#{n}\" could not be created: #{$!}") unless cdr
        raise(InvalidCD, "#{rownum}: CdRecord \"#{n}\" is invalid: #{cdr.errors.full_messages.join(', ')}") unless cdr.valid?
        b_authors = parse_booklet_authors(ba, n, rownum)
        b_authors.each do
          |ba|
          cdr.cd_data.booklet_authors << ba
          add_person_name_authority_record(cdr, ba)
        end
      end
      return cdr
    end

    def create_tracks(parent, row, rownum)
      (dummy, a, t, o, p, d, notes) = row
      durations = parse_durations(d, row, rownum)
      args = { :authors => a, :name => t, :players => p, :note => notes }
      if durations.size == 1
        args.update(:cd_track => { :for => o, :duration => durations[0] })
        track = create_track(parent, args, row, rownum)
      else
	      durations.each_with_index do
	        |dur, n|
          margs = args.dup
          margs.update(:cd_track => { :for => o, :ordinal => n+1, :duration => dur })
	        track = create_track(parent, margs, row, rownum)
	      end
      end
    end

    def create_track(parent, args, ref, rn)
      raise(InvalidCD, "#{rn}: Attempt to save track to a nil CD! (context: \"ref\")") unless parent && parent.valid?
      authors_string = args.read_and_delete(:authors)
      players_string = args.read_and_delete(:players)
      ord = args[:cd_track][:ordinal]
      ords = sprintf("%02d", ord ? ord : 0)
      rownum = rn + '+' + ords
      log_fh.puts("#{rn}:\tCdTrack.find_or_create(\"#{}\") -> { :author => [ #{authors_string} ], :name => #{args[:name]}, :ordinal => #{args[:ordinal]}, :for => #{args[:for]}, :performers => [ #{players_string} ], :duration => #{args[:duration].inspect}, :note => #{args[:note]} }")
      cdtr = CdTrackRecord.find_by_parent_id_and_name_and_note(parent.id, args[:name], args[:note])
      cdt = CdTrack.find_by_cd_track_record_id_and_ordinal(cdtr.id, ord) if cdtr
      unless cdtr && cdt
        c_args = creation_args.dup
        sess = c_args.read_and_delete(:session)
        args.update(c_args)
        args.delete(:parent); args.delete(:parent_id)
        args.update(:parent => parent)
        log_fh.puts("#{rownum}: CdTrackRecord.create_from_form(:parent => \"#{args[:parent].name}\", :name => #{args[:name]}, :note => #{args[:note]} )")
        cdtr = CdTrackRecord.create_from_form(args, sess)
      end
      add_score_title_authority_record(cdtr, cdtr.name)
      unless authors_string.blank?
        authors = parse_authors(authors_string, ref, rn) 
        authors.each do
          |a|
          begin
            cdtr.authors << a
            add_person_name_authority_record(cdtr, a)
          rescue ActiveRecord::RecordInvalid
            raise(InvalidName, "#{rn}: CdTrack.authors << \"#{a.inspect}\" failed: (#{a.errors.full_messages.join(', ')})")
          end
        end
      end
      unless players_string.blank?
        players = parse_track_participants(cdtr, players_string, ref, rn)
        players.each do
          |p|
          begin
            if p.is_a?(Ensemble) # it's an ensemble
              cdtr.ensembles << p
              add_institution_authority_record(cdtr, p)
              add_person_name_authority_record(cdtr, p.conductor) if p.conductor && p.conductor.valid?
            elsif p.is_a?(Performer) # it's a performer
              cdtr.performers << p
              add_person_name_authority_record(cdtr, p.name)
            elsif p.is_a?(Array) # it's one or more performers
              p.each do
                |perfs|
                cdtr.performers << perfs
                add_person_name_authority_record(cdtr, perfs.name)
              end
            else
              raise(InvalidName, "#{rn}: CdTrack.?.create(\"#{p.inspect}\") failed")
            end
          rescue ActiveRecord::RecordInvalid
            raise(InvalidName, "#{rn}: CdTrack.performers << \"#{p.inspect}\" failed: (#{p.errors.full_messages.join(', ')})")
          end
        end
      end
      return cdtr
    end

    def parse_durations(d, ref, rn)
      result = []
      durs = d.split(/\s+'?/)
      raise(InvalidCdTrack, "#{refnum}: CdTrack with invalid durations \"#{d}\" (context: \"#{ref.inspect}\"") if durs.blank?
      durs.each_with_index do
        |dur, ord|
        ordn = sprintf("%02d", ord ? ord : 0)
        refnum = "#{rn}+#{ordn}"
        result << parse_duration(dur, ref, refnum)
      end
      return result
    end

    def parse_duration(d, ref, rn)
      result = nil
      parts = d.count(':')
      raise(InvalidDuration, "#{rn}: Duration #{d} invalid for CdTrack #{ref.inspect}") unless parts == 2
      (hours, mins, secs) = d.split(':')
#     (h, m, s) = [ hours.to_i, mins.to_i, secs.to_i ]
#     begin
        result = { :hour => hours, :minute => mins, :second => secs }
#     rescue
#       raise(InvalidDuration, "#{rn}: Duration #{d} invalid (error: #{$!}) for CdTrack #{ref.inspect}") unless parts == 3
#     end
      return result
    end

    def parse_booklet_authors(ba, ref, rn)
      result = []
      return "" unless ba
      ba_array = ba.split(', ')
      ba_array.each do
        |n|
        result << parse_name_or_names(n, ref, rn)
      end
      return result.flatten
    end

    def parse_name_or_names(n, ref, rn)
      result = []
      names = n.split(/\s+e\s+/)
      names.each do
        |n|
        components = n.split(' ')
        raise(InvalidName, "#{rn}: Name \"#{n}\" with less than two components (context: \"#{ref.inspect}\")") if components.size < 2
        ln = components[components.size-1]
        fn = components[0..components.size-2].join(' ')
        if block_given?
          result << yield(ln, fn)
        else
          result << find_or_create(Name, InvalidName, rn, __LINE__, { :last_name =>  ln, :first_name => fn })
        end
      end
      return result
    end

    def parse_track_participants(cd_track, pg, ref, rn)
      result = []
      return result unless pg && !pg.blank?
      perfs = pg.split(/\s*;\s*/)
      raise(InvalidPerformerFormat, "#{rn}: Performer \"#{pg}\" is not conforming on composition \"#{ref.inspect}\"") unless perfs.size > 0
      perfs.each do
        |p|
        commas = p.count(',')
        if p =~ /[,]?\s*[Dd]irettore/ || commas == 0  # it's an ensemble
          result << parse_ensemble(cd_track, p, ref, rn)
        else # it's a single performer
          result << parse_performer_or_performers(cd_track, p, ref, rn)
        end
      end
      return result
    end

    def parse_performer_or_performers(track, perf, ref, rn)
      result = []
      (name, instrument) = perf.split(/,\s*/)
      all_names = parse_name_or_names(name, ref, rn) { |ln, fn| [ ln, fn ] }
      all_names.each do
        |n_comps|
        h = {}
        h[:name_id] = find_or_create(Name, InvalidPerformerFormat, rn, __LINE__, { :first_name => n_comps[1], :last_name => n_comps[0] }).id
        h[:instrument_id] = find_or_create(Instrument, InvalidPerformerFormat, rn, __LINE__, { :name => instrument }).id
        p = find_or_create(Performer, InvalidPerformerFormat, rn, __LINE__, h)
        result << p
      end
      return result
    end

    def parse_ensemble(cd_track, ens, ref, rn)
      result = nil
      parts = ens.count(',')
      (den, dirname, dummy) = nil
      dir_string = ""
      case parts
      when 0 then
        den = ens.strip
      when 1 then
        re = Regexp.compile(/\s*[Dd]irettore\s*/)
        rex = Regexp.compile(/^\s*[Dd]irettore\s*$/) 
        (part1, part2) = ens.split(/\s*,\s*/)
        part1.strip!; part2.strip!
        if part1 =~ rex
          dirname = part2
        elsif part2 =~ rex
          dirname = part1
        else
          den = part1
          dirname = part2
        end
        dirname.sub!(re, '')
      when 2 then
        (den, dirname, dummy) = ens.split(/\s*,\s*/)
      else
        raise(InvalidEnsembleFormat, "#{rn}: Ensemble string \"#{ens}\" is not conforming in \"#{ref.inspect}\"")
      end
      result = find_or_create(Ensemble, InvalidEnsembleFormat, rn, __LINE__, { :name => den }) if den
      if dirname
        names = parse_name_or_names(dirname, ens + " (" + [ part1, part2 ].join('|') + ")", rn) { |ln, fn| [ ln, fn ] }
        raise(InvalidEnsembleFormat, "#{rn}: Conductor string \"#{dirname}\" is not conforming in \"#{ref.inspect}\"") if names.size > 1
        dir = find_or_create(Name, InvalidEnsembleFormat, rn, __LINE__, { :first_name => names.first[1], :last_name => names.first[0] })
        if result
          result.conductor = dir
        else # if there's no ensemble, the conductor is treated like a performer
          i = find_or_create(Instrument, InvalidEnsembleFormat, rn, __LINE__, { :name => 'direttore' })
          result = find_or_create(Performer, InvalidEnsembleFormat, rn, __LINE__, { :name_id => dir.id, :instrument_id => i.id })
        end
      end
      return result.blank? ? nil : result
    end

    def parse_authors(as, ref, rn)
      result = []
      raise(InvalidName, "#{rn}: Author format \"#{as}\" is not conforming") unless as && as.is_a?(String) && !as.blank?
      ass = as.split(/\s*,\s*/)
      ass.each do 
        |a|
        names = parse_name_or_names(a, ref, rn)
        names.each do
          |n|
          result << n
        end
      end
      return result
    end

    def add_person_name_authority_record(record, nm)
      add_authority_record(record, { :name => nm.last_name, :first_name => nm.first_name }, PersonName)
    end

    def add_institution_authority_record(record, n)
      add_authority_record(record, { :name => n.name }, CollectiveName)
    end

    def add_score_title_authority_record(record, t)
      add_authority_record(record, { :name => t }, ScoreTitle)
    end

  private

    def add_authority_record(record, args, klass)
      method = 'create_' + klass.name.underscore + '_record'
      ar = record.send(method, creation_args[:last_modifier], args)
      raise(ActiveRecord::ActiveRecordError, "#{klass.name} authority record with args \"#{args.inspect}\" could not be created") unless ar && ar.valid?
    end

  end

end
