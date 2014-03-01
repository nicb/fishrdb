#
# $Id: roman_numeral.rb 296 2009-01-23 05:31:25Z nicb $
#
# Cannibalized from:
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/187530
#

class Integer

  class RomanNumeralOutOfRange < Exception
  end

	def to_roman
	  
	  if self < 1 || self > 3999
	    raise RomanNumeralOutOfRange, 'Cannot handle numbers outside of range 1-3999'
	  end
	
	  input = self
	  
	  m_mod = input%1000  
	  d_mod = input%500
	  c_mod = input%100
	  l_mod = input%50
	  x_mod = input%10
	  v_mod = input%5
	  
	  m_div = input/1000
	  d_div = m_mod/500
	  c_div = d_mod/100
	  l_div = c_mod/50
	  x_div = l_mod/10
	  v_div = x_mod/5
	  i_div = v_mod/1
	
	  m = 'M' * m_div
	  d = 'D' * d_div
	  c = 'C' * c_div
	  l = 'L' * l_div
	  x = 'X' * x_div
	  v = 'V' * v_div
	  i = 'I' * i_div
	
	  if i == 'IIII' && v != 'V'
	    i = 'IV'
	  elsif i == 'IIII'
	    v = 'IX'
	    i = ''
	  end
	 
	  if x == 'XXXX' && l != 'L'
	    x = 'XL'
	  elsif x == 'XXXX'
	    l = 'XC'
	    x = ''
	  end
	  
	  if c == 'CCCC' && d != 'D'
	    c = 'CD'
	  elsif c == 'CCCC'
	    d = 'CM'
	    c = ''
	  end
	
	  return m + d + c + l + x + v + i  
	  
	end

end
