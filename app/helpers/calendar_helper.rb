#
# $Id$
#

module CalendarHelper
  
  #
  # cannibalized from tracks-1.5
  # 
  def calendar_setup( input_field )
    str = "Calendar.setup({ ifFormat:\"%d-%m-%Y\""
    str << ",firstDay:1,showOthers:true,range:[1700, 2999]"
    str << ",step:10,inputField:\"" + input_field + "\",cache:true,align:\"TR\" })\n"
    javascript_tag str
  end

end
