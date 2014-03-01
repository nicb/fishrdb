#
# $Id: 20090201-print_GS_score_tree.rb 327 2009-03-09 21:34:37Z nicb $
#

INDENT_VALUE="2em"

def truncate(s, val)
  result = s
  if s.size > val
    result = s[0..val-3] + '...'
  end
  return result
end

def print_header(tfh)
  tfh.puts <<-EOF
    \\documentclass[9pt]{scrartcl}
    \\usepackage[utf8]{inputenc}
    \\usepackage[T1]{fontenc}
    \\usepackage[italian]{babel}
    \\usepackage[top=2cm,left=1cm,right=1cm,bottom=2cm]{geometry}
    \\usepackage{textcomp}
    \\usepackage{svninfo}
    \\begin{document}
    \\svnInfo $Id: 20090201-print_GS_score_tree.rb 327 2009-03-09 21:34:37Z nicb $
    \\setlength{\\parindent}{0pt}
  EOF
end

def print_trailer(tfh)
  tfh.puts("\\end{document}")
end

def indent(tfh)
  tfh.puts("\\addtolength{\\parindent}{#{INDENT_VALUE}}")
end

def deindent(tfh)
  tfh.puts("\\addtolength{\\parindent}{-#{INDENT_VALUE}}")
end

def name_to_be_printed(doc)
  result = doc.full_name
  if doc.full_name == doc.parent.full_name
    result = "#{doc.forma_documento_score}"
    unless doc.is_a_part?
      result += ", #{doc.tipologia_documento_score}"
    end
  end
  if result == 'Partiture Giacinto Scelsi'
    svn_version = `svnversion`.chomp
    result += " (v.#{svn_version} -- #{DateTime.now.to_s})"
  else
    result = truncate(result.gsub(/#/, '\#'), 60)
  end
  return result
end

def print_children(tfh, doc)

  if (doc.description_level == DescriptionLevel.fascicolo)
    tfh.puts("\\vspace{0.1em}\n\\hrulefill\n\\par")
  end

  cond_name = name_to_be_printed(doc)
  tc = (doc.class == Score && doc.is_a_part?) ? "{\\small (#{doc.forma_documento_score})}" : ''
  tfh.puts("{\\bfseries #{cond_name}} #{tc}\\par")
  unless doc.no_children?
    indent(tfh)
    doc.children.each do
      |c|
      print_children(tfh, c)
    end
    deindent(tfh)
  end
end

texw = File.open('tmp/GS_score_tree.tex', 'w')
pGS = Folder.find_by_name('Partiture Giacinto Scelsi')

print_header(texw)
indent(texw)
print_children(texw, pGS)
deindent(texw)
print_trailer(texw)

texw.close
