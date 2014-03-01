#
# $Id: 20080512-ard_dup_remover.rb 327 2009-03-09 21:34:37Z nicb $
#
# To be fed to the console
#

$stderr.puts("Cerco...")
ards = ArdReference.find(:all)

ards.each do
  |ard|
  dups = ArdReference.find(:all, :conditions => ["authority_record_id = ? and document_id = ?",
                           ard.authority_record_id, ard.document_id])
    if dups.size > 1
      $stderr.puts("DUPLICATE FOUND! #{dups.inspect}")
    end
end
