#
# $Id: 20090211-decouple_preludi.rb 327 2009-03-09 21:34:37Z nicb $
#
#

def descend_tree(root, &block)
  root.children.each do
    |c|
    descend_tree(c, &block)
  end
  yield(root)
end

def build_conditions
  start_conds =
  [
    { :like => '% prelud', :not_like => [ 'Piccolo prelud' ] },
  ]
  output_pars = {}
  cond = []
  par_n = 0
  start_conds.each do
    |c|
    par = 'par_' + par_n.to_s
    par_n += 1
    temp_cond = []
    temp_cond << "name like :#{par}"
    output_pars[par.intern] = c[:like] + '%'
    if c.has_key?(:not_like)
      c[:not_like].each do
        |cnl|
        par = 'par_' + par_n.to_s
        par_n += 1
        temp_cond << "name not like :#{par}"
        output_pars[par.intern] = cnl + '%'
      end
    end
    cond << '(' + temp_cond.join(' and ') + ')'
  end
  output_cond = cond.join(' or ')
  return [output_cond, output_pars]
end


u = User.authenticate('bootstrap', '__fishrdb_bootstrap__')
pGS = Folder.find_by_name('Partiture Giacinto Scelsi')
found = []

descend_tree(pGS) do
  |d|
  (conds, pars) = build_conditions
  d.children.find(:all, :conditions => [conds, pars]).each { |x| found << x.raw_name }
end

found.uniq!.size
found.each do
  |n|
  i = n.index(/(\s+|')/)
  pfx = n[0..i]
  name = n[i+1..n.size-1]
  puts("split: prefisso: \"#{pfx}\" nome \"#{name}\"")
  docs = Document.find(:all, :conditions => ["name = ?", n])
  docs.each do
    |d|
    d.user_update_attribute(u, :name_prefix, pfx)
    d.user_update_attribute(u, :name, name)
    d.save
  end
end
