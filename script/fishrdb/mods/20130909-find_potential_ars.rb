#
# $Id: 20130909-find_potential_ars.rb 637 2013-09-10 12:56:40Z nicb $
#
require 'lib/debugger'
require 'config/environment'

module ExcludeDictionary

  EXCLUDED_WORDS =
  %w(
    Castello Contiene Il La Le Lo Sembra Traccia Direttore Partitura
    Copia Annotazioni Dedica DataRegistrazione LuogoRegistrazione Op
    Registrazione SPOGLIO I II III IV V VI VII VIII IX X XI XII XIII XIV XV
    Letture Live Pezzi Direzione Presenti Lettera Comunicazioni
    Ensemble Mittenti Corrispondenza Pubblicati Suddiviso Opera
    Opere Interpreti Aus Klavier Flöte Gitarre Schlaginstrument
    Bassblockflöte Saxophon Kontrabass Posaune CD DVD VHS Commissionato
    Studio Riproduzioni Anteprima Assistenza Con Prima Partecipano
    Uno Due Tre Quattro Cinque Sei Sette Otto Nove Lingua Lingue
		Un Deux Trois Quatre Cinq Six Sept Huit Neuf Dix
		One Two Three Four Five Six Seven Eight Nine Zero
    Documentazione Francese Inglese Olandese Tedesco Italiano
    Produzione Associazione Organizzazione Testi Traduzioni
    Orchestra Coro Quasi Agitato Molto Vivace Andante Drammatico Violento
		Pesante Moderato Deciso Dolcissimo Sostenuto Allegro Lento
		Allegretto Blues Perpetuum Sonatine Menuetto Marcia Rondo
		Romanze Andante Sonate Sonata Trio Danse Opus
		Un Giovedì Audiovisivi Mancano Registrato Note
		Primo Secondo Terzo Quarto Direzione Parti Arr Esecuzione
		Invito Proposta Durata Busta Cartolina Cartoline Pubblicato
		Assemblea Statuto
  )

  class << self

      def contains?(s)
        EXCLUDED_WORDS.include?(s)
      end

  end

end

class ArReference

  attr_reader :ar, :document, :already_there

  def initialize(a, d, at)
    @ar = a
    @document = d
    @already_there = at
  end

  def is_already_there?
    self.already_there
  end

end

class Token

  attr_reader :token, :references

  def initialize(t, doc)
    @token = t
    @references = initialize_references(doc)
  end

  def print
    self.references.each do
      |key, refs|
      refs.each do
        |r|
        existing = r.is_already_there? ? "(Già connesso)" : "(Non connesso)"
        puts("      af_#{r.ar.id}: #{r.ar.display} #{existing}")
      end
    end
  end

private

  def initialize_references(doc)
    pns = PersonName.all(:conditions => ['first_name = ? or name = ?', self.token, self.token])
    sns = SiteName.all(:conditions => ['name = ?', self.token])
    sts = ScoreTitle.all(:conditions => ['name = ?', self.token])
    cns = CollectiveName.all(:conditions => ['name = ?', self.token])
    pnst = []
    snst = []
    stst = []
    cnst = []

    pns.each do
      |pn| 
      at = doc.person_names(true).include?(pn)
      pnst << ArReference.new(pn, doc, at)
    end

    sns.each do
      |sn| 
      at = doc.site_names(true).include?(sn)
      snst << ArReference.new(sn, doc, at)
    end

    sts.each do
      |st| 
      at = doc.collective_names(true).include?(st)
      stst << ArReference.new(st, doc, at)
    end

    cns.each do
      |cn| 
      at = doc.collective_names(true).include?(cn)
      cnst << ArReference.new(cn, doc, at)
    end

    res = { :person_names => pnst, :site_names => snst, :score_titles => stst, :collective_names => cnst }
    res
  end

end

class Desc

  attr_reader :document, :tokens

  def initialize(d)
    @document = d
    @tokens = initialize_tokens
  end

  def print
    unless self.tokens.empty?
      puts("documento_#{self.document.id}:\n  id: #{self.document.id}\n  titolo: #{self.document.name}")
      self.tokens.each_with_index do
        |t, idx|
        puts("    tag_#{"%03d" % idx}: #{t.token}")
        t.print
      end
    end
  end

private

  def initialize_tokens
    res = []
    toks = tokenize
    toks.each { |t| res << Token.new(t, self.document) unless ExcludeDictionary.contains?(t) }
    res
  end

  def tokenize
    desc = self.document.description ? self.document.description : ''
    note = self.document.note ? self.document.note : ''
    str = (desc + ' ' + note).strip
    #
    # try picking up full names first
    #
    names = str.scan(/(([A-Z]\w+\s+)+[A-Z]\w+|[A-Z]\w+\s+[A-Z]\w+)/).map { |a| a.first }
    #
    # now pick single strings
    #
    singles = str.scan(/[A-Z]\w+/)
    #
    # and match them against full names to reap what's already there
    #
    reaped = singles.map { |s| s unless names.join(' ').match(/#{s}/) }.compact
    names + reaped
  end

end

cnt = Document.count
step = 100
cur = 0

while cur < cnt
  #
  # we avoid the tapes because they are another cup of tea
  #
  batch = Document.all(:select => 'id,name,description,note,corda', :offset => cur, :limit => step, :conditions => ['(name NOT LIKE ?) AND ((description IS NOT NULL AND description != ?) OR (note IS NOT NULL AND note != ?))', 'NMGS%', '', ''], :order => 'corda')
  batch.each do
    |doc|
    d = Desc.new(doc)
    d.print
  end
  cur += step
end
