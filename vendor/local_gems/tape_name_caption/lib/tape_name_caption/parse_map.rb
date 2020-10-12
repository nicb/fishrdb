# encoding: utf-8
#
# $Id: parse_map.rb 552 2010-09-12 10:50:29Z nicb $
#

module TapeNameCaption

  module Parse

    module Map

	    REGEXP_MAP =
	    {
	      :name       =>  { :regexp => /(Riv|[AB][0-9]+|Conv|V[Ss]peed|TimeShift)/, :map => { /Riv/ => 'Riv. completo', /([AB][0-9]+)/ => 'Frammento \1', /Conv/ => 'Traccia con conversione', /V[Ss]peed/ => 'Traccia con cambio di Velocità', /TimeShift/ => 'Traccia con cambio di Tempo' } },
	      :speed      =>  { :regexp => /(4,75|9,5|19|38|76|152|NA)/, :map => { /(4,75|9,5|19|38|76|152)/ => 'Vel. Nastro: \1 cm/sec', /NA/ => 'Vel. nastro: info non disp.' } },
	      :direction  =>  { :regexp => /(STGT|RVRS|PiSh|TiSh|TSFN)/, :map => { /STGT/ => 'Scorr.: diritto', /RVRS/ => 'Scorr: rovesciato', /PiSh/ => 'Var. di altezza', /TiSh/ => 'Var. di Tempo', /TSFN/ => 'Trasformato' } },
	      :number     =>  { :regexp => /([0-9]+|NA)/, :map => { /([0-9]+)/ => '\1', /NA/ => '' } },
	      :channel    =>  { :regexp => /([LR]|[0-9]+|NA)/, :map => { /L/ => 'Canale: sinistro', /R/ => 'Canale: destro', /([0-9]+)/ => 'Canale: \1', /NA/ => 'Canale: info non disp.' } },
        :bitrate    =>  { :regexp => /(56|128)/, :map => { /(56|128)/ => 'bitrate: \1' } },
	      :format     =>  { :regexp => /^mp3$/, :map => { /^mp3$/ => 'formato: MPEG1/Layer3' } },
	    }

    end

  end

end
