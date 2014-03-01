#
# $Id: date_helper.rb 270 2008-11-09 12:06:14Z nicb $
#
# 

module DateHelper

	#
	# build some helpers that make the ajaxed select date functions easier to write
	#

	def all_days
		result = [ '' ]
		(1..31).map { |i| result << i }
		return result
	end

	def all_months(ms = {})

		result = [[ '', 0 ]]
		mnames = %w(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic)
		monthnames = ms.empty? ? mnames : ms
		(0..11).map { |i| result << [ monthnames[i], i ] }

		return result

	end

	def all_years(ystart=1900, yend=Date.today.year+20)
		result = ['']
		(ystart..yend).map { |i| result << i }
		return result
	end

	#
	# AJAX-ed selects
	#

	def select_day_w_jcache(tag, subtag, jvar, select_options = {})
		select(tag, subtag, all_days, select_options,
				{
					:onchange => "if (#{jvar} == null) #{jvar} = new Date(); #{jvar}.setDate(this[this.selectedIndex].value)",
				})
	end

	def select_month_w_jcache(tag, subtag, jvar, select_options = {})
		select(tag, subtag, all_months, select_options,
				{
					:onchange => "if (#{jvar} == null) #{jvar} = new Date(); #{jvar}.setMonth(this[this.selectedIndex].value)",
				})
	end

	def select_year_w_jcache(tag, subtag, jvar, select_options = {})
		select(tag, subtag, all_years, select_options,
				{
					:onchange => "if (#{jvar} == null) #{jvar} = new Date(); #{jvar}.setYear(this[this.selectedIndex].value)",
				})
	end

  #
  # year range string helper
  #

  def year_range_string(date_start = nil, date_end = nil)
    result = ''
    if date_start || date_end
      ds = date_start ? date_start.year.to_s : ''
      de = date_end ? date_end.year.to_s : ''
      result = sprintf("(%s-%s)", ds, de)
    end
    return result
  end

  #
  # methods used by date views
  #


end
